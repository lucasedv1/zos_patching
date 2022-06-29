/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
trace Off
parse upper arg resalt
 
if length(resalt) = 0 then do
   say;say "Informe o SYSRES alternado"
   return 16
   end
sistema = MVSVAR("SYMDEF", "TSID")
rescur  = MVSVAR("SYMDEF", "SYSR1")
/*
if substr(rescur, 5, 1) == "0" then
   resalt  = substr(rescur, 1, 4) || "1" || substr(rescur, 6, 1)
else
   resalt  = substr(rescur, 1, 4) || "0" || substr(rescur, 6, 1)
*/
 
contr          = 0
tipo           = "IS NOT a TWS controller - module EQQUX006 required."
controllers.0  = 17
controllers.1  = "EBF1"
controllers.2  = "EBI2"
controllers.3  = "EBI1"
controllers.4  = "EUB3"
controllers.5  = "EUB4"
controllers.6  = "EUB5"
controllers.7  = "EUB8"
controllers.8  = "EUC1"
controllers.9  = "EUCA"
controllers.10 = "EUE4"
controllers.11 = "EUEZ"
controllers.12 = "EUHA"
controllers.13 = "EUHR"
controllers.14 = "EUMA"
controllers.15 = "EUSP"
controllers.16 = "EUSZ"
controllers.17 = "NASG"
 
do i = 1 to controllers.0
   if controllers.i == sistema then do
      contr = 1
      tipo           = "IS a TWS controller - modules EQQUX001/EQQUX006 required."
      leave
      end
end
 
say;say "System name = "sistema tipo
say;say "New SYSRES  =" resalt
 
 
"execio * diskr IEFSSNXX (stem ssn. finis)"
rc_open = rc
 
if rc_open > 0 then do
   say "*** ERROR - RC=" rc_open "open IEFSSNxx"
   exit 16
   end
 
say;say;say "IEFSSNxx listing"
say COPIES("-", 71 )
 
laco = 0
numo = 0
isop = 0
do i = 1 to ssn.0
   ini = pos('SUBSYS', ssn.i)
   if ini > 0 then do
      if laco = 0 then do
         laco = 1
         numl = 0
         end
      else do
         if numl > 0 then do
           if isop > 0 then do
              do j = 1 to numl
                 say substr(lin.j, 1, 71)
              end
              isop = 0
           end
           numl = 0
         end
         end
      end
   ini = pos('EQQINI', ssn.i)
   if ini > 0 then do
      isop = 1
      numo = numo + 1
      end
   if laco > 0 then do
      numl = numl + 1
      lin.numl = ssn.i
   end
end
say COPIES("-", 71 )
 
/*                   */
/* Check TWS exits   */
/*                   */
 
dsn1  = 'SYS1.TWSZOS.SEQQLMD0'
rc    = 0
ret   = 0
exit1 = 0
exit6 = 0
 
say;say "Dataset:"dsn1 "- Volume:"resalt
 
Address 'ISPEXEC'
"LMInit Dataid(DATAID) Dataset('"dsn1"') Volume("resalt") Enq(SHR)"
if rc <> 0 then do
   say;say "Dataset" dsn1 ": not found" rc
   return 12
   end
"LMOpen Dataid("dataid")"
if rc <> 0 then do
   "LMFree Dataid("dataid")"
   say;say "Dataset" dsn1 ": open error" rc
   return 12
   end
padrao = 'EQQUX*'
do while rc = 0
   "LMMList Dataid("dataid") Option(LIST) Member(MEM1)" ,
     "Pattern("padrao")"
   if rc == 0 then do
      say "   "mem1
      if mem1 = 'EQQUX001' then
         exit1 = 1
      else
         if mem1 = 'EQQUX006' then
            exit6 = 1
   end
end
"LMClose Dataid("dataid")"
"LMFree Dataid("dataid")"
 
if contr = 1 then
   if exit1 == 0 then do
      ret = max(ret, 12)
      say;say "   EQQUX001 module not installed."
      end
   else
      ret = max(ret, 0)
 
if exit6 == 0 then do
   say;say "   EQQUX006 module not installed."
   ret = max(ret, 12)
   end
else
   ret = max(ret, 0)
 
if ret == 0 then do
   say;say "   all TWS modules installed. System OK.";say
   end
else do
   say;say "   TWS exit missing. System not OK.";say
   end
 
/*                   */
/* List OPS levels   */
/*                   */
/* OPS removed from SYSRES volume
dsn2 = 'SYS1.OPS.README'
rc   = 0
 
say;say "Dataset:"dsn2 "- Volume:"resalt
 
"LMInit Dataid(DATAID) Dataset('"dsn2"') Volume("resalt") Enq(SHR)"
if rc <> 0 then do
   say;say "Dataset" dsn2 ": not found" rc
   return 12
   end
"LMOpen Dataid("dataid")"
if rc <> 0 then do
   "LMFree Dataid("dataid")"
   say;say "Dataset" dsn2 ": open error" rc
   return 12
   end
padrao = 'SP*'
do while rc = 0
   "LMMList Dataid("dataid") Option(LIST) Member(MEM2)" ,
     "Pattern("padrao")"
   if rc == 0 then
      say "   "mem2
   end
"LMClose Dataid("dataid")"
"LMFree Dataid("dataid")"
*/
/*                   */
/* Check PARMLIB     */
/*                   */
 
