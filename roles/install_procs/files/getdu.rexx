/* rexx  __ANSIBLE_ENCODE_EBCDIC__  */
trace Off
parse upper arg duline

if length(duline) = 0 then do
   say;say "Line not provided"
   return 16
   end
select
   when substr( duline, 32, 2) == "01" then
     month = "Jan"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "02" then
     month = "Feb"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "03" then
     month = "Mar"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "04" then
     month = "Apr"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "05" then
     month = "May"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "06" then
     month = "Jun"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "07" then
     month = "Jul"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "08" then
     month = "Aug"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "09" then
     month = "Sep"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "10" then
     month = "Oct"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "11" then
     month = "Nov"substr(duline, 28, 4)
   when substr( duline, 32, 2) == "12" then
     month = "Dec"substr(duline, 28, 4)
end
info = "//   SET  GSD='Loaded "substr(duline, 58, 6)"("substr(duline, 99, 11)"/"substr(duline, 111, 2)"/"substr(duline, 114, 5)":"substr(duline, 120, 2)") CIRATS("month")'"
say info
 
RETURN 0
