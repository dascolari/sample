cd $root
use panel.dta, clear

//generate variables needed for regression
sort year, stable
gen base_cpi = cpi[1] //2010 cpi
gen rpinc_percap = (personal_income*(base_cpi/cpi))/population //real personal income per capita
gen rprices = (price)*(base_cpi/cpi) //real electricity prices
gen rnatgas = (dollar_kwh)*(base_cpi/cpi) //real nat. gas prices
gen sales_percap = sales/population //sales_percap
gen lag_sales = sales_percap[_n-1]
drop if t == 0
gen lnsales = ln(sales_percap)
gen lnprices = ln(rprices)
gen lninc = ln(rpinc_percap)
gen lnlagsales = ln(lag_sales)
labmask j, values(state)
egen panelid = group(fips sector), label
xtset panelid t
gen elasticity =.
gen t_elast =.
gen lrelasticity =.
gen t_lrelast =.

//residential end use
reg lnsales lnprices lninc heatdd cooldd lnlagsales i.j i.j#c.lnprices if sector == "res", r 
	
coefplot, drop(_cons lnsales lnprices lninc heatdd cooldd lnlagsales *.j) xline(1.9846712) msize(vsmall) ylabel( ,labsize(tiny)) coeflabels(, 	interaction(" x ")) title(Residential)
	graph export cplot_res.png, replace 
	graph save cplot_res.gph, replace
	
