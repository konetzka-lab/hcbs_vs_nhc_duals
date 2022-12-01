**IV analyses 

capture log close
clear all
set more off
set scheme s1color

local data05 *
local data12 *
local data *
local logpath *
local ver *
local yearlist 05 12

net set ado *
adopath ++ *
sysdir set PLUS *

 
use `data'\hcbs_`ver', replace

 
********************************************************************************
********************************************************************************


*Table 2. Marginal Effects (ME) of HCBS Use on Hospitalizations 
*Figure 1. Marginal Effects of HCBS Use on Hospitalizations by Race and Dementia
local predictor iv_cnty_young
local titlelist figure1
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
local outcome : word `n3' of `outcomelist'
local exclusion : word `n3' of `exclusionlist'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'
forvalues n=1/5{
local r=`n'
preserve
if `n'==1{
}
else if `n'==2{
keep if race_cat==0
}
else if `n'==3{
keep if race_cat==1
}
else if `n'==4{
keep if ccw_both_alz_dem==0
}
else if `n'==5{
keep if ccw_both_alz_dem==1
}

keep if `exclusion'==0


*without IV		
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
mat mat_`word1'`r'=r(table)
mat mat_`word1'`r'=mat_`word1'`r'[1,2] \ mat_`word1'`r'[4,2] \ mat_`word1'`r'[5,2] \ mat_`word1'`r'[6,2]
if `n'==1{
mat mat1=mat_`word1'`r'
}
else{
mat mat1=mat1,mat_`word1'`r'
}
mat list mat1
margins hcbs	
mat `word1'_`r'=r(table)*100
mat list `word1'_`r' 

mat  `word1'`r'=`word1'_`r'[1,1], `word1'_`r'[1,2] 
mat list  `word1'`r'	
margins, dydx(hcbs)
clear	
svmat  `word1'`r', names(col)
save `data'\dt_`outcome'_`title'_`word1'`r'.dta, replace
restore	

*with IV
preserve
if `n'==1{
}
else if `n'==2{
keep if race_cat==0
}
else if `n'==3{
keep if race_cat==1
}
else if `n'==4{
keep if ccw_both_alz_dem==0
}
else if `n'==5{
keep if ccw_both_alz_dem==1
}
keep if `exclusion'==0
logit hcbs `predictor' i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
mat iv_`word2'`r'=r(table)
mat iv_`word2'`r'=iv_`word2'`r'[1,1] \ iv_`word2'`r'[4,1] \ iv_`word2'`r'[5,1] \ iv_`word2'`r'[6,1]			 

if `n'==1{
mat mat2=iv_`word2'`r'
}
else{
mat mat2=mat2,iv_`word2'`r'
}		 
predict re, residuals 
sum re
test (`predictor'=0)
mat mat_chi=r(chi2)

if `n'==1{
mat mat3=mat_chi
}
else{
mat mat3=mat3,mat_chi
}

logit `outcome' i.hcbs  re i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
	 
mat mat_`word2'`r'=r(table)
mat mat_`word2'`r'=mat_`word2'`r'[1,2] \ mat_`word2'`r'[4,2] \ mat_`word2'`r'[5,2] \ mat_`word2'`r'[6,2]
mat mat1=mat1,mat_`word2'`r'
margins hcbs
mat `word2'1`r'=r(table)*100
mat list `word2'1`r' 
mat  `word2'`r'=`word2'1`r'[1,1], `word2'1`r'[1,2] 
mat list  `word2'`r'
margins, dydx(hcbs)
drop re
clear
svmat  `word2'`r', names(col)
save `data'\dt_`outcome'_`title'_`word2'`r'.dta, replace
restore	
}

mat mat1`outcome'_`title'=mat1'
mat mat2`outcome'_`title'=mat2'
mat mat3`outcome'_`title'=mat3'
mat mat4`outcome'_`title'=mat2', mat3'
}
}


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'
forvalues n1=1/3{
preserve
clear
svmat mat`n1'`outcome'_`title', names(col) 
save `data'\mat`n1'`outcome'_`title'.dta, replace
restore
}
}
}


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
	   		   
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Model")
putdocx save `logpath'\main_`ver'.docx, replace		   
**Graph
preserve
clear
use `data'\dt_hosp_`title'_iv1.dta
append using `data'\dt_hosp_`title'_iv2.dta
append using `data'\dt_hosp_`title'_iv3.dta
append using `data'\dt_hosp_`title'_iv4.dta
append using `data'\dt_hosp_`title'_iv5.dta
append using `data'\dt_pqi_`title'_iv1.dta
append using `data'\dt_pqi_`title'_iv2.dta
append using `data'\dt_pqi_`title'_iv3.dta
append using `data'\dt_pqi_`title'_iv4.dta
append using `data'\dt_pqi_`title'_iv5.dta
mkmat c1 c2, matrix(iv)
mat colnames iv = hcbs0 hcbs1
mat group =     (1\2\3\4\5\1\2\3\4\5)
mat colnames group = group
mat list group
mat full=group, iv
mat list full
restore

mat outcome=(1\1\1\1\1\2\2\2\2\2)
mat colnames outcome=outcome
mat full=full,outcome
preserve
clear
svmat full, names(col)
label def group 1 "Overall" 2 "White" 3 "Black" 4 "No Dementia" 5 "Dementia"
la val group group
label def outcome 1 "Any Hospitalization" 2 "PQI Hospitalization"
la val outcome outcome
save `data'\dt_overall_`title'_iv.dta, replace
use `data'\dt_overall_`title'_iv.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20) xsize(4.5) ysize(2.5) ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("gs11")) bar(2, color("gs3")) ///
 over(group, relabel(1 "Overall" 2 "White" 3 "Black" 4 "No Dementia" 5 "Dementia") label(labsize(vsmall))) ///
 over(outcome, label(labsize(small)))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Percentage (%)", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_overall_`title'.png, width(1350) height(750) replace	
restore	 
}

/*
*linear 

ivreghdfe hosp i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year  (hcbs=iv_cnty_young) , absorb(st_cnty_num) cluster(st_cnty_num) first
*/

*Figure 2: Instrumental Variables Estimates of Marginal Effects of HCBS Use on Hospitalizations by HCBS Spending Quartile
local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data

gen expend_hcbs_cpiRR=expend_hcbs*440.3/336.7 if year==2005
replace expend_hcbs_cpiRR=expend_hcbs if year==2012
egen p25 = pctile(expend_hcbs_cpiRR) if hcbs==1, p(25)
egen p50 = pctile(expend_hcbs_cpiRR) if hcbs==1, p(50)
egen p75 = pctile(expend_hcbs_cpiRR) if hcbs==1, p(75)
gen expend_hcbs_catRR=0 if expend_hcbs_cpiRR<p25 & hcbs==1
replace expend_hcbs_catRR=1 if expend_hcbs_cpiRR<p50 & expend_hcbs_catRR==. & hcbs==1
replace expend_hcbs_catRR=2 if expend_hcbs_cpiRR<p75 & expend_hcbs_catRR==. & hcbs==1
replace expend_hcbs_catRR=3 if expend_hcbs_catRR==. & hcbs==1


local varlist age_cat white_ind female_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  personal_care target_case home_health rehabilitation ///
			  private_duty_nursing adult_day_care residential_care ///
			  transportation hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  expend_hcbs hosp
			 
local group expend_hcbs_cat
preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
gen flag=1
sum expend_hcbs_cat
local a1=r(min)
local a2=r(max)
local r=1

mat mat`r'=r(N)
mat mat=mat`r'
mat matm=.
forvalues n1=`a1'/`a2'{
local r=`r'+1
sum flag if `group'==`n1'
mat mat`r'=r(N)
mat mat=mat, mat`r'
mat matm=matm, .
}

local n_2 : word count `varlist'
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1&`c2'<10{
mat mat = mat \ matm
forvalue n1=`c1'/`c2'{
sum flag if `var'==`n1'
local r=1
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat1
forvalues n3=`a1'/`a2'{
local r=`r'+1
sum flag if `var'==`n1' & expend_hcbs_cat==`n3'
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat_full1, mat`r'
}
mat mat = mat \ mat_full1
}
}
else if `c2'==1 {
sum flag if `var'==1
local r=1
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat1
forvalues n3=`a1'/`a2'{
local r=`r'+1
sum flag if `var'==1 & expend_hcbs_cat==`n3'
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat_full1, mat`r'
}
mat mat = mat \ mat_full1
}

else if `c2'>10{
local r=1
sum `var' 
mat mat1=r(mean)
mat mat_full1=mat1

forvalues n3=`a1'/`a2'{
local r=`r'+1
sum `var' if expend_hcbs_cat==`n3' 
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}

}
mat mat_full = mat
restore


