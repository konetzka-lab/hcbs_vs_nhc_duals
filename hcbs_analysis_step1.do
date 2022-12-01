**Descriptive analyses

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
*Table 1
local varlist age_cat white_ind female_ind elig_ind dem_ind  ///
			  cc_anemia_ind cc_asthma_ind cc_atrial_fib_ind  /// 
			  cc_cataract_ind cc_chronickidney_ind ///
			  cc_chf_ind cc_copd_ind cc_depression_ind cc_diabetes_ind cc_glaucoma_ind ///
			  cc_hyperl_ind cc_hyperp_ind cc_hypert_ind cc_hypoth_ind   ///
			  cc_ischemicheart_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			  cc_stroke_tia_ind cc_other
local group hcbs
preserve
sum year 
mat mat1=r(N)
sum year if `group'==0
mat mat2=r(N)
sum year if `group'==1
mat mat3=r(N)
mat mat=mat1, mat2, mat3
mat list mat
local n_2 : word count `varlist'
mat matm=.,.,.
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1{
mat mat = mat \ matm
forvalue n1=`c1'/`c2'{
sum year if `var'==`n1'
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==`n1' & `group'==0
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==`n1' & `group'==1
mat mat3=r(N)/mat[1,3]*100
mat mat4= mat1,mat2,mat3
mat mat = mat \ mat4
}
}
else {
sum year if `var'==1
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==1 & `group'==0
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==1 & `group'==1
mat mat3=r(N)/mat[1,3]*100
mat mat4= mat1,mat2,mat3
mat mat = mat \ mat4
}
}
mat list mat
restore
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Table 1. Baseline Characterstics by Care Setting")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'/main_tab1.rtf, statmat(mat) sdec(0,0,0 \ 1,1,1) ///
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
"Eligibility - Aged (%)" \ ///
"Dementia = Yes (%)" \ ///
"Anemia = Yes (%)" \ ///
"Asthma = Yes (%)" \ ///
"Atrial_Fib = Yes (%)" \ ///
"Cataract = Yes (%)" \ ///
"CHK = Yes (%)" \ ///
"CHF = Yes (%)" \ ///
"COPD = Yes (%)" \ ///
"Depression = Yes (%)" \ ///
"Diabetes = Yes (%)"  \  ///
"Glaucoma = Yes (%)"  \  ///
"Hyperl = Yes (%)" \  ///
"Hyperp = Yes (%)"  \  ///
"Hypert = Yes (%)"  \  ///
"Hypoth = Yes (%)"  \  ///
"Ischemicheart = Yes (%)"  \  ///
"Osteoporosis = Yes (%)"  \  ///
"RA OA = Yes (%)"  \  ///
"Stroke = Yes (%)"  \  ///
"Others = Yes (%)") ///
ctitles("","Overall","Inst.", "HCBS") ///
note() ///
replace
wordconvert "`logpath'/main_tab1.rtf" "`logpath'/main_tab1.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab1.docx, saving(`logpath'/main`ver', replace)





/*
preserve
gen year2005=1 if year==2005
replace year2005=0 if missing(year2005)
gen year2012=1 if year==2012
replace year2012=0 if missing(year2012)

graph hbar year2005 year2012,  ///
	over(hcbs, label(labsize(small))) stack percent ///
	blabel(bar, position(center) format(%2.1f) color(white)) ///
	legend(label(1 "Institutional Only") label(2 "HCBS Only") label(3 "Both") size(small)) ///
	title("Share LTSS Beneficiaries by Care Setting and IDD/SMI (n=`:display %9.0fc mat1[2,2]')", size(small)) ///
	ytitle("Percentage (%)", size(vsmall)) ///
	note("Note: IDD=Intellectual/Developmental Disabilities; SMI=Serious Mental Illness." "Source: 2012 MAX.", size(vsmall))
graph export `logpath'\ltss_setting_by_IDDxSMI.png, replace	
restore

  
preserve
mat mat1=J(3,3,.)
gen flag=1
sum flag if year==2005
mat mat1[1,1]=r(N)
sum flag if year==2012
mat mat1[1,2]=r(N)
mat mat1[1,3]=1
sum flag if year==2005 & hcbs==0
mat mat1[2,1]=r(N)
sum flag if year==2012 & hcbs==0
mat mat1[2,2]=r(N)
mat mat1[2,3]=2
sum flag if year==2005 & hcbs==1
mat mat1[3,1]=r(N)
sum flag if year==2012 & hcbs==1
mat mat1[3,2]=r(N)
mat mat1[3,3]=3
mat list mat1
clear	
svmat  mat1, names(col)
list
label def c3 1 "Overall" 2 "Institutional Care" ///
		      3 "HCBS"
label val c3 c3
graph hbar c1 c2,  ///
	over(c3, label(labsize(small))) stack percent ///
	blabel(bar, position(center) format(%2.1f) color(white)) ///
	legend(label(1 "2005") label(2 "2012") size(small)) ///
	ytitle("Percentage (%)", size(vsmall)) ///
	bar(1, color(192 192 192)) bar(2, color(100 100 100))
graph export `logpath'\ltss_setting_by_settingXyear.png, replace	
restore 
*/




/*
********************************************************************************
********************************************************************************
*Appendix Table 1 - by IV diff cat
local varlist hcbs age_cat white_ind female_ind elig_ind2 dem_ind  ///
			  cc_anemia_ind cc_asthma_ind cc_atrial_fib_ind  /// 
			  cc_cataract_ind cc_chronickidney_ind ///
			  cc_chf_ind cc_copd_ind cc_depression_ind cc_diabetes_ind cc_glaucoma_ind ///
			  cc_hyperl_ind cc_hyperp_ind cc_hypert_ind cc_hypoth_ind   ///
			  cc_ischemicheart_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			  cc_stroke_tia_ind cc_other
local group hcbs
local group1 iv_cat

preserve
gen elig_ind2=1 if elig_ind==0
replace elig_ind2=0 if elig_ind==1
merge m:1 st_cnty using `data'\df_iv_diff.dta
drop _merge
tab iv_cat
sum year 
mat mat1=r(N)
sum year if `group1'==0
mat mat2=r(N)
sum year if `group1'==1
mat mat3=r(N)
sum year if `group1'==2
mat mat4=r(N)
sum year if `group1'==3
mat mat5=r(N)

mat mat=mat1, mat2, mat3, mat4, mat5
mat list mat
local n_2 : word count `varlist'
mat matm=.,.,.,.,.
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1{
mat mat = mat \ matm
forvalue n1=`c1'/`c2'{
sum year if `var'==`n1'
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==`n1' & `group1'==0
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==`n1' & `group1'==1
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==`n1' & `group1'==2
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==`n1' & `group1'==3
mat mat5=r(N)/mat[1,5]*100

mat mat10= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat10
}
}
else {
sum year if `var'==1
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==1 & `group1'==0
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==1 & `group1'==1
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==1 & `group1'==2
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==1 & `group1'==3
mat mat5=r(N)/mat[1,5]*100

mat mat10= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat10
}
}
mat list mat
restore
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Appendix Table. Baseline Characterstics by IV Difference")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'/main_tab1.rtf, statmat(mat) sdec(0,0,0 \ 1,1,1) ///
rtitles("N" \ ///
"Setting - HCBS (%)" \ ///
"Age (%)" \ ///
"     65-69" \ ///
"     70-74" \ ///
"     75-79" \ ///
"     80-84" \ ///
"     85-89" \ ///
"     90+" \ ///
"Race - White (%)" \ ///
"Gender - Female (%)" \ ///
"Eligibility - Aged (%)" \ ///
"Dementia = Yes (%)" \ ///
"Anemia = Yes (%)" \ ///
"Asthma = Yes (%)" \ ///
"Atrial_Fib = Yes (%)" \ ///
"Cataract = Yes (%)" \ ///
"CHK = Yes (%)" \ ///
"CHF = Yes (%)" \ ///
"COPD = Yes (%)" \ ///
"Depression = Yes (%)" \ ///
"Diabetes = Yes (%)"  \  ///
"Glaucoma = Yes (%)"  \  ///
"Hyperl = Yes (%)" \  ///
"Hyperp = Yes (%)"  \  ///
"Hypert = Yes (%)"  \  ///
"Hypoth = Yes (%)"  \  ///
"Ischemicheart = Yes (%)"  \  ///
"Osteoporosis = Yes (%)"  \  ///
"RA OA = Yes (%)"  \  ///
"Stroke = Yes (%)"  \  ///
"Others = Yes (%)") ///
ctitles("","Overall","IV Diff=0","IV Diff=1", "IV Diff=2", "IV Diff=3") ///
colwidth(22 3 3 3 3 3) ///
note() ///
replace
wordconvert "`logpath'/main_tab1.rtf" "`logpath'/main_tab1.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab1.docx, saving(`logpath'/main`ver', replace)
*/
	

********************************************************************************
********************************************************************************
*Appendix Table 2 - Sample Characteristics by Care Setting and Race
local varlist age_cat white_ind female_ind elig_ind dem_ind  ///
			  cc_anemia_ind cc_asthma_ind cc_atrial_fib_ind  /// 
			  cc_cataract_ind cc_chronickidney_ind ///
			  cc_chf_ind cc_copd_ind cc_depression_ind cc_diabetes_ind cc_glaucoma_ind ///
			  cc_hyperl_ind cc_hyperp_ind cc_hypert_ind cc_hypoth_ind   ///
			  cc_ischemicheart_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			  cc_stroke_tia_ind cc_other
local group hcbs
local group1 white_ind

preserve
sum year 
mat mat1=r(N)
sum year if `group'==0 & `group1'==1
mat mat2=r(N)
sum year if `group'==1 & `group1'==1
mat mat3=r(N)
sum year if `group'==0 & `group1'==0
mat mat4=r(N)
sum year if `group'==1 & `group1'==0
mat mat5=r(N)
mat mat=mat1, mat2, mat3, mat4, mat5
mat list mat
local n_2 : word count `varlist'
mat matm=.,.,.,.,.
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1{
mat mat = mat \ matm
forvalue n1=`c1'/`c2'{
sum year if `var'==`n1'
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==`n1' & `group'==0 & `group1'==1
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==`n1' & `group'==1 & `group1'==1
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==`n1' & `group'==0 & `group1'==0
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==`n1' & `group'==1 & `group1'==0
mat mat5=r(N)/mat[1,5]*100
mat mat6= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat6
}
}
else {
sum year if `var'==1
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==1 & `group'==0 & `group1'==1
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==1 & `group'==1 & `group1'==1
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==1 & `group'==0 & `group1'==0
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==1 & `group'==1 & `group1'==0
mat mat5=r(N)/mat[1,5]*100
mat mat6= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat6
}
}
mat list mat
restore
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Appendix Table. Baseline Characterstics by Care Setting and Race")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'/main_tab1.rtf, statmat(mat) sdec(0,0,0 \ 1,1,1) ///
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
"Eligibility - Aged (%)" \ ///
"Dementia = Yes (%)" \ ///
"Anemia = Yes (%)" \ ///
"Asthma = Yes (%)" \ ///
"Atrial_Fib = Yes (%)" \ ///
"Cataract = Yes (%)" \ ///
"CHK = Yes (%)" \ ///
"CHF = Yes (%)" \ ///
"COPD = Yes (%)" \ ///
"Depression = Yes (%)" \ ///
"Diabetes = Yes (%)"  \  ///
"Glaucoma = Yes (%)"  \  ///
"Hyperl = Yes (%)" \  ///
"Hyperp = Yes (%)"  \  ///
"Hypert = Yes (%)"  \  ///
"Hypoth = Yes (%)"  \  ///
"Ischemicheart = Yes (%)"  \  ///
"Osteoporosis = Yes (%)"  \  ///
"RA OA = Yes (%)"  \  ///
"Stroke = Yes (%)"  \  ///
"Others = Yes (%)") ///
ctitles("","Overall","White","","Black", "",  \ "", "", "Inst.", "HCBS", "Inst.", "HCBS") ///
colwidth(22 3 3 3 3 3) ///
multicol(1,3,2;1,5,2) ///
note() ///
replace
wordconvert "`logpath'/main_tab1.rtf" "`logpath'/main_tab1.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab1.docx, saving(`logpath'/main`ver', replace)



