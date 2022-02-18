cd $root

import delimited monthXwalk.csv, clear
replace month = lower(month)
save monthXwalk.dta, replace

import excel state-geocodes-v2014.xls, clear
drop if _n<6
foreach var in "A" "B" "D" {
	label variable `var' "`=`var'[1]'"
	rename `var' `=`var'[1]'
}
rename C state
rename Region reg
rename Division div
rename state fips
rename Name name
replace name = subinstr(name," Division", "", .)
drop in 1
destring fips reg div, replace
save stdivXwalk.dta, replace

import delimited stateXwalk.csv, clear
rename stcode state
replace state = lower(state)
save stateXwalk.dta, replace

import delimited marketXwalk.csv, clear
forval i = 1/2 {
	label variable v`i' "`=v`i'[1]'"
	rename v`i' `=v`i'[1]'
}

drop in 1
rename stcode state
replace state = lower(state)
save marketXwalk.dta, replace 
