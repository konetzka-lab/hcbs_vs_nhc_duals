**IV

capture log close
clear all
set more off
set scheme s1color

local logpath *
local data05 *
local data12 *
local ver *
local st "ALL"
net set ado *
adopath ++ *
sysdir set PLUS *

local n : word count `st'
forvalues z = 1/`n' {
local st2 : word `z' of `st'


local yearlist 05 12
local n2 : word count `yearlist'
forvalues a=1/`n2'{
local year : word `a' of `yearlist'
if `a'==1 {
use `data'\hcbs_max_`year'_iv_sample_v2.dta, replace
keep if year==2005
replace died_ind=!missing(dod_dateformat) & year_died==2005
}
else{
use `data'\hcbs_max_`year'_iv_sample_v2.dta, replace
keep if year==2012
replace died_ind=!missing(dod_dateformat) & year_died==2012
}
if `z'==1{
}
else{
keep if state_cd=="`st2'"
}

*create indicator for dropping particular states, adjust this after discussion
gen state_drop=(inlist(state_cd,"AZ","NM","HI"))
tab state_drop, missing	
tab state_drop, missing	

*create indicator for MC LTSS users
gen mc_ltss_inst=1 if enc_tos_ind_2==1|enc_tos_ind_4==1|enc_tos_ind_5==1|enc_tos_ind_7==1

gen mc_ltss_hcbs=1 if enc_cltc_ind_11==1|enc_cltc_ind_12==1|enc_cltc_ind_13==1| ///
					  enc_cltc_ind_15==1|enc_cltc_ind_16==1|enc_cltc_ind_17==1| ///
					  enc_cltc_ind_18==1|enc_cltc_ind_19==1|cltc_14_enc_3m_ind==1

gen mc_ltss_cat=0 if mc_ltss_inst==. & mc_ltss_hcbs==.
	replace mc_ltss_cat=1 if mc_ltss_inst==1 & mc_ltss_hcbs==.
	replace mc_ltss_cat=2 if mc_ltss_inst==. & mc_ltss_hcbs==1
	replace mc_ltss_cat=3 if mc_ltss_inst==1 & mc_ltss_hcbs==1

**All Medicaid LTSS users
keep if ltss_cat3==1|ltss_cat3==2|ltss_cat3==3|mc_ltss_cat==1|mc_ltss_cat==2|mc_ltss_cat==3

**All Medicaid FFS LTSS users
keep if ltss_cat3==1|ltss_cat3==2|ltss_cat3==3

**exclude duplicate entries that didn't match
tab dup_no_conflicts beneid_dup_flag, missing
keep if (dup_no_conflicts==1 & beneid_dup_flag==1) | beneid_dup_flag==0

** Medicaid for full 12m period 
gen medicaid=1 if el_elgblty_mo_cnt==12 & died_ind==0
tab medicaid, missing
keep if medicaid==1

** in one of the states we drop due to data limitations
tab state_drop, m
keep if state_drop==0

** No age group
tab age , m
keep if !missing(age)

** HCBS only or IC only 
keep if ltss_cat3!=3

** County 
gen st=state_cd
gen cnty=el_rsdnc_cnty_cd_ltst
/*table year if st=="" - No missing State information*/
tab st
gen st_cnty=st+cnty
tab st_cnty if missing(st_cnty)
tab st_cnty if cnty=="000"
tab st_cnty if cnty=="999"
keep if cnty!="000" & cnty!="999" & !missing(cnty)

********************************************************************************
**Exclude Maine in 2012*******************************
********************************************************************************
gen state_drop2=(inlist(state_cd,"ME"))
tab state_drop2
keep if state_drop2==0

********************************************************************************
**Cnty exclusion criteria*******************************************************
********************************************************************************
**Exclude cnty <11 - younger than 65
gen flag=1 if age65_ind==0

preserve
collapse (sum) flag, by(st_cnty)
sum flag, detail
gen ex_cnty=0 if flag>10 
	replace ex_cnty=1 if ex_cnty==.
tab ex_cnty
drop flag
save `data'\ex_cnty_`year'_`ver', replace
restore

merge m:1 st_cnty using `data'\ex_cnty_`year'_`ver'

tab _merge 
keep if _merge==3
drop _merge
********************************************************************************
**Exclude cnty <11 - younger than 65*******************************
********************************************************************************
keep if ex_cnty==0


********************************************************************************
**save*******************************
********************************************************************************
if `a'==1{
preserve
collapse (sum) year, by(st_cnty)
gen sum=year
drop year
save `data'\hcbs_cnty_05_`ver', replace
restore
}
else{
preserve
collapse (sum) year, by(st_cnty)
gen sum=year
drop year
save `data'\hcbs_cnty_12_`ver', replace
restore
}

}
}

