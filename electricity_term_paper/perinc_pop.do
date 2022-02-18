cd $root
import delimited bea_perinc_pop.csv, clear

drop if _n<5|_n>185

//string cleaning to obtain valid var names
forval j = 5/90 {
	replace v`j' = subinstr(v`j', ":", "_", 1) in 1
	replace v`j' = substr(v`j', 5, .)+v`j' in 1
	replace v`j' = substr(v`j', 1, 7) in 1
}

//make firstrow varname
forval j = 1/90{
	label variable v`j' "`=v`j'[1]'"
	rename v`j' `=v`j'[1]'
}

//drop firstrow, since we now have valid varnames
drop in 1

//get 2 digit state codes from GeoFips
destring GeoFips, replace
replace GeoFips = GeoFips/1000
rename GeoFips fips

//remove stars from stnames
replace GeoName = subinstr(GeoName, " *", "", 1)
rename GeoName stname

destring LineCode, replace
label value LineCode Desciprtion

reshape long _Q, i(LineCode fips stname) j(year)

tostring year, replace
gen q = substr(year, 1, 1)
destring q, replace
replace year = substr(year, 2, .)
destring year, replace

//reshape 
replace Description = "inc" if LineCode == 1
replace Description = "pop" if LineCode == 2
replace Description = "inc_percap" if LineCode == 3
drop LineCode
reshape wide _Q, i(year q fips) j(Description, string)

rename _Qinc personal_income
drop _Qinc_percap //will make this myself
rename _Qpop population
drop if population == "(NA)"
destring personal_income, replace
destring population, replace
save perinc_pop.dta, replace