********************************************************************************
********************************************************************************
*Appendix Table 3 - Sample Characteristics by Care Setting and Dementia
local varlist age_cat white_ind female_ind elig_ind dem_ind  ///
			  cc_anemia_ind cc_asthma_ind cc_atrial_fib_ind  /// 
			  cc_cataract_ind cc_chronickidney_ind ///
			  cc_chf_ind cc_copd_ind cc_depression_ind cc_diabetes_ind cc_glaucoma_ind ///
			  cc_hyperl_ind cc_hyperp_ind cc_hypert_ind cc_hypoth_ind   ///
			  cc_ischemicheart_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			  cc_stroke_tia_ind cc_other
local group hcbs
local group1 dem_ind

preserve
sum year 
mat mat1=r(N)
sum year if `group'==0 & `group1'==0
mat mat2=r(N)
sum year if `group'==1 & `group1'==0
mat mat3=r(N)
sum year if `group'==0 & `group1'==1
mat mat4=r(N)
sum year if `group'==1 & `group1'==1
mat mat5=r(N)
mat mat=mat1, mat2, mat3, mat4, mat5
mat list mat
local n_2 : word count `varlist'
mat matm=.,.,.,.,.
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1{
mat mat = mat \ matm
forvalue n1=`c1'/`c2'{
sum year if `var'==`n1'
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==`n1' & `group'==0 & `group1'==0
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==`n1' & `group'==1 & `group1'==0
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==`n1' & `group'==0 & `group1'==1
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==`n1' & `group'==1 & `group1'==1
mat mat5=r(N)/mat[1,5]*100
mat mat6= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat6
}
}
else {
sum year if `var'==1
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==1 & `group'==0 & `group1'==0
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==1 & `group'==1 & `group1'==0
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==1 & `group'==0 & `group1'==1
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==1 & `group'==1 & `group1'==1
mat mat5=r(N)/mat[1,5]*100
mat mat6= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat6
}
}
mat list mat
restore
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Table 1. Baseline Characterstics by Care Setting and Dementia")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'/main_tab1.rtf, statmat(mat) sdec(0,0,0 \ 1,1,1) ///
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
"Eligibility - Aged (%)" \ ///
"Dementia = Yes (%)" \ ///
"Anemia = Yes (%)" \ ///
"Asthma = Yes (%)" \ ///
"Atrial_Fib = Yes (%)" \ ///
"Cataract = Yes (%)" \ ///
"CHK = Yes (%)" \ ///
"CHF = Yes (%)" \ ///
"COPD = Yes (%)" \ ///
"Depression = Yes (%)" \ ///
"Diabetes = Yes (%)"  \  ///
"Glaucoma = Yes (%)"  \  ///
"Hyperl = Yes (%)" \  ///
"Hyperp = Yes (%)"  \  ///
"Hypert = Yes (%)"  \  ///
"Hypoth = Yes (%)"  \  ///
"Ischemicheart = Yes (%)"  \  ///
"Osteoporosis = Yes (%)"  \  ///
"RA OA = Yes (%)"  \  ///
"Stroke = Yes (%)"  \  ///
"Others = Yes (%)") ///
ctitles("","Overall","Non-Dementia","","Dementia", "", \ "", "", "Inst.", "HCBS", "Inst.", "HCBS") ///
colwidth(22 3 3 3 3 3) ///
multicol(1,3,2;1,5,2) ///
note() ///
replace
wordconvert "`logpath'/main_tab1.rtf" "`logpath'/main_tab1.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab1.docx, saving(`logpath'/main`ver', replace)



********************************************************************************
********************************************************************************
*Appendix Table 4 - Sample Characteristics by Quartile of HCBS Spending among HCBS Users

gen expend_hcbs_cpi=expend_hcbs*1.19 if year==2005
replace expend_hcbs_cpi=expend_hcbs if year==2012

egen p25 = pctile(expend_hcbs_cpi) if hcbs==1, p(25)
egen p50 = pctile(expend_hcbs_cpi) if hcbs==1, p(50)
egen p75 = pctile(expend_hcbs_cpi) if hcbs==1, p(75)
gen expend_hcbs_cat=0 if expend_hcbs_cpi<p25 & hcbs==1
replace expend_hcbs_cat=1 if expend_hcbs_cpi<p50 & expend_hcbs_cat==. & hcbs==1
replace expend_hcbs_cat=2 if expend_hcbs_cpi<p75 & expend_hcbs_cat==. & hcbs==1
replace expend_hcbs_cat=3 if expend_hcbs_cat==. & hcbs==1

local varlist age_cat white_ind female_ind elig_ind dem_ind  ///
			  cc_anemia_ind cc_asthma_ind cc_atrial_fib_ind  /// 
			  cc_cataract_ind cc_chronickidney_ind ///
			  cc_chf_ind cc_copd_ind cc_depression_ind cc_diabetes_ind cc_glaucoma_ind ///
			  cc_hyperl_ind cc_hyperp_ind cc_hypert_ind cc_hypoth_ind   ///
			  cc_ischemicheart_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			  cc_stroke_tia_ind cc_other

local group1 expend_hcbs_cat