********************************************************************************
**Define counties in both 2005 and 2012*******************************
********************************************************************************
forvalues a=1/2{
if `a'==1 {
use `data05'\hcbs_cnty_05_`ver', replace
}
else{
merge 1:1 st_cnty using `data12'\hcbs_cnty_12_`ver'
keep if _merge==3
drop _merge
save `data12'\hcbs_cnty_05_12_`ver', replace
}
}

/*
*Make table 
local st "ALL AK AL AR CA CO CT DC DE FL GA IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NV OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY"
local n : word count `st'
forvalues z = 1/`n' {
local st2 : word `z' of `st'
mat s1=J(13,8,.)
mat s2=J(13,4,.)

local yearlist 05 12
local n2 : word count `yearlist'
forvalues a=1/`n2'{
local year : word `a' of `yearlist'
if `a'==1 {
use `data'\hcbs_max_`year'_iv_sample_v2.dta, replace
keep if year==2005
replace died_ind=!missing(dod_dateformat) & year_died==2005
}
else{
use `data'\hcbs_max_`year'_iv_sample_v2.dta, replace
keep if year==2012
replace died_ind=!missing(dod_dateformat) & year_died==2012
}
if `z'==1{
}
else{
keep if state_cd=="`st2'"
}

*create indicator for dropping particular states, adjust this after discussion
gen state_drop=(inlist(state_cd,"AZ","NM","HI"))
tab state_drop, missing	
tab state_drop, missing	

*create indicator for MC LTSS users
gen mc_ltss_inst=1 if enc_tos_ind_2==1|enc_tos_ind_4==1|enc_tos_ind_5==1|enc_tos_ind_7==1

gen mc_ltss_hcbs=1 if enc_cltc_ind_11==1|enc_cltc_ind_12==1|enc_cltc_ind_13==1| ///
					  enc_cltc_ind_15==1|enc_cltc_ind_16==1|enc_cltc_ind_17==1| ///
					  enc_cltc_ind_18==1|enc_cltc_ind_19==1|cltc_14_enc_3m_ind==1

gen mc_ltss_cat=0 if mc_ltss_inst==. & mc_ltss_hcbs==.
	replace mc_ltss_cat=1 if mc_ltss_inst==1 & mc_ltss_hcbs==.
	replace mc_ltss_cat=2 if mc_ltss_inst==. & mc_ltss_hcbs==1
	replace mc_ltss_cat=3 if mc_ltss_inst==1 & mc_ltss_hcbs==1


	
**All Medicaid LTSS users
keep if mc_ltss_cat>0 | ltss_cat3>0
local r=1
tab year
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100


if year==2005 {
mat s2[`r',1]=r(N) 
}
else {
mat s2[`r',3]=r(N) 
}
mat list s1
mat list s2



**All Medicaid FFS LTSS users
keep if ltss_cat3>0
local r = `r'+1
tab year
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s1
mat list s2


** Medicaid for full 12m period 
gen medicaid=1 if el_elgblty_mo_cnt==12 & died_ind==0
tab medicaid, missing
keep if medicaid==1
tab year
local r = `r'+1	
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2


** in one of the states we drop due to data limitations
tab state_drop, m
keep if state_drop==0
tab year  
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

** No age group
tab age, m
keep if !missing(age)
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2


** HCBS only or IC only 
tab ltss_cat3
tab ltss_cat3, nolabel
tab ltss_cat3 
keep if ltss_cat3!=3
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

** County 
gen st=state_cd
gen cnty=el_rsdnc_cnty_cd_ltst
/*table year if st=="" - No missing State information*/
tab st
gen st_cnty=st+cnty
tab st_cnty if missing(st_cnty)
tab st_cnty if cnty=="000"
tab st_cnty if cnty=="999"

keep if cnty!="000" & cnty!="999" & !missing(cnty)
tab year
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

********************************************************************************
**Exclude cnty <11 - younger than 65*******************************
********************************************************************************
merge m:1 st_cnty using `data'\ex_cnty_`year'_`ver'
tab _merge 
keep if _merge==3
drop _merge
keep if ex_cnty==0
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

********************************************************************************
**Exclude Maine in 2012*******************************
********************************************************************************
gen state_drop2=(inlist(state_cd,"ME"))
tab state_drop2
keep if state_drop2==0
tab year
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}

********************************************************************************
**Exclude cnty - not both in 2005 and 2012*******************************
********************************************************************************
merge m:1 st_cnty using `data12'\hcbs_cnty_05_12_`ver'
keep if _merge==3
drop _merge
tab year
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

keep if age<65
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1

