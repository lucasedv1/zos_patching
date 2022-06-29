/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
/*-------------------------------------------------------------------*/
/*
    ZONELIST will build the SMPE control cards for the MISSINGFIX
    report based on the parms passed to it. If TYPE is not specified
    it defaults to TYPE(ALLTGT) to verify the CIRATS have been
    applied.  If the ZINC parm is used, it takes precedence over
    TYPE and ZEXC and the SMPE control card will only process the
    zones passed via ZINC.
    --- Example 1:
    ZONELIST ZEXC(ZOS#01T J2Z#01T)
    This would process all TARGET zones except for the two zones
    specified in the ZEXC parm.
    ---
    --- Example 2:
    ZONELIST TYPE(ALLZONES) ZEXC(ZOS#01D)
    This would process all TARGET & DLIB zones except for the one
    zone specified in the ZEXC parm.
    ---
    Valid Parms are:
    TYPE(xxxx):
      Where xxxx can be:
      ALLZONES - Process all TARGET & DLIB zones
      ALLTGT   - Process only TARGET zones
      ALLDLIB  - Process only DLIB zones
    ZINC(xxxxxxx xxxxxxx ...):
      Where xxxxxxxx is a list of one or more zones to be processed.
    ZEXC(xxxxxxx xxxxxxx ...):
      Where xxxxxxxx is a list of one or more zones to be excluded
      from being processed.
*/
/*-------------------------------------------------------------------*/
parse upper arg parms
parse var parms "TYPE(" type ")" .
parse var parms "ZINC(" zinc ")" .
parse var parms "ZEXC(" zexc ")" .
/*-------------------------------------------------------------------*/
/* Initial some variables                                            */
/*-------------------------------------------------------------------*/
if type  = "" then type = "ALLTGT"  /* default to target zones only  */
zonelist = ""                       /* initialize zonelist           */
header.1 = "  SET    BOUNDARY (GLOBAL ) ."
header.2 = "   REPORT MISSINGFIX"
header.3 = "   ZONES ("
footer.1 = "         )"
footer.2 = "   FIXCAT(SIA*) ."
/*-------------------------------------------------------------------*/
/* if ZINC (zone include) is used, only process the zones specified. */
/*-------------------------------------------------------------------*/
if zinc /= ""
then do
  zonelist = zinc
  call build_cntl_cards
  exit                                       /* <= get out !         */
end
/*-------------------------------------------------------------------*/
/* verify TYPE is one of the acceptable values                       */
/*-------------------------------------------------------------------*/
if type /= "" & wordpos(type,"ALLZONES ALLTGT ALLDLIB") = 0
then do
  say;say;say
  say "*** ERROR - TYPE must be one of these values"
  say "          ALLZONES - Process all TARGET & DLIB zones"
  say "          ALLTGT   - Process only TARGET zones"
  say "          ALLDLIB  - Process only DLIB zones"
  say;say;say
  exit 16                                    /* <= get out !         */
end
call build_zonelist
call build_cntl_cards
exit
/*==================================================================*/
build_zonelist:
/*-------------------------------------------------------------------*/
/*                                                                   */
/* process the output of SMPE "LIST GLOBALZONE" to build a list      */
/* of zone names to feed into the SMPE MISSINGFIX report based on    */
/* parm values initially passed to this exec.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
"execio * diskr smpzones (stem irec. finis)"
rc_hold = rc
if rc_hold /= 0
then do
  say;say;say
  say "*** ERROR - RC="rc_hold "processing SMPE ZONEINDEX data"
  say;say;say
  exit 16                                    /* <= get out !         */
end
do i = 1 to irec.0
  temp = substr(irec.i,30,70)
  if wordpos(" TARGET ",substr(irec.i,37,11)) /= 0 , /* only process */
   | wordpos(" DLIB ",substr(irec.i,37,11)) /= 0     /* TARGET or    */
  then parse var temp z_name z_type z_dsname .       /* DLIB zones   */
  else iterate
/*-------------------------------------------------------------------*/
/*                                                                   */
/* !! the order of the following logic is important:                 */
/*                                                                   */
/* if this zone name is in the exclude list - skip it                */
/* if ALLZONES was requested or                                      */
/* if the zone type matches the parm passed to this exec             */
/*    then add it to the list                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
  if wordpos(z_name,zexc) /= 0 then iterate
  if type = "ALLZONES" ,
   | type = "ALLTGT" & z_type = "TARGET" ,
   | type = "ALLDLIB" & z_type = "DLIB"
  then zonelist = zonelist z_name
end
return
/*==================================================================*/
build_cntl_cards:
/*-------------------------------------------------------------------*/
/*                                                                   */
/* break zonelist into manageable chunks of around 60,70 characters  */
/*                                                                   */
/* i added 1 trailing blank to zonelist to make the logic below      */
/* a bit simpler.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
zonelist = zonelist " "
zonelist_count = 0
"execio 0 diskw smpcntl (open)"         /* open the output file      */
"execio 3 diskw smpcntl (stem header.)" /* write the first headers   */
do while zonelist /= ""
  t1 = pos(" ",substr(zonelist,60))     /* find a blank after col 59 */
  l1 = t1 + 59                          /* set the length            */
  orec.1 = left(zonelist,l1)            /* grab a chunk              */
  zonelist = substr(zonelist,l1)        /* strip off the chunk       */
/*-------------------------------------------------------------------*/
/* SMPE has a 255 zone limit per MISSINGFIX REPORT.                  */
/* if adding the current chunk of zonenames (orec.1) will push the   */
/* report over 240 zonenames ... make another MISSINGFIX REPORT.     */
/* then do                                                           */
/*   write the footer to the current list                            */
/*   write the header for the current chunk of zonenames (orec.1)    */
/*   set the counter to zero                                         */
/* end                                                               */
/*-------------------------------------------------------------------*/
  if zonelist_count + words(orec.1) > 240
  then do
    "execio 2 diskw smpcntl (stem footer.)"
    "execio 3 diskw smpcntl (stem header.)"
    zonelist_count = 0                     /* reset zonelist counter */
  end
/*-------------------------------------------------------------------*/
/* write the current chunk of zonenames (orec.1)                     */
/* increment counter by # of zonenames in this chunk                 */
/*-------------------------------------------------------------------*/
  "execio 1 diskw smpcntl (stem orec.)" /* add it to our zone list   */
  zonelist_count = zonelist_count + words(orec.1)
end
"execio 2 diskw smpcntl (stem footer.)" /* write the last foooters   */
"execio 0 diskw smpcntl (finis)"        /* close the file            */
return