mat list mat_full
frmttable using `logpath'/table1_hcbs_exp4RR.rtf, statmat(mat_full) sdec(0,0,0 \ 1,1,1) ///
rtitles("N" \ ///
"Age (%)" \ ///
"     65-69" \ ///
"     70-74" \ ///
"     75-79" \ ///
"     80-84" \ ///
"     85-89" \ ///
"     90+" \ ///
"Race - White (%)" \ ///
"Gender - Female (%)" \ ///
"Eligibility (%)" \ ///
"     Aged" \ ///
"     Disabled" \ ///
"     Others" \ ///
"Dementia (%)" \ ///
"IDD (%)" \ ///
"# of Chronic Conditions" \ ///
"     0-1" \ ///
"     2-3" \ ///
"     4-5" \ ///
"     6-7" \ ///
"     8-9" \ ///
"     10+" \ ///
"Personal Care (%)" \ ///
"Targeted Case Management (%)" \ ///
"Home Health (%)"  \ ///
"Rehabilitation (%)" \ ///
"Private Duty Nursing (%)" \ ///
"Adult Day Care (%)" \ ///
"Residential (%)" \ ///
"Transportation (%)" \ ///
"Hospice (%)" \ ///
"Other/Unspecified (%)" \ ///
"DME (%)" \ ///
"HCBS Exp ($)" \ ///
"Hosp %")  ///
ctitles("","Overall","Q1", "Q2","Q3", "Q4") ///
colwidth(22 3 3 3 3 3) ///
note() ///
replace
wordconvert "`logpath'/table1_hcbs_exp4RR.rtf" "`logpath'/table1_hcbs_exp4RR.docx", replace
	
	

local predictor iv_cnty_young
local titlelist figure2
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'


log using `logpath'\model_expend_RR2.txt, text replace
forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
local outcome : word `n3' of `outcomelist'
local exclusion : word `n3' of `exclusionlist'
forvalues n2=2/2{
local outcome : word `n2' of `outcomelist'
forvalues n=1/4{
local r=`n'
preserve
if `n'==1{
keep if expend_hcbs_catRR==0|hcbs==0
}
else if `n'==2{
keep if expend_hcbs_catRR==1|hcbs==0
}
else if `n'==3{
keep if expend_hcbs_catRR==2|hcbs==0
}
else if `n'==4{
keep if expend_hcbs_catRR==3|hcbs==0
}

keep if `exclusion'==0


*without IV		

logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
		 

mat mat_`word1'`r'=r(table)
mat mat_`word1'`r'=mat_`word1'`r'[1,2] \ mat_`word1'`r'[4,2] \ mat_`word1'`r'[5,2] \ mat_`word1'`r'[6,2]
if `n'==1{
mat mat1=mat_`word1'`r'
}
else{
mat mat1=mat1,mat_`word1'`r'
}
mat list mat1
margins hcbs	
mat `word1'_`r'=r(table)*100
mat list `word1'_`r' 

mat  `word1'`r'=`word1'_`r'[1,1], `word1'_`r'[1,2] 
mat list  `word1'`r'	
margins, dydx(hcbs)
clear	
svmat  `word1'`r', names(col)
save `data'\dt_`outcome'_`title'_`word1'`r'.dta, replace
restore	


*with IV
preserve
if `n'==1{
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==2{
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==3{
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==4{
keep if expend_hcbs_cat==3|hcbs==0
}

keep if `exclusion'==0
logit hcbs `predictor' i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
	 
mat iv_`word2'`r'=r(table)
mat iv_`word2'`r'=iv_`word2'`r'[1,1] \ iv_`word2'`r'[4,1] \ iv_`word2'`r'[5,1] \ iv_`word2'`r'[6,1]			 

if `n'==1{
mat mat2=iv_`word2'`r'
}
else{
mat mat2=mat2,iv_`word2'`r'
}		 
predict re, residuals 
sum re
test (`predictor'=0)
mat mat_chi=r(chi2)

if `n'==1{
mat mat3=mat_chi
}
else{
mat mat3=mat3,mat_chi
}

logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster' re, robust `cluster2'
	 
mat mat_`word2'`r'=r(table)
mat mat_`word2'`r'=mat_`word2'`r'[1,2] \ mat_`word2'`r'[4,2] \ mat_`word2'`r'[5,2] \ mat_`word2'`r'[6,2]
mat mat1=mat1,mat_`word2'`r'
margins hcbs
mat `word2'1`r'=r(table)*100
mat list `word2'1`r' 
mat  `word2'`r'=`word2'1`r'[1,1], `word2'1`r'[1,2] 
mat list  `word2'`r'
margins, dydx(hcbs)
drop re
clear
svmat  `word2'`r', names(col)
save `data'\dt_`outcome'_`title'_`word2'`r'.dta, replace
restore	
}

mat mat1`outcome'_`title'=mat1'
mat mat2`outcome'_`title'=mat2'
mat mat3`outcome'_`title'=mat3'
mat mat4`outcome'_`title'=mat2', mat3'
}
}


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'
forvalues n1=1/3{
preserve
clear
svmat mat`n1'`outcome'_`title', names(col) 
save `data'\mat`n1'`outcome'_`title'.dta, replace
restore
}
}
}


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
	   		   
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Model")
putdocx save `logpath'\main_`ver'.docx, replace		   


**Graph
preserve
clear
use `data'\dt_hosp_`title'_iv1.dta
append using `data'\dt_hosp_`title'_iv2.dta
append using `data'\dt_hosp_`title'_iv3.dta
append using `data'\dt_hosp_`title'_iv4.dta
append using `data'\dt_pqi_`title'_iv1.dta
append using `data'\dt_pqi_`title'_iv2.dta
append using `data'\dt_pqi_`title'_iv3.dta
append using `data'\dt_pqi_`title'_iv4.dta
mkmat c1 c2, matrix(iv)
mat colnames iv = hcbs0 hcbs1
mat group =     (1\2\3\4\1\2\3\4)
mat colnames group = group
mat list group
mat full=group, iv
mat list full
restore

mat outcome=(1\1\1\1\2\2\2\2)
mat colnames outcome=outcome
mat full=full,outcome
preserve
clear
svmat full, names(col)
label def group 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4"
la val group group
label def outcome 1 "Any Hospitalization" 2 "PQI Hospitalization"
la val outcome outcome
save `data'\dt_overall_`title'_iv.dta, replace
use `data'\dt_overall_`title'_iv.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20)  ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("gs11")) bar(2, color("gs3")) ///
 over(group, relabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4") label(labsize(vsmall))) ///
 over(outcome, label(labsize(small)))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Percentage (%)", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_overall_`title'.png, replace	
restore	 

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Analysis"), linebreak
putdocx image `logpath'\result_overall_`title'.png, width(6.6) height(3.5)
putdocx save `logpath'\main_`ver'.docx, append
}


********************************************************************************


**Main Table 3. Robustness Checks: Instrumental Variables Estimates of Marginal Effects of HCBS Use on Hospitalizations under Alternative Samples/Assumptions
*Row 1 - Base model for comparison

preserve
keep if exclusion==0
logit hcbs iv_cnty_young i.age_cat i.female_ind i.month_alive i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)			 
predict re, residuals 
sum re
test (iv_cnty_young=0)
logit hosp i.hcbs re i.age_cat i.female_ind i.race_5cat i.month_alive c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
logit pqi i.hcbs re i.age_cat i.female_ind i.race_5cat i.month_alive c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
restore	 


*Row2 - 2005 and 2012 results using only states available in 2014
preserve
keep if exclusion==0
keep if st=="CA"|st=="GA"|st=="IA"|st=="LA"|st=="MI"|st=="MN"|st=="MO"|st=="MS"| ///
		st=="PA"|st=="UT"|st=="VT"|st=="WV"|st=="WY"
logit hosp i.hcbs i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
logit pqi i.hcbs i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
restore

preserve
keep if exclusion==0
keep if st=="CA"|st=="GA"|st=="IA"|st=="LA"|st=="MI"|st=="MN"|st=="MO"|st=="MS"| ///
		st=="PA"|st=="UT"|st=="VT"|st=="WV"|st=="WY"
logit hcbs iv_cnty_young i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)			 
			 
predict re, residuals 
sum re
test (iv_cnty_young=0)
logit hosp i.hcbs re i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
logit pqi i.hcbs re i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
restore

*Row 3 - 2005 and 2014 results for subset of states1
**hcbs_analysis_step2_table3_row3.do

*Row 4 - Used long-term care the entire year
**hcbs_analysis_step2_table3_row4.do


*Row 5 - Alternative IV
**hcbs_analysis_step2_table3_row5.do




**Appendix table 8. Estimates of Marginal Effects, People who Started Their First Service in January.

preserve
keep if exclusion_jan==0
keep if svc_first_month==1
logit hosp i.hcbs i.age_cat i.female_ind i.race_5cat ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
logit pqi i.hcbs i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
restore


preserve
keep if svc_first_month==1
logit hcbs iv_cnty_young i.age_cat i.female_ind i.race_5cat ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)			 
			 
predict re, residuals 
sum re
test (iv_cnty_young=0)
logit hosp i.hcbs re i.age_cat i.female_ind i.race_5cat ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
logit pqi i.hcbs re i.age_cat i.female_ind i.race_5cat ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 
restore






