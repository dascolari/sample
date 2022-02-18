cd $root

foreach year in "2001_2002" "2003_2004" "2005-2007" "2008-2009" "2010-2011" {
	import excel generation_monthly.xlsx, sheet("`year'_FINAL") firstrow case(lower) clear
	rename gen gen
	save `year'_monthlygen.dta, replace
}

forval y = 12/21 {
	import excel generation_monthly.xlsx, sheet("20`y'_Final") clear
	save 20`y'_monthlygen.dta, replace
}

import excel generation_monthly.xlsx, sheet("2021_Preliminary") clear
save 2021_monthlygen.dta, replace

forval v = 12/21 {
	use 20`v'_monthlygen.dta, clear
	drop if _n<5

	foreach var in "A" "B" "C" "D" "E" "F" {
		replace `var' = lower(subinstr(`var', " ", "", .)) in 1
		replace `var' = lower(subinstr(`var', "(", "", .)) in 1
		replace `var' = lower(subinstr(`var', ")", "", .)) in 1
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	rename gen gen
	drop in 1
	destring year month gen, replace
	save inter`v'.dta, replace
}	

use inter12.dta, clear

use 2001_2002_monthlygen.dta, clear
append using 2003_2004_monthlygen.dta 2005-2007_monthlygen.dta 2008-2009_monthlygen.dta 2010-2011_monthlygen.dta inter12.dta inter13.dta inter14.dta inter15.dta inter16.dta inter17.dta inter18.dta inter19.dta inter20.dta inter21.dta
rename typeofproducer type
rename energysource source
keep if strpos(type, "Total") != 0
drop type

replace state = lower(state)
replace source = lower(source)
gen t = gen if source == "total"
bysort year month state: egen total = sum(t)
gen pctgen = gen/total
drop t total

//stop here for all sources

keep if source == "natural gas"

rename gen ng_gen
rename pctgen ng_pct
rename month m
save ng_gen.dta, replace