// 	gen pestimate =.
// 	replace pestimate = _b[lnprices] if j==1 & sector == "res"
// 	forval s = 3(1)51 {
// 		replace pestimate = _b[`s'.j#c.lnprices] + _b[lnprices] if j==`s' & sector == "res"
// 	}
// 	sort pestimate, stable
// 	order division state market pestimate
// 	drop pestimate
	
	//creating data for elasticity estimtes
	replace elasticity = _b[lnprices] if j == 1 & sector == "res"
	replace t_elast = _b[lnprices]/_se[lnprices] if j==1 & sector == "res"
	forval s = 3(1)51 {
		replace elasticity = _b[`s'.j#c.lnprices] + _b[lnprices] if j==`s' & sector == "res"
		replace t_elast = _b[`s'.j#c.lnprices]/_se[`s'.j#c.lnprices] if j==`s' & sector == "res"
	}
	
//LONG RUN: residential end use
reg lnsales lnprices lninc heatdd cooldd lnlagsales i.j i.j#c.lnprices i.j#c.lnlagsales if sector == "res", r
	
	//LONG RUN: creating data for elasticity estimtes
	replace lrelasticity = _b[lnprices]/(1-_b[lnlagsales]) if j == 1 & sector == "res"
	replace t_elast = (_b[lnprices]/(1-_b[lnlagsales]))/_se[lnlagsales] if j==1 & sector == "res"
	forval s = 3(1)51 {
		replace lrelasticity = (_b[`s'.j#c.lnprices] + _b[lnprices])/(1-(_b[`s'.j#c.lnlagsales] + _b[lnlagsales])) if j==`s' & sector == "res"
		replace t_lrelast = _b[`s'.j#c.lnlagsales]/_se[`s'.j#c.lnlagsales] if j==`s' & sector == "res"
	}

	
	
//industrial end use 
reg lnsales lnprices lninc heatdd cooldd lnlagsales i.j i.j#c.lnprices if sector == "ind", r 
coefplot, drop(_cons lnsales lnprices lninc heatdd cooldd lnlagsales *.j) xline(.11634684) msize(vsmall) ylabel( ,labsize(tiny)) title(Industrial)
graph export cplot_ind.png, replace 
graph save cplot_ind.gph, replace
	
// 	gen pestimate =.
// 	replace pestimate = _b[lnprices] if j==1 & sector == "ind"
// 	forval s = 3(1)51 {
// 		replace pestimate = _b[`s'.j#c.lnprices] + _b[lnprices] if j==`s' & sector == "ind"
// 	}
// 	sort pestimate, stable
// 	order division state market pestimate
// 	drop pestimate

	//creating data for elasticity estimtes
	replace elasticity = _b[lnprices] if j == 1 & sector == "ind"
	replace t_elast = _b[lnprices]/_se[lnprices] if j==1 & sector == "ind"
	forval s = 2(1)51 {
		replace elasticity = _b[`s'.j#c.lnprices] + _b[lnprices] if j==`s' & sector == "ind"
		replace t_elast = _b[`s'.j#c.lnprices]/_se[`s'.j#c.lnprices] if j==`s' & sector == "ind"
	}
	
//LONG RUN: industrial end use 
reg lnsales lnprices lninc heatdd cooldd lnlagsales i.j i.j#c.lnprices i.j#c.lnlagsales if sector == "ind", r 

	//LONG RUN: creating data for elasticity estimtes
	replace lrelasticity = _b[lnprices]/(1-_b[lnlagsales]) if j == 1 & sector == "ind"
	replace t_elast = (_b[lnprices]/(1-_b[lnlagsales]))/_se[lnlagsales] if j==1 & sector == "ind"
	forval s = 2(1)51 {
		replace lrelasticity = (_b[`s'.j#c.lnprices] + _b[lnprices])/(1-(_b[`s'.j#c.lnlagsales] + _b[lnlagsales])) if j==`s' & sector == "ind"
		replace t_lrelast = _b[`s'.j#c.lnlagsales]/_se[`s'.j#c.lnlagsales] if j==`s' & sector == "ind"
	}

//commercial end use 
reg lnsales lnprices lninc heatdd cooldd lnlagsales i.j i.j#c.lnprices if sector == "com", r 
coefplot, drop(_cons lnsales lnprices lninc heatdd cooldd lnlagsales *.j) xline(.10488205) msize(vsmall) ylabel( ,labsize(tiny))title(Commercial)
graph export cplot_com.png, replace 
graph save cplot_com.gph, replace 
di _b[lnprices]

	//creating data for elasticity estimtes
	replace elasticity = _b[lnprices] if j == 1 & sector == "com"
	replace t_elast = _b[lnprices]/_se[lnprices] if j==1 & sector == "com"
	forval s = 2(1)51 {
		replace elasticity = _b[`s'.j#c.lnprices] + _b[lnprices] if j==`s' & sector == "com"
		replace t_elast = _b[`s'.j#c.lnprices]/_se[`s'.j#c.lnprices] if j==`s' & sector == "com"
	}
	
//LONG RUN: commercial end use
reg lnsales lnprices lninc heatdd cooldd lnlagsales i.j i.j#c.lnprices i.j#c.lnlagsales if sector == "com", r 
	
	//LONG RUN: creating data for elasticity estimtes
	replace lrelasticity = _b[lnprices]/(1-_b[lnlagsales]) if j == 1 & sector == "com"
	replace t_elast = (_b[lnprices]/(1-_b[lnlagsales]))/_se[lnlagsales] if j==1 & sector == "com"
	forval s = 2(1)51 {
		replace lrelasticity = (_b[`s'.j#c.lnprices] + _b[lnprices])/(1-(_b[`s'.j#c.lnlagsales] + _b[lnlagsales])) if j==`s' & sector == "com"
		replace t_lrelast = _b[`s'.j#c.lnlagsales]/_se[`s'.j#c.lnlagsales] if j==`s' & sector == "com"
	}

//combining coefplots
graph combine cplot_res.gph cplot_ind.gph cplot_com.gph, rows(1) title(Price Elasticities) 
graph export cplot_combined.png, replace 



//calculating estimated marginal costs and measuring error
gen est_mc = (1/100)*price*(1+(1/abs(elasticity)))*ng_pct
gen resid_mc = rnatgas - est_mc

//LONG RUN
gen lrest_mc = (1/100)*price*(1+(1/abs(lrelasticity)))*ng_pct
gen lrresid_mc = rnatgas - lrest_mc

//making tables to show accuracy of etimated mc
//table 1: end use level mc estimates
eststo clear
estpost tabstat est_mc lrest_mc rnatgas, by(sector) stat(mean)
esttab using estmc.tex , replace cells("est_mc(fmt(%13.3fc)) lrest_mc(fmt(%13.3fc)) rnatgas(fmt(%13.3fc))") collabels("Est. MC (SR)" "Est. MC (LR)" "Natural Gas")noobs label nonumber

egen state_sect = group(state sector), label

//table 2: industry end use estimates for most significant elasticity results
eststo clear
estpost tabstat resid_mc if sector == "ind" & t_elast>1.9, by(state_sect) stat(mean sd)
esttab using indresid.tex, replace cells("mean(fmt(3)) sd") collabels("Error" "St Dev") noobs label nonumber

//table 3: residential end use estimates for most significant LR elasticity results
eststo clear
estpost tabstat lrresid_mc if sector == "res" & t_lrelast>1.9, by(state_sect) stat(mean sd)
esttab using reslrresid.tex, replace cells("mean(fmt(3)) sd") collabels("Error" "St Dev") noobs label nonumber
