/* rexx  __ANSIBLE_ENCODE_EBCDIC__  */
trace Off
parse upper arg svar

if length(svar) = 0 then do
   say;say "Line not provided"
   return 16
   end
retorno = MVSVAR("SYMDEF", svar)
say retorno
 
RETURN 0
