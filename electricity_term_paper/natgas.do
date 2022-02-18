cd $root

import delimited U.S._Natural_Gas_Electric_Power_Price_Monthly.csv, clear
drop if _n<=5
rename v1 month
rename v2 dollar_1kft3

gen year = substr(month, 5, .)
replace month = lower(substr(month, 1, 3))
destring year dollar_1kft3, replace 
gen dollar_kwh = dollar_1kft3/(.13*1000)
save nattygas.dta, replace 
