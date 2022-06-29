/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
trace Off
 
parse upper arg parms .
 
sistema = MVSVAR("SYMDEF", "TSID")
rescur  = MVSVAR("SYMDEF", "SYSR1")
resalt  = parms

maiusc  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
minusc  = 'abcdefghijklmnopqrstuvwxyz'
usuario = TRANSLATE(USERID(), minusc, maiusc)

say "Sistema ........ :" sistema
say "SYSRES em uso .. :" rescur
say "SYSRES alternado :" resalt

retrc = 0
indx  = 0
vers  = ''
 
"execio * diskr BPXPRMXX (stem bpx. finis)"
rc_open = rc
 
if rc_open == 0 then do
   say; say "BPXPRM contains" RIGHT(bpx.0, 4, '0') "lines"; say
   end
else do
   say "*** ERROR - RC=" rc_open "open BPXPRM"
   ZISPFRC = 16
   ADDRESS ISPEXEC "VPUT (ZISPFRC)" 
   exit 16
   end
 
say "BPXPRM checking routine results"
say; say "line  File System or Mount Point"
say COPIES("-", 121)
flag   = 0
nri    = 0
nrf    = 0
nrmkd  = 0
mkds.0 = 0
do i = 1 to bpx.0
  bpx.i = SUBSTR(bpx.i, 1, 71)
  if flag then do
     comenti = 2
     comentf = 70
     end
  else do
     comenti = 72
     comentf = 70
     end
  ini = pos("/*",bpx.i)
  if ini > 0 then do
     flag = 1
     comenti = ini
     end
  ini = pos("*/",bpx.i)
  if ini > 0 then do
     flag = 0
     comentf = ini
     end
  bpx.i = SUBSTR(bpx.i, 1, comenti - 1) || ,
          SUBSTR(bpx.i, comentf + 2)
  upp   = bpx.i
  UPPER upp
  sit   = 0
  ini = pos("VERSION",upp)
  if ini > 0 then
     sit = 1
  ini = pos("MKDIR",upp)
  if ini > 0 then
     sit = 2
  ini = pos("ROOT ",upp)
  if ini > 0 then
     sit = 3
  ini = pos("FILESYSTEM",upp)
  if ini > 0 then
     sit = 3
  ini = pos("MOUNTPOINT",upp)
  if ini > 0 then
     sit = 4
 
  if sit == 1 then do  /* VERSION */
     say;say RIGHT(i, 4) ||  ":" strip(bpx.i)
     Parse Var bpx.i "'"vers"'"
     ini = pos("&",vers)
     if ini > 0 then do
        Parse Var vers "&"vers"."
        vers = MVSVAR("SYMDEF", vers)
     end
     say "        " LEFT(vers, 80)
     iterate
     end
  if sit == 2 then do  /* MKDIR */
     say;say RIGHT(i, 4) ||  ":" strip(bpx.i)
     Parse Var bpx.i "'"mkd"'"
     say "        " LEFT(mkd, 80)
     nrmkd      = nrmkd  + 1
     mkds.nrmkd = mkd
     iterate
     end
  if sit == 3 then do  /* FILEYSTEM  or ROOT */
     say;say RIGHT(i, 4) ||  ":" strip(bpx.i)
     Parse Var bpx.i "('"omvsfn"')"
     ini = pos("')",bpx.i)
     j = i
     DO WHILE ini = 0
        de    = 1
        tam   = 71
        j     = j + 1
        say RIGHT(j, 4) || ":" strip(bpx.j)
        ini = pos("('",bpx.j)
        if ini > 0 then
           de = ini + 2
        ini = pos("')",bpx.j)
        if ini > 0 then
           tam = (ini - de) - 1
        omvsfn = omvsfn || SUBSTR(bpx.j, de, tam)
     end
     if omvsfn == "" then
        say "Syntax error on line" i
     else do
        fsn = omvsfn
        DO WHILE pos("$VERSION", fsn) > 0
           ini = pos("$VERSION", fsn)
           fsn = SUBSTR(fsn, 1, ini - 1) || vers || ,
                 SUBSTR(fsn, ini + 8)
           end
        DO WHILE pos("&", fsn) > 0
           ini = pos("&", fsn)
           Parse Var fsn "&"simbolico".."
           if LENGTH(simbolico) > 0 then do
              substituto = MVSVAR("SYMDEF", simbolico)
              fsn = SUBSTR(fsn, 1, ini - 1) || substituto || ,
                    SUBSTR(fsn, ini + LENGTH(simbolico) +2)
              end
           end
        ini = pos('/', fsn)
        if ini == 0 then do       
           if SYSDSN("'"fsn"'") == "OK" | SYSDSN("'"fsn"'") == "UNAVAILABLE DATASET" then
              say "        " LEFT(fsn,57,'.')"exist"
           else do
              say "        " LEFT(fsn,57,'.')"does not exist"
              retrc = 4
              end
           ini = pos(rescur, fsn)
           if ini > 0 then do
              fsna = substr(fsn, 1, ini - 1) || resalt || substr(fsn, ini + 6)
              if SYSDSN("'"fsna"'") == "OK" | SYSDSN("'"fsna"'") == "UNAVAILABLE DATASET" then
                 say "        " LEFT(fsna,57,'.')"exist"
              else do
                 say "        " LEFT(fsna,57,'.')"does not exist"
                 retrc = 4
                 end
              end
           end
        else
           say "        " LEFT('.',57,'.')"File system in memory"
     iterate
     end
  end
  if sit == 4 then do  /* MOUNTPOINT */
     say;say RIGHT(i, 4) || ":" strip(bpx.i)
     Parse Var bpx.i "('"omvsmp"')"
     ini = pos("')",bpx.i)
     j   = i
     DO WHILE ini = 0
        de    = 1
        tam   = 70
        j     = j + 1
        say RIGHT(j, 4) || ":" strip(bpx.j)
        ini = pos("(",bpx.j)
        if ini > 0 then
           de = ini + 2
        ini = pos(")",bpx.j)
        if ini > 0 then
           tam = (ini - de) - 1
        omvsmp = omvsmp || SUBSTR(bpx.j, de, tam)
     end
     mpt = omvsmp
     DO WHILE pos("$VERSION", mpt) > 0
        ini = pos("$VERSION", mpt)
        mpt = SUBSTR(mpt, 1, ini - 1) || vers || ,
              SUBSTR(mpt, ini + 8)
     end
     DO WHILE pos("&", mpt) > 0
        ini = pos("&", mpt)
        Parse Var mpt "&"simbolico"."
        if LENGTH(simbolico) > 0 then do
           substituto = MVSVAR("SYMDEF", simbolico)
           mpt = SUBSTR(mpt, 1, ini - 1) || substituto || ,
                 SUBSTR(mpt, ini + LENGTH(simbolico) +2)
           end
     end
     shcmd = "/bin/test -d" mpt
     "BPXBATSL PGM " shcmd
     if RC == 0 then
        say "        " LEFT(mpt,57,'.')"exist now"
     else do
        say "        " LEFT(mpt,57,'.')"does not exist now"
        retrc = 4
        acho = 0
        do j = 1 to nrmkd
           ini = pos(mkds.j, mpt)
           if ini > 0 then do
              acho = 1
              indx = j
              end
        end
        if acho == 1 then
           say "         " LEFT(mkds.indx,47,'.')"it will create by MKDIR"
        end
 
     upp = mpt
     UPPER upp
     ini = pos(vers,upp)
     if ini > 0 then
        iterate
     ini = pos("DB2",upp)
     if ini > 0 then
        iterate
     ini = pos("DEV",upp)
     if ini > 0 then
        iterate
     ini = pos("ETC",upp)
     if ini > 0 then
        iterate
     ini = pos("TMP",upp)
     if ini > 0 then
        iterate
     ini = pos("VAR",upp)
     if ini > 0 then
        iterate
     ini = pos("SERVICE",upp)
     if ini > 0 then
        iterate
     ini = pos("_PRDS",upp)
     if ini > 0 then
        iterate
     ini = pos("GLOBAL",upp)
     if ini > 0 then
        iterate
     ini = pos("ALTROOT",upp)
     if ini > 0 then
        iterate
     ini = pos("REQUESTS",upp)
     if ini > 0 then
        iterate
     ini = pos("('/&SYSNAME.')",bpx.i)
     if ini > 0 then
        iterate
     mpta = '/tmp/ansible/'usuario'/asr'mpt
     shcmd = "/bin/test -d" mpta
     "BPXBATSL PGM " shcmd
     if rc == 0 then
        say "        " LEFT(mpt,57,'.')"exist on new root"
     else do
        say "        " LEFT(mpt,57,'.')"does not exist on new root"
        retrc = 4
        acho = 0
        do j = 1 to nrmkd
           ini = pos(mkds.j, mpta)
           if ini > 0 then do
              acho = 1
              indx = j
              end
        end
        if acho == 1 then
           say "         " LEFT(mkds.indx,47,'.')"it will create by MKDIR"
        end
     end
end
say COPIES("-", 121)
DROP bpx.
 
ZISPFRC = retrc
ADDRESS ISPEXEC "VPUT (ZISPFRC)" 
exit retrc