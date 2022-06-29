/* rexx  __ANSIBLE_ENCODE_EBCDIC__                                    */
/*          (c)Copyright IBM Corporation 2008                         */
/*                                                                    */
/*  Name:    LSTDU                                                    */
/*                                                                    */
/*  Title:   List DUs                                                 */
/*                                                                    */
/*  Purpose: This REXX EXEC uses GIMAPIRX to extract the DUs          */
/*           from the SMPE Global CSI that it is passed.              */
/*                                                                    */
/*  Output Files: REPORT   - Report                                   */
/*                SYSTSPRT - Messages                                 */
/*                                                                    */
/*  Input Files:  SMPE Global CSI                                     */
/*                                                                    */
/*  Dependencies: None                                                */
/*                                                                    */
/*  Schedule of Changes:                                              */
/*    Date       Programmer          Description                      */
/*    ----       ----------          -----------                      */
/*    2011/06/17 mjcleary@us.ibm.com Add LINKLIB keyword              */
/*    2011/06/17 mjcleary@us.ibm.com Add PARMLIB keyword              */
/*    2011/06/17 mjcleary@us.ibm.com Add HLQ keyword                  */
/*    2011/06/17 mjcleary@us.ibm.com Add XPROC                        */
/*    2010/05/13 mjcleary@us.ibm.com Add New Fields                   */
/*    2009/03/01 mjcleary@us.ibm.com Inception                        */
/**********************************************************************/
trace OFF
 
"XPROC 1 csidsn trace hlq(SYS1.UAT) linklib(LINKLIB) ,
 parmlib(PARMLIB)"
 
xprocrc = RC
IF xprocrc <> 0 THEN DO
  SAY 'Return code from XPROC was' xprocrc '... exiting!'
  SAY
  exit xprocrc
END /* xprocrc <> 0 */
 
IF trace = 'TRACE' THEN DO
  trace i
END /* trace = 'TRACE' */
 
csidsn = STRIP(csidsn)
 
IF (SYSDSN("'"csidsn"'") <> 'OK') THEN DO
  SAY csidsn 'is NOT Cataloged... exiting!'
  SAY
  EXIT 8
END /* (SYSDSN(csidsn) <> 'OK') */
 
/*
   Extract TARGETZONEs from ALLTZONES
*/
 
duseq.  = ''
duseq.0 = 0
durpt.  = ''
durpt.0 = 0
 
GIMAPICSI=csidsn
GIMAPIZONE='ALLTZONES'
GIMAPIENTRY='TARGETZONE'
GIMAPISUBENTRY='ZDESC'
GIMAPIFILTER=''
GIMAPILANGUAGE='ENU'
GIMAPISORT='SORT FIELDS=(32,8,CH,A)'
 
x = MSG('OFF')
"FREE  F(SORTIN SORTOUT GIMAPISM)"
x = MSG('ON')
 
"ALLOC F(SORTIN) NEW UNIT(SYSALLDA) CYL SPACE(100 500) " ,
       "RECFM(F) DSORG(PS) LRECL(16384) BLKSIZE(0)"
"ALLOC F(SORTOUT) NEW UNIT(SYSALLDA) CYL SPACE(100 500) " ,
       "RECFM(F) DSORG(PS) LRECL(16384) BLKSIZE(0)"
"ALLOC F(GIMAPISM) DUMMY"
 
"CALL '"hlq"."linklib"(GIMAPIRX)'"
gimapirxrc = RC
 
