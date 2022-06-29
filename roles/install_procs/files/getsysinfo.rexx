/* rexx  __ANSIBLE_ENCODE_EBCDIC__  */
    numeric digits 20

    parm = ""
    parse upper arg parm .
    if parm = "" then do
      parm = "PARMLIB"
    end

    /* chain of control blocks */
    psa         = 0     /* absolute address of PSA              */
    psa_cvt     = 16    /* psa->cvt   see: SYS1.MACLIB(IHAPSA)  */
    cvt_ecvt    = 140   /* cvt->ecvt  see: SYS1.MACLIB(CVT)     */
    ecvt_ipa    = 392   /* ecvt->ipa  see: SYS1.MODGEN(IHAECVT) */

    /* Initialization Parameter Area */
    ipa_lparm   =   20  /* LOADxx suffix                        */
    ipa_lpdsn   =   48  /* LOADxx dataset name                  */
    ipa_iodev   =   92  /* IODFxx dev number                    */
    ipa_iodf    =   96  /* IODFxx suffix                        */
    ipa_iohlq   =   99  /* IODFxx high-level qualifier          */
    ipa_sys     =  160  /* IEASYSxx suffices                    */
    ipa_mcatvol =  224  /* master catalog volume                */
    ipa_mcat    =  234  /* master catalog data set name         */
    ipa_sym     =  288  /* IEASYMxx suffices                    */
    ipa_plib    =  416  /* PARMLIBs at IPL                      */
    ipa_plnumx  = 2134  /* number of PARMLIBs in concatenation  */
    ipa_npde    = 2140  /* number of PDEs                       */
    ipa_nuc     = 2144  /* NUCLSTxx suffix                      */
    ipa_pde     = 2152  /* start of PDEs                        */

    /* parameter descriptor elements as at z/OS 2.4                         */
    /* pde.n.name = IEASYSxx parameter name                                 */
    /* pde.n.alt  = alias or parmlib member name if different to pde.n.name */
    /* pde.n.type = 'X' if xx parmlib suffix or list in parentheses (any    */
    /*                  value which is not 2 characters is ignored          */
    /*              'S' a solus parameter, present if offset 6 of PDE not 0 */
    /*              'V' a value - not treated as a suffix                   */
    /*              'N' not a IEASYSxx parameter                            */
    /* pde.n.def  = default value if none is specified in PDE               */

    pde.0 = 113

    pde.1.name    = "ALLOC"
    pde.1.alt     = "ALLOC"
    pde.1.type    = "X"
    pde.1.def     = ""

    pde.2.name    = "APF"
    pde.2.alt     = "IEAAPF"
    pde.2.type    = "X"
    pde.2.def     = ""

    pde.3.name    = "APG"
    pde.3.alt     = "APG"
    pde.3.type    = "N"
    pde.3.def     = ""

    pde.4.name    = "BLDL"
    pde.4.alt     = "BLDL"
    pde.4.type    = "N"
    pde.4.def     = ""

    pde.5.name    = "BLDLF"
    pde.5.alt     = "BLDLF"
    pde.5.type    = "N"
    pde.5.def     = ""

    pde.6.name    = "CLOCK"
    pde.6.alt     = "CLOCK"
    pde.6.type    = "X"
    pde.6.def     = "00"

    pde.7.name    = "CLPA"
    pde.7.alt     = "CLPA"
    pde.7.type    = "S"
    pde.7.def     = ""

    pde.8.name    = "CMB"
    pde.8.alt     = "CMB"
    pde.8.type    = "V"
    pde.8.def     = ""

    pde.9.name    = "CMD"
    pde.9.alt     = "COMMND"
    pde.9.type    = "X"
    pde.9.def     = "00"

    pde.10.name   = "CON"
    pde.10.alt    = "CONSOL"
    pde.10.type   = "X"
    pde.10.def    = "NONE"

    pde.11.name   = "CONT"
    pde.11.alt    = "CONT"
    pde.11.type   = "N"
    pde.11.def    = ""

    pde.12.name   = "COUPLE"
    pde.12.alt    = "COUPLE"
    pde.12.type   = "X"
    pde.12.def    = "00"

    pde.13.name   = "CPQE"
    pde.13.alt    = "CPQE"
    pde.13.type   = "N"
    pde.13.def    = ""

    pde.14.name   = "CSA"
    pde.14.alt    = "CSA"
    pde.14.type   = "V"
    pde.14.def    = ""

    pde.15.name   = "CSCBLOC"
    pde.15.alt    = "CSCBLOC"
    pde.15.type   = "V"
    pde.15.def    = "ABOVE"

    pde.16.name   = "CVIO"
    pde.16.alt    = "CVIO"
    pde.16.type   = "S"
    pde.16.def    = ""

    pde.17.name   = "DEVSUP"
    pde.17.alt    = "DEVSUP"
    pde.17.type   = "X"
    pde.17.def    = ""

    pde.18.name   = "DIAG"
    pde.18.alt    = "DIAG"
    pde.18.type   = "X"
    pde.18.def    = "00"

    pde.19.name   = "DUMP"
    pde.19.alt    = "DUMP"
    pde.19.type   = "V"
    pde.19.def    = "DASD"

    pde.20.name   = "DUPLEX"
    pde.20.alt    = "DUPLEX"
    pde.20.type   = "N"
    pde.20.def    = ""

    pde.21.name   = "EXIT"
    pde.21.alt    = "EXIT"
    pde.21.type   = "X"
    pde.21.def    = ""

    pde.22.name   = "FIX"
    pde.22.alt    = "IEAFIX"
    pde.22.type   = "X"
    pde.22.def    = ""

    pde.23.name   = "GRS"
    pde.23.alt    = "GRS"
    pde.23.type   = "V"
    pde.23.def    = ""

    pde.24.name   = "GRSCNF"
    pde.24.alt    = "GRSCNF"
    pde.24.type   = "X"
    pde.24.def    = "00"

    pde.25.name   = "GRSRNL"
    pde.25.alt    = "GRSRNL"
    pde.25.type   = "X"
    pde.25.def    = ""

    pde.26.name   = "ICS"
    pde.26.alt    = "ICS"
    pde.26.type   = "N"
    pde.26.def    = ""

    pde.27.name   = "IOS"
    pde.27.alt    = "IECIOS"
    pde.27.type   = "X"
    pde.27.def    = ""

    pde.28.name   = "IPS"
    pde.28.alt    = "IPS"
    pde.28.type   = "N"
    pde.28.def    = ""

    pde.29.name   = "LNK"
    pde.29.alt    = "LNKLST"
    pde.29.type   = "X"
    pde.29.def    = "00"

    pde.30.name   = "LNKAUTH"
    pde.30.alt    = "LNKAUTH"
    pde.30.type   = "V"
    pde.30.def    = "LNKLST"

    pde.31.name   = "LOGCLS"
    pde.31.alt    = "LOGCLS"
    pde.31.type   = "V"
    pde.31.def    = "A"

    pde.32.name   = "LOGLMT"
    pde.32.alt    = "LOGLMT"
    pde.32.type   = "V"
    pde.32.def    = "500"

    pde.33.name   = "LOGREC"
    pde.33.alt    = "LOGREC"
    pde.33.type   = "V"
    pde.33.def    = "SYS1.LOGREC"

    pde.34.name   = "LPA"
    pde.34.alt    = "LPALST"
    pde.34.type   = "X"
    pde.34.def    = ""

    pde.35.name   = "MAXCAD"
    pde.35.alt    = "MAXCAD"
    pde.35.type   = "V"
    pde.35.def    = "50"

    pde.36.name   = "MAXUSER"
    pde.36.alt    = "MAXUSER"
    pde.36.type   = "V"
    pde.36.def    = "255"

    pde.37.name   = "MLPA"
    pde.37.alt    = "IEALPA"
    pde.37.type   = "X"
    pde.37.def    = ""

    pde.38.name   = "MSTRJCL"
    pde.38.alt    = "MSTJCL"
    pde.38.type   = "X"
    pde.38.def    = "00"

    pde.39.name   = "NONVIO"
    pde.39.alt    = "NONVIO"
    pde.39.type   = "V"
    pde.39.def    = ""

    pde.40.name   = "NSYSLX"
    pde.40.alt    = "NSYSLX"
    pde.40.type   = "V"
    pde.40.def    = "165"

    pde.41.name   = "NUCMAP"
    pde.41.alt    = "NUCMAP"
    pde.41.type   = "N"
    pde.41.def    = ""

    pde.42.name   = "OMVS"
    pde.42.alt    = "BPXPRM"
    pde.42.type   = "X"
    pde.42.def    = "DEFAULT"

    pde.43.name   = "OPI"
    pde.43.alt    = "OPI"
    pde.43.type   = "V"
    pde.43.def    = "YES"

    pde.44.name   = "OPT"
    pde.44.alt    = "IEAOPT"
    pde.44.type   = "X"
    pde.44.def    = ""

    pde.45.name   = "PAGEO"
    pde.45.alt    = "PAGEO"
    pde.45.type   = "N"
    pde.45.def    = ""

    pde.46.name   = "PAGE"
    pde.46.alt    = "PAGE"
    pde.46.type   = "V"
    pde.46.def    = ""

    pde.47.name   = "PAGNUM"
    pde.47.alt    = "PAGNUM"
    pde.47.type   = "N"
    pde.47.def    = ""

    pde.48.name   = "PAGTOTL"
    pde.48.alt    = "PAGTOTL"
    pde.48.type   = "V"
    pde.48.def    = "40"

    pde.49.name   = "PAK"
    pde.49.alt    = "IEAPAK"
    pde.49.type   = "X"
    pde.49.def    = "00"

    pde.50.name   = "PLEXCFG"
    pde.50.alt    = "PLEXCFG"
    pde.50.type   = "V"
    pde.50.def    = "ANY"

    pde.51.name   = "PROD"
    pde.51.alt    = "IFAPRD"
    pde.51.type   = "X"
    pde.51.def    = ""

    pde.52.name   = "PROG"
    pde.52.alt    = "PROG"
    pde.52.type   = "X"
    pde.52.def    = ""

    pde.53.name   = "PURGE"
    pde.53.alt    = "PURGE"
    pde.53.type   = "N"
    pde.53.def    = ""

    pde.54.name   = "RDE"
    pde.54.alt    = "RDE"
    pde.54.type   = "V"
    pde.54.def    = "NO"

    pde.55.name   = "REAL"
    pde.55.alt    = "REAL"
    pde.55.type   = "V"
    pde.55.def    = "0"

    pde.56.name   = "RER"
    pde.56.alt    = "RER"
    pde.56.type   = "V"
    pde.56.def    = "NO"

    pde.57.name   = "RSU"
    pde.57.alt    = "RSU"
    pde.57.type   = "V"
    pde.57.def    = "0"

    pde.58.name   = "RSVNONR"
    pde.58.alt    = "RSVNONR"
    pde.58.type   = "V"
    pde.58.def    = "100"

    pde.59.name   = "RSVSTRT"
    pde.59.alt    = "RSVSTRT"
    pde.59.type   = "V"
    pde.59.def    = "5"

    pde.60.name   = "SCH"
    pde.60.alt    = "SCHED"
    pde.60.type   = "X"
    pde.60.def    = ""

    pde.61.name   = "SMF"
    pde.61.alt    = "SMFPRM"
    pde.61.type   = "X"
    pde.61.def    = "00"

    pde.62.name   = "SMS"
    pde.62.alt    = "IGDSMS"
    pde.62.type   = "X"
    pde.62.def    = "00"

    pde.63.name   = "SQA"
    pde.63.alt    = "SQA"
    pde.63.type   = "V"
    pde.63.def    = "(1,0)"

    pde.64.name   = "SSN"
    pde.64.alt    = "IEFSSN"
    pde.64.type   = "X"
    pde.64.def    = "00"

    pde.65.name   = "SVC"
    pde.65.alt    = "IEASVC"
    pde.65.type   = "X"
    pde.65.def    = ""

    pde.66.name   = "SWAP"
    pde.66.alt    = "SWAP"
    pde.66.type   = "N"
    pde.66.def    = ""

    pde.67.name   = "SYSNAME"
    pde.67.alt    = "SYSNAME"
    pde.67.type   = "V"
    pde.67.def    = ""

    pde.68.name   = "SYSP"
    pde.68.alt    = "SYSP"
    pde.68.type   = "X"
    pde.68.def    = ""

    pde.69.name   = "VAL"
    pde.69.alt    = "VATLST"
    pde.69.type   = "X"
    pde.69.def    = "00"

    pde.70.name   = "VIODSN"
    pde.70.alt    = "VIODSN"
    pde.70.type   = "V"
    pde.70.def    = "SYS1.STGINDEX"

    pde.71.name   = "VRREGN"
    pde.71.alt    = "VRREGN"
    pde.71.type   = "V"
    pde.71.def    = "64"

    pde.72.name   = "RTLS"
    pde.72.alt    = "RTLS"
    pde.72.type   = "N"
    pde.72.def    = ""

    pde.73.name   = "UNI"
    pde.73.alt    = "CUNUNI"
    pde.73.type   = "X"
    pde.73.def    = ""

    pde.74.name   = "ILM"
    pde.74.alt    = "ILMLIB"
    pde.74.type   = "N"
    pde.74.def    = ""

    pde.75.name   = "ILMOD"
    pde.75.alt    = "ILMOD"
    pde.75.type   = "N"
    pde.75.def    = ""

    pde.76.name   = "TSO"
    pde.76.alt    = "IKJTSO"
    pde.76.type   = "X"
    pde.76.def    = "00"

    pde.77.name   = "LICENSE"
    pde.77.alt    = "LICENSE"
    pde.77.type   = "V"
    pde.77.def    = "Z/OS"

    pde.78.name   = "unused z/OS"
    pde.78.alt    = "unused z/OS"
    pde.78.type   = "N"
    pde.78.def    = ""

    pde.79.name   = "HVSHARE"
    pde.79.alt    = "HVSHARE"
    pde.79.type   = "V"
    pde.79.def    = "510T"

    pde.80.name   = "ILM"
    pde.80.alt    = "ILM"
    pde.80.type   = "N"
    pde.80.def    = ""

    pde.81.name   = "DRMODE"
    pde.81.alt    = "DRMODE"
    pde.81.type   = "V"
    pde.81.def    = "NO"

    pde.82.name   = "CEE"
    pde.82.alt    = "CEEPRM"
    pde.82.type   = "X"
    pde.82.def    = "00"

    pde.83.name   = "PRESCPU"
    pde.83.alt    = "PRESCPU"
    pde.83.type   = "S"
    pde.83.def    = ""

    pde.84.name   = "LFAREA"
    pde.84.alt    = "LFAREA"
    pde.84.type   = "V"
    pde.84.def    = "INCLUDE1MAFC(YES)"

    pde.85.name   = "CEA"
    pde.85.alt    = "CEAPRM"
    pde.85.type   = "X"
    pde.85.def    = "00"

    pde.86.name   = "HVCOMMON"
    pde.86.alt    = "HVCOMMON"
    pde.86.type   = "V"
    pde.86.def    = "64G"

    pde.87.name   = "AXR"
    pde.87.alt    = "AXR"
    pde.87.type   = "X"
    pde.87.def    = "00"

    pde.88.name   = "ZAAPZIIP"
    pde.88.alt    = "ZZ"
    pde.88.type   = "V"
    pde.88.def    = "YES"

    pde.89.name   = "IQP"
    pde.89.alt    = "IQPPRM"
    pde.89.type   = "X"
    pde.89.def    = ""

    pde.90.name   = "CPCR"
    pde.90.alt    = "CPCR"
    pde.90.type   = "N"
    pde.90.def    = ""

    pde.91.name   = "DDM"
    pde.91.alt    = "DDM"
    pde.91.type   = "N"
    pde.91.def    = ""

    pde.92.name   = "AUTOR"
    pde.92.alt    = "AUTOR"
    pde.92.type   = "X"
    pde.92.def    = "00"

    pde.93.name   = "CATALOG"
    pde.93.alt    = "IGGCAT"
    pde.93.type   = "X"
    pde.93.def    = "00"

    pde.94.name   = "IXGCNF"
    pde.94.alt    = "IXGCNF"
    pde.94.type   = "X"
    pde.94.def    = ""

    pde.95.name   = "PAGESCM"
    pde.95.alt    = "PAGESCM"
    pde.95.type   = "V"
    pde.95.def    = "ALL"

    pde.96.name   = "WARNUND"
    pde.96.alt    = "WARNUND"
    pde.96.type   = "S"
    pde.96.def    = ""

    pde.97.name   = "HZS"
    pde.97.alt    = "HZSPRM"
    pde.97.type   = "X"
    pde.97.def    = ""

    pde.98.name   = "GTZ"
    pde.98.alt    = "GTZPRM"
    pde.98.type   = "X"
    pde.98.def    = ""

    pde.99.name   = "HZSPROC"
    pde.99.alt    = "HZSPROC"
    pde.99.type   = "V"
    pde.99.def    = "HZSPROC"

    pde.100.name  = "SMFLIM"
    pde.100.alt   = "SMFLIM"
    pde.100.type  = "X"
    pde.100.def   = ""

    pde.101.name  = "IEFOPZ"
    pde.101.alt   = "IEFOPZ"
    pde.101.type  = "X"
    pde.101.def   = ""

    pde.102.name  = "RACF"
    pde.102.alt   = "IRRPRM"
    pde.102.type  = "X"
    pde.102.def   = ""

    pde.103.name  = "FXE"
    pde.103.alt   = "FXEPRM"
    pde.103.type  = "X"
    pde.103.def   = ""

    pde.104.name  = "IZU"
    pde.104.alt   = "IZUPRM"
    pde.104.type  = "X"
    pde.104.def   = ""

    pde.105.name  = "SMFTBUFF"
    pde.105.alt   = "SMFTBUFF"
    pde.105.type  = "V"
    pde.105.def   = "5"

    pde.106.name  = "DIAG1"
    pde.106.alt   = "DIAG1"
    pde.106.type  = "N"
    pde.106.def   = ""

    pde.107.name  = "OSPROTECT"
    pde.107.alt   = "OSPROTECT"
    pde.107.type  = "V"
    pde.107.def   = "SYSTEM"

    pde.108.name  = "ICSF"
    pde.108.alt   = "CSFPRM"
    pde.108.type  = "X"
    pde.108.def   = ""

    pde.109.name  = "ICSFPROC"
    pde.109.alt   = "ICSFPROC"
    pde.109.type  = "V"
    pde.109.def   = ""

    pde.110.name  = "RUCSA"
    pde.110.alt   = "RUCSA"
    pde.110.type  = "V"
    pde.110.def   = "0M"

    pde.111.name  = "BOOST"
    pde.111.alt   = "BOOST"
    pde.111.type  = "V"
    pde.111.def   = "SYSTEM"

    pde.112.name  = "IODEV"
    pde.112.alt   = "IODEV"
    pde.112.type  = "V"
    pde.112.def   = "0"

    pde.113.name  = "CATVOL"
    pde.113.alt   = "CATVOL"
    pde.113.type  = "V"
    pde.113.def   = "0"

    /* chain to IPA control block */
    cvt   = C2D(STORAGE(D2X(psa  + psa_cvt), 4))
    ecvt  = C2D(STORAGE(D2X(cvt  + cvt_ecvt),4))
    ipa   = C2D(STORAGE(D2X(ecvt + ecvt_ipa),4))

    /* get active PARMLIBs */
    plnumx = C2D(STORAGE(D2X(ipa + ipa_plnumx),2))
    parmlib.0 = 0
    do i = 1 to plnumx
      lib = STRIP(STORAGE(D2X(ipa + ipa_plib + 64 * (i-1)),44))
      flag = STORAGE(D2X(ipa + ipa_plib + 64 * (i-1) + 63),1)
      if C2D(BITAND(flag, '80'x)) > 0 then do
        parmlib.0 = parmlib.0 + 1
        x = parmlib.0
        parmlib.x = lib
      end
    end

    select
      when parm = "PARMLIB" then
        do
          x = print("PARMLIB concatenation:")
          do i = 1 to parmlib.0
            x = print("  "parmlib.i)
          end
        end
      when parm = "LOAD" then
        do
          value = STORAGE(D2X(ipa + ipa_lparm),2)
          dsn = STRIP(STORAGE(D2X(ipa + ipa_lpdsn),44))
          x = print(value)
          x = print(dsn"(LOAD"value")")
        end
      when parm = "IODF" then
        do
          value = STORAGE(D2X(ipa + ipa_iodf),2)
          hlq = STRIP(STORAGE(D2X(ipa + ipa_iohlq),8))
          x = print("IODF = "value)
          x = print(hlq".IODF"value)
        end
      when parm = "IODEV" then
        do
          value = STORAGE(D2X(ipa + ipa_iodev),4)
          x = print(value)
        end
      when (parm = "IEASYS") | (parm = "SYS") | (parm = "SYSPARM") then
        do
          value = STRIP(STORAGE(D2X(ipa + ipa_sys),63))
          if value = "" then do
            value = "00"
            source = "Default"
          end
          else do
            xx = STORAGE(D2X(ipa + ipa_lparm),2)
            dsn = STRIP(STORAGE(D2X(ipa + ipa_lpdsn),44))
            source = dsn"(LOAD"xx")"
          end
          x = print("SYSPARM = "value)
          call findem "IEASYS",value
          do i = 1 to fm.0
            x = print(fm.i)
          end
          x = print("Source: "source)
        end
      when parm = "CATVOL" then
        do
          value = STORAGE(D2X(ipa + ipa_mcatvol),6)
          x = print(value)
        end
      when (parm = "MCAT") | (parm = "SYSCAT") then
        do
          value = STRIP(STORAGE(D2X(ipa + ipa_mcat),44))
          x = print("SYSCAT = "value)
          xx = STORAGE(D2X(ipa + ipa_lparm),2)
          dsn = STRIP(STORAGE(D2X(ipa + ipa_lpdsn),44))
          source = dsn"(LOAD"xx")"
          x = print("Source: "source)
        end
      when (parm = "IEASYM") | (parm = "SYM") then
        do
          value = STRIP(STORAGE(D2X(ipa + ipa_sym),63))
          x = print(value)
          call findem "IEASYM",value
          do i = 1 to fm.0
            x = print(fm.i)
          end
        end
      when parm = "NUCLST" then
        do
          value = STORAGE(D2X(ipa + ipa_nuc),2)
          dsn = STRIP(STORAGE(D2X(ipa + ipa_lpdsn),44))
          if value = "" then do
            x = print("NUCLST = *** Not set ***")
          end
          else do
            x = print("NUCLST = "value)
            x = print(dsn"(NUCLST"value")")
          end
        end
      otherwise
        do
          /* get number of PDEs to search */
          npde = C2D(STORAGE(D2X(ipa + ipa_npde),2))
          if npde > pde.0 then do
            npde = pde.0
          end

          /* look for a PDE */
          found = 0
          i = 1
          do while (found = 0) & (i <= npde)
            if (parm = pde.i.name) | (parm = pde.i.alt) then do
              found = 1
            end
            else i = i + 1
          end
          if found = 1 then do
            vaddr = C2D(STORAGE(D2X(ipa + ipa_pde + 8 * (i-1)),4))
            vlen  = C2D(STORAGE(D2X(ipa + ipa_pde + 8 * (i-1) + 4),2))
            vsrc  = STORAGE(D2X(ipa + ipa_pde + 8 * (i-1) + 6),2)
            if C2D(vsrc) = 0 then do
              source = "Default"
            end
            else do
              if c2d(vsrc) = 65535 then do
                source = "Operator"
              end
              else do
                call findem "IEASYS",vsrc
                if fm.0 = 0 then do
                  source = "IEASYS"vsrc
                end
                else do
                  source = fm.1
                end
              end
            end
            value = ""
            if vlen > 0 then do
              value = STORAGE(D2X(vaddr),vlen)
            end
            select
              when pde.i.type = "N" then      /* not specified in IEASYSxx */
                do
                  if value = "" then do
                    x = print(pde.i.name" = *** Not set ***")
                  end
                  else do
                    x = print(pde.i.name" = "value)
                  end
                end
              when pde.i.type = "S" then      /* solus parameter - no value */
                do
                  if C2D(vsrc) = 0 then do
                    x = print(pde.i.name" is not present")
                  end
                  else do
                    x = print(pde.i.name" is present")
                    x = print("Source: "source)
                  end
                end
              when pde.i.type = "V" then      /* a value */
                do
                  if value = "" then do
                    if pde.i.def <> "" then do
                      value = pde.i.def
                    end
                    else do
                      value = "*** Not set ***"
                    end
                  end
                  dflt = ""
                  if (pde.i.def <> "") & (TRANSLATE(value) = pde.i.def) then do
                    dflt = " (default)"
                  end
                  x = print(pde.i.name" = "value||dflt)
                  x = print("Source: "source)
                end
              when pde.i.type = "X" then      /* suffix(es) */
                do
                  if value = "" then do
                    if pde.i.def <> "" then do
                      value = pde.i.def
                    end
                    else do
                      value = "*** Not set ***"
                    end
                  end
                  dflt = ""
                  if (pde.i.def <> "") & (TRANSLATE(value) = pde.i.def) then do
                    dflt = " (default)"
                  end
                  x = print(value||dflt) 
                  call findem pde.i.alt,value
                  do j = 1 to fm.0
                    x = print(fm.j)
                  end
                  x = print("Source: "source)
                end
              otherwise do
                end
            end
          end
          else do
            x = print("*** "parm" not recognised ***")
          end
        end
      end
    x = printOff()
    exit 0

    findem:
    fm.0 = 0
    arg prefix,suffices
    if POS('(', suffices) = 0 then do  /* single suffix or lone value */
      fmfound = 0
      fmi = 1
      if LENGTH(suffices) = 2 then do
        do while (fmfound = 0) & (fmi <= parmlib.0)
          if ismember(parmlib.fmi,prefix||suffices) then do
            fm.1 = parmlib.fmi"("prefix||suffices")"
            fm.0 = 1
            fmfound = 1
          end
          fmi = fmi + 1
        end
      end
    end
    else do
      parse var suffices "("rest")" .
      do while rest <> ""
        parse var rest suffix","rest
        if length(suffix) = 2 then do  /* because e.g. CON=xx,xx,NOJES3 */
          fmfound = 0
          fmi = 1
          do while (fmfound = 0) & (fmi <= parmlib.0)
            if ismember(parmlib.fmi,prefix||suffix) then do
              fm.0 = fm.0 + 1
              j = fm.0
              fm.j = parmlib.fmi"("prefix||suffix")"
              fmfound = 1
            end
            fmi = fmi + 1
          end
        end
      end
    end
    return

    ismember: procedure
    arg proc,mem
    x = outtrap("var.")
    ADDRESS TSO "LISTDS '"proc"' MEMBERS"
    x = outtrap("off")
    foundmlist = 0
    foundmem = 0
    i = 1
    do while (i <= var.0) & (foundmem = 0)
      if var.i = "--MEMBERS--" then do
        foundmlist = 1
      end
      else do
        if var.i = "THE FOLLOWING ALIAS NAMES EXIST WITHOUT TRUE NAMES" then do
          /* say "*** there are DUDS in the list" */
          foundmlist = 0
        end
        else if foundmlist = 1 then do
          parse var var.i memname . "ALIAS("alias")" .
          if memname = mem then foundmem = 1
          if alias <> "" then do
            rest = alias
            do while rest <> ""
              parse var rest memname","rest
              if memname = mem then foundmem = 1
            end
          end
        end
      end
      i = i + 1
    end
    return foundmem

    print: procedure expose MYAXRCONN AXRREQTOKEN
    parse arg line
    ll = 67
    lin.0 = 1
    lin.1 = STRIP(line)
/*    do while LENGTH(line) > ll
      lin.0 = lin.0 + 1
      line = STRIP(line)
      lli = lin.0
      lin.lli = LEFT(line, ll)
    end */
    firstLineType = 'D'
    if AXRREQTOKEN = "AXRREQTOKEN" then do /* we are not in System REXX */
      do pi = 1 to lin.0
        say lin.pi
      end
      x = 0
    end
    else do
      do pi = 1 to lin.0
        if MYAXRCONN = "MYAXRCONN" THEN DO
          MYAXRCONN = "FIRSTLINE"
          x = AXRMLWTO(lin.pi, 'MYAXRCONN', firstLineType)
        end
        else do
          x = AXRMLWTO(lin.pi, 'MYAXRCONN', 'D')
        end
      end
    end
    return x

    printOff: procedure expose MYAXRCONN AXRREQTOKEN
    if AXRREQTOKEN = "AXRREQTOKEN" then do
      x = 0
    end
    else do
      x = AXRMLWTO(, 'MYAXRCONN', 'E')
    end
return x
