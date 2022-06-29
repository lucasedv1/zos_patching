/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
/*REXX----------------------------------------------------------------\
| ORDER6D - for use with FIXORDER_v6 - Jan 2021                       |
| Parse MISSINGFIX report to simple list of missing maintenance       |
\--------------------------------------------------------------------*/
 trace 0  ;
 parse upper arg ds_prefix
 /* initialize variables */
 o = 0;
 /*    */
  if sysdsn(ds_prefix'.zgsd.order.output3') = 'OK' then
     "del outfle1";                               /* if so delete it */
 "alloc f(ORDER3) da('"ds_prefix".zgsd.order.output3')" ,
     "new catalog tr space(1,1)" ,
     "unit(sysda) recfm(f b a) lrecl(121) dsorg(ps)"
 'EXECIO * DISKR' INDD1 '(FINIS STEM rec1.';    /* read in raw input  */
 /* output header */
 o = o + 1;
 out.o = '  SIA-NUMBER         PRODUCT ZONE    SUBSYS';
 out.o = out.o || copies(' ', 121 - length(out.o))
 o = o + 1;
 out.o = ' ------------------------------------------------------------------';
 out.o = out.o || copies(' ', 121 - length(out.o))
 /*     */
 /* read in output2 file */
 do loop1 =  1 to rec1.0;                      /* loop through input */
  rec1.loop1 = space(rec1.loop1);
  parse var rec1.loop1 v_sia v_sev v_z v_p v_f v_a v_ptf v_ss v_s2 v_st;
  v_sia = SUBSTR(v_sia,1,19);
  v_sev = SUBSTR(v_sev,1,1);
  v_z = SUBSTR(v_z,1,7);
  v_p = SUBSTR(v_p,1,7);
  v_f = SUBSTR(v_f,1,7);
  v_a = SUBSTR(v_a,1,7);
  v_ptf = SUBSTR(v_ptf,1,7);
  v_ss = SUBSTR(v_ss,1,8);
  v_st = SUBSTR(v_st,1,12);
    if v_ss = "--------" then do;
      v_ss = "       ";
      end;
    if v_st = "GOOD        " then do;
      v_st = " ";
      end;
    if v_st = "HELD        " then do;
      v_st = "   HELD - IN ERROR !";
      end;
  o = o + 1;
  out.o = ' ' v_sia v_p v_z v_ss v_st;
 end;
 /* finialize and write order.output report */
 out.0 = o;
 'EXECIO * DISKW' ORDER3 '(FINIS STEM out.';     /* to msgds        */
 'FREE F(ORDER3)';