preserve
keep if hcbs==1
sum year 
mat mat1=r(N)
sum year if `group1'==0
mat mat2=r(N)
sum year if `group1'==1 
mat mat3=r(N)
sum year if `group1'==2 
mat mat4=r(N)
sum year if `group1'==3
mat mat5=r(N)
mat mat=mat1, mat2, mat3, mat4, mat5
mat list mat
local n_2 : word count `varlist'
mat matm=.,.,.,.,.
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1{
mat mat = mat \ matm
forvalue n1=`c1'/`c2'{
sum year if `var'==`n1'
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==`n1' & `group1'==0
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==`n1' & `group1'==1 
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==`n1' & `group1'==2 
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==`n1' & `group1'==3 
mat mat5=r(N)/mat[1,5]*100
mat mat6= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat6
}
}
else {
sum year if `var'==1
mat mat1=r(N)/mat[1,1]*100
sum year if `var'==1 & `group1'==0 
mat mat2=r(N)/mat[1,2]*100
sum year if `var'==1 & `group1'==1 
mat mat3=r(N)/mat[1,3]*100
sum year if `var'==1 & `group1'==2
mat mat4=r(N)/mat[1,4]*100
sum year if `var'==1 & `group1'==3 
mat mat5=r(N)/mat[1,5]*100
mat mat6= mat1,mat2,mat3,mat4,mat5
mat mat = mat \ mat6
}
}
mat list mat
restore
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Appendix Table. Sample Characteristics by Quartile of HCBS Spending among HCBS Users")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'/main_tab1.rtf, statmat(mat) sdec(0,0,0 \ 1,1,1) ///
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
"Eligibility - Aged (%)" \ ///
"Dementia = Yes (%)" \ ///
"Anemia = Yes (%)" \ ///
"Asthma = Yes (%)" \ ///
"Atrial_Fib = Yes (%)" \ ///
"Cataract = Yes (%)" \ ///
"CHK = Yes (%)" \ ///
"CHF = Yes (%)" \ ///
"COPD = Yes (%)" \ ///
"Depression = Yes (%)" \ ///
"Diabetes = Yes (%)"  \  ///
"Glaucoma = Yes (%)"  \  ///
"Hyperl = Yes (%)" \  ///
"Hyperp = Yes (%)"  \  ///
"Hypert = Yes (%)"  \  ///
"Hypoth = Yes (%)"  \  ///
"Ischemicheart = Yes (%)"  \  ///
"Osteoporosis = Yes (%)"  \  ///
"RA OA = Yes (%)"  \  ///
"Stroke = Yes (%)"  \  ///
"Others = Yes (%)") ///
ctitles("","Overall","Spending", "", "", "" \ "", "", "Q1", "Q2", "Q3", "Q4") ///
colwidth(22 3 3 3 ) ///
multicol(1,3,2;1,5,4) ///
note() ///
replace
wordconvert "`logpath'/main_tab1.rtf" "`logpath'/main_tab1.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab1.docx, saving(`logpath'/main`ver', replace)



*Appendix Table 7. Sample Size by Month of First Long-Term Care Service
********************************************************************************
********************************************************************************
**Month distribution - First Service Date
forvalues n=0/12{
preserve
keep if exclusion==0
if `n'==0{
sum year 
mat mat1=r(N)
mat mat2=100
mat mat3 = mat1, mat2
mat mat=mat3
}
else{
keep if svc_first_month==`n'
sum year 
mat mat1=r(N)
mat mat2=mat1/mat[1,1]*100
mat mat3 = mat1, mat2
mat mat=mat\mat3
}
restore
}
mat list mat

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Table: Sample Size for Each Stratification")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'/main_tab1.rtf, statmat(mat) sdec(0,1) ///
rtitles("Overall" \ ///
"Jan" \ ///
"Feb" \ ///
"Mar" \ ///
"Apr" \ ///
"May" \ ///
"Jun" \ ///
"Jul" \ ///
"Aug" \ ///
"Sep" \ ///
"Oct" \ ///
"Nov" \ ///
"Dec")  ///
ctitles("","N","%") ///
note() ///
replace
wordconvert "`logpath'/main_tab1.rtf" "`logpath'/main_tab1.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab1.docx, saving(`logpath'/main`ver', replace)









/*
********************************************************************************
**Define HCBS based on people with personal care and home health care
********************************************************************************

local outcomelist1 "hcbs hosp pqi"
local list1 "0 0 1 1"
local list2 "0 1 0 1"
forvalues n2=1/3{
local outcome : word `n2' of `outcomelist1'
forvalues n=1/4{
preserve
keep if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1|hcbs_waiver_cltc34==1|cltc_exp_gt0_14_3m==1| ///
	hcbs_waiver_cltc37==1|cltc_exp_gt0_17==1|hcbs==0
local word1 : word `n' of `list1'
local word2 : word `n' of `list2'
collapse (mean) `outcome' if race_cat==`word1'&ccw_both_alz_dem==`word2', by(st_cnty_num)
gen exclusion_`outcome'`n'_svc=1 if `outcome'==1|`outcome'==0
replace exclusion_`outcome'`n'_svc=0 if exclusion_`outcome'`n'_svc==.
tab exclusion_`outcome'`n'_svc
keep st_cnty exclusion_`outcome'`n'_svc
save `data'\hcbs_cnty_exclusion_`outcome'`n'_svc, replace
restore
merge m:1 st_cnty_num using `data'\hcbs_cnty_exclusion_`outcome'`n'_svc.dta
drop _merge
}
}
gen exclusion_svc=0 if exclusion_hcbs1_svc==0&exclusion_hcbs2_svc==0&exclusion_hcbs3_svc==0&exclusion_hcbs4_svc==0& ///
				   exclusion_pqi1_svc==0&exclusion_pqi2_svc==0&exclusion_pqi3_svc==0&exclusion_pqi4_svc==0 & ///
				   exclusion_hcbs1_svc==0&exclusion_hcbs2_svc==0&exclusion_hcbs3_svc==0&exclusion_hcbs4_svc==0
replace exclusion_svc=1 if exclusion_svc==.
tab exclusion_svc

**Define HCBS as people with transportation
local outcomelist1 "hcbs hosp pqi"
local grouplist trans nontrans
local list1 "0 0 1 1"
local list2 "0 1 0 1"
forvalues n3=1/2{
forvalues n2=1/3{
local outcome : word `n2' of `outcomelist1'
local group : word `n3' of `grouplist'
forvalues n=1/4{
preserve
if `n3'==1{
keep if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1|hcbs==0
}
else {
drop if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1
}
local word1 : word `n' of `list1'
local word2 : word `n' of `list2'

collapse (mean) `outcome' if race_cat==`word1'&ccw_both_alz_dem==`word2', by(st_cnty_num)
gen exclusion_`outcome'`n'_`group'=1 if `outcome'==1|`outcome'==0
replace exclusion_`outcome'`n'_`group'=0 if exclusion_`outcome'`n'_`group'==.
tab exclusion_`outcome'`n'_`group'
keep st_cnty exclusion_`outcome'`n'_`group'
save `data'\hcbs_cnty_exclusion_`outcome'`n'_`group', replace
restore
merge m:1 st_cnty_num using `data'\hcbs_cnty_exclusion_`outcome'`n'_`group'.dta
drop _merge
}
}
gen exclusion_`group'=0 if exclusion_hcbs1_`group'==0&exclusion_hcbs2_`group'==0&exclusion_hcbs3_`group'==0&exclusion_hcbs4_`group'==0& ///
				   exclusion_pqi1_`group'==0&exclusion_pqi2_`group'==0&exclusion_pqi3_`group'==0&exclusion_pqi4_`group'==0 & ///
				   exclusion_hcbs1_`group'==0&exclusion_hcbs2_`group'==0&exclusion_hcbs3_`group'==0&exclusion_hcbs4_`group'==0
replace exclusion_`group'=1 if exclusion_`group'==.
tab exclusion_`group'
}

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local ver "0303"
**Define HCBS as people with other
local outcomelist1 "hcbs hosp pqi"
local list1 "0 0 1 1"
local list2 "0 1 0 1"
forvalues n2=1/3{
local outcome : word `n2' of `outcomelist1'
forvalues n=1/4{
preserve
keep if hcbs_waiver_cltc30==1|hcbs==0

local word1 : word `n' of `list1'
local word2 : word `n' of `list2'

collapse (mean) `outcome' if race_cat==`word1'&ccw_both_alz_dem==`word2', by(st_cnty_num)
gen exclusion_`outcome'`n'_others=1 if `outcome'==1|`outcome'==0
replace exclusion_`outcome'`n'_others=0 if exclusion_`outcome'`n'_others==.
tab exclusion_`outcome'`n'_others
keep st_cnty exclusion_`outcome'`n'_others
save `data'\hcbs_cnty_exclusion_`outcome'`n'_others, replace
restore
merge m:1 st_cnty_num using `data'\hcbs_cnty_exclusion_`outcome'`n'_others.dta
drop _merge
}
}
local svc others
gen exclusion_`svc'=0 if exclusion_hcbs1_`svc'==0&exclusion_hcbs2_`svc'==0&exclusion_hcbs3_`svc'==0&exclusion_hcbs4_`svc'==0& ///
				   exclusion_pqi1_`svc'==0&exclusion_pqi2_`svc'==0&exclusion_pqi3_`svc'==0&exclusion_pqi4_`svc'==0 & ///
				   exclusion_hcbs1_`svc'==0&exclusion_hcbs2_`svc'==0&exclusion_hcbs3_`svc'==0&exclusion_hcbs4_`svc'==0
replace exclusion_`svc'=1 if exclusion_`svc'==.
tab exclusion_`svc'

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local ver "0303"
**$efine HCBS as people with other
local outcomelist1 "hcbs hosp pqi"
local list1 "0 0 1 1"
local list2 "0 1 0 1"
forvalues n2=1/3{
local outcome : word `n2' of `outcomelist1'
forvalues n=1/4{
preserve
keep if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1|hcbs==0

local word1 : word `n' of `list1'
local word2 : word `n' of `list2'

collapse (mean) `outcome' if race_cat==`word1'&ccw_both_alz_dem==`word2', by(st_cnty_num)
gen exclusion_`outcome'`n'_personal=1 if `outcome'==1|`outcome'==0
replace exclusion_`outcome'`n'_personal=0 if exclusion_`outcome'`n'_personal==.
tab exclusion_`outcome'`n'_personal
keep st_cnty exclusion_`outcome'`n'_personal
save `data'\hcbs_cnty_exclusion_`outcome'`n'_personal, replace
restore
merge m:1 st_cnty_num using `data'\hcbs_cnty_exclusion_`outcome'`n'_personal.dta
drop _merge
}
}
local svc personal
gen exclusion_`svc'=0 if exclusion_hcbs1_`svc'==0&exclusion_hcbs2_`svc'==0&exclusion_hcbs3_`svc'==0&exclusion_hcbs4_`svc'==0& ///
				   exclusion_pqi1_`svc'==0&exclusion_pqi2_`svc'==0&exclusion_pqi3_`svc'==0&exclusion_pqi4_`svc'==0 & ///
				   exclusion_hcbs1_`svc'==0&exclusion_hcbs2_`svc'==0&exclusion_hcbs3_`svc'==0&exclusion_hcbs4_`svc'==0
replace exclusion_`svc'=1 if exclusion_`svc'==.
tab exclusion_`svc'
*/


