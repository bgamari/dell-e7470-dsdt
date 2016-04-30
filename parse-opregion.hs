{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE NamedFieldPuns #-}

import Data.Bifunctor
import Text.Trifecta
import Data.Maybe (catMaybes)
import Data.List (mapAccumL)
import Control.Applicative
import Numeric (showHex)

import Control.Monad (forM_, when)
import Control.Exception (finally)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Internal as BS
import qualified Data.ByteString.Lazy as BSL
import Bindings.Posix.Sys.Mman
import Foreign.Ptr (nullPtr, castPtr, ptrToIntPtr)
import qualified Foreign.Concurrent as FC
import System.Posix
import Data.Binary
import Data.Binary.Get

newtype RegionName = RegionName String
                    deriving (Show, Eq, Ord)

newtype FieldName = FieldName String
                  deriving (Show, Eq, Ord)

newtype Address = Address Integer
                deriving (Eq, Ord, Enum, Num, Integral, Real)

instance Show Address where
    showsPrec _ n = showString "0x" . showHex n

data OpRegion = OpRegion { oprName :: RegionName
                         , oprSpace :: String
                         , oprBase :: Address
                         , oprLength :: Integer
                         }
              deriving (Show)

data Field = Field { fldRegionName :: RegionName
                   , fldAccessType :: String
                   , fldLockRule   :: String
                   , fldUpdateRule :: String
                   , fldFields     :: [FieldBits]
                   }
           deriving (Show)

data FieldBits = Offset Int
               | FieldBits FieldName Int
               deriving (Show)

nameString :: Parser String
nameString = some alphaNum

opRegion :: Parser OpRegion
opRegion = do
    symbol "OperationRegion"
    parens $ do
        oprName   <- RegionName <$> nameString <* comma
        oprSpace  <- nameString <* comma
        oprBase   <- Address <$> natural <* comma
        oprLength <- natural
        return OpRegion {..}

field :: Parser Field
field = do
    symbol "Field"
    f <- parens $ do
        fldRegionName <- RegionName <$> nameString <* comma
        fldAccessType <- nameString <* comma
        fldLockRule   <- nameString <* comma
        fldUpdateRule <- nameString
        let fldFields = []
        return Field {..}

    fldFields <- braces $ sepBy fieldBits comma
    return $ f {fldFields}

fieldBits :: Parser FieldBits
fieldBits = offset <|> field
  where
    offset = Offset . fromIntegral <$> (symbol "Offset" >> parens natural)
    field = FieldBits <$> fmap FieldName nameString <* comma <*> fmap fromIntegral natural

fieldOffsets :: Address -> [FieldBits] -> [(FieldName, Address, Int)]
fieldOffsets off0 = catMaybes . snd . mapAccumL f off0
  where
    f :: Address -> FieldBits -> (Address, Maybe (FieldName, Address, Int))
    f off (Offset bits) = (offset off bits, Nothing)
    f off (FieldBits name bits) = (offset off bits, Just (name, off, bits))
    offset off bits = off + fromIntegral (bits `div` 8)

main :: IO ()
main = do
    str <- getContents
    (opr, fld) <- case parseString (spaces >> (,) <$> opRegion <*> field) mempty str of
        Success r -> return r
        o         -> print o >> fail "uh oh"
    print opr
    --print $ fieldOffsets (oprBase opr) (fldFields fld)


    bs <- unsafeMMapPhys (fromIntegral $ oprBase opr) (fromIntegral $ oprLength opr)
    forM_ (fieldOffsets 0 (fldFields fld)) $ \ (fldName, Address addr, len) -> do
        let getValue :: Get Integer
            getValue | len == 8   = fromIntegral <$> getWord8
                     | len == 16  = fromIntegral <$> getWord16host
                     | len == 32  = fromIntegral <$> getWord32host
                     | len == 64  = fromIntegral <$> getWord64host
                     | otherwise  = fail $ "uh oh: "++show len
        print (fldName, flip showHex "" $ runGet getValue $ BSL.fromStrict $ BS.take (len `div` 8) $ BS.drop (fromIntegral addr) bs)


unsafeMMapPhys :: Address -> Int -> IO BS.ByteString
unsafeMMapPhys (Address addr) len = do
    fd <- openFd "/dev/mem" ReadOnly Nothing defaultFileFlags
    flip finally (closeFd fd) $ do
        let base = addr `div` 4096 * 4096
        ptr <- c'mmap nullPtr (fromIntegral len) c'PROT_READ c'MAP_SHARED (fromIntegral fd) (fromIntegral base)
        when (ptr == c'MAP_FAILED) $ fail "mmap failed"
        fp <- FC.newForeignPtr (castPtr ptr) $ do
            v <- c'munmap ptr (fromIntegral len)
            when (v == -1) $ fail "munmap failed"
        let delta = fromIntegral $ addr - fromIntegral base
        return $ BS.drop delta $ BS.fromForeignPtr fp 0 (len + delta)
