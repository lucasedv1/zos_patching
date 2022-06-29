/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
trace Off
 
parse upper arg parms
 
sistema = MVSVAR("SYMDEF", "TSID")
rescur  = MVSVAR("SYMDEF", "SYSR1")
resalt  = parms
thissys = MVSVAR("SYMDEF", "SYSNAME")
 
say "Sistema ........ :" sistema
say "SYSRES em uso .. :" rescur
say "SYSRES alternado :" resalt
 
indx = 0
vers = ''
 
"execio * diskr BPXPRMXX (stem bpx. finis)"
rc_open = rc
 
if rc_open != 0 then do
   say "*** ERROR - RC=" rc_open "open BPXPRM"
   exit 16
end
 
"execio * diskr IEASYMXX (stem sym. finis)"
rc_open = rc
 
if rc_open != 0 then do
   say "*** ERROR - RC=" rc_open "open IEASYM"
   exit 16
end
 
"execio * diskr TREE (stem tree. finis)"
rc_open = rc
 
if rc_open != 0 then do
   say "*** ERROR - RC=" rc_open "open TREE"
   exit 16
end
 
nrsys = 0
do i = 1 to sym.0
   ini = pos("SYSNAME",sym.i)
   if ini > 0 then do
      Parse Var sym.i "("sysn")"
      acho = 0
      do j = 1 to nrsys
         if sysn = sysnames.j then
            acho = 1
      end
      if acho = 0 then do
         nrsys = nrsys + 1
         sysnames.nrsys = sysn
      end
   end
end
sysnames.0 = nrsys
 
nrpaths = 0
do i = 1 to tree.0 by 2
   nrpaths = nrpaths + 1
   mp = strip(tree.i)
   j = i + 1
   fs = strip(tree.j)
   fstable.nrpaths = mp fs
end
fstable.0 = nrpaths
 
say;say "BPXPRMxx checking routine results"
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
   if ini > 0 then do
      sit = 3
      tfs = 0
   end
   ini = pos("TFS",upp)
   if ini > 0 then
      tfs = 1
   ini = pos("MOUNTPOINT",upp)
   if ini > 0 then
      sit = 4
 
   if sit == 1 then do  /* VERSION */
      say;say strip(bpx.i)
      Parse Var bpx.i "'"vers"'"
      ini = pos("&",vers)
      if ini > 0 then do
         Parse Var vers "&"vers"."
         vers = MVSVAR("SYMDEF", vers)
      end
      say "   -" vers
      if vers == rescur then do
         versa = resalt
         say "   -" versa
         end
      else
         versa = vers
      iterate
   end
   if sit == 2 then do  /* MKDIR */
      say;say strip(bpx.i)
      Parse Var bpx.i "'"mkd"'"
      say "   -" mkd
      nrmkd      = nrmkd  + 1
      mkds.nrmkd = mkd
      iterate
   end
   if sit == 3 then do  /* FILEYSTEM  or ROOT */
      say;say strip(bpx.i)
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
         say "   -Syntax error on line" i
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
      end
      iterate
   end
   if sit == 4 then do  /* MOUNTPOINT */
/* first, check file system related */
      acho = 0
      do j = 1 to fstable.0
         ini = pos(fsn, fstable.j)
         if ini > 0 then do
            acho = 1
            indx = j
         end
      end
      if acho == 1 then
         say "   -" fsn"-ok"
      else do
         if SYSDSN("'"fsn"'") == "OK" | SYSDSN("'"fsn"'") == "UNAVAILABLE DATASET" then
            say "   -" fsn"-ok"
         else
            say "   -" fsn"-nok"
      end
      ini = pos(rescur, fsn)
      if ini > 0 then do
         fsna = substr(fsn, 1, ini - 1) || resalt || substr(fsn, ini + 6)
         if SYSDSN("'"fsna"'") == "OK" | SYSDSN("'"fsna"'") == "UNAVAILABLE DATASET" then
            say "   -" fsna"-ok"
         else
            say "   -" fsn"-nok"
      end
      if tfs == 0 then do
         ini = pos('SYSNAME', bpx.i)
         if ini > 0 then do
            do j = 1 to sysnames.0
               if sysnames.j <> thissys then do
                  ini = pos(thissys, fsn)
                  fsna = substr(fsn, 1, ini - 1) || sysnames.j || substr(fsn, ini + LENGTH(thissys))
                  if SYSDSN("'"fsna"'") == "OK" | SYSDSN("'"fsna"'") == "UNAVAILABLE DATASET" then
                     say "   -" fsna"-ok"
                  else
                     say "   -" fsna"-nok"
               end
            end
         end
      end
/* now, check mountpoint itself */
      say;say strip(bpx.i)
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
      acho = 0
      do j = 1 to fstable.0
         ini = pos(mpt, fstable.j)
           if ini > 0 then do
              acho = 1
              indx = j
           end
      end
      if acho == 1 then
         say "   -" mpt"-ok"
      else do
         acho = 0
         do j = 1 to nrmkd
            ini = pos(mkds.j, mpt)
            if ini > 0 then do
               acho = 1
               indx = j
            end
         end
         if acho == 1 then
            say "   -" mpt"-ok. It will create by MKDIR" mkds.indx
         else
            say "   -" mpt"-nok"
      end
      ini = pos('SYSNAME', bpx.i)
      if ini > 0 then do
         do j = 1 to sysnames.0
            if sysnames.j <> thissys then do
               ini = pos(thissys, mpt)
               mpta = substr(mpt, 1, ini - 1) || sysnames.j || substr(mpt, ini + LENGTH(thissys))
               shcmd = "/bin/test -d" mpta
               "BPXBATSL PGM " shcmd
               if rc == 0 then
                  say "   -" mpta"-ok"
               else
                  say "   -" mpta"-nok"
            end
         end
      end
 
      ini = pos(rescur, fsn)
      if ini = 0 then
         iterate
 
      upp = mpt
      UPPER upp
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
 
      mpta = omvsmp
      DO WHILE pos("$VERSION", mpta) > 0
         ini = pos("$VERSION", mpta)
         mpta = SUBSTR(mpta, 1, ini - 1) || versa || ,
                SUBSTR(mpta, ini + 8)
      end
      DO WHILE pos("&", mpta) > 0
         ini = pos("&", mpta)
         Parse Var mpta "&"simbolico"."
         if LENGTH(simbolico) > 0 then do
            substituto = MVSVAR("SYMDEF", simbolico)
            mpta = SUBSTR(mpta, 1, ini - 1) || substituto || ,
                   SUBSTR(mpta, ini + LENGTH(simbolico) +2)
         end
      end
      shcmd = "/bin/test -d /_SERVICE"mpta
      "BPXBATSL PGM " shcmd
      if rc == 0 then
         say "   -" mpta"-ok"
      else do
         acho = 0
         do j = 1 to nrmkd
            ini = pos(mkds.j, mpta)
            if ini > 0 then do
               acho = 1
               indx = j
            end
         end
         if acho == 1 then
            say "   -" mpta"-ok. It will create by MKDIR" mkds.indx
         else
            say "   -" mpta"-nok"
      end
   end
end
say COPIES("-", 121)
DROP bpx.
 
exit