if `a'==1 {
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else {
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

tab year if ltss_cat3==2
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1

if `a'==1 {
tab year if ltss_cat3==2
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else {
tab year if ltss_cat3==2
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

if `z'==1 & `a'==1 {
frmttable using `logpath'/spl_iv_ltc_`ver', statmat(s1) sdec(0,2,0,2,0,2,0,2) ///
title("LTSS Sample restrictions for IV `year', `st2'") ///
rtitles("All Medicaid LTSS Users" \ ///
"All FFS LTSS Users, from MAX claims/enrollment" \ ///
"Medicaid eligible & Alive for the whole year" \ ///
"Dropping excluded states - note 1" \ ///
"Age information" \ ///
"HCBS only or Institutional only" \ ///
"Available State and County Information" \ ///
"Counties - note 2" \  ///
"Dropping state, ME - note 3" \ ///
"Counties both in 2005 and 2012" \ ///
"Age<65" \ ///
"HCBS")  ///
ctitles("","N","%", "Inst.", "", "HCBS", "", "Both", "" \ "","","", "N", "%", "N", "%", "N", "%") ///
note("1. States dropped=AZ, HI, NM large MLTSS programs." \ ///
"2. Counties with less than 11 individuals - younger than 65." \ ///
"3. No ME data in MAX 2005.") ///
replace
}
else {
frmttable using `logpath'/spl_iv_ltc_`ver', statmat(s1) addtable sdec(0,2,0,2,0,2,0,2) ///
title("LTSS Sample restrictions for IV `year', `st2'") ///
rtitles("All Medicaid LTSS Users" \ ///
"All FFS LTSS Users, from MAX claims/enrollment" \ ///
"Medicaid eligible & Alive for the whole year" \ ///
"Dropping excluded states - note 2" \ ///
"Age information" \ ///
"HCBS only or Institutional only" \ ///
"Available State and County Information" \ ///
"Counties - note 3" \  ///
"Dropping state, ME - note 4" \ ///
"Counties both in 2005 and 2012" \ ///
"Age<65" \ ///
"HCBS")  ///
ctitles("","N","%", "Inst.", "", "HCBS", "", "Both", "" \ "","","", "N", "%", "N", "%", "N", "%") ///
note("1. States dropped=AZ, HI, NM large MLTSS programs." \ ///
"2. Counties with less than 11 individuals - younger than 65." \ ///
"3. No ME data in MAX 2005.") ///
replace
}

if `z'==1 & `a'==2 {
frmttable using `logpath'/hcbs_spl_iv_05_12_`ver', statmat(s2) sdec(0,2,0,2) ///
title("LTSS User Analysis Sample restrictions for IV, `st2'") ///
rtitles("All Medicaid LTSS Users" \ ///
"All FFS LTSS Users, from MAX claims/enrollment" \ ///
"Medicaid eligible & Alive for the whole year" \ ///
"Dropping excluded states - note 1" \ ///
"Age information" \ ///
"HCBS only or Institutional only" \ ///
"Available State and County Information" \ ///
"Counties - note 2" \  ///
"Dropping state, ME - note 3" \ ///
"Counties both in 2005 and 2012" \ ///
"Age<65" \ ///
"HCBS")  ///
ctitles("","2005","","2012","" \ "","N","%","N","%") ///
note("1. States dropped=AZ, HI, NM large MLTSS programs." \ ///
"2. Counties with less than 11 individuals - younger than 65." \ ///
"3. No ME data in MAX 2005.") ///
replace
}
else if `a'==2 {
frmttable using `logpath'/hcbs_spl_iv_05_12_`ver', statmat(s2) addtable sdec(0,2,0,2) ///
title("LTSS User Analysis Sample restrictions for IV, `st2'") ///
rtitles("All Medicaid LTSS Users" \ ///
"All FFS LTSS Users, from MAX claims/enrollment" \ ///
"Medicaid eligible & Alive for the whole year" \ ///
"Dropping excluded states - note 1" \ ///
"Age information " \ ///
"HCBS only or Institutional only" \ ///
"Available State and County Information" \ ///
"Counties - note 2" \  ///
"Dropping state, ME - note 3" \ ///
"Counties both in 2005 and 2012" \ ///
"Age<65" \ ///
"HCBS")  ///
ctitles("","2005","","2012","" \ "","N","%","N","%") ///
note("1. States dropped=AZ, HI, NM large MLTSS programs." \ ///
"2. Counties with less than 11 individuals - younger than 65." \ ///
"3. No ME data in MAX 2005.") ///
replace
}
else{
}

if `z'==1{
gen flag=1
save `data'\hcbs_max_`year'_iv_sample2_`ver', replace
********************************************************************************
**IV - Users, HCBS/LTC, state-level**********************************
********************************************************************************	
forvalues y = 0/0 {
preserve
collapse (mean) ltss_cat_ind2 if age65_ind==`y', by(st)
tab ltss_cat_ind2 if missing(ltss_cat_ind2)
local a "user"
*Percentage of LTC users through HCBS
gen user_st_ltc_hcbs_young=ltss_cat_ind2*100
sum user_st_ltc_hcbs_young, detail

