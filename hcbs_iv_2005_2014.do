**IV

capture log close
clear all
set more off
set scheme s1color

local logpath *
local data05 *
local data14 *
local ver *
local st "ALL"
net set ado *
adopath ++ *
sysdir set PLUS *

local n : word count `st'
forvalues z = 1/`n' {
local st2 : word `z' of `st'


local yearlist 05 14
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
keep if year==2014
replace died_ind=!missing(dod_dateformat) & year_died==2014
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
**Exclude Maine in 2014*******************************
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
save `data'\hcbs_cnty_14_`ver', replace
restore
}

}
}

********************************************************************************
**Define counties in both 2005 and 2014*******************************
********************************************************************************
forvalues a=1/2{
if `a'==1 {
use `data05'\hcbs_cnty_05_`ver', replace
}
else{
merge 1:1 st_cnty using `data12'\hcbs_cnty_14_`ver'
keep if _merge==3
drop _merge
save `data12'\hcbs_cnty_05_14_`ver', replace
}
}
