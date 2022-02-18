cd $root

use rt_price.dta, clear

merge 1:1 state sector year month using rt_sales.dta
drop _merge
merge m:1 state using stateXwalk.dta
drop if _merge == 1
drop _merge
merge m:m fips using stdivXwalk.dta, keepusing(div)
drop if _merge == 2
drop _merge

merge m:1 div year month using heatdd.dta
drop if _merge == 2
drop _merge 
merge m:1 div year month using cooldd.dta
drop if _merge == 2
drop _merge

merge m:1 month using monthXwalk.dta
drop _merge 

gen q = 1 if m == 1 | m == 2 | m == 3
replace q = 2 if m == 4 | m == 5 | m == 6
replace q = 3 if m == 7 | m == 8 | m == 9
replace q = 4 if m == 10 | m == 11 | m == 12
sort year q m

merge m:m year q fips using perinc_pop.dta
drop if _merge ==1 | _merge == 2
drop _merge

replace personal_income=personal_income/3
merge m:1 year month using cpi.dta
drop if _merge == 2
drop _merge

merge m:1 state using marketXwalk.dta
drop _merge

merge m:1 month year using nattygas.dta
drop if _merge == 2
drop _merge

merge m:1 m year state using ng_gen.dta, keepusing(ng*)
drop if year <2010
drop if state == "us-total"
drop if _merge == 2
replace ng_gen = 0 if _merge == 1
replace ng_pct = 0 if _merge == 1
drop _merge 

order div* market st* fips year q m month sector sales price
sort sector fips year m

gen t = 0
gen first = 0
foreach sec in "com" "ind" "res" {
	forval s = 1(1)56 {
			replace first = _n if sector == "`sec'" & fips == `s' & year == 2010 & m == 1
			replace t = 1 if first[_n-1] != 0 & first[_n-1] !=.
			
	}
}

forval i = 0(1)137 {
				replace t = t[_n-1] + 1 if  t == 0 & first == 0 
			}
drop first

save panel.dta, replace