mat s`y'=J(1,8,.)
local r = 1
mat s`y'[`r',1]=r(N)
mat s`y'[`r',2]=round(r(mean), 0.01)
mat s`y'[`r',3]=round(r(sd), 0.01)
mat s`y'[`r',4]=round(r(min), 1)
mat s`y'[`r',5]=round(r(p25), 1)
mat s`y'[`r',6]=round(r(p50), 1)
mat s`y'[`r',7]=round(r(p75), 1)
mat s`y'[`r',8]=round(r(max), 1)
mat list s`y'
keep st user_st_ltc_hcbs_young 
save `data'\hcbs_max_`year'_iv_st_`ver', replace
restore

preserve
collapse (mean) ltss_cat_ind2 if age65_ind==`y', by(st_cnty)
tab ltss_cat_ind2 if missing(ltss_cat_ind2)
local a "user"
*Percentage of LTC users through HCBS
gen user_cnty_ltc_hcbs_young=ltss_cat_ind2*100
sum user_cnty_ltc_hcbs_young, detail
gen state_cd = substr(st_cnty,1,2)
tab state_cd
mat s`y'=J(1,8,.)
local r = 1
mat s`y'[`r',1]=r(N)
mat s`y'[`r',2]=round(r(mean), 0.01)
mat s`y'[`r',3]=round(r(sd), 0.01)
mat s`y'[`r',4]=round(r(min), 1)
mat s`y'[`r',5]=round(r(p25), 1)
mat s`y'[`r',6]=round(r(p50), 1)
mat s`y'[`r',7]=round(r(p75), 1)
mat s`y'[`r',8]=round(r(max), 1)
mat list s`y'
keep st_cnty state_cd user_cnty_ltc_hcbs_young 
save `data'\hcbs_max_`year'_iv_cnty_`ver', replace
restore

}
}
}
}

********************************************************************************
**Check - Sample restriction for IV, 2005 and 2012, Age first*******************
********************************************************************************
local st "ALL AK AL AR CA CO CT DC DE FL GA IA ID IL IN KS KY LA MA MD MI MN MO MS MT NC ND NE NH NJ NV OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY"
local n : word count `st'
forvalues z = 1/1 {
local st2 : word `z' of `st'
mat s1=J(13,8,.)
mat s2=J(13,4,.)
local yearlist 05 12
local n2 : word count `yearlist'
forvalues a=1/`n2'{
local year : word `a' of `yearlist'
if `a'==1 {
use `data'\hcbs_max_`year'_iv_sample_v2.dta, replace
keep if year==2005
}
else{
use `data'\hcbs_max_`year'_iv_sample_v2.dta, replace
keep if year==2012
}
if `z'==1{
}
else{
keep if state_cd=="`st2'"
}

*create indicator for dropping particular states, adjust this after discussion
gen state_drop=(inlist(state_cd,"AZ","NM","HI"))
tab state_drop, missing	
tab state_drop, missing	

*create indicator for MC LTSS users
gen mc_ltss_inst=1 if enc_tos_ind_2==1|enc_tos_ind_4==1|enc_tos_ind_5==1|enc_tos_ind_7==1

gen mc_ltss_hcbs=1 if enc_cltc_ind_11==1|enc_cltc_ind_12==1|enc_cltc_ind_13==1| ///
					  enc_cltc_ind_15==1|enc_cltc_ind_16==1|enc_cltc_ind_17==1| ///
					  enc_cltc_ind_18==1|enc_cltc_ind_19==1|cltc_14_enc_3m_ind==1

gen mc_ltss_cat=0 if mc_ltss_inst==. & mc_ltss_hcbs==.
	replace mc_ltss_cat=1 if mc_ltss_inst==1 & mc_ltss_hcbs==.
	replace mc_ltss_cat=2 if mc_ltss_inst==. & mc_ltss_hcbs==1
	replace mc_ltss_cat=3 if mc_ltss_inst==1 & mc_ltss_hcbs==1

	