/*
********************************************************************************
********************************************************************************
**1) Main: County-level Fixed effect - Personal Care/Home Health/Adult day care
**2) Main: County-level Fixed effect - Transportation
********************************************************************************
local predictor iv_cnty_young
local titlelist cnty_non_trans cnty_nontrans cnty_trans cnty_other cnty_personal
local clusterlist `""i.st_cnty_num" "i.st_cnty_num"  "i.st_cnty_num" "i.st_cnty_num" "i.st_cnty_num""'
local clusterlist2 `""cluster(st_cnty_num)" "cluster(st_cnty_num)" "cluster(st_cnty_num)" "cluster(st_cnty_num)" "cluster(st_cnty_num)" "'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"

local n_3 : word count `clusterlist'
local n_2 : word count `outcomelist'

local outcomelist "hosp pqi"
forvalues n3=2/3{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/1{
forvalues n=1/9{
local r=`n'
local outcome : word `n2' of `outcomelist'
**1) Any Hospitalization
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
keep if race_cat==0 & ccw_both_alz_dem==0
}
else if `n'==6{
keep if race_cat==1 & ccw_both_alz_dem==0
}
else if `n'==7{
keep if ccw_both_alz_dem==1
}
else if `n'==8{
keep if race_cat==0 & ccw_both_alz_dem==1
}
else if `n'==9{
keep if race_cat==1 & ccw_both_alz_dem==1
}
tab year

keep if exclusion==0

if `n3'==1{
keep if exclusion_svc==0
keep if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1|hcbs_waiver_cltc34==1|cltc_exp_gt0_14_3m==1| ///
	hcbs_waiver_cltc37==1|cltc_exp_gt0_17==1|hcbs==0
}
else if `n3'==2{	
keep if exclusion_nontrans==0
drop if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1	
}
else if `n3'==3{	
keep if exclusion_trans==0
keep if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1|hcbs==0	
}
else if `n3'==4{	
keep if exclusion_others==0
keep if hcbs_waiver_cltc30==1|hcbs==0	
}
else if `n3'==5{	
keep if exclusion_others==0
keep if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1|hcbs==0
}
else if `n3'==6{	
keep if exclusion_trans_only==0
keep if trans_only==1|hcbs==0	
}
tab year

*without IV		 
logit `outcome' i.hcbs i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
*		 

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
keep if race_cat==0 & ccw_both_alz_dem==0
}
else if `n'==6{
keep if race_cat==1 & ccw_both_alz_dem==0
}
else if `n'==7{
keep if ccw_both_alz_dem==1
}
else if `n'==8{
keep if race_cat==0 & ccw_both_alz_dem==1
}
else if `n'==9{
keep if race_cat==1 & ccw_both_alz_dem==1
}

keep if exclusion==0

if `n3'==1{
keep if exclusion_svc==0
keep if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1|hcbs_waiver_cltc34==1|cltc_exp_gt0_14_3m==1| ///
	hcbs_waiver_cltc37==1|cltc_exp_gt0_17==1|hcbs==0
}
else if `n3'==2{	
keep if exclusion_nontrans==0
drop if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1	
}
else if `n3'==3{	
keep if exclusion_trans==0
keep if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1|hcbs==0	
}
else if `n3'==4{	
keep if exclusion_others==0
keep if hcbs_waiver_cltc30==1|hcbs==0	
}
else if `n3'==5{	
keep if exclusion_others==0
keep if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1|hcbs==0
}
else if `n3'==6{	
keep if exclusion_trans_only==0
keep if trans_only==1|hcbs==0	
}

logit hcbs `predictor' i.age_cat i.female_ind i.race_cat c.svc_first_month ///
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year `cluster', robust `cluster2'
	 
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
			 i.elig_ind i.cc_count_cat10 i.ccw_both_alz_dem i.year `cluster' re, robust `cluster2'
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

mat mat1`outcome'_`title'=mat1'
mat mat2`outcome'_`title'=mat2'
mat mat3`outcome'_`title'=mat3'
mat mat4`outcome'_`title'=mat2', mat3'
}
}



********************************************************************************
********************************************************************************
**Table

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local ver "trans"
local predictor iv_cnty_young
local titlelist cnty_non_trans cnty_trans cnty_other cnty_personal
local clusterlist `""i.st_cnty_num" "i.st_cnty_num" "i.st_cnty_num" "i.st_cnty_num""'
local clusterlist2 `""cluster(st_cnty_num)" "cluster(st_cnty_num)" "cluster(st_cnty_num)""'
local word1 woiv
local word2 iv
local outcomelist "hosp pqi"

local n_3 : word count `clusterlist'
local n_2 : word count `outcomelist'



forvalues n3=4/`n_3'{
local title : word `n3' of `titlelist'
local cluster : word `n3' of `clusterlist'
local cluster2 : word `n3' of `clusterlist2'
forvalues n2=1/1{
local outcome : word `n2' of `outcomelist'

				   
putdocx begin
putdocx paragraph, style(Heading1)
if `n3'==1{
putdocx text ("Main Model, Personal Care/Home Health/Adult day care")
putdocx save `logpath'\main`ver'.docx, replace
}
else {
putdocx text ("Main Model, Transportation")
putdocx save `logpath'\main`ver'.docx, append
}
frmttable using `logpath'\main_tab.rtf, statmat(mat1`outcome'_`title') sdec(3) ///
rtitles("Overall" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"White" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Black" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Overall, No Dementia" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"White, No Dementia" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Black, No Dementia" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Overall, Dementia" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"White, Dementia" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS" \ ///
		"Black, Dementia" ,"Without IV", "HCBS" \ ///
		"" ,"With IV", "HCBS")  ///
ctitles("Group" "Model" "Variable" "Coef." "p" "95% CI" "" \ ///
		"" "" "" "" "" "Low" "High") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main`ver', replace)


putdocx begin
putdocx paragraph
putdocx text ("IV Test")
putdocx save `logpath'\main`ver'.docx, append
frmttable using `logpath'\main_tab.rtf, statmat(mat4`outcome'_`title') sdec(3) ///
rtitles("Overall" \ "White" \ "Black" \ ///
		"Overall, No Dementia" \ "White, No Dementia" \ "Black, No Dementia" \ ///
		"Overall, Dementia" \ "White, Dementia" \ "Black, Dementia")  ///
ctitles("Group" "Coef." "p" "95% CI" "" "F"  \ /// 
		"" "" "" "Low" "High" "") ///
replace
wordconvert "`logpath'/main_tab.rtf" "`logpath'/main_tab.docx", replace
putdocx append `logpath'/main`ver'.docx `logpath'/main_tab.docx, saving(`logpath'/main`ver', replace)


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
append using `data'\dt_`outcome'_`title'_`word'9.dta
mkmat c1 c2, matrix(`word')
mat colnames `word' = hcbs0 hcbs1
mat race =     (0\1\2\0\1\2\0\1\2)
mat dementia = (0\0\0\1\1\1\2\2\2)
mat colnames race = race
mat colnames dementia = dementia
mat list race
mat list dementia
mat full`n4'=race, dementia, `word'
mat list full`n4'
restore


preserve
clear
svmat full`n4', names(col)
label def race 0 "Overall" 1 "White" 2"Black"  
la val race race
label def dementia 0 "Overall" 1 "Dementia: No" 2"Dementia: Yes"
la val dementia dementia
save `data'\dt_`outcome'_`title'_`word'.dta, replace
use `data'\dt_`outcome'_`title'_`word'.dta, replace
graph bar (mean) hcbs0 hcbs1, bargap(20)  ///
legend(lab(1 "Inst.") lab(2 "HCBS") size(vsmall)) ///
bar(1, color("243 66 85")) bar(2, color("47 127 137")) ///
 over(race, relabel(1 "Overall" 2 "White" 3 "Black") label(labsize(vsmall))) ///
 by(dementia, noiy note("") row(1))  ///
 blabel(bar, format(%9.1f) color(black) size(vsmall)) ///
 ytitle("Percentage (%)", size(small))  ///
 graphregion(fcolor(white)) ylabel(0 (10) 50,labsize(vsmall)) subtitle(, size(small)) 
graph export `logpath'\result_`outcome'_`title'_`word'.png, replace	
restore	 
}

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
*/



************************************************************************************************************************************************************************









********************************************************************************
********************************************************************************
**Table: Baseline characteristics 
********************************************************************************
********************************************************************************