/*
*Boot

capture program drop twosri
program twosri, rclass 
capture drop re
logit hcbs iv_cnty_young i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
matrix b1=e(b)
		 
			 
predict re, residuals 
sum re
test (iv_cnty_young=0)
logit hosp i.hcbs re i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
matrix b2=e(b)

margins hcbs
matrix b3=r(table)'

margins, dydx(hcbs)
mat mat4_1=r(table)'
margins, dydx(age_cat)
mat mat4_2=r(table)'
margins, dydx(female_ind)
mat mat4_3=r(table)'
margins, dydx(race_5cat)
mat mat4_4=r(table)'
margins, dydx(svc_first_month)
mat mat4_5=r(table)'
margins, dydx(elig_ind) 
mat mat4_6=r(table)'
margins, dydx(ccw_both_alz_dem)
mat mat4_7=r(table)'
margins, dydx(cc_anemia_ind) 
mat mat4_8=r(table)'
margins, dydx(cc_asthma_ind) 
mat mat4_9=r(table)'
margins, dydx(cc_atrial_fib_ind) 
mat mat4_10=r(table)'
margins, dydx(cc_cataract_ind) 
mat mat4_11=r(table)'
margins, dydx(cc_chronickidney_ind)
mat mat4_12=r(table)'
margins, dydx(cc_chf_ind)
mat mat4_13=r(table)'
margins, dydx(cc_copd_ind) 
mat mat4_14=r(table)'
margins, dydx(cc_depression_ind) 
mat mat4_15=r(table)'
margins, dydx(cc_diabetes_ind) 
mat mat4_16=r(table)'
margins, dydx(cc_glaucoma_ind)
mat mat4_17=r(table)'
margins, dydx(cc_hyperl_ind) 
mat mat4_18=r(table)'
margins, dydx(cc_hyperp_ind) 
mat mat4_19=r(table)'
margins, dydx(cc_hypert_ind) 
mat mat4_20=r(table)'
margins, dydx(cc_hypoth_ind)
mat mat4_21=r(table)'
margins, dydx(cc_ischemicheart_ind) 
mat mat4_22=r(table)'
margins, dydx(cc_osteoporosis_ind) 
mat mat4_23=r(table)'
margins, dydx(cc_ra_oa_ind)
mat mat4_24=r(table)'
margins, dydx(cc_stroke_tia_ind)
mat mat4_25=r(table)'
margins, dydx(cc_other)
mat mat4_26=r(table)'
	

logit hosp i.hcbs i.age_cat i.female_ind i.race_5cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
matrix b5=e(b)
margins hcbs
matrix b6=r(table)'

	 
margins, dydx(hcbs)
mat mat7_1=r(table)'
margins, dydx(age_cat)
mat mat7_2=r(table)'
margins, dydx(female_ind)
mat mat7_3=r(table)'
margins, dydx(race_5cat)
mat mat7_4=r(table)'
margins, dydx(svc_first_month)
mat mat7_5=r(table)'
margins, dydx(elig_ind) 
mat mat7_6=r(table)'
margins, dydx(ccw_both_alz_dem)
mat mat7_7=r(table)'
margins, dydx(cc_anemia_ind) 
mat mat7_8=r(table)'
margins, dydx(cc_asthma_ind) 
mat mat7_9=r(table)'
margins, dydx(cc_atrial_fib_ind) 
mat mat7_10=r(table)'
margins, dydx(cc_cataract_ind) 
mat mat7_11=r(table)'
margins, dydx(cc_chronickidney_ind)
mat mat7_12=r(table)'
margins, dydx(cc_chf_ind)
mat mat7_13=r(table)'
margins, dydx(cc_copd_ind) 
mat mat7_14=r(table)'
margins, dydx(cc_depression_ind) 
mat mat7_15=r(table)'
margins, dydx(cc_diabetes_ind) 
mat mat7_16=r(table)'
margins, dydx(cc_glaucoma_ind)
mat mat7_17=r(table)'
margins, dydx(cc_hyperl_ind) 
mat mat7_18=r(table)'
margins, dydx(cc_hyperp_ind) 
mat mat7_19=r(table)'
margins, dydx(cc_hypert_ind) 
mat mat7_20=r(table)'
margins, dydx(cc_hypoth_ind)
mat mat7_21=r(table)'
margins, dydx(cc_ischemicheart_ind) 
mat mat7_22=r(table)'
margins, dydx(cc_osteoporosis_ind) 
mat mat7_23=r(table)'
margins, dydx(cc_ra_oa_ind)
mat mat7_24=r(table)'
margins, dydx(cc_stroke_tia_ind)
mat mat7_25=r(table)'
margins, dydx(cc_other)
mat mat7_26=r(table)'



forvalues a=1/61{
return scalar a1`a'=b1[1,`a']
return scalar a2`a'=b2[1,`a']
return scalar a3`a'=b5[1,`a']
}

return scalar a4 = b3[1,1]
return scalar a5 = b3[2,1]


return scalar a6_1 = mat4_1[2,1]
return scalar a6_2a = mat4_2[2,1]
return scalar a6_2b = mat4_2[3,1]
return scalar a6_2c = mat4_2[4,1]
return scalar a6_2d = mat4_2[5,1]
return scalar a6_2e = mat4_2[6,1]
return scalar a6_3 = mat4_3[2,1]
return scalar a6_4a = mat4_4[2,1]
return scalar a6_4b = mat4_4[3,1]
return scalar a6_4c = mat4_4[4,1]
return scalar a6_4d = mat4_4[5,1]
return scalar a6_5 = mat4_5[2,1]
return scalar a6_6 = mat4_6[2,1]
return scalar a6_7 = mat4_7[2,1]
return scalar a6_8 = mat4_8[2,1]
return scalar a6_9 = mat4_9[2,1]
return scalar a6_10 = mat4_10[2,1]
return scalar a6_11 = mat4_11[2,1]
return scalar a6_12 = mat4_12[2,1]
return scalar a6_13 = mat4_13[2,1]
return scalar a6_14 = mat4_14[2,1]
return scalar a6_15 = mat4_15[2,1]
return scalar a6_16 = mat4_16[2,1]
return scalar a6_17 = mat4_17[2,1]
return scalar a6_18 = mat4_18[2,1]
return scalar a6_19 = mat4_19[2,1]
return scalar a6_20 = mat4_20[2,1]
return scalar a6_21 = mat4_21[2,1]
return scalar a6_22 = mat4_22[2,1]
return scalar a6_23 = mat4_23[2,1]
return scalar a6_24 = mat4_24[2,1]
return scalar a6_25 = mat4_25[2,1]
return scalar a6_26 = mat4_26[2,1]


return scalar a7 = b6[1,1]
return scalar a8 = b6[2,1]



return scalar a9_1 = mat7_1[2,1]
return scalar a9_2a = mat7_2[2,1]
return scalar a9_2b = mat7_2[3,1]
return scalar a9_2c = mat7_2[4,1]
return scalar a9_2d = mat7_2[5,1]
return scalar a9_2e = mat7_2[6,1]
return scalar a9_3 = mat7_3[2,1]
return scalar a9_4a = mat7_4[2,1]
return scalar a9_4b = mat7_4[3,1]
return scalar a9_4c = mat7_4[4,1]
return scalar a9_4d = mat7_4[5,1]
return scalar a9_5 = mat7_5[2,1]
return scalar a9_6 = mat7_6[2,1]
return scalar a9_7 = mat7_7[2,1]
return scalar a9_8 = mat7_8[2,1]
return scalar a9_9 = mat7_9[2,1]
return scalar a9_10 = mat7_10[2,1]
return scalar a9_11 = mat7_11[2,1]
return scalar a9_12 = mat7_12[2,1]
return scalar a9_13 = mat7_13[2,1]
return scalar a9_14 = mat7_14[2,1]
return scalar a9_15 = mat7_15[2,1]
return scalar a9_16 = mat7_16[2,1]
return scalar a9_17 = mat7_17[2,1]
return scalar a9_18 = mat7_18[2,1]
return scalar a9_19 = mat7_19[2,1]
return scalar a9_20 = mat7_20[2,1]
return scalar a9_21 = mat7_21[2,1]
return scalar a9_22 = mat7_22[2,1]
return scalar a9_23 = mat7_23[2,1]
return scalar a9_24 = mat7_24[2,1]
return scalar a9_25 = mat7_25[2,1]
return scalar a9_26 = mat7_26[2,1]

end  
		
forvalues n=1/1{

*with IV

if `n'==1{
}
else if `n'==2{
keep if race_5cat==1
}
else if `n'==3{
keep if race_5cat==2
}
else if `n'==4{
keep if ccw_both_alz_dem==0
}
else if `n'==5{
keep if ccw_both_alz_dem==1
}
	
bootstrap r(a11) r(a12) r(a13) r(a14) r(a15) r(a16) r(a17) r(a18) r(a19) r(a110) r(a111) ///
		  r(a112) r(a113) r(a114) r(a115) r(a116) r(a117) r(a118) r(a119) r(a120) r(a121) ///
		  r(a122) r(a123) r(a124) r(a125) r(a126) r(a127) r(a128) r(a129) r(a130) r(a131) ///
		  r(a132) r(a133) r(a134) r(a135) r(a136) r(a137) r(a138) r(a139) r(a140) r(a141) ///
		  r(a142) r(a143) r(a144) r(a145) r(a146) r(a147) r(a148) r(a149) r(a150) r(a151) ///
		  r(a152) r(a153) r(a154) r(a155) r(a156) r(a157) r(a158) r(a159) r(a160) r(a161)  /// 
		  r(a21) r(a22) r(a23) r(a24) r(a25) r(a26) r(a27) r(a28) r(a29) r(a210) r(a211) ///
		  r(a212) r(a213) r(a214) r(a215) r(a216) r(a217) r(a218) r(a219) r(a220) r(a221) ///
		  r(a222) r(a223) r(a224) r(a225) r(a226) r(a227) r(a228) r(a229) r(a230) r(a231) ///
		  r(a232) r(a233) r(a234) r(a235) r(a236) r(a237) r(a238) r(a239) r(a240) r(a241) ///
		  r(a242) r(a243) r(a244) r(a245) r(a246) r(a247) r(a248) r(a249) r(a250) r(a251) ///
		  r(a252) r(a253) r(a254) r(a255) r(a256) r(a257) r(a258) r(a259) r(a260) r(a261) ///
		  r(a31) r(a32) r(a33) r(a34) r(a35) r(a36) r(a37) r(a38) r(a39) r(a310) r(a311) ///
		  r(a312) r(a313) r(a314) r(a315) r(a316) r(a317) r(a318) r(a319) r(a320) r(a321) ///
		  r(a322) r(a323) r(a324) r(a325) r(a326) r(a327) r(a328) r(a329) r(a330) r(a331) ///
		  r(a332) r(a333) r(a334) r(a335) r(a336) r(a337) r(a338) r(a339) r(a340) r(a341) ///
		  r(a342) r(a343) r(a344) r(a345) r(a346) r(a347) r(a348) r(a349) r(a350) r(a351) ///
		  r(a352) r(a353) r(a354) r(a355) r(a356) r(a357) r(a358) r(a359) r(a360) r(a361) ///
		  r(a4) r(a5) r(a6_1) r(a6_2a) r(a6_2b) r(a6_2c) r(a6_2d) r(a6_2e) r(a6_3) ///
		  r(a6_4a) r(a6_4b) r(a6_4c) r(a6_4d) r(a6_5) r(a6_6) r(a6_7) r(a6_8) r(a6_9) r(a6_10) r(a6_11) ///
		  r(a6_12) r(a6_13) r(a6_14) r(a6_15) r(a6_16) r(a6_17) r(a6_18) r(a6_19) r(a6_20) r(a6_21) r(a6_22) ///
		  r(a6_23) r(a6_24) r(a6_25) r(a6_26) r(a7) r(a8) r(a9_1) r(a9_2a) r(a9_2b) r(a9_2c) r(a9_2d) r(a9_2e) r(a9_3) ///
		  r(a9_4a) r(a9_4b) r(a9_4c) r(a9_4d) r(a9_5) r(a9_6) r(a9_7) r(a9_8) r(a9_9) r(a9_10) r(a9_11) ///
		  r(a9_12) r(a9_13) r(a9_14) r(a9_15) r(a9_16) r(a9_17) r(a9_18) r(a9_19) r(a9_20) r(a9_21) r(a9_22) ///
		  r(a9_23) r(a9_24) r(a9_25) r(a9_26), reps(200) seed (10101) nodots nowarn: twosri 			 

		  
		  
}







capture program drop twosri2
program twosri2, rclass 
forvalues a=1/61{
return scalar a1`a'=b1[1,`a']
return scalar a2`a'=b2[1,`a']
return scalar a3`a'=b5[1,`a']
}

return scalar a4 = b3[1,1]
return scalar a5 = b3[2,1]


return scalar a6_1 = mat4_1[2,1]
return scalar a6_2a = mat4_2[2,1]
return scalar a6_2b = mat4_2[3,1]
return scalar a6_2c = mat4_2[4,1]
return scalar a6_2d = mat4_2[5,1]
return scalar a6_2e = mat4_2[6,1]
return scalar a6_3 = mat4_3[2,1]
return scalar a6_4a = mat4_4[2,1]
return scalar a6_4b = mat4_4[3,1]
return scalar a6_4c = mat4_4[4,1]
return scalar a6_4d = mat4_4[5,1]
return scalar a6_5 = mat4_5[1,1]
return scalar a6_6 = mat4_6[2,1]
return scalar a6_7 = mat4_7[2,1]
return scalar a6_8 = mat4_8[2,1]
return scalar a6_9 = mat4_9[2,1]
return scalar a6_10 = mat4_10[2,1]
return scalar a6_11 = mat4_11[2,1]
return scalar a6_12 = mat4_12[2,1]
return scalar a6_13 = mat4_13[2,1]
return scalar a6_14 = mat4_14[2,1]
return scalar a6_15 = mat4_15[2,1]
return scalar a6_16 = mat4_16[2,1]
return scalar a6_17 = mat4_17[2,1]
return scalar a6_18 = mat4_18[2,1]
return scalar a6_19 = mat4_19[2,1]
return scalar a6_20 = mat4_20[2,1]
return scalar a6_21 = mat4_21[2,1]
return scalar a6_22 = mat4_22[2,1]
return scalar a6_23 = mat4_23[2,1]
return scalar a6_24 = mat4_24[2,1]
return scalar a6_25 = mat4_25[2,1]
return scalar a6_26 = mat4_26[2,1]


return scalar a7 = b6[1,1]
return scalar a8 = b6[2,1]



return scalar a9_1 = mat7_1[2,1]
return scalar a9_2a = mat7_2[2,1]
return scalar a9_2b = mat7_2[3,1]
return scalar a9_2c = mat7_2[4,1]
return scalar a9_2d = mat7_2[5,1]
return scalar a9_2e = mat7_2[6,1]
return scalar a9_3 = mat7_3[2,1]
return scalar a9_4a = mat7_4[2,1]
return scalar a9_4b = mat7_4[3,1]
return scalar a9_4c = mat7_4[4,1]
return scalar a9_4d = mat7_4[5,1]
return scalar a9_5 = mat7_5[1,1]
return scalar a9_6 = mat7_6[2,1]
return scalar a9_7 = mat7_7[2,1]
return scalar a9_8 = mat7_8[2,1]
return scalar a9_9 = mat7_9[2,1]
return scalar a9_10 = mat7_10[2,1]
return scalar a9_11 = mat7_11[2,1]
return scalar a9_12 = mat7_12[2,1]
return scalar a9_13 = mat7_13[2,1]
return scalar a9_14 = mat7_14[2,1]
return scalar a9_15 = mat7_15[2,1]
return scalar a9_16 = mat7_16[2,1]
return scalar a9_17 = mat7_17[2,1]
return scalar a9_18 = mat7_18[2,1]
return scalar a9_19 = mat7_19[2,1]
return scalar a9_20 = mat7_20[2,1]
return scalar a9_21 = mat7_21[2,1]
return scalar a9_22 = mat7_22[2,1]
return scalar a9_23 = mat7_23[2,1]
return scalar a9_24 = mat7_24[2,1]
return scalar a9_25 = mat7_25[2,1]
return scalar a9_26 = mat7_26[2,1]

end  

bootstrap r(a11) r(a12) r(a13) r(a14) r(a15) r(a16) r(a17) r(a18) r(a19) r(a110) r(a111) ///
		  r(a112) r(a113) r(a114) r(a115) r(a116) r(a117) r(a118) r(a119) r(a120) r(a121) ///
		  r(a122) r(a123) r(a124) r(a125) r(a126) r(a127) r(a128) r(a129) r(a130) r(a131) ///
		  r(a132) r(a133) r(a134) r(a135) r(a136) r(a137) r(a138) r(a139) r(a140) r(a141) ///
		  r(a142) r(a143) r(a144) r(a145) r(a146) r(a147) r(a148) r(a149) r(a150) r(a151) ///
		  r(a152) r(a153) r(a154) r(a155) r(a156) r(a157) r(a158) r(a159) r(a160) r(a161)  /// 
		  r(a21) r(a22) r(a23) r(a24) r(a25) r(a26) r(a27) r(a28) r(a29) r(a210) r(a211) ///
		  r(a212) r(a213) r(a214) r(a215) r(a216) r(a217) r(a218) r(a219) r(a220) r(a221) ///
		  r(a222) r(a223) r(a224) r(a225) r(a226) r(a227) r(a228) r(a229) r(a230) r(a231) ///
		  r(a232) r(a233) r(a234) r(a235) r(a236) r(a237) r(a238) r(a239) r(a240) r(a241) ///
		  r(a242) r(a243) r(a244) r(a245) r(a246) r(a247) r(a248) r(a249) r(a250) r(a251) ///
		  r(a252) r(a253) r(a254) r(a255) r(a256) r(a257) r(a258) r(a259) r(a260) r(a261) ///
		  r(a31) r(a32) r(a33) r(a34) r(a35) r(a36) r(a37) r(a38) r(a39) r(a310) r(a311) ///
		  r(a312) r(a313) r(a314) r(a315) r(a316) r(a317) r(a318) r(a319) r(a320) r(a321) ///
		  r(a322) r(a323) r(a324) r(a325) r(a326) r(a327) r(a328) r(a329) r(a330) r(a331) ///
		  r(a332) r(a333) r(a334) r(a335) r(a336) r(a337) r(a338) r(a339) r(a340) r(a341) ///
		  r(a342) r(a343) r(a344) r(a345) r(a346) r(a347) r(a348) r(a349) r(a350) r(a351) ///
		  r(a352) r(a353) r(a354) r(a355) r(a356) r(a357) r(a358) r(a359) r(a360) r(a361) ///
		  r(a4) r(a5) r(a6_1) r(a6_2a) r(a6_2b) r(a6_2c) r(a6_2d) r(a6_2e) r(a6_3) ///
		  r(a6_4a) r(a6_4b) r(a6_4c) r(a6_4d) r(a6_5) r(a6_6) r(a6_7) r(a6_8) r(a6_9) r(a6_10) r(a6_11) ///
		  r(a6_12) r(a6_13) r(a6_14) r(a6_15) r(a6_16) r(a6_17) r(a6_18) r(a6_19) r(a6_20) r(a6_21) r(a6_22) ///
		  r(a6_23) r(a6_24) r(a6_25) r(a6_26) r(a7) r(a8) r(a9_1) r(a9_2a) r(a9_2b) r(a9_2c) r(a9_2d) r(a9_2e) r(a9_3) ///
		  r(a9_4a) r(a9_4b) r(a9_4c) r(a9_4d) r(a9_5) r(a9_6) r(a9_7) r(a9_8) r(a9_9) r(a9_10) r(a9_11) ///
		  r(a9_12) r(a9_13) r(a9_14) r(a9_15) r(a9_16) r(a9_17) r(a9_18) r(a9_19) r(a9_20) r(a9_21) r(a9_22) ///
		  r(a9_23) r(a9_24) r(a9_25) r(a9_26), reps(2) seed (10101) nodots nowarn: twosri2
*/		  
		 