**All Medicaid LTSS users
keep if mc_ltss_cat>0 | ltss_cat3>0
local r=1
tab year
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s1
mat list s2
**All Medicaid FFS LTSS users
keep if ltss_cat3>0
local r = `r'+1
tab year
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s1
mat list s2

** No age group
tab age, m
keep if !missing(age)
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2


**Age<65
keep if age<65 
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1

if `a'==1 {
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else {
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2


**exclude duplicate entries that didn't match
tab dup_no_conflicts beneid_dup_flag, missing
keep if (dup_no_conflicts==1 & beneid_dup_flag==1) | beneid_dup_flag==0
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

** Medicaid for full 12m period 
gen medicaid=1 if el_elgblty_mo_cnt==12 & died_ind==0
tab medicaid, missing
keep if medicaid==1
tab year
local r = `r'+1	
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2


** in one of the states we drop due to data limitations
tab state_drop, m
keep if state_drop==0
tab year  
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

** HCBS only or IC only 
tab ltss_cat3
tab ltss_cat3, nolabel
tab ltss_cat3 
keep if ltss_cat3!=3
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

** County 
gen st=state_cd
gen cnty=el_rsdnc_cnty_cd_ltst
/*table year if st=="" - No missing State information*/
tab st
gen st_cnty=st+cnty
tab st_cnty if missing(st_cnty)
tab st_cnty if cnty=="000"
tab st_cnty if cnty=="999"

keep if cnty!="000" & cnty!="999" & !missing(cnty)
tab year
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

********************************************************************************
**Exclude cnty <11 - age: 21-64*******************************
********************************************************************************
merge m:1 st_cnty using `data'\ex_cnty_`year'_`ver'
tab _merge 
keep if _merge==3
drop _merge
keep if ex_cnty==0
tab year 
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

********************************************************************************
**Exclude Maine in 2012*******************************
********************************************************************************
gen state_drop2=(inlist(state_cd,"ME"))
tab state_drop2
keep if state_drop2==0
tab year
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}

********************************************************************************
**Exclude cnty not both in 2005 and 2012*******************************
********************************************************************************

merge m:1 st_cnty using `data12'\hcbs_cnty_05_12_`ver'
keep if _merge==3
drop _merge
tab year
local r = `r'+1
mat s1[`r',1]=r(N) 
mat s1[`r',2]=s1[`r',1]/s1[`r'-1,1]*100
tab year if ltss_cat_ind1==1
mat s1[`r',3]=r(N) 
 sum ltss_cat_ind1 
mat s1[`r',4]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind2==1
mat s1[`r',5]=r(N) 
sum ltss_cat_ind2 
mat s1[`r',6]=round(r(mean)*100, 0.01)
tab year if ltss_cat_ind3==1
mat s1[`r',7]=r(N) 
sum ltss_cat_ind3 
mat s1[`r',8]=round(r(mean)*100, 0.01)
mat list s1
if `a'==1{
mat s2[`r',1]=r(N) 
mat s2[`r',2]=s2[`r',1]/s2[`r'-1,1]*100
}
else{
mat s2[`r',3]=r(N) 
mat s2[`r',4]=s2[`r',3]/s2[`r'-1,3]*100
}
mat list s2

frmttable using `logpath'/spl_iv_ltc_`ver', statmat(s1) addtable sdec(0,2,0,2,0,2,0,2) ///
title("LTSS Sample restrictions for IV `year', `st2'") ///
rtitles("All" \ ///
"All Medicaid LTSS Users" \ ///
"All FFS LTSS Users, from MAX claims/enrollment" \ ///
"Age information" \ ///
"Age<65" \ ///
"Medicaid eligible & Alive for the whole year" \ ///
"Dropping excluded states - note 1" \ ///
"HCBS only or Instituional only" \ ///
"Available State and County Information" \ ///
"Counties - note 2" \  ///
"Dropping state, ME - note 3" \ ///
"Counties both in 2005 and 2012")  ///
ctitles("","N","%", "Inst.", "", "HCBS", "", "Both", "" \ "","","", "N", "%", "N", "%", "N", "%") ///
note("1. States dropped=AZ, HI, NM large MLTSS programs." \ ///
"2. Counties with less than 11 individuals - Age<65." \ ///
"3. No ME data in MAX 2005.") ///
replace

if `a'==2 {
frmttable using `logpath'/hcbs_spl_iv_05_12_`ver', statmat(s2) addtable sdec(0,2,0,2) ///
title("LTSS User Analysis Sample restrictions for IV, `st2'") ///
rtitles("All Medicaid LTSS Users" \ ///
"All FFS LTSS Users, from MAX claims/enrollment" \ ///
"Age information" \ ///
"Age<65" \ ///
"Medicaid eligible & Alive for the whole year" \ ///
"Dropping excluded states - note 1" \ ///
"HCBS only or Instituional only" \ ///
"Available State and County Information" \ ///
"Counties - note 2" \  ///
"Dropping state, ME - note 3" \ ///
"Counties both in 2005 and 2012")  ///
ctitles("","2005","","2012","" \ "","N","%","N","%") ///
note("1. States dropped=AZ, HI, NM large MLTSS programs." \ ///
"2. Counties with less than 11 individuals - Age<65." \ ///
"3. No ME data in MAX 2005.") ///
replace
}
else{
}

}
}

********************************************************************************
**county-level diff in percentage of HCBS users between 2005 and 2012**********
********************************************************************************

local yearlist 05 12
local n : word count `yearlist'
forvalues a=1/2{
local year : word `a' of `yearlist'
if `a'==1 {
local data05 K:\Outputdata\DJ\2005_hcbs_max
use `data05'\hcbs_max_05_iv_cnty_`ver', replace
gen year=2005
}
else{
local data12 K:\Outputdata\DJ\data
append using `data12'\hcbs_max_12_iv_cnty_`ver'
replace year=2012 if year==.
}
}

sort st_cnty
quietly by st_cnty:  gen dup = cond(_N==1,0,_n)
tab dup year

drop if dup==0
keep state_cd st_cnty user_cnty_ltc_hcbs_young year 

preserve
keep if year==2005
gen user_2005=user_cnty_ltc_hcbs_young
drop user_cnty_ltc_hcbs_young
save `data05'\hcbs_05_user_diff_`ver', replace
restore

