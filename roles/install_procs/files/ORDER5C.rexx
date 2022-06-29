/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
/*REXX----------------------------------------------------------------\
| ORDER6C - for use with FIXORDER_v6 - Jan 2021                       |
| Parse MISSINGFIX report to simple list of missing maintenance       |
\--------------------------------------------------------------------*/
 trace 0  ;
 parse upper arg ds_prefix
 /* initialize variables */
 o = 0;
 /* header */
 o = o + 1;
 out.o = " SIA                FMID    APAR    PTF     STATUS";
 o = o + 1;
 out.o = "------------------- ------- ------- ------- -------";
 /*    */
  if sysdsn(ds_prefix'.zgsd.status.output') = 'OK' then
     "del outfile";                               /* if so delete it */
 "alloc f(SIALIST) da('"ds_prefix".zgsd.status.output')" ,
     "new catalog tr space(1,1)" ,
     "unit(sysda) recfm(f b) lrecl(80) dsorg(ps)"
 'EXECIO * DISKR' INDD1 '(FINIS STEM rec.';     /* read in raw input  */
 'EXECIO * DISKR' INDD2 '(FINIS STEM rec2.';    /* read in raw input  */
 /*     */
 do loop1 =  1 to rec.0;                       /* loop through input */
  rec.loop1 = space(rec.loop1);
  parse var rec.loop1 sia1 sev1 fmid1 apar1 ptf1;
     sia1 = SUBSTR(sia1,1,19);
     /* remove header info */
     if SUBSTR(sia1,1,5) = "1PAGE" then do;
        iterate loop1;
        end;
     if sia1 = "" then do;
        iterate loop1;
        end;
     if SUBSTR(sia1,1,7) = "RECEIVE" then do;
        iterate loop1;
        end;
     if SUBSTR(sia1,1,5) = "NOTE:" then do;
        iterate loop1;
        end;
     if sia1 = "RSN" then do;
        iterate loop1;
        end;
     if sia1 = "INT" then do;
        iterate loop1;
        end;
     /* end remove header */
     status = "previously applied";
     stat3 = "previously applied";
     match = 0;
     sia1 = SUBSTR(sia1,1,19);
     if sia1 = "SIA" then do;
        iterate loop1;
        end;
     if sia1 = "-------------------" then do;
        iterate loop1;
        end;
     do loop2 = 1 to rec2.0;
     rec2.loop2 = space(rec2.loop2);
 /*  parse var rec2.loop2 sia2 sev2 t1 t2 fmid2 apar2 ptf2;   */
     parse var rec2.loop2 sia2 sev2 t1 t2 fmid2 apar2 ptf2 t3 t4 stat2;
     SAY sia2 sev2 fmid2 apar2 ptf2 t3 t4 stat2;
     sia2 = SUBSTR(sia2,1,19);
     if sia2 = "SIA_NUMBER" then do;
        iterate loop2;
        end;
     if sia2 = "----------" then do;
        iterate loop2;
        end;
     if match = 1 then do;
        iterate loop2;
        end;
     if sia1 = sia2 then do;
        match = 1;
        if stat2 = "HELD" then do;
          stat3 = "   > HELD - investigate";
          end;
        if stat2 = "GOOD" then do;
          stat3 = " * MISSING *";
          end;
        end;
     end;   /* loop2 */
     o = o + 1;
     out.o = sia1 fmid1 apar1 ptf1 stat3;
  end;     /* loop 1 */
 'EXECIO * DISKW' SIALIST '(FINIS STEM out.';    /* to msgds        */
 'FREE F(SIALIST)';
