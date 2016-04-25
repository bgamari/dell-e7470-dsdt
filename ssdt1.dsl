/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20160318-64
 * Copyright (c) 2000 - 2016 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of ssdt1.dat, Mon Apr 25 03:18:04 2016
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000046D (1133)
 *     Revision         0x01
 *     Checksum         0x36
 *     OEM ID           "SataRe"
 *     OEM Table ID     "SataTabl"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20120913 (538052883)
 */
DefinitionBlock ("", "SSDT", 1, "SataRe", "SataTabl", 0x00001000)
{
    External (_SB_.PCI0.SAT0, DeviceObj)
    External (DSSP, UnknownObj)
    External (FHPP, UnknownObj)
    External (HFSE, UnknownObj)

    Scope (\)
    {
        Name (STFE, Buffer (0x07)
        {
             0x10, 0x06, 0x00, 0x00, 0x00, 0x00, 0xEF         /* ....... */
        })
        Name (STFD, Buffer (0x07)
        {
             0x90, 0x06, 0x00, 0x00, 0x00, 0x00, 0xEF         /* ....... */
        })
        Name (FZTF, Buffer (0x07)
        {
             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF5         /* ....... */
        })
        Name (DCFL, Buffer (0x07)
        {
             0xC1, 0x00, 0x00, 0x00, 0x00, 0x00, 0xB1         /* ....... */
        })
        Name (STFF, Buffer (0x07)
        {
             0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00         /* ....... */
        })
        Name (SCBF, Buffer (0x1C) {})
        Name (CMDC, Zero)
        Method (GTFB, 2, Serialized)
        {
            Local0 = (CMDC * 0x38)
            CreateField (SCBF, Local0, 0x38, CMDX)
            Local0 = (CMDC * 0x07)
            CreateByteField (SCBF, (Local0 + One), A001)
            CMDX = Arg0
            A001 = Arg1
            CMDC++
        }
    }

    Scope (\_SB.PCI0.SAT0)
    {
        Name (REGF, One)
        Name (TFGF, Zero)
        Method (_REG, 2, NotSerialized)  // _REG: Region Availability
        {
            If ((Arg0 == 0x02))
            {
                REGF = Arg1
            }
        }

        Name (TMD0, Buffer (0x14) {})
        CreateDWordField (TMD0, Zero, PIO0)
        CreateDWordField (TMD0, 0x04, DMA0)
        CreateDWordField (TMD0, 0x08, PIO1)
        CreateDWordField (TMD0, 0x0C, DMA1)
        CreateDWordField (TMD0, 0x10, CHNF)
        Method (_GTM, 0, NotSerialized)  // _GTM: Get Timing Mode
        {
            PIO0 = 0x78
            DMA0 = 0x14
            PIO1 = 0x78
            DMA1 = 0x14
            CHNF |= 0x05
            Return (TMD0) /* \_SB_.PCI0.SAT0.TMD0 */
        }

        Method (_STM, 3, NotSerialized)  // _STM: Set Timing Mode
        {
        }

        Device (SPT0)
        {
            Name (_ADR, 0xFFFF)  // _ADR: Address
            Method (_SDD, 1, NotSerialized)  // _SDD: Set Device Data
            {
                Name (FFS0, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00         /* ....... */
                })
                CreateByteField (FFS0, Zero, FF00)
                CreateByteField (FFS0, 0x06, FF06)
                If ((SizeOf (Arg0) == 0x0200))
                {
                    If ((TFGF == One))
                    {
                        If ((HFSE != Zero))
                        {
                            CreateWordField (Arg0, 0x0134, W154)
                            CreateWordField (Arg0, 0x0138, W156)
                            If (((W154 == 0x1028) & ((W156 & 0x4000) == 0x4000)))
                            {
                                If (((W156 & 0x8000) == Zero))
                                {
                                    FF00 = 0x5A
                                    FF06 = 0xEF
                                }
                            }
                        }
                    }
                }

                STFF = FFS0 /* \_SB_.PCI0.SAT0.SPT0._SDD.FFS0 */
            }

            Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
            {
                CMDC = Zero
                If ((DSSP || FHPP))
                {
                    GTFB (STFD, 0x06)
                }
                Else
                {
                    GTFB (STFE, 0x06)
                }

                GTFB (FZTF, Zero)
                GTFB (DCFL, Zero)
                GTFB (STFF, Zero)
                Return (SCBF) /* \SCBF */
            }
        }

        Device (SPT1)
        {
            Name (_ADR, 0x0001FFFF)  // _ADR: Address
            Method (_SDD, 1, NotSerialized)  // _SDD: Set Device Data
            {
                Name (FFS0, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00         /* ....... */
                })
                CreateByteField (FFS0, Zero, FF00)
                CreateByteField (FFS0, 0x06, FF06)
                If ((SizeOf (Arg0) == 0x0200))
                {
                    If ((TFGF == One))
                    {
                        If ((HFSE != Zero))
                        {
                            CreateWordField (Arg0, 0x0134, W154)
                            CreateWordField (Arg0, 0x0138, W156)
                            If (((W154 == 0x1028) & ((W156 & 0x4000) == 0x4000)))
                            {
                                If (((W156 & 0x8000) == Zero))
                                {
                                    FF00 = 0x5A
                                    FF06 = 0xEF
                                }
                            }
                        }
                    }
                }

                STFF = FFS0 /* \_SB_.PCI0.SAT0.SPT1._SDD.FFS0 */
            }

            Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
            {
                CMDC = Zero
                If ((DSSP || FHPP))
                {
                    GTFB (STFD, 0x06)
                }
                Else
                {
                    GTFB (STFE, 0x06)
                }

                GTFB (FZTF, Zero)
                GTFB (DCFL, Zero)
                GTFB (STFF, Zero)
                Return (SCBF) /* \SCBF */
            }
        }

        Device (SPT3)
        {
            Name (_ADR, 0x0003FFFF)  // _ADR: Address
            Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
            {
                CMDC = Zero
                If ((DSSP || FHPP))
                {
                    GTFB (STFD, 0x06)
                }
                Else
                {
                    GTFB (STFE, 0x06)
                }

                GTFB (FZTF, Zero)
                GTFB (DCFL, Zero)
                Return (SCBF) /* \SCBF */
            }
        }

        Device (SPT4)
        {
            Name (_ADR, 0x0004FFFF)  // _ADR: Address
            Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
            {
                CMDC = Zero
                If ((DSSP || FHPP))
                {
                    GTFB (STFD, 0x06)
                }
                Else
                {
                    GTFB (STFE, 0x06)
                }

                GTFB (FZTF, Zero)
                GTFB (DCFL, Zero)
                Return (SCBF) /* \SCBF */
            }
        }

        Device (SPT5)
        {
            Name (_ADR, 0x0005FFFF)  // _ADR: Address
            Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
            {
                CMDC = Zero
                If ((DSSP || FHPP))
                {
                    GTFB (STFD, 0x06)
                }
                Else
                {
                    GTFB (STFE, 0x06)
                }

                GTFB (FZTF, Zero)
                GTFB (DCFL, Zero)
                Return (SCBF) /* \SCBF */
            }
        }
    }
}