preserve
keep if year==2012
gen user_2012=user_cnty_ltc_hcbs_young
drop user_cnty_ltc_hcbs_young
save `data12'\hcbs_12_user_diff_`ver', replace
restore

forvalues a=1/2{
local year : word `a' of `yearlist'
if `a'==1 {
local data05 K:\Outputdata\DJ\2005_hcbs_max
use `data05'\hcbs_05_user_diff_`ver', replace
}
else{
local data12 K:\Outputdata\DJ\data
merge 1:1 st_cnty using `data12'\hcbs_12_user_diff_`ver'
}
}
drop _merge

gen abs_diff=user_2012-user_2005
gen rel_diff=user_2012/user_2005
egen mean_abs=mean(abs_diff)
egen mean_rel=mean(rel_diff)


gen mean_abs_diff=0 if abs_diff<mean_abs
	replace mean_abs_diff=1 if abs_diff>mean_abs|abs_diff==mean_abs
gen mean_rel_diff=0 if rel_diff<mean_rel
	replace mean_rel_diff=1 if rel_diff>mean_rel|rel_diff==mean_rel

egen median_abs=pctile(abs_diff), p(50)
egen median_rel=pctile(rel_diff), p(50)	

gen median_abs_diff=0 if abs_diff<median_abs
	replace median_abs_diff=1 if abs_diff>median_abs|abs_diff==median_abs
gen median_rel_diff=0 if rel_diff<median_rel
	replace median_rel_diff=1 if rel_diff>median_rel|rel_diff==median_rel
	
save `data12'\hcbs_05_12_user_diff_`ver'.dta, replace	
	
sum abs_diff, detail
sum rel_diff, detail

tab user_2012 if abs_diff==.,m
tab user_2005 if abs_diff==.,m



********************************************************************************
**state-level diff in percentage of HCBS users between 2005 and 2012**********
********************************************************************************
local logpath K:\Outputdata\DJ\logs
local data05 K:\Outputdata\DJ\2005_hcbs_max
local data12 K:\Outputdata\DJ\data
local ver "v1"
local yearlist 05 12
local n : word count `yearlist'
forvalues a=1/2{
local year : word `a' of `yearlist'
if `a'==1 {
local data05 K:\Outputdata\DJ\2005_hcbs_max
use `data05'\hcbs_max_05_iv_st_`ver', replace
gen year=2005
}
else{
local data12 K:\Outputdata\DJ\data
append using `data12'\hcbs_max_12_iv_st_`ver'
replace year=2012 if year==.
}
}

sort st
quietly by st:  gen dup = cond(_N==1,0,_n)
tab dup year

drop if dup==0
keep st user_st_ltc_hcbs_young year 

preserve
keep if year==2005
gen user_st2005=user_st_ltc_hcbs_young
drop user_st_ltc_hcbs_young
save `data05'\hcbs_05_st_user_diff_`ver', replace
restore

preserve
keep if year==2012
gen user_st2012=user_st_ltc_hcbs_young
drop user_st_ltc_hcbs_young
save `data12'\hcbs_12_st_user_diff_`ver', replace
restore


forvalues a=1/2{
local year : word `a' of `yearlist'
if `a'==1 {
local data05 K:\Outputdata\DJ\2005_hcbs_max
use `data05'\hcbs_05_st_user_diff_`ver', replace
}
else{
local data12 K:\Outputdata\DJ\data
merge 1:1 st using `data12'\hcbs_12_st_user_diff_`ver'
}
}
drop _merge
	
save `data12'\hcbs_05_12_st_user_diff_`ver'.dta, replace	


************************************************************************
**Append 2005 and 2012**
************************************************************************	
use `data05'\hcbs_max_05_iv_sample2_`ver'.dta, replace
merge m:1 st_cnty using `data05'\hcbs_max_05_iv_cnty_`ver'.dta
save `data05'\hcbs_max_05_iv_sample3_`ver'.dta, replace

use `data12'\hcbs_max_12_iv_sample2_`ver'.dta, replace
merge m:1 st_cnty using `data12'\hcbs_max_12_iv_cnty_`ver'.dta
save `data12'\hcbs_max_12_iv_sample3_`ver'.dta, replace

