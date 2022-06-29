/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
/*--------------------------------------------------------------------\
| ORDER6A - for use with FIXORDER_v6 - Jan 2021                       |
| Parse MISSINGFIX report to simple list of missing maintenance       |
| Parse LSTDU report for GSD subsystem designation                    |
\--------------------------------------------------------------------*/
 trace 0  ;
 parse upper arg ds_prefix
 /* initialize variables */
 o = 0;
 linlabl = "";
 zone = SIA_num = sev = fmid = product = sclass = apar = sysmod = " ";
 v_du = v_zone = v_ss = v_gsn = " ";
 /*    */
  if sysdsn(ds_prefix'.zgsd.order.output') = 'OK' then
     "del outfile";                               /* if so delete it */
 "alloc f(SIALIST) da('"ds_prefix".zgsd.order.output'),
     new catalog tr space(1,1),
     unit(sysda) recfm(f b) lrecl(80) dsorg(ps)"
 'EXECIO * DISKR' INDD1 '(FINIS STEM rec.';     /* read in raw input  */
 'EXECIO * DISKR' INDD2 '(FINIS STEM rec2.';    /* read in raw input  */
 do loopy =  1 to rec.0;                       /* loop through input */
  rec.loopy = space(rec.loopy);
  parse var rec.loopy linlabl v2 v3 v4 v5 v6 v7;
   if linlabl = "MISSING" then do;
    zone = v7;
   end;
   if SUBSTR(linlabl,1,3) = "SIA" then do;
    SIA_num = linlabl;
    SIA_num = SUBSTR(SIA_num,1,19);
   end;
/* how about this? */
   if v6 = "GOOD" | v6 = "HELD" then do;
    parse var rec.loopy fmid sclass apar junk sysmod junk2 junk3;
    sev = SUBSTR(sclass,1,1);
    product = SUBSTR(sclass,2,7);
/* GOOD */
   if v6 = "GOOD" then do;
    sstatus = "GOOD";
     end;
/* HELD */
   if v6 = "HELD" then do;
    sstatus = "HELD";
     end;
    if SUBSTR(SIA_num,9,1) = '#' then do;
     iterate loopy;
   end;
/* loop through LSTDU report for subsys   */
 do loop2 =  1 to rec2.0;                    /* loop through input */
  rec2.loop2 = space(rec2.loop2);
  parse var rec2.loop2 v_du v_zone v3 v4 v5 v6 v7 v8 v9 v_ss v11 v_gsn v13;
  /* here we go ! */
  product = v_du;
  if zone =  v_zone then do;
     if v11 = " " then do;
       v_ss = "---------";
       v_gsn = "-";
     end;
  v_ss = SUBSTR(v_ss,1,8);
  leave;
  end;
 end;
/* loop through LSTDU report for subsys   */
    o = o + 1;
    out.o = SIA_num sev zone product fmid apar sysmod v_ss v_gsn sstatus;
   end;
 end;
 out.0 = o;
 'EXECIO * DISKW' SIALIST '(FINIS STEM out.';    /* to msgds        */
 'FREE F(SIALIST)';