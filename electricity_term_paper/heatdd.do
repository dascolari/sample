cd $root

//this loop imports hdds from each census division and appends them in to a single dataset
local div = 0
foreach reg in "New_England" "Middle_Atlantic" "E._N._Central" "W._N._Central" "E._S._Central" "South_Atlantic" "W._S._Central" "Mountain"  "Pacific"  {
	import delimited Heating_Degree_Days_`reg'_Monthly.csv, clear
	drop if v2=="" | strpos(v1,"Month")!=0 | strpos(v2,"Series")!=0
	rename v1 month_year
	rename v2 heatdd
	gen month = lower(substr(month_year, 1, 3))
	gen year = substr(month_year, 5, .)
	destring year, replace
	destring heatdd, replace
	drop month_year
	local div = `div'+1 //to match census div code
	gen div = `div'
	gen division = subinstr("`reg'", "_", " ", .)
	save heatdd_`div'.dta, replace
}

use heatdd_1.dta, clear
forvalues n = 2(1)9 {
	append using heatdd_`n'.dta
}

order div* year month



save heatdd.dta, replace