************************************************************************
**Compare state-level percentage of LTC users through HCBS btw 05 and 12
************************************************************************
use `data05'\hcbs_max_05_iv_sample3_`ver'.dta, replace
append using `data12'\hcbs_max_12_iv_sample3_`ver'.dta
drop _merge
merge m:1 st_cnty using `data12'\hcbs_05_12_user_diff_`ver'.dta
keep if _merge==3
keep if age<65
local age "Age<65"
drop _merge	
local st "ALL AK AL AR CA CO CT DC DE FL GA IA ID IL IN KS KY LA MA MD MI MN MO MS MT NC ND NE NH NJ NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY"
local n : word count `st'
mat s1=J(`n',8,.)
forvalues a = 1/`n' {
local st2 : word `a' of `st'
preserve
gen ltss_cat_ind2_dup=ltss_cat_ind2
if `a'==1{
local r=1
tab flag if year==2005 
mat s1[`r',1]=r(N)
tab flag if year==2012 
mat s1[`r',4]=r(N)
collapse (sum) ltss_cat_ind2_dup (mean) ltss_cat_ind2, by(year)
sum ltss_cat_ind2_dup if year==2005 
mat s1[`r',2]=r(mean)
sum ltss_cat_ind2_dup if year==2012 
mat s1[`r',5]=r(mean)
}
else{
local r = `r'+1
tab flag if year==2005 & state_cd=="`st2'"
mat s1[`r',1]=r(N)
tab flag if year==2012 & state_cd=="`st2'"
mat s1[`r',4]=r(N)
collapse (sum) ltss_cat_ind2_dup (mean) ltss_cat_ind2 if state_cd=="`st2'", by(year)
sum ltss_cat_ind2_dup if year==2005 
mat s1[`r',2]=r(mean)
sum ltss_cat_ind2_dup if year==2012 
mat s1[`r',5]=r(mean)
}

sum ltss_cat_ind2 if year==2005
mat s1[`r',3]=round(r(mean)*100, 0.01)
sum ltss_cat_ind2 if year==2012
mat s1[`r',6]=round(r(mean)*100, 0.01)
mat s1[`r',7]=s1[`r',6]/s1[`r',3]
mat s1[`r',8]=s1[`r',6]-s1[`r',3]
restore
}
mat list s1

frmttable using `logpath'\diff_iv_05_12_`ver', statmat(s1) sdec(0,0,1, 0, 0,1,2,2) ///
title("State-level Diff in % of LTC users through HCBS btw 2005 and 2012") ///
rtitles("Total" \ ///
"Alaska" \ ///
"Alabama" \ ///
"Arkansas" \ ///
"California" \ ///
"Colorado" \ ///
"Connecticut" \ ///
"DC" \ ///
"Delaware" \ ///
"Florida" \ ///
"Georgia" \ ///
"Iowa" \ ///
"Idaho"  \ ///
"Illinois" \ ///
"Indiana" \ ///
"Kansas" \ ///
"Kentucky" \ ///
"Louisiana" \ ///
"Massachusetts" \ ///
"Maryland" \ ///
"Michigan" \ ///
"Minnesota" \ ///
"Missouri" \ ///
"Mississippi" \ ///
"Montana" \ ///
"North Carolina" \ ///
"North Dakota" \ ///
"Nebraska" \ ///
"New Hampshire" \ ///
"New Jersey" \ ///
"Nevada" \ ///
"New York" \ ///
"Ohio" \ ///
"Oklahoma" \ ///
"Oregon" \ ///
"Pennsylvania" \ ///
"Rhode Island" \ ///
"South Carolina" \ ///
"South Dakota" \ ///
"Tennessee" \ ///
"Texas" \ ///
"Utah" \ ///
"Virginia" \ ///
"Vermont" \ ///
"Washington" \ ///
"Wisconsin" \ ///
"West Virginia" \ ///
"Wyoming")  ///
ctitles("State", "2005", "", "", "2012", "", "", "Rel Diff*", "Abs Diff**" \ "", "N", "HCBS N", "%", "N",  "HCBS N","%", "", "") ///
note("*Relative Difference between 2012 and 2005" \ ///
"**Absoluate Difference between 2012 and 2005") ///
replace


************************************************************************
**Compare County-level percentage of LTC users through HCBS btw 05 and 12
************************************************************************	
local st "ALL AK AL AR CA CO CT DC DE FL GA IA ID IL IN KS KY LA MA MD MI MN MO MS MT NC ND NE NH NJ NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY"
local n : word count `st'
mat s2=J(`n',6,.)

use `data12'\hcbs_05_12_user_diff_`ver'.dta, replace	

forvalues a = 1/`n' {
local st2 : word `a' of `st'
preserve
if `a'==1{
local r=1
}
else{
keep if state_cd=="`st2'"
local r = `r'+1
}
sum user_2005
mat s2[`r',1]=round(r(N), 0.01)
mat s2[`r',2]=round(r(mean), 0.01)
sum user_2012
mat s2[`r',3]=round(r(N), 0.01)
mat s2[`r',4]=round(r(mean), 0.01)
mat s2[`r',5]=s2[`r',4]/s2[`r',2]
mat s2[`r',6]=s2[`r',4]-s2[`r',2]
restore
}
mat list s2
frmttable using `logpath'\diff_iv_05_12_`ver', statmat(s2) addtable sdec(0,1,0,1,2,2) ///
title("Cnty-level Diff in % of LTC users through HCBS btw 2005 and 2012 by State") ///
rtitles("Total" \ ///
"Alaska" \ ///
"Alabama" \ ///
"Arkansas" \ ///
"California" \ ///
"Colorado" \ ///
"Connecticut" \ ///
"DC" \ ///
"Delaware" \ ///
"Florida" \ ///
"Georgia" \ ///
"Iowa" \ ///
"Idaho"  \ ///
"Illinois" \ ///
"Indiana" \ ///
"Kansas" \ ///
"Kentucky" \ ///
"Louisiana" \ ///
"Massachusetts" \ ///
"Maryland" \ ///
"Michigan" \ ///
"Minnesota" \ ///
"Missouri" \ ///
"Mississippi" \ ///
"Montana" \ ///
"North Carolina" \ ///
"North Dakota" \ ///
"Nebraska" \ ///
"New Hampshire" \ ///
"New Jersey" \ ///
"Nevada" \ ///
"New York" \ ///
"Ohio" \ ///
"Oklahoma" \ ///
"Oregon" \ ///
"Pennsylvania" \ ///
"Rhode Island" \ ///
"South Carolina" \ ///
"South Dakota" \ ///
"Tennessee" \ ///
"Texas" \ ///
"Utah" \ ///
"Virginia" \ ///
"Vermont" \ ///
"Washington" \ ///
"Wisconsin" \ ///
"West Virginia" \ ///
"Wyoming")  ///
ctitles("State" "2005 (%)" "" "2012 (%)" "" "Rel Diff*" "Abs Diff**" \ ///
"" "N" "Mean" "N" "Mean"  "" "") multicol(1,2,2;1,4,2) ///
note("*Relative Difference between 2012 and 2005" \ ///
"**Absoluate Difference between 2012 and 2005") ///
replace





************************************************************************
**Details - Diff in County-level percentage of LTC users through HCBS btw 05 and 12
************************************************************************	
local st "ALL AK AL AR CA CO CT DC DE FL GA IA ID IL IN KS KY LA MA MD MI MN MO MS MT NC ND NE NH NJ NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY"
local n : word count `st'
mat s3=J(`n',12,.)
forvalues a = 1/`n' {
local st2 : word `a' of `st'
preserve

if `a'==1{
local r=1
}
else{
keep if state_cd=="`st2'"
local r = `r'+1
}

sum abs_diff, detail
mat s3[`r',1]=round(r(mean), 0.01)
mat s3[`r',2]=round(r(min), 0.01)
mat s3[`r',3]=round(r(p25), 0.01)
mat s3[`r',4]=round(r(p50), 0.01)
mat s3[`r',5]=round(r(p75), 0.01)
mat s3[`r',6]=round(r(max), 0.01)
sum rel_diff, detail
mat s3[`r',7]=round(r(mean), 0.01)
mat s3[`r',8]=round(r(min), 0.01)
mat s3[`r',9]=round(r(p25), 0.01)
mat s3[`r',10]=round(r(p50), 0.01)
mat s3[`r',11]=round(r(p75), 0.01)
mat s3[`r',12]=round(r(max), 0.01)
restore
}
mat list s3
frmttable using `logpath'\diff_iv_05_12_`ver', statmat(s3) addtable sdec(1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2) ///
title("Cnty-level Diff in % of LTC users through HCBS btw 2005 and 2012 by State") ///
rtitles("Total" \ ///
"Alaska" \ ///
"Alabama" \ ///
"Arkansas" \ ///
"California" \ ///
"Colorado" \ ///
"Connecticut" \ ///
"DC" \ ///
"Delaware" \ ///
"Florida" \ ///
"Georgia" \ ///
"Iowa" \ ///
"Idaho"  \ ///
"Illinois" \ ///
"Indiana" \ ///
"Kansas" \ ///
"Kentucky" \ ///
"Louisiana" \ ///
"Massachusetts" \ ///
"Maryland" \ ///
"Michigan" \ ///
"Minnesota" \ ///
"Missouri" \ ///
"Mississippi" \ ///
"Montana" \ ///
"North Carolina" \ ///
"North Dakota" \ ///
"Nebraska" \ ///
"New Hampshire" \ ///
"New Jersey" \ ///
"Nevada" \ ///
"New York" \ ///
"Ohio" \ ///
"Oklahoma" \ ///
"Oregon" \ ///
"Pennsylvania" \ ///
"Rhode Island" \ ///
"South Carolina" \ ///
"South Dakota" \ ///
"Tennessee" \ ///
"Texas" \ ///
"Utah" \ ///
"Virginia" \ ///
"Vermont" \ ///
"Washington" \ ///
"Wisconsin" \ ///
"West Virginia" \ ///
"Wyoming")  ///
ctitles("State" "Abs (%)" "" "" "" "" "" "Rel (%)" "" "" "" "" ""  \ ///
"" "Mean" "Min" "p25" "p50" "p75" "Max" "Mean" "Min" "p25" "p50" "p75" ) ///
multicol(1,3,4;1,8,2) ///
note("*Relative Difference between 2012 and 2005" \ ///
"**Absoluate Difference between 2012 and 2005") ///
replace
*/