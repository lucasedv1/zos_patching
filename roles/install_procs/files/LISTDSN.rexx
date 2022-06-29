/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
trace Off
 
parse upper arg resalt list
 
if length(resalt) = 0 then do
   say;say "Informe o SYSRES alternado"
   return 16
   end
 
sistema = MVSVAR("SYMDEF", "TSID")
rescur  = MVSVAR("SYMDEF", "SYSR1")
/*
if substr(rescur, 5, 1) == "A" then
   resalt  = substr(rescur, 1, 4) || "B" || substr(rescur, 6, 1)
else
   resalt  = substr(rescur, 1, 4) || "A" || substr(rescur, 6, 1)
*/
 
say;say 'System name = ' sistema
say;say 'New SYSRES  = ' resalt
say;say 'Datasets OMVS.**.V'resalt'.**'
 
ADDRESS ISPEXEC
 
'LMDINIT LISTID(LISTID1) LEVEL(OMVS.**.V'resalt'.**)'
if rc = 0 then do
   do while rc = 0
      'LMDLIST LISTID('listid1') OPTION(list) dataset(dsvar1)'
      if rc == 0 then
         if length(list) > 0 then do
            ini = pos('DATA', dsvar1)
            if ini = 0 then do
               dsn = strip(dsvar1)
               ini = pos(resalt, dsn)
               dsn = substr(dsn, 1, ini - 1)'&NEW.'substr(dsn, ini + 6)
               say '  UNMOUNT FILESYSTEM('dsn')' ,
                   right('IMMEDIATE', 46 - length(dsn))
               say '  DELETE 'dsn ,
                   right('PURGE', 59 - length(dsn))
               end
            end
         else
            say "   "dsvar1
   end
   'LMDFREE LISTID('listid1')'
   end
 
if length(list) = 0 then do
   say;say 'Datasets SMPE.*.V'resalt'.**'
 
   'LMDINIT LISTID(LISTID2) LEVEL(SMPE.*.V'resalt'.**)'
   if rc = 0 then do
      do while rc = 0
         'LMDLIST LISTID('listid2') OPTION(list) dataset(dsvar2)'
         if rc == 0 then
            say "   "dsvar2
      end
      'LMDFREE LISTID('listid2')'
      end
   end
 
say;say 'Datasets SMPE.**.V'resalt'.**'
 
'LMDINIT LISTID(LISTID3) LEVEL(SMPE.**.V'resalt'.**)'
if rc = 0 then do
   do while rc = 0
      'LMDLIST LISTID('listid3') OPTION(list) dataset(dsvar3)'
      if rc == 0 then
         if length(list) > 0 then do
            dsn = strip(dsvar3)
            ini = pos(resalt, dsn)
            dsn = substr(dsn, 1, ini - 1)'&NEW.'substr(dsn, ini + 6)
            ini = pos('.DATA', dsn)
            if ini = 0 then do
               ini = pos('.INDEX', dsn)
               if ini = 0 then do
                  ini = pos('CSI', dsn)
                  if ini = 0 then
                      say '  DELETE' dsn ,
                         right('PURGE SCRATCH', 59 - length(dsn))
                  else
                      say '  DELETE' dsn ,
                         right('CLUSTER PURGE SCRATCH', 59 - length(dsn))
                  end
               end
            end
         else do
            ini = pos('.DATA', dsvar3)
            if ini = 0 then
               dsvar3 = "   "dsvar3
            ini = pos('.INDEX', dsvar3)
            if ini = 0 then
               dsvar3 = "   "dsvar3
            say "   "dsvar3
            end
   end
   'LMDFREE LISTID('listid3')'
   end