SELECT
  WHEN (gimapirxrc > 0) THEN DO
    DO d=1 TO 999999
      "EXECIO 1 DISKR SORTOUT"
      IF RC > "1" THEN LEAVE
      PARSE PULL sortout
      duseq.d = SUBSTR(sortout,1,INDEX(sortout,'          '))
      duseq.0 = duseq.0 + 1
    END /* DO d=1 TO 999999 */
    "EXECIO 0 DISKR SORTOUT (FINIS"
    IF verbose = 'YES' THEN DO
      SAY csidsn 'GLOBAL contains the following' duseq.0 'DUs:'
      SAY
      DO d=1 TO duseq.0
        SAY duseq.d
      END /* d=1 TO duseq.0 */
      SAY
    END /* verbose = 'YES' */
    DO d=1 TO duseq.0
      applied     = ''
      delivery    = ''
      du          = ''
      dudesc      = ''
      dulevel     = ''
      generic     = ''
      gnstype     = ''
      gnsvalue    = ''
      pkg         = ''
      subsystem   = ''
      symbolovol  = ''
      tsid        = ''
      userid      = ''
      zdesc       = ''
      duseq.d = SUBSTR(duseq.d,9)
      zone = SUBSTR(duseq.d,1,8)
      duseq.d = SUBSTR(duseq.d,10)
      DO WHILE WORDS(duseq.d) > 0
        SELECT
          WHEN SUBSTR(WORD(duseq.d,1),1,11) = 'APPLY_DATE=' THEN DO
            applied = STRIP(SUBSTR(WORD(duseq.d,1),12),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* APPLY_DATE= */
          WHEN SUBSTR(WORD(duseq.d,1),1,12) = 'CLONED_DATE=' THEN DO
            applied = STRIP(SUBSTR(WORD(duseq.d,1),13),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* CLONED_DATE= */
          WHEN SUBSTR(WORD(duseq.d,1),1,12) = 'CLONED_OVOL=' THEN DO
            symbolovol = STRIP(SUBSTR(WORD(duseq.d,1),13),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* CLONED_OVOL= */
          WHEN SUBSTR(WORD(duseq.d,1),1,09) = 'DELIVERY=' THEN DO
            delivery = STRIP(SUBSTR(WORD(duseq.d,1),10),'T',',')
            duseq.d  = DELWORD(duseq.d,1,1)
          END /* DELIVERY= */
          WHEN SUBSTR(WORD(duseq.d,1),1,15) = 'DISTRIBUTED_BY=' THEN DO
            userid = STRIP(SUBSTR(WORD(duseq.d,1),16),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* DISTRIBUTED_BY= */
          WHEN SUBSTR(WORD(duseq.d,1),1,08) = 'DU_DESC=' THEN DO
            dudesc = STRIP(SUBSTR(WORD(duseq.d,1),09),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* DU_DESC= */
          WHEN SUBSTR(WORD(duseq.d,1),1,09) = 'DU_LEVEL=' THEN DO
            dulevel = STRIP(SUBSTR(WORD(duseq.d,1),10),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* DU_LEVEL= */
          WHEN SUBSTR(WORD(duseq.d,1),1,08) = 'GENERIC=' THEN DO
            generic = STRIP(SUBSTR(WORD(duseq.d,1),09),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* GENERIC= */
          WHEN SUBSTR(WORD(duseq.d,1),1,09) = 'GNS_TYPE=' THEN DO
            gnstype = STRIP(SUBSTR(WORD(duseq.d,1),10),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* GNS_TYPE= */
          WHEN SUBSTR(WORD(duseq.d,1),1,10) = 'GNS_VALUE=' THEN DO
            gnsvalue = STRIP(SUBSTR(WORD(duseq.d,1),11),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* GNS_VALUE= */
          WHEN SUBSTR(WORD(duseq.d,1),1,08) = 'PACKAGE=' THEN DO
            pkg     = STRIP(SUBSTR(WORD(duseq.d,1),09),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* PACKAGE= */
          WHEN SUBSTR(WORD(duseq.d,1),1,08) = 'PRODUCT=' THEN DO
            du      = STRIP(SUBSTR(WORD(duseq.d,1),09),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* PRODUCT= */
          WHEN SUBSTR(WORD(duseq.d,1),1,10) = 'SUBSYSTEM=' THEN DO
            subsystem = STRIP(SUBSTR(WORD(duseq.d,1),11),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* SUBSYSTEM= */
          WHEN SUBSTR(WORD(duseq.d,1),1,12) = 'SYMBOL_OVOL=' THEN DO
            symbolovol = STRIP(SUBSTR(WORD(duseq.d,1),13),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* SYMBOL_OVOL= */
          WHEN SUBSTR(WORD(duseq.d,1),1,07) = 'SYSTEM=' THEN DO
            tsid    = STRIP(SUBSTR(WORD(duseq.d,1),08),'T',',')
            duseq.d = DELWORD(duseq.d,1,1)
          END /* SYMBOL_OVOL= */
          WHEN SUBSTR(WORD(duseq.d,1),1,06) = 'ZDESC=' THEN DO
            zdesc = SUBSTR(WORD(duseq.d,1),07)
            zdesc = TRANSLATE(zdesc,' ','|')
            duseq.d = zdesc
            du = SUBSTR(zdesc,9,6)
            duseq.d = DELWORD(duseq.d,1,1)
          END /* ZDESC= */
          OTHERWISE DO
            SAY 'Unknown:' duseq.d
            duseq.d = DELWORD(duseq.d,1,1)
          END /* OTHERWISE */
        END /* SELECT */
      END /* DO WHILE WORDS(duseq.d) > 0 */
      IF LENGTH(du) > 1 THEN DO
        applied     = LEFT(applied,16)
        delivery    = LEFT(delivery,08)
        du          = LEFT(du,07)
        dulevel     = LEFT(dulevel,06)
        generic     = LEFT(generic,08)
        gnstype     = LEFT(gnstype,08)
        gnsvalue    = LEFT(gnsvalue,08)
        pkg         = LEFT(pkg,06)
        subsystem   = LEFT(subsystem,08)
        symbolovol  = LEFT(symbolovol,06)
        tsid        = LEFT(tsid,04)
        userid      = LEFT(userid,07)
        zone        = LEFT(zone,07)
        x = durpt.0 + 1
        durpt.x = du zone generic delivery pkg dulevel applied ,
                    userid symbolovol subsystem gnstype gnsvalue ,
                    dudesc
        durpt.0 = durpt.0 + 1
      END /* IF LENGTH(du) > 1 THEN DO */
    END /* DO d=1 TO durpt.0 */
 
    IF durpt.0 > 0 THEN DO
      report = ' 'csidsn 'GLOBAL contains the following' durpt.0 'DUs:'
      PUSH report
      "EXECIO 1 DISKW REPORT"
      report = ' '
      PUSH report
      "EXECIO 1 DISKW REPORT"
      report = ' DU      Zone    Generic  Delivery Pkg    DUID  ' ,
               'Applied          Userid  OVOL ' ,
               'SubSys  GNSType  GNSValue   Description'
      PUSH report
      "EXECIO 1 DISKW REPORT"
      DO d=1 TO durpt.0
        report = ' 'durpt.d
        PUSH report
        "EXECIO 1 DISKW REPORT"
      END /* DO d=1 TO durpt.0 */
      report = ' '
      PUSH report
      "EXECIO 1 DISKW REPORT"
      "EXECIO 0 DISKW REPORT (FINIS"
      IF verbose /= 'YES' THEN DO
        SAY csidsn 'GLOBAL contains' durpt.0 'DUs'
        SAY
      END /* verbose = 'YES' */
    END /* IF durpt.0 > 0 THEN DO */
    IF durpt.0 = 0 THEN DO
      report = ' 'csidsn 'ALLTZONES contains zero DUs'
      PUSH report
      "EXECIO 1 DISKW REPORT"
      report = ' '
      PUSH report
      "EXECIO 1 DISKW REPORT"
      "EXECIO 0 DISKW REPORT (FINIS"
      SAY csidsn 'ALLTZONES contains zero DUs'
      SAY
    END /* IF durpt.0 = 0 THEN DO */
  END /* (gimapirxrc > 0) */
  WHEN (gimapirxrc = 0) THEN DO
    report = ' 'csidsn 'GLOBAL contains zero DUs'
    PUSH report
    "EXECIO 1 DISKW REPORT"
    report = ' '
    PUSH report
    "EXECIO 1 DISKW REPORT"
    "EXECIO 0 DISKW REPORT (FINIS"
    SAY ' 'csidsn 'GLOBAL contains zero DUs'
    SAY
  END /* (gimapirxrc = 0) */
  WHEN (gimapirxrc < 0) THEN DO
    "EXECIO * DISKR sortout (STEM sortout. OPEN FINIS)"
    DO f=1 TO sortout.0
      SAY LEFT(sortout.f,INDEX(sortout.f,'     '))
    END
    SAY
    SAY csidsn 'encountered the above error message'
    SAY
    EXIT 8
  END /* (gimapirxrc < 0) */
  OTHERWISE DO
    NOP
  END /* OTHERWISE */
END /* SELECT */
 
x = MSG('OFF')
"FREE  F(SORTIN SORTOUT GIMAPISM)"
x = MSG('ON')
 
EXIT 0