**Develop service indicator variable and spending variable
gen personal_care=1 if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1
replace personal_care=0 if personal_care==.
gen private_duty_nursing=1 if hcbs_waiver_cltc32==1|cltc_exp_gt0_12==1
replace private_duty_nursing=0 if private_duty_nursing==.
gen adult_day_care=1 if hcbs_waiver_cltc33==1|cltc_exp_gt0_13==1
replace adult_day_care=0 if adult_day_care==.
gen home_health=1 if hcbs_waiver_cltc34==1|cltc_exp_gt0_14==1
replace home_health=0 if home_health==.
gen residential_care=1 if hcbs_waiver_cltc35==1|cltc_exp_gt0_15==1
replace residential_care=0 if residential_care==.
gen rehabilitation=1 if hcbs_waiver_cltc36==1|cltc_exp_gt0_16==1
replace rehabilitation=0 if rehabilitation==.
gen target_case=1 if hcbs_waiver_cltc37==1|cltc_exp_gt0_17==1
replace target_case=0 if target_case==.
gen transportation=1 if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1
replace transportation=0 if transportation==.
gen trans=1 if hcbs_waiver_cltc38==1|cltc_exp_gt0_18==1
replace trans=0 if trans==.
gen hospice=1 if hcbs_waiver_cltc39==1|cltc_exp_gt0_19==1
replace hospice=0 if hospice==.
gen others=1 if hcbs_waiver_cltc30==1
replace others=0 if others==.
gen dme=1 if hcbs_waiver_cltc40==1
replace dme=0 if dme==.

local list "transportation personal_care target_case home_health rehabilitation private_duty_nursing adult_day_care residential_care hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40"
local n : word count `list'
forvalues a=1/`n'{
local svc : word `a' of `list'

if `a'==1{
gen trans_only=1 if `svc'==1
}
else {
replace trans_only=0 if trans_only==1&`svc'==1 
}
}
replace trans_only=0 if trans_only==.
tab trans_only
tab trans_only transportation

local list "personal_care private_duty_nursing adult_day_care home_health residential_care rehabilitation target_case transportation hospice "
local n_1 : word count `list'
forvalues n1=1/`n_1'{
local svc1 : word `n1' of `list'
local svc2=`n1'+30
local svc3=`n1'+10
replace expend_wvr`svc2'=0 if expend_wvr`svc2'==.
replace expend_state`svc3'=0 if expend_state`svc3'==.
gen expend_`svc1'=expend_wvr`svc2'+expend_state`svc3'
replace expend_`svc1'=0 if expend_`svc1'==.
}

gen expend_others=expend_wvr30
replace expend_others=0 if expend_others==.
gen expend_dme=expend_wvr40
replace expend_dme=0 if expend_dme==.


	

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
local varlist age_cat white_ind female_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  personal_care target_case home_health rehabilitation ///
			  private_duty_nursing adult_day_care residential_care ///
			  transportation hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  expend_hcbs hosp
			 
local group expend_hcbs_ind
preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
sum expend_hcbs_ind
local a1=r(min)
local a2=r(max)
local r=1
sum flag 
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
sum flag if `var'==`n1' & expend_hcbs_ind==`n3'
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
sum flag if `var'==1 & expend_hcbs_ind==`n3'
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
sum `var' if expend_hcbs_ind==`n3' 
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}

}
mat mat_full = mat
restore


mat list mat_full
frmttable using `logpath'/table1_hcbs_exp.rtf, statmat(mat_full) sdec(0,0,0 \ 1,1,1) ///
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
ctitles("","Overall","Blw", "Abv") ///
colwidth(22 3 3 3) ///
note() ///
replace
wordconvert "`logpath'/table1_hcbs_exp.rtf" "`logpath'/table1_hcbs_exp.docx", replace
	

	

	
/*
*characteristics by spending Q
local varlist age_cat white_ind female_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  personal_care target_case home_health rehabilitation ///
			  private_duty_nursing adult_day_care residential_care ///
			  transportation hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  expend_hcbs hosp
			 
local group expend_hcbs_cat
preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem

sum expend_hcbs_cat
local a1=r(min)
local a2=r(max)
local r=1
sum flag 
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
frmttable using `logpath'/table1_hcbs_exp4.rtf, statmat(mat_full) sdec(0,0,0 \ 1,1,1) ///
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
wordconvert "`logpath'/table1_hcbs_exp4.rtf" "`logpath'/table1_hcbs_exp4.docx", replace
	
*/	
	
	
	
/*
*Among HCBS, characteristics - by type of service / by transportation 			 
local varlist age_cat white_ind female_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  personal_care target_case home_health rehabilitation ///
			  private_duty_nursing adult_day_care residential_care ///
			  transportation hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  expend_hcbs hosp
local sublist "personal_care home_health trans target_case hcbs_waiver_cltc30 hcbs_waiver_cltc40 trans"
local titlelist "personal_care home_health trans target_care others DME trans_wo_hh"
local n_5 : word count `sublist'

forvalues n5=1/`n_5'{
local sub : word `n5' of `sublist'
local title : word `n5' of `titlelist'
preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem

if `n5'==7{
keep if home_health==0
}
sum `sub'
local b1=r(min)
local b2=r(max)
local r=1
sum flag
mat mat`r'=r(N)
mat mat=mat`r'
mat matm=.
forvalues n2=`b1'/`b2'{

local r=`r'+1
sum flag if `sub'==`n2'
mat mat`r'=r(N)
mat mat=mat, mat`r'
mat matm=matm, .
}

local n_4 : word count `varlist'
forvalues n4=1/`n_4' {
local var : word `n4' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1&`c2'<10{
mat mat = mat \ matm
forvalue n3=`c1'/`c2'{
local r=1
sum flag if `var'==`n3'
mat mat1=r(N)/mat[1,1]*100
mat mat_full1=mat1
forvalues n2=`b1'/`b2'{
local r=`r'+1
sum flag if `var'==`n3'  & `sub'==`n2'
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}
}
else if `c2'==1{
local r=1
sum flag if `var'==1
mat mat1=r(N)/mat[1,1]*100
mat mat_full1=mat1
forvalues n2=`b1'/`b2'{
local r=`r'+1
sum flag if `var'==1 & `sub'==`n2'
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}

else if `c2'>10{
local r=1
sum `var' 
mat mat1=r(mean)
mat mat_full1=mat1
forvalues n2=`b1'/`b2'{
local r=`r'+1
sum `var' if `sub'==`n2'
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}
}
mat full = mat
restore
mat list full

if `n5'==1 {
local a `""","Overall","Non-Personal Care", "Personal Care" "'
}
else if `n5'==2 {
local a `""","Overall","Non-Home Health", "Home Health""'
}
else if `n5'==3 {
local a `""","Overall","Non-Trans",  "Trans" "'
}
else if `n5'==4 {
local a `""","Overall","Non-Target care", "Target Care""'
}
else if `n5'==5 {
local a `""","Overall","Non-Others", "Others" "'
}
else if `n5'==6 {
local a `""","Overall","Non-DME", "DME" "'
}
else if `n5'==7 {
local a `""","Overall","Non-Trans", "Trans""'
}

frmttable using `logpath'/table1_bin_`title'.rtf,  statmat(full) sdec(0 \ 1) ///
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
ctitles(`a') ///
colwidth(22 3 3 ) ///
note() ///
replace
wordconvert "`logpath'/table1_bin_`title'.rtf" "`logpath'/table1_bin_`title'.docx", replace		
}


		 
local varlist age_cat white_ind female_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  personal_care target_case home_health rehabilitation ///
			  private_duty_nursing adult_day_care residential_care ///
			  transportation hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  expend_hcbs hosp
local sublist "personal_care home_health trans target_case hcbs_waiver_cltc30 hcbs_waiver_cltc40 trans trans_only"
local titlelist "personal_care home_health trans target_care others DME trans_wo_hh trans_only"
local n_5 : word count `sublist'

forvalues n5=1/`n_5'{
local sub : word `n5' of `sublist'
local title : word `n5' of `titlelist'
preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
if `n5'==7{
keep if home_health==0
}
sum expend_hcbs_ind
local a1=r(min)
local a2=r(max)
sum `sub'
local b1=r(min)
local b2=r(max)
local r=1
sum flag
mat mat`r'=r(N)
mat mat=mat`r'
mat matm=.
forvalues n2=`b1'/`b2'{
forvalues n1=`a1'/`a2'{
local r=`r'+1
sum flag if expend_hcbs_ind==`n1' & `sub'==`n2'
mat mat`r'=r(N)
mat mat=mat, mat`r'
mat matm=matm, .
}
}
local n_4 : word count `varlist'
forvalues n4=1/`n_4' {
local var : word `n4' of `varlist'
sum `var'
local c1=r(min)
local c2=r(max)
if `c2'>1&`c2'<10{
mat mat = mat \ matm
forvalue n3=`c1'/`c2'{
local r=1
sum flag if `var'==`n3'
mat mat1=r(N)/mat[1,1]*100
mat mat_full1=mat1
forvalues n2=`b1'/`b2'{
forvalues n1=`a1'/`a2'{
local r=`r'+1
sum flag if `var'==`n3' & expend_hcbs_ind==`n1' & `sub'==`n2'
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat_full1, mat`r'
}
}
mat mat=mat\mat_full1
}
}
else if `c2'==1{
local r=1
sum flag if `var'==1
mat mat1=r(N)/mat[1,1]*100
mat mat_full1=mat1
forvalues n2=`b1'/`b2'{
forvalues n1=`a1'/`a2'{
local r=`r'+1
sum flag if `var'==1 & expend_hcbs_ind==`n1' & `sub'==`n2'
mat mat`r'=r(N)/mat[1,`r']*100
mat mat_full1=mat_full1, mat`r'
}
}
mat mat=mat\mat_full1
}

else if `c2'>10{
local r=1
sum `var' 
mat mat1=r(mean)
mat mat_full1=mat1
forvalues n2=`b1'/`b2'{
forvalues n1=`a1'/`a2'{
local r=`r'+1
sum `var' if expend_hcbs_ind==`n1' & `sub'==`n2'
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
}
mat mat=mat\mat_full1
}
}
mat full = mat
restore
mat list full

if `n5'==1 {
local a `""","Overall","Non-Personal Care", "", "Personal Care", "" \ "","","blw","abv","blw","abv""'
local b `"1,3,2;1,5,2"'
}
else if `n5'==2 {
local a `""","Overall","Non-Home Health", "", "Home Health", "" \ "","", "blw","abv","blw","abv""'
local b `"1,3,2;1,5,2"'
}
else if `n5'==3 {
local a `""","Overall","Non-Trans", "", "Trans", "" \ "","", "blw","abv","blw","abv""'
local b `"1,3,2;1,5,2"'
}
else if `n5'==4 {
local a `""","Overall","Non-Target care", "", "Target Care", "" \ "","", "blw","abv","blw","abv""'
local b `"1,3,2;1,5,2"'
}
else if `n5'==5 {
local a `""","Overall","Non-Others", "", "Others", "" \ "","", "blw","abv","blw","abv""'
local b `"1,3,2;1,5,2"'
}
else if `n5'==6 {
local a `""","Overall","Non-DME", "", "DME", "" \ "","","blw","abv","blw","abv""'
local b `"1,3,2;1,5,2"'
}
else if `n5'==7 {
local a `""","Overall","Non-Trans", "", "Trans", "" \ "","","blw","abv","blw","abv""'
local b `"1,3,2;1,5,2"'

}

frmttable using `logpath'/table1_`title'.rtf,  statmat(full) sdec(0 \ 1) ///
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
ctitles(`a') ///
colwidth(22 3 3 3 3 3) ///
multicol(`b') ///
note() ///
replace
wordconvert "`logpath'/table1_`title'.rtf" "`logpath'/table1_`title'.docx", replace		
}

*/

