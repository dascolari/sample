cd $root

//this loop imports cdds from each census division and appends them in to a single dataset
local div = 0
foreach reg in "New_England" "Middle_Atlantic" "E._N._Central" "W._N._Central" "E._S._Central" "South_Atlantic" "W._S._Central" "Mountain"  "Pacific"  {
	import delimited Cooling_Degree_Days_`reg'_Monthly.csv, clear
	drop if v2=="" | strpos(v1,"Month")!=0 | strpos(v2,"Series")!=0
	rename v1 month_year
	rename v2 cooldd
	gen month = lower(substr(month_year, 1, 3))
	gen year = substr(month_year, 5, .)
	destring year, replace
	drop month_year
	destring cooldd, replace
	local div = `div'+1 //to match census div code
	gen div = `div'
	gen division = subinstr("`reg'", "_", " ", .)
	save cooldd_`div'.dta, replace
}

use cooldd_1.dta, clear
forvalues n = 2(1)9 {
	append using cooldd_`n'.dta
}

order div* year month

save cooldd.dta, replace
