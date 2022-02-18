//change root to personal file path
global root "/Users/davidscolari/Dropbox/grad_school/2_Fall21/electricity/assignments/term_paper"

cd $root

do natgas.do
do xwalk.do
do cpi.do
do heatdd.do
do cooldd.do 
do perinc_pop.do
do rt_sales.do
do rt_prices.do
do merge.do



