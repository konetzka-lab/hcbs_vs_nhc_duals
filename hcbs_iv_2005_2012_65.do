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
**Exclude cnty <11 - 65 or older
gen flag=1 if age65_ind==1

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
use `data05'\hcbs_cnty_65_05_`ver', replace
}
else{
merge 1:1 st_cnty using `data12'\hcbs_cnty_65_12_`ver'
keep if _merge==3
drop _merge
save `data12'\hcbs_cnty_65_05_12_`ver', replace
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
**Exclude cnty <11 - 65*******************************
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
"2. Counties with less than 11 individuals - 65." \ ///
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
"2. Counties with less than 11 individuals - 65." \ ///
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
"2. Counties with less than 11 individuals - 65." \ ///
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
"2. Counties with less than 11 individuals - 65." \ ///
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

*/