/*
*by transportation or spending

gen expend_hcbs_cpi=expend_hcbs*1.19 if year==2005
replace expend_hcbs_cpi=expend_hcbs if year==2012

egen p25 = pctile(expend_hcbs_cpi) if hcbs==1, p(25)
egen p50 = pctile(expend_hcbs_cpi) if hcbs==1, p(50)
egen p75 = pctile(expend_hcbs_cpi) if hcbs==1, p(75)
gen expend_hcbs_cat=0 if expend_hcbs_cpi<p25 & hcbs==1
replace expend_hcbs_cat=1 if expend_hcbs_cpi<p50 & expend_hcbs_cat==. & hcbs==1
replace expend_hcbs_cat=2 if expend_hcbs_cpi<p75 & expend_hcbs_cat==. & hcbs==1
replace expend_hcbs_cat=3 if expend_hcbs_cat==. & hcbs==1

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local predictor iv_cnty_young
local titlelist model30
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'


log using `logpath'\model_trans_expend.txt, text replace
forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
local outcome : word `n3' of `outcomelist'
local exclusion : word `n3' of `exclusionlist'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'
forvalues n=1/6{
local r=`n'
preserve
if `n'==1{
keep if trans==0|hcbs==0
}
else if `n'==2{
keep if trans==1|hcbs==0
}
else if `n'==3{
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==4{
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==5{
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==6{
keep if expend_hcbs_cat==3|hcbs==0
}

keep if `exclusion'==0


*without IV		

logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
		 

mat mat_`word1'`r'=r(table)
mat mat_`word1'`r'=mat_`word1'`r'[1,2] \ mat_`word1'`r'[4,2] \ mat_`word1'`r'[5,2] \ mat_`word1'`r'[6,2]
if `n'==1{
mat mat1=mat_`word1'`r'
}
else{
mat mat1=mat1,mat_`word1'`r'
}
mat list mat1
margins hcbs	
mat `word1'_`r'=r(table)*100
mat list `word1'_`r' 

mat  `word1'`r'=`word1'_`r'[1,1], `word1'_`r'[1,2] 
mat list  `word1'`r'	
margins, dydx(hcbs)
clear	
svmat  `word1'`r', names(col)
save `data'\dt_`outcome'_`title'_`word1'`r'.dta, replace
restore	


*with IV
preserve
if `n'==1{
keep if trans==0|hcbs==0
}
else if `n'==2{
keep if trans==1|hcbs==0
}
else if `n'==3{
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==4{
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==5{
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==6{
keep if expend_hcbs_cat==3|hcbs==0
}

keep if `exclusion'==0

logit hcbs `predictor' i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
	 
mat iv_`word2'`r'=r(table)
mat iv_`word2'`r'=iv_`word2'`r'[1,1] \ iv_`word2'`r'[4,1] \ iv_`word2'`r'[5,1] \ iv_`word2'`r'[6,1]			 

if `n'==1{
mat mat2=iv_`word2'`r'
}
else{
mat mat2=mat2,iv_`word2'`r'
}		 
predict re, residuals 
sum re
test (`predictor'=0)
mat mat_chi=r(chi2)

if `n'==1{
mat mat3=mat_chi
}
else{
mat mat3=mat3,mat_chi
}

logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster' re, robust `cluster2'
	 
mat mat_`word2'`r'=r(table)
mat mat_`word2'`r'=mat_`word2'`r'[1,2] \ mat_`word2'`r'[4,2] \ mat_`word2'`r'[5,2] \ mat_`word2'`r'[6,2]
mat mat1=mat1,mat_`word2'`r'
margins hcbs
mat `word2'1`r'=r(table)*100
mat list `word2'1`r' 
mat  `word2'`r'=`word2'1`r'[1,1], `word2'1`r'[1,2] 
mat list  `word2'`r'
margins, dydx(hcbs)
drop re
clear
svmat  `word2'`r', names(col)
save `data'\dt_`outcome'_`title'_`word2'`r'.dta, replace
restore	
}

mat mat1`outcome'_`title'=mat1'
mat mat2`outcome'_`title'=mat2'
mat mat3`outcome'_`title'=mat3'
mat mat4`outcome'_`title'=mat2', mat3'
}
}


log close


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'
forvalues n1=1/3{
preserve
clear
svmat mat`n1'`outcome'_`title', names(col) 
save `data'\mat`n1'`outcome'_`title'.dta, replace
restore
}
}
}




forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'		   		   
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Model 30 - Transportion, Spending")
putdocx save `logpath'\main_`ver'.docx, append			   
preserve
use `data'\mat1`outcome'_`title'.dta, replace
list
mkmat r1 r2 r3 r4, matrix(mat1`outcome'_`title') 
mat list mat1`outcome'_`title'
frmttable using `logpath'\main_tab.rtf, statmat(mat1`outcome'_`title') sdec(3) ///
title("") ///
rtitles("Trans X","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans O","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Spending-Q1" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Spending-Q2"  ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Spending-Q3" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Spending-Q4","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS")  ///
ctitles("Group" "Model" "Variable" "Coef." "p" "95% CI" "" \ ///
		"" "" "" "" "" "Low" "High") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main_`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main_`ver', replace)
restore
preserve
use `data'\mat2`outcome'_`title'.dta, replace
list
mkmat r1 r2 r3 r4, matrix(mat2`outcome'_`title') 
mat list mat2`outcome'_`title'
use `data'\mat3`outcome'_`title'.dta, replace
list
mkmat r1, matrix(mat3`outcome'_`title') 
mat list mat3`outcome'_`title'
mat mat4`outcome'_`title'=mat2`outcome'_`title', mat3`outcome'_`title'

frmttable using `logpath'\main_tab.rtf, statmat(mat4`outcome'_`title') sdec(3) ///
title("") ///
rtitles("Trans X" \ "Trans O" \ "Spending-Q1" \ "Spending-Q2" \ "Spending-Q3" \ "Spending-Q4")  ///
ctitles("Group" "Coef." "p" "95% CI" "" "F"  \ /// 
		"" "" "" "Low" "High" "") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main_`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main_`ver', replace)
restore
********************************************************************************
********************************************************************************
**Graph
local list "woiv iv"
forvalues n4=1/2{
local word : word `n4' of `list'
preserve
use `data'\dt_`outcome'_`title'_`word'1.dta, replace
append using `data'\dt_`outcome'_`title'_`word'2.dta
append using `data'\dt_`outcome'_`title'_`word'3.dta
append using `data'\dt_`outcome'_`title'_`word'4.dta
append using `data'\dt_`outcome'_`title'_`word'5.dta
append using `data'\dt_`outcome'_`title'_`word'6.dta
mkmat c1 c2, matrix(`word')
mat colnames `word' = hcbs0 hcbs1
mat group =     (1\2\3\4\5\6)
mat colnames group = group
mat list group
mat full`n4'=group, `word'
mat list full`n4'
restore
}
mat iv=(1\1\1\1\1\1\2\2\2\2\2\2)
mat colnames iv=iv
mat full=full1\full2
mat full=full,iv
preserve
clear
svmat full, names(col)
label def group 1 "Trans O" 2 "Trans x" 3"Exp-Q1" 4 "Exp-Q2" 5 "Exp-Q3" 6 "Exp-Q4"
la val group group
label def iv 1 "w/o IV" 2 "with IV"
la val iv iv
save `data'\dt_`outcome'_`title'_`word'.dta, replace
use `data'\dt_`outcome'_`title'_`word'.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20)  ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("243 66 85")) bar(2, color("47 127 137")) ///
 over(group, relabel(1 "Trans X" 2 "Trans O" 3"Q1" 4 "Q2" 5 "Q3" 6 "Q4") label(labsize(vsmall))) ///
 by(iv, noiy note("") row(1))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Percentage (%)", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_`outcome'_`title'.png, replace	
restore	 

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Analysis"), linebreak
putdocx image `logpath'\result_`outcome'_`title'.png, width(6.6) height(3.5)
putdocx save `logpath'\main_`ver'.docx, append
}
}








capture log close
clear all
set more off
set scheme s1color
set matsize 10000
net set ado "\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\ado\"
adopath ++ "\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\ado\"
sysdir set PLUS "\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\ado\"
 
 
local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local predictor iv_cnty_young
local titlelist model30
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp  pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'
local ver "model_comparison"



forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
	   		   
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Model 30 - Transportion, Spending")
putdocx save `logpath'\main_`ver'.docx, append			   

********************************************************************************
********************************************************************************
**Graph


preserve
use `data'\dt_hosp_`title'_iv3.dta
append using `data'\dt_hosp_`title'_iv4.dta
append using `data'\dt_hosp_`title'_iv5.dta
append using `data'\dt_hosp_`title'_iv6.dta
append using `data'\dt_pqi_`title'_iv3.dta
append using `data'\dt_pqi_`title'_iv4.dta
append using `data'\dt_pqi_`title'_iv5.dta
append using `data'\dt_pqi_`title'_iv6.dta
mkmat c1 c2, matrix(iv)
mat colnames iv = hcbs0 hcbs1
mat group =     (1\2\3\4\1\2\3\4)
mat colnames group = group
mat list group
mat full=group, iv
mat list full
restore

mat outcome=(1\1\1\1\2\2\2\2)
mat colnames outcome=outcome
mat full=full,outcome
preserve
clear
svmat full, names(col)
label def group 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4"
la val group group
label def outcome 1 "Any Hospitalization" 2 "PQI Hospitalization"
la val outcome outcome
save `data'\dt_overall_`title'_iv.dta, replace
use `data'\dt_overall_`title'_iv.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20)  ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("gs11")) bar(2, color("gs3")) ///
 over(group, relabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4") label(labsize(vsmall))) ///
 over(outcome, label(labsize(small)))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Percentage (%)", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_overall_`title'.png, replace	
restore	 

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Analysis"), linebreak
putdocx image `logpath'\result_overall_`title'.png, width(6.6) height(3.5)
putdocx save `logpath'\main_`ver'.docx, append
}




local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local predictor iv_cnty_young
local titlelist model30
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp  pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'
local ver "model_comparison"



forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
	   		   
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Model 30 - Transportion, Spending")
putdocx save `logpath'\main_`ver'.docx, append			   

********************************************************************************
********************************************************************************
**Graph


preserve
use `data'\dt_hosp_`title'_iv3.dta
append using `data'\dt_hosp_`title'_iv4.dta
append using `data'\dt_hosp_`title'_iv5.dta
append using `data'\dt_hosp_`title'_iv6.dta
append using `data'\dt_pqi_`title'_iv3.dta
append using `data'\dt_pqi_`title'_iv4.dta
append using `data'\dt_pqi_`title'_iv5.dta
append using `data'\dt_pqi_`title'_iv6.dta
mkmat c1 c2, matrix(iv)
mat colnames iv = hcbs0 hcbs1
mat iv = iv/100
mat group =     (1\2\3\4\1\2\3\4)
mat colnames group = group
mat list group
mat full=group, iv
mat list full
restore

mat outcome=(1\1\1\1\2\2\2\2)
mat colnames outcome=outcome
mat full=full,outcome
preserve
clear
svmat full, names(col)
label def group 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4"
la val group group
label def outcome 1 "Any Hospitalization" 2 "PQI Hospitalization"
la val outcome outcome
save `data'\dt_overall_`title'_iv.dta, replace
use `data'\dt_overall_`title'_iv.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20)  ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("grey")) bar(2, color("black")) ///
 over(group, relabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4") label(labsize(vsmall))) ///
 over(outcome, label(labsize(small)))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Average Margin", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_overall_`title'.png, replace	
restore	 

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Analysis"), linebreak
putdocx image `logpath'\result_overall_`title'.png, width(6.6) height(3.5)
putdocx save `logpath'\main_`ver'.docx, append
}

*/		 
		 
		 
		 
		 
/*
*by transportation and spending
egen p25 = pctile(expend_hcbs) if hcbs==1, p(25)
egen p50 = pctile(expend_hcbs) if hcbs==1, p(50)
egen p75 = pctile(expend_hcbs) if hcbs==1, p(75)
gen expend_hcbs_cat=0 if expend_hcbs<p25 & hcbs==1
replace expend_hcbs_cat=1 if expend_hcbs<p50 & expend_hcbs_cat==. & hcbs==1
replace expend_hcbs_cat=2 if expend_hcbs<p75 & expend_hcbs_cat==. & hcbs==1
replace expend_hcbs_cat=3 if expend_hcbs_cat==. & hcbs==1

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local predictor iv_cnty_young
local titlelist model33
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'


**Exclude cnty with no hcbs or inst. user 
forvalues n=1/8{
preserve
if `n'==1{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==2{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==3{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==4{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==3|hcbs==0
}
else if `n'==5{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==6{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==7{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==8{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==3|hcbs==0
}
collapse (mean) hosp pqi hcbs, by(st_cnty)
gen trans_exclusion_hosp`n'=1 if hosp==1|hosp==0
replace trans_exclusion_hosp`n'=0 if hosp>0&hosp<1
gen trans_exclusion_pqi`n'=1 if pqi==1|pqi==0
replace trans_exclusion_pqi`n'=0 if pqi>0&pqi<1
gen trans_exclusion_hcbs`n'=1 if hcbs==1|hcbs==0
replace trans_exclusion_hcbs`n'=0 if hcbs>0&hcbs<1
keep st_cnty trans_exclusion_hosp`n' trans_exclusion_pqi`n' trans_exclusion_hcbs`n'
save `data'\trans_exclusion`n', replace
restore
}

forvalues n=1/8{
merge m:1 st_cnty using `data'\trans_exclusion`n'.dta
drop _merge
}

gen trans_exclusion=0 if trans_exclusion_hosp1==0&trans_exclusion_pqi1==0&trans_exclusion_hcbs1==0& ///
					   trans_exclusion_hosp2==0&trans_exclusion_pqi2==0&trans_exclusion_hcbs2==0& ///
					   trans_exclusion_hosp3==0&trans_exclusion_pqi3==0&trans_exclusion_hcbs3==0& ///
					   trans_exclusion_hosp4==0&trans_exclusion_pqi4==0&trans_exclusion_hcbs4==0& ///
					   trans_exclusion_hosp5==0&trans_exclusion_pqi5==0&trans_exclusion_hcbs5==0& ///
					   trans_exclusion_hosp6==0&trans_exclusion_pqi6==0&trans_exclusion_hcbs6==0& ///
					   trans_exclusion_hosp7==0&trans_exclusion_pqi7==0&trans_exclusion_hcbs7==0& ///
					   trans_exclusion_hosp8==0&trans_exclusion_pqi8==0&trans_exclusion_hcbs8==0 
keep if trans_exclusion==0



local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local predictor iv_cnty_young
local titlelist model33
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'
log using `logpath'\model_trans_x_expend.txt, text replace





local predictor iv_cnty_young
local titlelist model
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'

forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'

local exclusion : word `n3' of `exclusionlist'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'
forvalues n=1/8{
preserve
if `n'==1{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==2{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==3{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==4{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==3|hcbs==0
}
else if `n'==5{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==6{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==7{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==8{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==3|hcbs==0
}
keep if `exclusion'==0



*without IV		

logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
		 

mat mat_`word1'`r'=r(table)
mat mat_`word1'`r'=mat_`word1'`r'[1,2] \ mat_`word1'`r'[4,2] \ mat_`word1'`r'[5,2] \ mat_`word1'`r'[6,2]
if `n'==1{
mat mat1=mat_`word1'`r'
}
else{
mat mat1=mat1,mat_`word1'`r'
}
mat list mat1
margins hcbs	
mat `word1'_`r'=r(table)*100
mat list `word1'_`r' 

mat  `word1'`r'=`word1'_`r'[1,1], `word1'_`r'[1,2] 
mat list  `word1'`r'	
margins, dydx(hcbs)
clear	
svmat  `word1'`r', names(col)
save `data'\dt_`outcome'_`title'_`word1'`r'.dta, replace
restore	


*with IV
preserve
if `n'==1{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==2{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==3{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==4{
keep if trans==0|hcbs==0
keep if expend_hcbs_cat==3|hcbs==0
}
else if `n'==5{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==0|hcbs==0
}
else if `n'==6{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==1|hcbs==0
}
else if `n'==7{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==2|hcbs==0
}
else if `n'==8{
keep if trans==1|hcbs==0
keep if expend_hcbs_cat==3|hcbs==0
}

keep if `exclusion'==0

logit hcbs `predictor' i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster', robust `cluster2'
	 
mat iv_`word2'`r'=r(table)
mat iv_`word2'`r'=iv_`word2'`r'[1,1] \ iv_`word2'`r'[4,1] \ iv_`word2'`r'[5,1] \ iv_`word2'`r'[6,1]			 

if `n'==1{
mat mat2=iv_`word2'`r'
}
else{
mat mat2=mat2,iv_`word2'`r'
}		 
predict re, residuals 
sum re
test (`predictor'=0)
mat mat_chi=r(chi2)

if `n'==1{
mat mat3=mat_chi
}
else{
mat mat3=mat3,mat_chi
}

logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year `cluster' re, robust `cluster2'
	 
mat mat_`word2'`r'=r(table)
mat mat_`word2'`r'=mat_`word2'`r'[1,2] \ mat_`word2'`r'[4,2] \ mat_`word2'`r'[5,2] \ mat_`word2'`r'[6,2]
mat mat1=mat1,mat_`word2'`r'
margins hcbs
mat `word2'1`r'=r(table)*100
mat list `word2'1`r' 
mat  `word2'`r'=`word2'1`r'[1,1], `word2'1`r'[1,2] 
mat list  `word2'`r'
margins, dydx(hcbs)
drop re
clear
svmat  `word2'`r', names(col)
save `data'\dt_`outcome'_`title'_`word2'`r'.dta, replace
restore	
}

mat mat1`outcome'_`title'=mat1'
mat mat2`outcome'_`title'=mat2'
mat mat3`outcome'_`title'=mat3'
mat mat4`outcome'_`title'=mat2', mat3'
}
}

log close


local predictor iv_cnty_young
local titlelist model33
local clusterlist `""i.st_cnty_num" """'
local clusterlist2 `""cluster(st_cnty_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local exclusionlist "exclusion"
local n_3 : word count `clusterlist'
local ver "model_comparison"
forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'
forvalues n1=1/3{
preserve
clear
svmat mat`n1'`outcome'_`title', names(col) 
save `data'\mat`n1'`outcome'_`title'.dta, replace
restore
}
}
}


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/2{
local outcome : word `n2' of `outcomelist'			   		   
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Model")
putdocx save `logpath'\main_`ver'.docx, append			   
preserve
use `data'\mat1`outcome'_`title'.dta, replace
list
mkmat r1 r2 r3 r4, matrix(mat1`outcome'_`title') 
mat list mat1`outcome'_`title'
frmttable using `logpath'\main_tab.rtf, statmat(mat1`outcome'_`title') sdec(3) ///
title("") ///
rtitles("Trans X, Q1","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans X, Q2","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans X, Q3","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans X, Q4","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans O, Q1","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans O, Q2","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans O, Q3","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Trans O, Q4","Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS")  ///
ctitles("Group" "Model" "Variable" "Coef." "p" "95% CI" "" \ ///
		"" "" "" "" "" "Low" "High") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main_`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main_`ver', replace)
restore
preserve
use `data'\mat2`outcome'_`title'.dta, replace
list
mkmat r1 r2 r3 r4, matrix(mat2`outcome'_`title') 
mat list mat2`outcome'_`title'
use `data'\mat3`outcome'_`title'.dta, replace
list
mkmat r1, matrix(mat3`outcome'_`title') 
mat list mat3`outcome'_`title'
mat mat4`outcome'_`title'=mat2`outcome'_`title', mat3`outcome'_`title'

frmttable using `logpath'\main_tab.rtf, statmat(mat4`outcome'_`title') sdec(3) ///
title("") ///
rtitles("Trans X, Q1" \ "Trans X, Q2" \ "Trans X, Q3" \ "Trans X, Q4"\ "Trans O, Q1" \ "Trans O, Q2" \ "Trans O, Q3" \ "Trans O, Q4")  ///
ctitles("Group" "Coef." "p" "95% CI" "" "F"  \ /// 
		"" "" "" "Low" "High" "") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main_`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main_`ver', replace)
restore
********************************************************************************
********************************************************************************
**Graph
local list "woiv iv"
forvalues n4=1/2{
local word : word `n4' of `list'
preserve
use `data'\dt_`outcome'_`title'_`word'1.dta, replace
append using `data'\dt_`outcome'_`title'_`word'2.dta
append using `data'\dt_`outcome'_`title'_`word'3.dta
append using `data'\dt_`outcome'_`title'_`word'4.dta
append using `data'\dt_`outcome'_`title'_`word'5.dta
append using `data'\dt_`outcome'_`title'_`word'6.dta
append using `data'\dt_`outcome'_`title'_`word'7.dta
append using `data'\dt_`outcome'_`title'_`word'8.dta
mkmat c1 c2, matrix(`word')
mat colnames `word' = hcbs0 hcbs1
mat group =     (1\2\3\4\5\6\7\8)
mat colnames group = group
mat list group
mat full`n4'=group, `word'
mat list full`n4'
restore
}
mat iv=(1\1\1\1\1\1\1\1\2\2\2\2\2\2\2\2)
mat colnames iv=iv
mat full=full1\full2
mat full=full,iv
preserve
clear
svmat full, names(col)
label def group 1 "Trans X, Q1" 2 "Trans X, Q2" 3"Trans X, Q3"  4 "Trans X, Q4" 5"Trans O, Q1"  6 "Trans O, Q2" 7"Trans O, Q3"  8 "Trans O, Q4"
la val group group
label def iv 1 "w/o IV" 2 "with IV"
la val iv iv
save `data'\dt_`outcome'_`title'_`word'.dta, replace
use `data'\dt_`outcome'_`title'_`word'.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20)  ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("243 66 85")) bar(2, color("47 127 137")) ///
 over(group, relabel(1 "Trans X, Q1" 2 "Trans X, Q2" 3"Trans X, Q3"  4 "Trans X, Q4" 5"Trans O, Q1"  6 "Trans O, Q2" 7"Trans O, Q3"  8 "Trans O, Q4") label(labsize(vsmall))) ///
 by(iv, noiy note("") row(2))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Percentage (%)", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_`outcome'_`title'.png, replace	
restore	 

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Analysis"), linebreak
putdocx image `logpath'\result_`outcome'_`title'.png, width(6.6) height(3.5)
putdocx save `logpath'\main_`ver'.docx, append
}
}

*/

