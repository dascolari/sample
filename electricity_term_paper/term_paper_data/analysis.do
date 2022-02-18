//to run, enter filepath:
global root "YOUR/FILEPATHE/HERE/term_paper_data"

cd "/Users/davidscolari/Dropbox/grad_school/2_Fall21/electricity/assignments/term_paper/term_paper_data"

cd $root
use panel.dta, clear

//generate variables needed for regression
sort year, stable
gen base_cpi = cpi[1] //2010 cpi

gen rpinc_percap = (personal_income*(base_cpi/cpi))/population //real personal income per capita

gen rprices = (price)*(base_cpi/cpi) //real prices
gen sales_percap = sales/population //sales_percap

gen lag_sales = sales_percap[_n-1]
drop if t == 0

gen lnsales = ln(sales_percap)
gen lnprices = ln(rprices)
gen lninc = ln(rpinc_percap)
gen lnlagsales = ln(lag_sales)

//model that estimates own price elasticities for residential electrcity generation in Iowa
reg lnsales lnprices lninc heatdd cooldd lnlagsales i.j i.j#c.lnprices if sector == "res", r 


//example: I want to run this test for each state paired with each state (51x51)
testnl _b[1.j#c.lnprices] = _b[4.j#c.lnprices]

//The below loop runs the tests I want, but i dont know how to access the values

//CAUTION, this loop takes a while to run
// forval s = 3(1)51 {
// 	forval r = 3(1)51 {
// 	testnl _b[`s'.j#c.lnprices] = _b[`r'.j#c.lnprices]
// 	}
// }