res.1 = rescur
res.2 = resalt
 
dsn1  = 'SYS1.PARMLIB'
rc    = 0
cont  = 0
 
do i = 1 to 2
   vol  = res.i
   mem1 = ''
   Address 'ISPEXEC'
   "LMInit Dataid(DIPARM) Dataset('"dsn1"') Volume("vol") Enq(SHR)"
   if rc == 0 then do
      "LMOpen Dataid("diparm")"
      if rc <> 0 then do
         "LMFree Dataid("diparm")"
         end
      else do
         padrao = '*'
         do while rc = 0
            "LMMList Dataid("diparm") Option(LIST) Member(MEM1) STATS(YES)" ,
              "Pattern("padrao")"
            if rc == 0 then do
               achou = 0
               do j = 1 to cont
                  if parms.j.1 = mem1 then do
                     achou        = 1
                     indx         = i + 1
                     if ZLUSER = ">7CHARS" then
                        parms.j.indx = ZLM4DATE ZLMTIME ZLUSER8
                     else
                        parms.j.indx = ZLM4DATE ZLMTIME ZLUSER" "
                  end
               end
               if achou = 0 then do
                  cont            = cont + 1
                  indx            = i + 1
                  parms.cont.1    = mem1
                  parms.cont.2    = "                         "
                  parms.cont.3    = "                         "
                  if ZLUSER = ">7CHARS" then
                     parms.cont.indx = ZLM4DATE ZLMTIME ZLUSER8
                  else
                     parms.cont.indx = ZLM4DATE ZLMTIME ZLUSER" "
               end
            end
         end
         "LMClose Dataid("dataid")"
         "LMFree Dataid("dataid")"
      end
      end
end
 
difs = 0
say;say "Dataset: SYS1.PARMLIB"
say;say "         current SYSRES -" res.1 "     new SYSRES -" res.2
say " Member     Date    Time  Userid      Date    Time  Userid"
say "-------- ---------- ----- -------- ---------- ----- --------"
do i = 1 to cont
   if parms.i.2 <> parms.i.3 then do
      say parms.i.1 parms.i.2 parms.i.3
      difs = difs + 1
      end
end
if difs  == 0 then
   say "No differences"
say "-------- ---------- ----- -------- ---------- ----- --------"
 
/*                   */
/* Check PROCLIB     */
/*                   */
 
dsn2  = 'SYS1.PROCLIB'
rc    = 0
cont  = 0
 
do i = 1 to 2
   vol  = res.i
   mem1 = ''
   Address 'ISPEXEC'
   "LMInit Dataid(DIPROC) Dataset('"dsn2"') Volume("vol") Enq(SHR)"
   if rc == 0 then do
      "LMOpen Dataid("diproc")"
      if rc <> 0 then do
         "LMFree Dataid("diproc")"
         end
      else do
         padrao = '*'
         do while rc = 0
            "LMMList Dataid("diproc") Option(LIST) Member(MEM1) STATS(YES)" ,
              "Pattern("padrao")"
            if rc == 0 then do
               achou = 0
               do j = 1 to cont
                  if procs.j.1 = mem1 then do
                     achou        = 1
                     indx         = i + 1
                     if ZLUSER = ">7CHARS" then
                        procs.j.indx = ZLM4DATE ZLMTIME ZLUSER8
                     else
                        procs.j.indx = ZLM4DATE ZLMTIME ZLUSER" "
                     end
               end
               if achou = 0 then do
                  cont            = cont + 1
                  indx            = i + 1
                  procs.cont.1    = mem1
                  procs.cont.2    = "                         "
                  procs.cont.3    = "                         "
                  if ZLUSER = ">7CHARS" then
                     procs.cont.indx = ZLM4DATE ZLMTIME ZLUSER8
                  else
                     procs.cont.indx = ZLM4DATE ZLMTIME ZLUSER" "
               end
            end
         end
         "LMClose Dataid("dataid")"
         "LMFree Dataid("dataid")"
      end
      end
end
 
difs = 0
say;say "Dataset: SYS1.PROCLIB"
say;say "         current SYSRES -" res.1 "     new SYSRES -" res.2
say " Member     Date    Time  Userid      Date    Time  Userid"
say "-------- ---------- ----- -------- ---------- ----- --------"
do i = 1 to cont
   if procs.i.2 <> procs.i.3 then do
      say procs.i.1  procs.i.2 procs.i.3
      difs = difs + 1
   end
end
if difs  == 0 then
   say "No differences"
say "-------- ---------- ----- -------- ---------- ----- --------"
 
RETURN ret
