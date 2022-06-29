/* rexx  __ANSIBLE_ENCODE_EBCDIC__ */
trace Off
 
parse upper arg parms
 
if length(parms) = 0 then do
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
say;say 'System name ............ = ' sistema
say;say 'SYSRES em uso no sistema = ' rescur
say;say 'New SYSRES informado ... = ' parms
 
if SUBSTR(rescur, 1, 4) != SUBSTR(parms, 1, 4)  then do
   say;say "New SYSRES informado eh invalido. Comeco do VOLSER nao coincide.";say
   return 12
   end
 
if rescur = parms then do
   say;say "New SYSRES informado eh o SYSRES em uso.";say
   return 12
   end
else do
   say;say "New SYSRES difere do SYSRES em uso.";say
   return 0
   end