/*
preserve
ivreghdfe hosp c.hcbs_cnty_old i.age_cat i.race_cat i.female_ind ///
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year, ///
			 absorb(st_cnty_num) cluster(st_cnty_num) first
 
predict yhat, xb
sum yhat, detail

gen hcbs_cnty_old_r=round(hcbs_cnty_old)

sum yhat if hcbs_cnty_old_r==60
mat mat1a=r(mean)
sum yhat if hcbs_cnty_old_r==90
mat mat1b=r(mean)

mat colnames mat1a = Q1
mat colnames mat1b = Q3

mat full=mat1a*100, mat1b*100
mat list full

clear
svmat full, names(col)
graph bar (mean) Q1 Q3, bargap(60)  ///
legend(lab(1 "HCBS%_cnty=60") lab(2 "HCBS%_Cnty=90") size(vsmall)) ///
bar(1, color("243 66 85")) bar(2, color("47 127 137")) ///
	blabel(bar, position(center) format(%9.1f) color(white) size(vsmall)) ///
	graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) ///
	ytitle("Percentage (%)", size(vsmall)) name(hcbs3,replace)
graph export `logpath'\sa_hosp_withoutiv.png, replace
restore	 

preserve
ivreghdfe hosp i.age_cat i.race_cat i.female_ind ///
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year (hcbs_cnty_old=hcbs_cnty_young), ///
			 absorb(st_cnty_num) cluster(st_cnty_num) first
 
predict yhat, xb
sum yhat, detail

gen hcbs_cnty_old_r=round(hcbs_cnty_old)

sum yhat if hcbs_cnty_old_r==60
mat mat1a=r(mean)
sum yhat if hcbs_cnty_old_r==90
mat mat1b=r(mean)

mat colnames mat1a = Q1
mat colnames mat1b = Q3

mat full=mat1a*100, mat1b*100
mat list full

clear
svmat full, names(col)
graph bar (mean) Q1 Q3, bargap(60)  ///
legend(lab(1 "HCBS%_cnty=60") lab(2 "HCBS%_Cnty=90") size(vsmall)) ///
bar(1, color("243 66 85")) bar(2, color("47 127 137")) ///
	blabel(bar, position(center) format(%9.1f) color(white) size(vsmall)) ///
	graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) ///
	ytitle("Percentage (%)", size(vsmall)) name(hcbs3,replace)
graph export `logpath'\sa_hosp_withiv.png, replace
restore	 
*/


