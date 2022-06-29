/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
/*--------------------------------------------------------------------\
| Parse MISSINGFIX report to simple list of missing maintenance       |
\--------------------------------------------------------------------*/
 trace Off
 /* initialize variables */
 linlabl = ""
 zone = SIA_num = sev = fmid = product = sclass = apar = sysmod = " "
 /* output header */
 o     = 1
 out.o = '  SIA-NUMBER          SEV SMP_ZONE  PRODUCT   FMID      APAR      PTF'
 o = o + 1
 out.o = ' -----------          --- --------  -------   ----      ----      ---'
 
 'EXECIO * DISKR FIXRPT1 (FINIS STEM rec.';     /* read in raw input  */
 /*     */
 
 do loopy =  1 to rec.0;                       /* loop through input */
    rec.loopy = space(rec.loopy);
    parse var rec.loopy linlabl v2 v3 v4 v5 v6 v7
    if linlabl = "MISSING" then
       zone = v7
    if SUBSTR(linlabl,1,3) = "SIA" then do
       SIA_num = linlabl
       SIA_num = SUBSTR(SIA_num,1,18)
       SIA_num = substr(SIA_num, 1, 16) || right(strip(substr(SIA_num, 17, 2)),2,'0')
       end
    if v7 = "NO" then do
       parse var rec.loopy fmid sclass apar sysmod ptf junk3;
       if DATATYPE(substr(SIA_num, 9, 3), 'N') then do
          sev     = SUBSTR(sclass,1,1)
          product = SUBSTR(sclass,2,7)
          o = o + 1
          out.o = ' 'SIA_num ' ' sev ' ' zone ' ' product ' ' fmid ' ' apar ' ' ptf
          end
       end
 end
 out.0 = o
 'EXECIO' o 'DISKW FIXRPT2 (FINIS STEM out.';
 exit
