cd $root

import delimited cpi.csv, clear
drop seriesid period
rename label month
replace month = lower(substr(month, 6, .))
rename value cpi
save cpi.dta, replace