/*
*transportation service users 
local list "transportation trans_only "
local n_1 : word count `list'
preserve
keep if hcbs==1
forvalues n1=1/`n_1'{
local svc : word `n1' of `list'
sum `svc'
mat mat1=r(mean)*100
mat mat_full=mat1
if `n1'==1{
mat mat=mat_full
}
else{
mat mat=mat\mat_full
}
}
mat list mat
mat svc_type=1\2
mat colnames svc_type=svc_type
mat colnames mat=svc1
mat list mat
mat full=mat, svc_type
restore


preserve
clear
svmat full, names(col)
la def svc_type 1 "Transportation" 2"Trans Only",replace
label val svc_type svc_type	
local vlist svc1
makelegendlabelsfromvarlabels `vlist', local(relabellegend) c(30)
graph hbar svc1, intensity(100) ///
	over(svc_type, label(labsize(small)) gap(50)) ///
	bar(1, color("22 137 128")) bar(2, color("102 102 102"))   ///
	legend(size(vsmall) `relabellegend') ///
	ylabel(0 (20) 60) ytitle("(%)", size(vsmall)) ///
	ysize(4.1) xsize(6.6)
graph export `logpath'\trans_only.png, replace	
restore


local list "transportation trans_only trans_other"
local n_1 : word count `list'
forvalues n1=1/`n_1'{
local svc : word `n1' of `list'
preserve
gen trans_other=1 if trans_only==0&transportation==1
keep if hcbs==1
keep if `svc'==1
sum hosp
mat mat1=r(mean)*100
mat mat_full=mat1
if `n1'==1{
mat mat=mat_full
}
else{
mat mat=mat\mat_full
}
restore
}
mat list mat
mat svc_type=1\2\3
mat colnames svc_type=svc_type
mat colnames mat=svc1
mat list mat
mat full=mat, svc_type
preserve
clear
svmat full, names(col)
la def svc_type 1 "Trans, Overall" 2"Trans, Only" 3"Trans, non-only",replace
label val svc_type svc_type	
local vlist svc1
makelegendlabelsfromvarlabels `vlist', local(relabellegend) c(30)
graph hbar svc1, intensity(100) ///
	over(svc_type, label(labsize(small)) gap(50)) ///
	bar(1, color("22 137 128")) bar(2, color("102 102 102"))   ///
	legend(size(vsmall) `relabellegend') ///
	ylabel(0 (20) 60) ytitle("(%)", size(vsmall)) ///
	ysize(4.1) xsize(6.6)
graph export `logpath'\trans_hosp.png, replace	
restore


local varlist age_cat white_ind female_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  personal_care target_case home_health rehabilitation ///
			  private_duty_nursing adult_day_care residential_care ///
			  transportation hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  expend_hcbs hosp
			 
local grouplist "transportation trans_only trans_other non_trans"
preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
gen trans_other=1 if trans_only==0&transportation==1
gen non_trans=1 if transportation==0
sum expend_hcbs_cat
local a1=r(min)
local a2=r(max)
local r=1
sum flag 
mat mat`r'=r(N)
mat mat=mat`r'
mat matm=.
forvalues n1=1/4{
local group : word `n1' of `grouplist'
local r=`r'+1
sum flag if `group'==1
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
forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum flag if `var'==`n1' & `group'==1
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
forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum flag if `var'==1 & `group'==1
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

forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum `var' if `group'==1 
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}

}
mat mat_full = mat
restore


mat list mat_full
frmttable using `logpath'/table1_trans_type1.rtf, statmat(mat_full) sdec(0,0,0 \ 1,1,1) ///
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
ctitles("","Overall","Trans, Overall", "Trans, Only","Trans, non-Only", "Non-Trans") ///
colwidth(22 3 3 3 3 3) ///
note() ///
replace
wordconvert "`logpath'/table1_trans_type1.rtf" "`logpath'/table1_trans_type1.docx", replace
	
	
	

local varlist age_cat white_ind female_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  personal_care target_case home_health rehabilitation ///
			  private_duty_nursing adult_day_care residential_care ///
			  transportation hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			   hosp expend_hcbs 
			 
local grouplist "home_trans1 home_trans2 home_trans3 home_trans4"
preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
gen home_trans1=1 if home_health==0&transportation==0
gen home_trans2=1 if home_health==1&transportation==0
gen home_trans3=1 if home_health==0&transportation==1
gen home_trans4=1 if home_health==1&transportation==1

sum expend_hcbs_cat
local a1=r(min)
local a2=r(max)
local r=1
sum flag 
mat mat`r'=r(N)
mat mat=mat`r'
mat matm=.
forvalues n1=1/4{
local group : word `n1' of `grouplist'
local r=`r'+1
sum flag if `group'==1
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
forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum flag if `var'==`n1' & `group'==1
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
forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum flag if `var'==1 & `group'==1
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
forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum `var' if `group'==1 
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}
}
restore
mat list mat

local varlist expend_transportation expend_transportation expend_home_health expend_home_health expend_personal_care expend_personal_care
local grouplist "home_trans1 home_trans2 home_trans3 home_trans4"

preserve
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
gen home_trans1=1 if home_health==0&transportation==0
gen home_trans2=1 if home_health==1&transportation==0
gen home_trans3=1 if home_health==0&transportation==1
gen home_trans4=1 if home_health==1&transportation==1
local n_2 : word count `varlist'
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'

if `n2'==1|`n2'==3|`n2'==5{
local r=1
sum `var' 
mat mat1=r(mean)
mat mat_full1=mat1
forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum `var' if `group'==1 
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
}
else{
local r=1
sum `var' 
mat mat1=r(mean)
sum expend_hcbs
mat de=r(mean)

mat mat1=mat1[1,1]/de[1,1]*100

mat list mat1
mat mat_full1=mat1
forvalues n3=1/4{
local group : word `n3' of `grouplist'
local r=`r'+1
sum `var' if `group'==1 
mat mat`r'=r(mean)
sum expend_hcbs if `group'==1 
mat de=r(mean)
mat mat`r'=mat`r'[1,1]/de[1,1]*100
mat mat_full1=mat_full1, mat`r'
}
}
mat mat=mat\mat_full1
}
mat mat_full = mat
restore


mat list mat_full
frmttable using `logpath'/table1_trans_home.rtf, statmat(mat_full) sdec(0,0,0 \ 1,1,1) ///
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
"Hosp %" \ ///
"HCBS Exp ($)" \ ///
"Trans Exp ($)" \ ///
"%" \ ///
"Home Health Exp ($)" \ ///
"%" \ ///
"Personal Care Exp ($)" \ ///
"%")  ///
ctitles("","Overall","No Trans, No Home", "No Trans, Home","Trans, No Home", "Trans, Home") ///
colwidth(22 3 3 3 3 3 3) ///
note() ///
replace
wordconvert "`logpath'/table1_trans_home.rtf" "`logpath'/table1_trans_home.docx", replace
	
	
			 
local keeplist "home_trans1 home_trans2 home_trans3 home_trans4"			 
local group expend_hcbs_cat
forvalues n4=1/4{
local keep : word `n4' of `keeplist'
preserve
local varlist age_cat white_ind female_ind non_metro_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  cc_ami_ind cc_atrial_fib_ind cc_cataract_ind cc_chronickidney_ind ///
			  cc_copd_ind cc_chf_ind cc_diabetes_ind cc_glaucoma_ind cc_hip_fracture_ind ///
			  cc_ischemicheart_ind cc_depression_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			  cc_stroke_tia_ind  ///
			  cc_anemia_ind cc_asthma_ind cc_hyperl_ind cc_hyperp_ind cc_hypert_ind ///
			  cc_hypoth_ind personal_care target_case home_health  ///
			  adult_day_care residential_care ///
			  transportation hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  hosp expend_hcbs 
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
gen home_trans1=1 if home_health==0&transportation==0
gen home_trans2=1 if home_health==1&transportation==0
gen home_trans3=1 if home_health==0&transportation==1
gen home_trans4=1 if home_health==1&transportation==1
keep if `keep'==1
sum expend_hcbs_cat
local a1=r(min)
local a2=r(max)
local r=1
sum flag 
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



local varlist expend_personal_care expend_personal_care ///
			  expend_target_case expend_target_case ///
			  expend_home_health expend_home_health ///
			  expend_adult_day_care expend_adult_day_care ///
			  expend_residential_care expend_residential_care ///
			  expend_transportation expend_transportation ///
			  expend_others expend_others ///
			  expend_dme expend_dme 
			  

preserve
local keep : word `n4' of `keeplist'
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
gen home_trans1=1 if home_health==0&transportation==0
gen home_trans2=1 if home_health==1&transportation==0
gen home_trans3=1 if home_health==0&transportation==1
gen home_trans4=1 if home_health==1&transportation==1
keep if `keep'==1
local n_2 : word count `varlist'
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'

if `n2'==1|`n2'==3|`n2'==5|`n2'==7|`n2'==9|`n2'==11|`n2'==13|`n2'==15{
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
}
else{
local r=1
sum `var' 
mat mat1=r(mean)
sum expend_hcbs 
mat de=r(mean)
mat mat1=mat1[1,1]/de[1,1]*100
mat list mat1
mat mat_full1=mat1

forvalues n3=0/3{
local r=`r'+1
sum `var' if expend_hcbs_cat==`n3'
mat mat`r'=r(mean)
sum expend_hcbs if expend_hcbs_cat==`n3'
mat de=r(mean)
mat mat`r'=mat`r'[1,1]/de[1,1]*100
mat mat_full1=mat_full1, mat`r'
}
}
mat mat=mat\mat_full1
}
mat mat_full = mat
restore

mat list mat_full
frmttable using `logpath'/table1_hcbs_exp4_group.rtf, statmat(mat_full) sdec(0,0,0 \ 1,1,1) ///
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
"Rural (%)" \ ///
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
"AMI (%)" \ ///
"Atrial_Fib (%)" \ ///
"Cataract (%)" \ ///
"CHK (%)" \ ///
"COPD (%)" \ ///
"CHF (%)" \ ///
"Diabetes (%)" \ ///
"Glaucoma (%)" \ ///
"Hip Fracture (%)" \ ///
"Ischemic heart (%)" \ ///
"Depression (%)" \ ///
"Osteoporosis (%)" \ ///
"RA OA (%)" \ ///
"Stroke (%)" \ ///
"Anemia (%)" \ ///
"Asthma (%)" \ ///
"Hyperl (%)" \ ///
"Hyperp (%)" \ ///
"Hypert (%)" \ ///
"Hypoth (%)" \ ///
"Personal Care (%)" \ ///
"Targeted Case Management (%)" \ ///
"Home Health (%)"  \ ///
"Adult Day Care (%)" \ ///
"Residential (%)" \ ///
"Transportation (%)" \ ///
"Other/Unspecified (%)" \ ///
"DME (%)" \ ///
"Hosp %" \ ///
"HCBS Exp ($)" \ ///
"Personal Care ($)" \ ///
"    %" \ ///
"Targeted Case Management ($)" \ ///
"    %" \ ///
"Home Health ($)"  \ ///
"    %" \ ///
"Adult Day Care ($)" \ ///
"    %" \ ///
"Residential ($)" \ ///
"    %" \ ///
"Transportation ($)" \ ///
"    %" \ ///
"Other/Unspecified ($)" \ ///
"    %" \ ///
"DME ($)" \ ///
"    %")  ///
ctitles("","Overall","Q1", "Q2","Q3", "Q4") ///
colwidth(22 3 3 3 3 3) ///
note() ///
replace
wordconvert "`logpath'/table1_hcbs_exp4_group.rtf" "`logpath'/table1_hcbs_exp4_group`n4'.docx", replace
}	


local varlist overall personal_care target_case home_health adult_day_care residential_care transportation hcbs_waiver_cltc30 hcbs_waiver_cltc40

local n_1 : word count `sublist'
local n_2 : word count `varlist'
forvalues n2=1/`n_2'{
local var : word `n2' of `varlist'	
preserve
keep if hcbs==1 
if `n2'==1{
}
else{
keep if `var'==1
}
sum expend_hcbs 
mat mat1=r(mean)
mat mat_full=mat1
if `n2'==1{
mat full=mat_full
}
else{
mat full=full \ mat_full
}
restore
}
mat full=full
mat group1=1\2\3\4\5\6\7\8\9
mat full=full, group1
mat colnames full = svc1  group1 
mat list full

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
preserve
clear
svmat full, names(col)
la def group1 1 "Overall"2 "Personal Care" 3"Target Case" 4"Home Health" 5"Adult Day Care" 6"Residential Care" 7"Trans" 8"Other/Unspecified" 9"DME",replace
label val group1 group1
local vlist svc1
makelegendlabelsfromvarlabels `vlist', local(relabellegend) c(30)
graph hbar `vlist', intensity(100) ///
	over(group1, label(labsize(small)) gap(50)) ///
	bar(1, color("22 137 128")) bar(2, color("102 102 102"))   ///
	legend(size(vsmall) `relabellegend') ///
	ylabel(0 (10000) 35000) ytitle("(%)", size(vsmall)) ///
	ysize(4.1) xsize(6.6)
graph export `logpath'\sub_hcbs_expend_by_subgroup.png, replace	
restore

*/






	
/*
*Make one document 
local logpath *
local data *
local ver *
putdocx begin
putdocx paragraph, style(Heading1)
putdocx text ("Table. Baseline Characteristics")
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending Median")
putdocx save `logpath'/table1_`ver'.docx, replace
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_hcbs_exp.docx, saving(`logpath'/table1_`ver', replace)

putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending quantile")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_hcbs_exp4.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Figure. HCBS Exp by Service"), linebreak
putdocx image `logpath'/sub_hcbs_expend_by_subgroup.png, width(6.6) height(4.1)
putdocx save `logpath'/sub_hcbs_expend_by_subgroup.docx,replace
putdocx append `logpath'/table1_`ver'.docx `logpath'/sub_hcbs_expend_by_subgroup.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Service: Personal Care")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_bin_personal_care.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Service: Home Health")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_bin_home_health.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Service: Transportation")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_bin_trans.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users -Home health and Trans")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_trans_home.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending quantile - No Home Health & No Transportation")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_hcbs_exp4_group1.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending quantile - Home Health & No Transportation")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_hcbs_exp4_group2.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending quantile - No Home Health & Transportation")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_hcbs_exp4_group3.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending quantile - Home Health & Transportation")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_hcbs_exp4_group4.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Service: Target Care")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_bin_target_care.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Service: Others")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_bin_others.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Service: DME")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_bin_DME.docx, saving(`logpath'/table1_`ver', replace)

putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Figure. Pct of Transportation and Trans_only"), linebreak
putdocx image `logpath'/trans_only.png, width(6.6) height(4.1)
putdocx save `logpath'/trans_only.docx,replace
putdocx append `logpath'/table1_`ver'.docx `logpath'/trans_only.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users -Trans, Trans only")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_trans_type1.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending Median and Service: Personal Care")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_personal_care.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending Median and Service: Home Health")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_home_health.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending Median and Service: Transportation")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_trans.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending Median and Service: Target Care")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_target_care.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending Median and Service: Others")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_others.docx, saving(`logpath'/table1_`ver', replace)
putdocx begin
putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Table. Characteristics of HCBS users by Spending Median and Service: DME")
putdocx save `logpath'/table1_`ver'.docx, append
putdocx append `logpath'/table1_`ver'.docx `logpath'/table1_DME.docx, saving(`logpath'/table1_`ver', replace)
*/
/*
ftools, compile
reghdfe, compile
cap ado uninstall ivreg2hdfe
cap ado uninstall ivreghdfe
cap ssc install ivreg2 // Install ivreg2, the core package
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)
*/