/*
********************************************************************************
**Model Comparison - with different variables and iv
********************************************************************************


local predictor iv_cnty_young
local titlelist cnty_compare st no
local clusterlist `""i.st_cnty_num" "i.st_num" """'
local clusterlist2 `""cluster(st_cnty_num)" "cluster(st_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local n_3 : word count `clusterlist'
local n_2 : word count `outcomelist'

forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/1{
forvalues n=1/6{
local r=`n'
local outcome : word `n2' of `outcomelist'
preserve
tab year
if `n'<4{
keep if exclusion_hosp1==0
keep if exclusion_hcbs1==0
keep if exclusion_pqi1==0
}
else{
keep if exclusion==0
}
tab year
*without IV		 
if `n'==1|`n'==4{
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_cat cc_ami_ind cc_atrial_fib_ind cc_cataract_ind cc_chronickidney_ind ///
			 cc_copd_ind cc_chf_ind cc_diabetes_ind cc_glaucoma_ind cc_hip_fracture_ind ///
			 cc_ischemicheart_ind cc_depression_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			 cc_stroke_tia_ind cc_cancer_breast_ind cc_cancer_colorectal_ind ///
			 cc_cancer_prostate_ind cc_cancer_lung_ind cc_cancer_endometrial_ind ///
			 cc_anemia_ind cc_asthma_ind cc_hyperl_ind cc_hyperp_ind cc_hypert_ind ///
			 cc_hypoth_ind i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
}
else if `n'==2|`n'==5{
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_ind i.cc_atrial_fib_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind i.cc_ra_oa_ind ///
			 i.cc_stroke_tia_ind i.cc_other ///
			 i.cc_anemia_ind i.cc_asthma_ind i.cc_hyperl_ind i.cc_hyperp_ind i.cc_hypert_ind ///
			 i.cc_hypoth_ind i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
}
else if `n'==3|`n'==6{
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
}		 
mat mat_`word1'`r'=r(table)
mat mat_`word1'`r'=mat_`word1'`r'[1,2] \ mat_`word1'`r'[4,2] \ mat_`word1'`r'[5,2] \ mat_`word1'`r'[6,2]
if `n'==1{
mat mat1=mat_`word1'`r'
}
else{
mat mat1=mat1,mat_`word1'`r'
}
mat list mat1
margins hcbs	
mat `word1'_`r'=r(table)*100
mat list `word1'_`r' 

mat  `word1'`r'=`word1'_`r'[1,1], `word1'_`r'[1,2] 
mat list  `word1'`r'	
contrast hcbs, overall
clear	
svmat  `word1'`r', names(col)
save `data'\dt_`outcome'_`title'_`word1'`r'.dta, replace
restore	

*with IV
preserve
if `n'<4{
keep if exclusion_hosp1==0
keep if exclusion_hcbs1==0
keep if exclusion_pqi1==0
}
else{
keep if exclusion==0
}
logit hcbs `predictor' i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_ind cc_atrial_fib_ind cc_cataract_ind cc_chronickidney_ind ///
			 cc_copd_ind cc_chf_ind cc_diabetes_ind cc_glaucoma_ind ///
			 cc_ischemicheart_ind cc_depression_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			 cc_stroke_tia_ind cc_other ///
			 cc_anemia_ind cc_asthma_ind cc_hyperl_ind cc_hyperp_ind cc_hypert_ind ///
			 cc_hypoth_ind i.ccw_both_alz_dem i.year `cluster', robust `cluster2'

if `n'==1|`n'==4{
logit hcbs `predictor' i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_cat cc_ami_ind cc_atrial_fib_ind cc_cataract_ind cc_chronickidney_ind ///
			 cc_copd_ind cc_chf_ind cc_diabetes_ind cc_glaucoma_ind cc_hip_fracture_ind ///
			 cc_ischemicheart_ind cc_depression_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			 cc_stroke_tia_ind cc_cancer_breast_ind cc_cancer_colorectal_ind ///
			 cc_cancer_prostate_ind cc_cancer_lung_ind cc_cancer_endometrial_ind ///
			 cc_anemia_ind cc_asthma_ind cc_hyperl_ind cc_hyperp_ind cc_hypert_ind ///
			 cc_hypoth_ind i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
}
else if `n'==2|`n'==5{
logit hcbs `predictor' i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_ind i.cc_atrial_fib_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind i.cc_ra_oa_ind ///
			 i.cc_stroke_tia_ind i.cc_other ///
			 i.cc_anemia_ind i.cc_asthma_ind i.cc_hyperl_ind i.cc_hyperp_ind i.cc_hypert_ind ///
			 i.cc_hypoth_ind i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
}
else if `n'==3|`n'==6{
logit hcbs `predictor' i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
}
mat iv_`word2'`r'=r(table)
mat iv_`word2'`r'=iv_`word2'`r'[1,1] \ iv_`word2'`r'[4,1] \ iv_`word2'`r'[5,1] \ iv_`word2'`r'[6,1]			 
if `n'==1{
mat mat2=iv_`word2'`r'
}
else{
mat mat2=mat2,iv_`word2'`r'
}		 
predict re, residuals 
sum re
test (`predictor'=0)
mat mat_chi=r(chi2)

if `n'==1{
mat mat3=mat_chi
}
else{
mat mat3=mat3,mat_chi
}
if `n'==1|`n'==4{
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_cat cc_ami_ind cc_atrial_fib_ind cc_cataract_ind cc_chronickidney_ind ///
			 cc_copd_ind cc_chf_ind cc_diabetes_ind cc_glaucoma_ind cc_hip_fracture_ind ///
			 cc_ischemicheart_ind cc_depression_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			 cc_stroke_tia_ind cc_cancer_breast_ind cc_cancer_colorectal_ind ///
			 cc_cancer_prostate_ind cc_cancer_lung_ind cc_cancer_endometrial_ind ///
			 cc_anemia_ind cc_asthma_ind cc_hyperl_ind cc_hyperp_ind cc_hypert_ind ///
			 cc_hypoth_ind i.ccw_both_alz_dem i.year `cluster' re, robust `cluster2'
}
else if `n'==2|`n'==5{
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_ind i.cc_atrial_fib_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind i.cc_ra_oa_ind ///
			 i.cc_stroke_tia_ind i.cc_other ///
			 i.cc_anemia_ind i.cc_asthma_ind i.cc_hyperl_ind i.cc_hyperp_ind i.cc_hypert_ind ///
			 i.cc_hypoth_ind i.ccw_both_alz_dem i.year `cluster' re, robust `cluster2'
}
else if `n'==3|`n'==6{
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat i.svc_first_month ///
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year `cluster' re, robust `cluster2'
}
mat mat_`word2'`r'=r(table)
mat mat_`word2'`r'=mat_`word2'`r'[1,2] \ mat_`word2'`r'[4,2] \ mat_`word2'`r'[5,2] \ mat_`word2'`r'[6,2]
mat mat1=mat1,mat_`word2'`r'
margins hcbs
mat `word2'1`r'=r(table)*100
mat list `word2'1`r' 
mat  `word2'`r'=`word2'1`r'[1,1], `word2'1`r'[1,2] 
mat list  `word2'`r'
drop re
contrast hcbs, overall	
clear
svmat  `word2'`r', names(col)
save `data'\dt_`outcome'_`title'_`word2'`r'.dta, replace
restore	
}
mat mat1`title'`outcome'=mat1'
mat mat2`title'`outcome'=mat2'
mat mat3`title'`outcome'=mat3'
mat mat4`title'`outcome'=mat2', mat3'
}
}


local predictor iv_cnty_young
local titlelist cnty_compare st no
local clusterlist `""i.st_cnty_num" "i.st_num" """'
local clusterlist2 `""cluster(st_cnty_num)" "cluster(st_num)" """'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"
local n_3 : word count `clusterlist'
local n_2 : word count `outcomelist'

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Compare models - County-level Fixed-Effects")
putdocx save `logpath'\main`ver'.docx, replace


forvalues n3=1/1{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/1{
local outcome : word `n2' of `outcomelist'
frmttable using `logpath'\main_tab.rtf, statmat(mat1`title'`outcome') sdec(3) ///
title("Coefficients") ///
rtitles("Full CC{\super 1}" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Limited CC{\super 1}" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"CC Count{\super 1}" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Full CC{\super 2}" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Limited CC{\super 2}" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"CC Count{\super 2}" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS")  ///
ctitles("Group" "Model" "Variable" "Coef." "p" "95% CI" "" \ ///
		"" "" "" "" "" "Low" "High") ///
note("Exclude Counties: hcbs%=0/100, hosp%=0/100" \ ///
"{\super 1}Applied for each stratification" \ ///
"{\super 2}Applied for all stratifications") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main`ver', replace)


putdocx begin
putdocx paragraph
putdocx text ("IV Test")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'\main_tab.rtf, statmat(mat4`title'`outcome') sdec(3) addtable ///
title("IV test") ///
rtitles("Full CC{\super 1}" \ "Limited CC{\super 1}" \ "CC Count{\super 1}" \ ///
"Full CC{\super 2}" \ "Limited CC{\super 2}" \ "CC Count{\super 2}")  ///
ctitles("Group" "Coef." "p" "95% CI" "" "F"  \ /// 
		"" "" "" "Low" "High" "") ///
note("Exclude Counties: hcbs%=0/100, hosp%=0/100" \ ///
"{\super 1}Applied for each stratification" \ ///
"{\super 2}Applied for all stratifications") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main`ver', replace)


********************************************************************************
********************************************************************************
**Graph
local list "woiv iv woiv iv"
local outcomelist "hosp hosp pqi pqi"
forvalues n4=1/2{
local word : word `n4' of `list'
local outcome : word `n4' of `outcomelist'
preserve
use `data'\dt_`outcome'_`title'_`word'1.dta, replace
append using `data'\dt_`outcome'_`title'_`word'2.dta
append using `data'\dt_`outcome'_`title'_`word'3.dta
append using `data'\dt_`outcome'_`title'_`word'4.dta
append using `data'\dt_`outcome'_`title'_`word'5.dta
append using `data'\dt_`outcome'_`title'_`word'6.dta
mkmat c1 c2, matrix(`word')
mat colnames `word' = hcbs0 hcbs1
mat model =     (0\1\2\0\1\2)
mat sample = (0\0\0\1\1\1)
mat colnames model = model
mat colnames sample = sample
mat full`n4'=model, sample, `word'
mat list full`n4'
restore


preserve
clear
svmat full`n4', names(col)

save `data'\dt_`outcome'_`title'_`word'.dta, replace
use `data'\dt_`outcome'_`title'_`word'.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20)  ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("243 66 85")) bar(2, color("47 127 137")) ///
 over(model, relabel(1 "Full CC" 2 "Limited CC" 3 "CC Count") label(labsize(vsmall))) ///
 by(sample, noiy note("") row(1))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Percentage (%)", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_`outcome'_`title'_`word'.png, replace	
restore	 

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Without IV"), linebreak
putdocx image `logpath'\result_`outcome'_`title'_woiv.png, width(6.6) height(4.1)
putdocx text ("Without IV"), linebreak
putdocx image `logpath'\result_`outcome'_`title'_iv.png, width(6.6) height(4.1)
putdocx save `logpath'\main`ver'.docx, append

}
}
}

*/

