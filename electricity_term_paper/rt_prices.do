cd $root

import delimited Average_retail_price_of_electricity.csv, clear
drop if _n<5


//take a look at what was dropped here when we do drop if =="NM"
forval j = 3/250 {
	replace v`j' = "v"+subinstr(v`j', " ", "_", .) in 1
	drop if v`j' == "NM"
}

forval j = 1/250 {
	label variable v`j' "`=v`j'[1]'"
	rename v`j' `=v`j'[1]'
}
rename vsource_key source_key
drop if _n<3

gen sector = lower(substr(source_key, 15, 3))
order sector
gen state = lower(substr(source_key, 12, 2))
order state
drop source_key
replace sector = subinstr(sector, "-al", "all", .)
replace sector = subinstr(sector, "-re", "res", .)
replace sector = subinstr(sector, "-co", "com", .)
replace sector = subinstr(sector, "-in", "ind", .)
replace sector = subinstr(sector, "-tr", "tra", .)
replace sector = subinstr(sector, "-ot", "oth", .)

drop if sector == "tra" | sector == "oth" | sector == "all" | vJan_2001 == ""
drop units description

destring v*, replace

gen index = _n
reshape long v, i(sector state index) j(myr, string)
drop index

rename v price //million kilowatthours
gen month = lower(substr(myr, 1, 3))
gen year = lower(substr(myr, 5, 4))
destring year, replace
drop myr
order state sector year month
duplicates drop state sector year month, force
save rt_price.dta, replace