/*
***Transportation Availability - by State 
**Unadjusted hosp by state 
local statelist "ALL" "AL" "CA"  "CO" "DC" "FL"  "GA"  "IA"  "ID"  ///
				"IL" "IN"  "KS"  "KY"  "LA"  "MA"  "MD"  "MI"  "MN"  "MO"  ///
				"MS"  "MT"  "NC"  "ND"  "NE"  "NH"  "NV"  "NY"  "OK"  ///
				"OR"  "PA"  "SC"  "SD"  "TX"  "UT"  "VA"  "VT"  "WA"  "WI"  ///
				"WV"  "WY"
local n : word count `statelist'

forvalues a=1/`n'{
preserve
local st : word `a' of `statelist'
if `a'==1{
}
else{
keep if st=="`st'"
}
sum flag
mat mat1=r(N)
sum hcbs 
mat mat2=r(mean)*100
sum flag if hcbs==1
mat mat3=r(N)
sum transportation if hcbs==1
mat mat4=r(mean)*100
sum trans_only if hcbs==1
mat mat10=r(mean)*100
sum expend_hcbs if hcbs==1
mat mat5=r(mean)
sum expend_transportation if transportation==1
mat mat6=r(mean)
sum expend_transportation if trans_only==1
mat mat7=r(mean)
sum hosp if hcbs==1
mat mat8=r(mean)*100
sum hosp if transportation==1
mat mat9=r(mean)*100

if `a'==1{
mat full1=mat1
mat full2=mat2
mat full3=mat3
mat full4=mat4
mat full10=mat10
mat full5=mat5
mat full6=mat6
mat full7=mat7
mat full8=mat8
mat full9=mat9
}
else{
mat full1=full1 \ mat1
mat full2=full2 \ mat2
mat full3=full3 \ mat3
mat full4=full4 \ mat4
mat full10=full10 \ mat10
mat full5=full5 \ mat5
mat full6=full6 \ mat6
mat full7=full7 \ mat7
mat full8=full8 \ mat8
mat full9=full9 \ mat9
}
restore
}
mat full=full1, full2, full3, full4, full10, full5, full6, full7, full8, full9
mat colnames full = total hcbs_pct hcbs trans_pct trans_only_pct hcbs_expend trans_expend trans_expend_pct hosp hosp_trans
mat list full
preserve
clear
svmat full, names(col)
save `data'\trans_st.dta, replace
restore

local logpath K:\Outputdata\DJ\logs
local data K:\Outputdata\DJ\data
preserve
clear
use `data'\trans_st.dta, replace
frmttable using `logpath'\trans_st.rtf, statmat(full) sdec(0,1,0,1,0) ///
rtitles("Overall"  \ "AL" \ "CA" \ "CO" \ "DC" \ "FL" \ "GA" \ "IA" \ "ID" \ ///
		"IL" \ "IN" \ "KS" \ "KY" \ "LA" \ "MA" \ "MD" \ "MI" \ "MN" \ "MO" \ ///
		"MS" \ "MT" \ "NC" \ "ND" \ "NE" \ "NH" \ "NV" \ "NY" \  "OK" \ ///
		"OR" \ "PA" \ "SC" \ "SD" \ "TX" \ "UT" \ "VA" \ "VT" \ "WA" \ "WI" \ ///
		"WV" \ "WY" )  ///
ctitles("State" , "LTC N", "HCBS %", "HCBS N", "Trans %", "Trans only %", "HCBS $", "Trans $", "Trans only $", "Hosp-HCBS", "Hosp-Trans") ///
colwidth(14 3 3 3 3 3 3 3 3 3 3 3 3 3 3) ///
replace
wordconvert "`logpath'/trans_st.rtf" "`logpath'/trans_st.docx", replace
restore
			 
local keeplist "expendmed_trans1 expendmed_trans2 expendmed_trans3 expendmed_trans4"			 
forvalues n4=1/1{

preserve
local varlist age_cat white_ind female_ind non_metro_ind elig_cat dementia_ind cc_idd_ind cc_count_cat10 ///
			  cc_ami_ind cc_atrial_fib_ind cc_cataract_ind cc_chronickidney_ind ///
			  cc_copd_ind cc_chf_ind cc_diabetes_ind cc_glaucoma_ind cc_hip_fracture_ind ///
			  cc_ischemicheart_ind cc_depression_ind cc_osteoporosis_ind cc_ra_oa_ind ///
			  cc_stroke_tia_ind  ///
			  cc_anemia_ind cc_asthma_ind cc_hyperl_ind cc_hyperp_ind cc_hypert_ind ///
			  cc_hypoth_ind personal_care target_case home_health  ///
			  adult_day_care residential_care ///
			  transportation hcbs_waiver_cltc30 hcbs_waiver_cltc40 ///
			  hosp expend_hcbs 
keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem

egen med = median(expend_hcbs) if hcbs==1	
gen expend_hcbs_med=1 if expend_hcbs>med &hcbs==1
replace expend_hcbs_med=0 if expend_hcbs<med &hcbs==1

gen expendmed_trans=0 if expend_hcbs_med==0&transportation==0
replace expendmed_trans=1 if expend_hcbs_med==1&transportation==0
replace expendmed_trans=2 if expend_hcbs_med==0&transportation==1
replace expendmed_trans=3 if expend_hcbs_med==1&transportation==1

sum expendmed_trans
local a1=r(min)
local a2=r(max)
local r=1
sum flag 
mat mat`r'=r(N)
mat mat=mat`r'
mat matm=.
forvalues n1=`a1'/`a2'{
local r=`r'+1
sum flag if expendmed_trans==`n1'
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
sum flag if `var'==`n1' & expendmed_trans==`n3'
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
sum flag if `var'==1 & expendmed_trans==`n3'
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
sum `var' if expendmed_trans==`n3' 
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
mat mat=mat\mat_full1
}

}
mat mat_full = mat
restore



local varlist expend_personal_care expend_personal_care ///
			  expend_target_case expend_target_case ///
			  expend_home_health expend_home_health ///
			  expend_adult_day_care expend_adult_day_care ///
			  expend_residential_care expend_residential_care ///
			  expend_transportation expend_transportation ///
			  expend_others expend_others ///
			  expend_dme expend_dme 
			  

preserve

keep if hcbs==1
gen dementia_ind=ccw_both_alz_dem
egen med = median(expend_hcbs) if hcbs==1	
gen expend_hcbs_med=1 if expend_hcbs>med &hcbs==1
replace expend_hcbs_med=0 if expend_hcbs<med &hcbs==1
gen expendmed_trans=0 if expend_hcbs_med==0&transportation==0
replace expendmed_trans=1 if expend_hcbs_med==1&transportation==0
replace expendmed_trans=2 if expend_hcbs_med==0&transportation==1
replace expendmed_trans=3 if expend_hcbs_med==1&transportation==1

local n_2 : word count `varlist'
forvalues n2=1/`n_2' {
local var : word `n2' of `varlist'

if `n2'==1|`n2'==3|`n2'==5|`n2'==7|`n2'==9|`n2'==11|`n2'==13|`n2'==15{
local r=1
sum `var' 
mat mat1=r(mean)
mat mat_full1=mat1
forvalues n3=`a1'/`a2'{
local r=`r'+1
sum `var' if expendmed_trans==`n3'
mat mat`r'=r(mean)
mat mat_full1=mat_full1, mat`r'
}
}
else{
local r=1
sum `var' 
mat mat1=r(mean)
sum expend_hcbs 
mat de=r(mean)
mat mat1=mat1[1,1]/de[1,1]*100
mat list mat1
mat mat_full1=mat1

forvalues n3=0/3{
local r=`r'+1
sum `var' if expendmed_trans==`n3'
mat mat`r'=r(mean)
sum expend_hcbs if expendmed_trans==`n3'
mat de=r(mean)
mat mat`r'=mat`r'[1,1]/de[1,1]*100
mat mat_full1=mat_full1, mat`r'
}
}
mat mat=mat\mat_full1
}
mat mat_full = mat
restore

mat list mat_full
frmttable using `logpath'/table1_by_trans.rtf, statmat(mat_full) sdec(0,0,0 \ 1,1,1) ///
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
"Rural (%)" \ ///
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
"AMI (%)" \ ///
"Atrial_Fib (%)" \ ///
"Cataract (%)" \ ///
"CHK (%)" \ ///
"COPD (%)" \ ///
"CHF (%)" \ ///
"Diabetes (%)" \ ///
"Glaucoma (%)" \ ///
"Hip Fracture (%)" \ ///
"Ischemic heart (%)" \ ///
"Depression (%)" \ ///
"Osteoporosis (%)" \ ///
"RA OA (%)" \ ///
"Stroke (%)" \ ///
"Anemia (%)" \ ///
"Asthma (%)" \ ///
"Hyperl (%)" \ ///
"Hyperp (%)" \ ///
"Hypert (%)" \ ///
"Hypoth (%)" \ ///
"Personal Care (%)" \ ///
"Targeted Case Management (%)" \ ///
"Home Health (%)"  \ ///
"Adult Day Care (%)" \ ///
"Residential (%)" \ ///
"Transportation (%)" \ ///
"Other/Unspecified (%)" \ ///
"DME (%)" \ ///
"Hosp %" \ ///
"HCBS Exp ($)" \ ///
"Personal Care ($)" \ ///
"    %" \ ///
"Targeted Case Management ($)" \ ///
"    %" \ ///
"Home Health ($)"  \ ///
"    %" \ ///
"Adult Day Care ($)" \ ///
"    %" \ ///
"Residential ($)" \ ///
"    %" \ ///
"Transportation ($)" \ ///
"    %" \ ///
"Other/Unspecified ($)" \ ///
"    %" \ ///
"DME ($)" \ ///
"    %")  ///
ctitles("","Overall","Non-Trans", "","Trans", "" \ "", "", "<Med$", ">Med$", "<Med$", ">Med$") ///
colwidth(22 3 3 3 3 3) multicol(1,3,2;1,5,2) ///
note() ///
replace
wordconvert "`logpath'/table1_by_trans.rtf" "`logpath'/table1_by_trans.docx", replace
}	
*/









log close
