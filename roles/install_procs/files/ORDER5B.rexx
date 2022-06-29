/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
/*REXX----------------------------------------------------------------\
| Parse MISSINGFIX report to simple list of missing maintenance       |
\--------------------------------------------------------------------*/
 trace 0  ;
 parse upper arg ds_prefix
 /* initialize variables */
 o = 0;
 v1 = v2 = v3 = v4 = v5 = v6 = v7 = v8 = v9 = v10 = "";
 sia = apar = ptf = "";
 /* header */
 o = o + 1;
 out.o = " SIA                  FMID      APAR      PTF";
 o = o + 1;
 out.o = "-------------------   -------   -------   -------";
 /*    */
  if sysdsn(ds_prefix'.zgsd.temp2.output') = 'OK' then
     "del outfile";                               /* if so delete it */
 "alloc f(SIALIST) da('"ds_prefix".zgsd.temp2.output')" ,
     "new catalog tr space(1,1)" ,
     "unit(sysda) recfm(f b) lrecl(80) dsorg(ps)"
 'EXECIO * DISKR' INDD '(FINIS STEM rec.';     /* read in raw input  */
 /*     */
 do loopy =  1 to rec.0;                       /* loop through input */
  rec.loopy = space(rec.loopy);
  parse var rec.loopy v1 v2 v3 v4 v5 v6 v7 v8 v9 v10;
     if v3 = "HELD" then do;
        fmid = v5;
        sia = SUBSTR(v10,2,19);
          if SUBSTR(sia,19,1) = ")" then do;
           sia = SUBSTR(sia,1,18);
           sia = SUBSTR(sia,1,19);
           end;
        end;
     if SUBSTR(v1,1,6) = "REASON" then do;
        apar = SUBSTR(v1,8,7);
        ptf = SUBSTR(v2,10,7);
        if SUBSTR(sia,9,1) = "#" then do;
           iterate loopy;
           end;
        o = o + 1;
        out.o = sia " " fmid " " apar " " ptf;
        end;
 end;
/*  out.o = o; */
 'EXECIO * DISKW' SIALIST '(FINIS STEM out.';    /* to msgds        */
 'FREE F(SIALIST)';
