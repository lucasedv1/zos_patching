/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
trace Off
parse upper arg resalt dsn1
 
if length(resalt) = 0 then do
   say;say "Informe o SYSRES alternado"
   return 16
   end
if length(dsn1) = 0 then do
   say;say "Informe a biblioteca"
   return 16
   end
sistema = MVSVAR("SYMDEF", "TSID")
rescur  = MVSVAR("SYMDEF", "SYSR1")
 
res.1 = rescur
res.2 = resalt
 
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
say;say "Dataset:" dsn1
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
 
RETURN
