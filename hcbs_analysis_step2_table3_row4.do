**Table 3. Robustness Checks: Instrumental Variables Estimates of Marginal Effects of HCBS Use on Hospitalizations under Alternative Samples/Assumptions
**Row 4 - Used long-term care the entire year


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

set matsize 10000

net set ado *
adopath ++ *
sysdir set PLUS *

 ********************************************************************************
********************************************************************************
*Sample Size
local yearlist 05 12
mat s1=J(17,3,.)
mat s2=J(17,3,.)
forvalues a=1/2{
local year : word `a' of `yearlist'

if `a'==1{
use `data05'\hcbs_max_`year'_iv_sample_v2.dta, replace
tab year
replace died_ind=!missing(dod_dateformat) & year_died==2005
merge m:1 bene_id using `data'\admsn2005.dta	
drop if _merge==2
drop _merge
merge m:1 bene_id using \\prfs.cri.uchicago.edu\medicaid-max\Users\jung\data\hcbs\pqi_admsn2005.dta	
drop if _merge==2
drop _merge
}
else{
/*
use `data'\walk.dta, replace
gen bene_id=bene_id_51206
gen bene_id2012=bene_id_28773
drop bene_id_28773 bene_id_51206
merge 1:1 bene_id using `data'\admsn2012.dta	
keep if _merge==3
drop bene_id
gen bene_id=bene_id2012
drop bene_id2012 _merge
save  `data'\admsn2012_bene_id, replace

use `data'\walk.dta, replace
gen bene_id=bene_id_28773
gen bene_id2012=bene_id_28773
drop bene_id_28773 bene_id_51206
merge 1:1 bene_id using \\prfs.cri.uchicago.edu\medicaid-max\Users\jung\data\hcbs\pqi_admsn2012.dta	
keep if _merge==3
drop bene_id
gen bene_id=bene_id2012
drop bene_id2012 _merge
save  `data'\pqi_admsn2012_bene_id, replace
*/
use `data'\hcbs_max_`year'_iv_sample_v2.dta, replace
tab year
merge m:1 bene_id using `data'\admsn2012_bene_id.dta	
drop if _merge==2
tab year
drop _merge
merge m:1 bene_id using `data'\pqi_admsn2012_bene_id.dta	
drop if _merge==2
tab year
drop _merge
}
 
************************************************************************
**Variable development - check **
************************************************************************
gen hcbs=1 if ltss_cat3==2
	replace hcbs=0 if ltss_cat3==1

** County 
gen st=state_cd
gen cnty=el_rsdnc_cnty_cd_ltst
gen st_cnty=st+cnty

**age
tab age
gen age_cat=0 if age<70 & age>64
	replace age_cat=1 if age<75 & age>69
	replace age_cat=2 if age<80 & age>74
	replace age_cat=3 if age<85 & age>79
	replace age_cat=4 if age<90 & age>84
	replace age_cat=5 if age>89
label define age_cat 0 "65-69" 1 "70-74" ///
					  2 "75-79" 3 "80-84" 4 "85-89" 5 "90+", replace 
label values age_cat age_cat  
tab age_cat	

gen Age="65-69" if age<70 & age>64
	replace Age="70-74" if age<75 & age>69
	replace Age="75-79" if age<80 & age>74
	replace Age="80-84" if age<85 & age>79
	replace Age="85-89" if age<90 & age>84
	replace Age="90-94" if age>89
tab Age


**female
drop female_ind
if `a'==1{
gen female_ind=0 if bene_sex_ident_cd==1
	replace female_ind=1 if bene_sex_ident_cd==2
}
else {
gen female_ind=0 if sex_ident_cd==1
	replace female_ind=1 if sex_ident_cd==2
}
label define female_ind 0 "Male" 1 "Female"
label values female_ind female_ind
tab female_ind, m

gen Female="Male" if female_ind==0
	replace Female="Female" if female_ind==1

**race/ethnicity
tab rti_race_cd, nolabel m
gen race_cat=0 if rti_race_cd==1	
	replace race_cat=1 if rti_race_cd==2	
	replace race_cat=2 if rti_race_cd==5	
	replace race_cat=3 if rti_race_cd==4	
label define race_cat 0 "White, non-Hispanic" 1 "Black, non-Hispanic" ///
					  2 "Hispanic" 3 "Asian", replace 
label values race_cat race_cat  
tab race_cat		

gen Race="White, non-Hispanic" if rti_race_cd==1	
	replace Race="Black, non-Hispanic" if rti_race_cd==2	
	replace Race="Hispanic" if rti_race_cd==5	
	replace Race="Asian" if rti_race_cd==4	
tab Race, m

**chronic conditions
gen cc_count_cat=0 if cc_count_mbsf==0|cc_count_mbsf==1
	replace cc_count_cat=1 if cc_count_mbsf==2|cc_count_mbsf==3
	replace cc_count_cat=2 if cc_count_mbsf==4|cc_count_mbsf==5
	replace cc_count_cat=3 if cc_count_mbsf>5
	
label define cc_count_cat 0 "0-1" 1 "2-3" ///
					  2 "4-5" 3 "6+", replace 
label values cc_count_cat cc_count_cat 
tab cc_count_cat	

gen cc_cancer=1 if cc_cancer_breast_ind==1| cc_cancer_colorectal_ind==1| ///
			 cc_cancer_prostate_ind==1|cc_cancer_lung_ind==1|cc_cancer_endometrial_ind==1
replace cc_cancer=0 if cc_cancer==.
gen cc_other=1 if cc_cancer==1|cc_ami_ind==1|cc_hip_fracture_ind==1
replace cc_other=0 if cc_other==.
tab cc_cancer

gen cc_count_cat10=0 if cc_count_mbsf==0|cc_count_mbsf==1
replace cc_count_cat10=1 if cc_count_mbsf==2|cc_count_mbsf==3
replace cc_count_cat10=2 if cc_count_mbsf==4|cc_count_mbsf==5
replace cc_count_cat10=3 if cc_count_mbsf==6|cc_count_mbsf==7
replace cc_count_cat10=4 if cc_count_mbsf==8|cc_count_mbsf==9
replace cc_count_cat10=5 if cc_count_mbsf==10|cc_count_mbsf>10

**entitlement
tab elig_cat, nolabel
gen elig_cat2=elig_cat
drop elig_cat
gen elig_cat=0 if elig_cat2==0	
	replace elig_cat=1 if elig_cat2==1	
	replace elig_cat=2 if elig_cat==.
label define elig_cat 0 "Aged" 1 "Disabled" ///
					  2 "Others", replace 
label values elig_cat elig_cat  

gen elig_ind=0 if elig_cat==0
replace elig_ind=1 if elig_cat==1|elig_cat==2

**rural
tab rural_ind	
gen Rural="Rural" if rural_ind==1
	replace Rural="Urban" if rural_ind==0
	
**hospitalization
tab _has_hosp
tab _has_pqi

*create indicator for MC LTSS users
gen mc_ltss_inst=1 if enc_tos_ind_2==1|enc_tos_ind_4==1|enc_tos_ind_5==1|enc_tos_ind_7==1

gen mc_ltss_hcbs=1 if enc_cltc_ind_11==1|enc_cltc_ind_12==1|enc_cltc_ind_13==1| ///
					  enc_cltc_ind_15==1|enc_cltc_ind_16==1|enc_cltc_ind_17==1| ///
					  enc_cltc_ind_18==1|enc_cltc_ind_19==1|cltc_14_enc_3m_ind==1

gen mc_ltss_cat=1 if mc_ltss_inst==1 | mc_ltss_hcbs==1
	replace mc_ltss_cat=0 if mc_ltss_inst==. & mc_ltss_hcbs==.

*create indicator for dropping particular states, adjust this after discussion
gen state_drop=(inlist(state_cd,"AZ","NM","HI", "TN"))
tab state_drop, missing	
tab state_drop, missing	

gen dem_ind=ccw_both_alz_dem
gen white_ind=1 if race_cat==0
replace white_ind=0 if race_cat==1

*iv
gen iv_cnty_young=user2005 if year==2005
replace iv_cnty_young=user2012 if year==2012

*cnty
encode st_cnty, generate(st_cnty_num)	
encode st, generate(st_num)	

*First date of HCBS/Inst service 
forvalues n=1/12{	
local wvr max_waiver_type_1_mo_`n'
gen wvr_mo`n'=1 if `wvr'=="G"|`wvr'=="H"|`wvr'=="I"|`wvr'=="J"|`wvr'=="K"|`wvr'=="L"|`wvr'=="M"|`wvr'=="N"|`wvr'=="O"|`wvr'=="P"
local wvr max_waiver_type_2_mo_`n'
replace wvr_mo`n'=1 if `wvr'=="G"|`wvr'=="H"|`wvr'=="I"|`wvr'=="J"|`wvr'=="K"|`wvr'=="L"|`wvr'=="M"|`wvr'=="N"|`wvr'=="O"|`wvr'=="P" 
local wvr max_waiver_type_3_mo_`n'
replace wvr_mo`n'=1 if `wvr'=="G"|`wvr'=="H"|`wvr'=="I"|`wvr'=="J"|`wvr'=="K"|`wvr'=="L"|`wvr'=="M"|`wvr'=="N"|`wvr'=="O"|`wvr'=="P" 
}

tab wvr_mo1
tab wvr_mo2
tab wvr_mo3
tab wvr_mo4
tab wvr_mo5
tab wvr_mo6
tab wvr_mo7
tab wvr_mo8
tab wvr_mo9
tab wvr_mo10
tab wvr_mo11
tab wvr_mo12

gen first_wvr_mo=1 if wvr_mo1==1
forvalues n=2/12{
replace first_wvr_mo=`n' if wvr_mo`n'==1 & first_wvr_mo==. 
}
tab first_wvr_mo

gen hcbs_svc_enroll = mdy(first_wvr_mo, 1, 2012) if year==2012
replace hcbs_svc_enroll = mdy(first_wvr_mo, 1, 2005) if year==2005
format hcbs_svc_enroll %d
tab hcbs_svc_enroll

gen hcbs_svc_claims=hcbs_svc_start
format hcbs_svc_claims %d
tab hcbs_svc_claims
drop hcbs_svc_start

gen hcbs_svc_first=hcbs_svc_claims if (hcbs_svc_claims<hcbs_svc_enroll|hcbs_svc_claims==hcbs_svc_enroll) & (ltss_cat3==2|ltss_cat3==3)
replace hcbs_svc_first=hcbs_svc_enroll if (hcbs_svc_claims>hcbs_svc_enroll) & (ltss_cat3==2|ltss_cat3==3)
tab hcbs_svc_first
format hcbs_svc_first %d
tab hcbs_svc_first

gen inst_svc_first=inst_svc_start
format inst_svc_first %d
tab inst_svc_first

tab year if missing(hcbs_svc_first) & hcbs==1
tab year if missing(inst_svc_first) & hcbs==0

gen hcbs_svc_first_drop=1 if missing(hcbs_svc_first) & (ltss_cat3==2|ltss_cat3==3)
gen inst_svc_first_drop=1 if missing(inst_svc_first) & (ltss_cat3==1|ltss_cat3==3)
	
gen svc_first_month=month(hcbs_svc_first) if hcbs==1
replace svc_first_month=month(inst_svc_first) if hcbs==0

tab hcbs svc_first_month, m	

gen last_wvr_mo=12 if wvr_mo12==1
forvalues n=11(-1)1{
replace last_wvr_mo=`n' if wvr_mo`n'==1 & last_wvr_mo==. 
}
tab last_wvr_mo

*Duration - HCBS/Inst service 
gen hcbs_svc_enroll_last = mdy(last_wvr_mo, 1, 2012) if year==2012
replace hcbs_svc_enroll_last = mdy(last_wvr_mo, 1, 2005) if year==2005
format hcbs_svc_enroll_last %d
tab hcbs_svc_enroll_last

gen hcbs_svc_claims_last=hcbs_svc_last
format hcbs_svc_claims_last %d
tab hcbs_svc_claims_last
drop hcbs_svc_last

gen hcbs_svc_last=hcbs_svc_claims_last if (hcbs_svc_claims_last>hcbs_svc_enroll_last|hcbs_svc_claims_last==hcbs_svc_enroll_last) & (ltss_cat3==2|ltss_cat3==3)
replace hcbs_svc_last=hcbs_svc_enroll_last if (hcbs_svc_claims_last<hcbs_svc_enroll_last) & (ltss_cat3==2|ltss_cat3==3)
tab hcbs_svc_last
format hcbs_svc_last %d
tab hcbs_svc_last

format inst_svc_last %d
tab inst_svc_first

tab year if missing(hcbs_svc_last) & hcbs==1
tab year if missing(inst_svc_last) & hcbs==0

gen hcbs_svc_last_drop=1 if missing(hcbs_svc_last) & (ltss_cat3==2|ltss_cat3==3)
gen inst_svc_last_drop=1 if missing(inst_svc_last) & (ltss_cat3==1|ltss_cat3==3)
	
gen svc_last_month=month(hcbs_svc_last) if hcbs==1
replace svc_last_month=month(inst_svc_last) if hcbs==0

tab hcbs svc_first_last, m	
	
gen hcbs_month_dur=month(hcbs_svc_last)-month(hcbs_svc_first) if hcbs==1
gen inst_month_dur=month(inst_svc_last)-month(inst_svc_first) if hcbs==0

	
************************************************************************
**Sample Size**
************************************************************************
** Main sample
**All Medicaid FFS LTSS users
keep if ltss_cat3==1|ltss_cat3==2|ltss_cat3==3
drop if hcbs_svc_first_drop==1|inst_svc_first_drop==1
**FFS users without Medicaid Managed Care Claims
keep if mc_ltss_cat==0
** had linkage by bene_id to MBSF files
keep if merge_mbsf==1 	
** duals for full 12m period 
keep if mc_dual_mbsf==1 
** also dropped in if managed care enrolled, MA, PACE ** first definition
tab ma_ind 
tab cmcp_enroll_ind
tab pace_plan_mogt0
gen byte sample_hosp=1
replace sample_hosp=0 if ma_ind==1 | pace_plan_mogt0==1
label var sample_hosp "No MA, No PACE(ie FFS Medicare)"
tab sample_hosp, missing
keep if sample_hosp==1 

** e1. age >65 - restrict to elderly group to  make sample more homogenous
tab age65_ind 
keep if age65_ind==1
tab year
local r = 1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e2. Full demographic information
gen full_demo=(!missing(race_5cat) & !missing(female_ind) & !missing(age_mbsf))
tab full_demo, missing
keep if full_demo==1
tab year 
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e3. race - White, Black
tab race_5cat
keep if race_5cat==1|race_5cat==2
tab year  
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e4. HCBS only or IC only 
tab ltss_cat3
keep if ltss_cat3==1|ltss_cat3==2
tab year 
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e5. Excluded trans only hcbs user
gen personal_care=1 if hcbs_waiver_cltc31==1|cltc_exp_gt0_11==1
replace personal_care=0 if personal_care==.
gen private_duty_nursing=1 if hcbs_waiver_cltc32==1|cltc_exp_gt0_12==1
replace private_duty_nursing=0 if private_duty_nursing==.
gen adult_day_care=1 if hcbs_waiver_cltc33==1|cltc_exp_gt0_13==1
replace adult_day_care=0 if adult_day_care==.
gen home_health=1 if hcbs_waiver_cltc34==1|cltc_exp_gt0_14_3m==1
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

local list "trans personal_care target_case home_health rehabilitation private_duty_nursing adult_day_care residential_care hospice hcbs_waiver_cltc30 hcbs_waiver_cltc40"
local n_3 : word count `list'
forvalues n3=1/`n_3'{
local svc : word `n3' of `list'
if `n3'==1{
gen trans_only=1 if `svc'==1
}
else {
replace trans_only=0 if trans_only==1&`svc'==1 
}
}
replace trans_only=0 if trans_only==.
tab trans_only
tab trans_only trans
drop if trans_only==1
tab year
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e6. Alive for full year
keep if died_ind==0
tab year
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e7. No County Information
tab st_cnty if missing(st_cnty)
tab st_cnty if cnty=="000"
tab st_cnty if cnty=="999"
keep if cnty!="000" & cnty!="999" & !missing(cnty)
tab year
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e8. Exclude cnty without IV
merge m:1 st_cnty using `data'\hcbs_cnty_05_12_ver4.dta
keep if _merge==3
tab year
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

***full year 
keep if (hcbs_month_dur==11 &hcbs==1)|(inst_month_dur==1&hcbs==0)

** e9. Counties both in 2005 and 2012
gen flag=1
preserve
collapse (mean) flag, by(st_cnty)
gen flag`year'=flag
drop flag
save `data'\exclusion_cnty_`year', replace
restore
save `data'\hcbs_max_`year'_iv_sample_v3.dta, replace
}
preserve
use `data'\exclusion_cnty_05, replace
merge 1:1 st_cnty using `data'\exclusion_cnty_12.dta
keep if _merge==3
gen cnty_flag=1
drop _merge
save `data'\exclusion_cnty, replace
restore
local r = `r'+1	
forvalues a=1/2{
local year : word `a' of `yearlist'
use `data'\hcbs_max_`year'_iv_sample_v3.dta, replace 
drop _merge
merge m:1 st_cnty using `data'\exclusion_cnty.dta
keep if cnty_flag==1
drop _merge
tab year
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'
save `data'\hcbs_`year'_`ver', replace
}

*Merge 2005 and 2012
use `data'\hcbs_05_`ver', replace
append using `data'\hcbs_12_`ver'

********************************************************************************
**Define hosp and pqi
********************************************************************************
gen hosp_post_flag=1 if _has_hosp==1     & hcbs==1 &(hcbs_svc_first>admsn_last)
replace hosp_post_flag=1 if _has_hosp==1 & hcbs==0 &(inst_svc_first>admsn_last)
replace hosp_post_flag=0 if hosp_post_flag==.
tab hosp_post_flag year, col
tab hosp_post_flag year if _has_hosp==1, col
tab _has_hosp
tab _has_hosp year if missing(admsn_last)
gen hosp_pre_flag=1 if _has_hosp==1     & hcbs==1 &(hcbs_svc_first>admsn_first)
replace hosp_pre_flag=1 if _has_hosp==1 & hcbs==0 &(inst_svc_first>admsn_first)
replace hosp_pre_flag=0 if hosp_pre_flag==.
tab hosp_pre_flag year, col
tab hosp_pre_flag year if _has_hosp==1, col
**If the last hospitalization date < first date of inst/hcbs service = do not count as a hospitalization
gen hosp=1 if _has_hosp==1 & hosp_post_flag==0
replace hosp=0 if _has_hosp==0 | (_has_hosp==1 & hosp_post_flag==1)
tab hosp _has_hosp

gen pqi_post_flag=1 if _has_pqi==1     & hcbs==1 &(hcbs_svc_first>pqi_admsn_last)
replace pqi_post_flag=1 if _has_pqi==1 & hcbs==0 &(inst_svc_first>pqi_admsn_last)
replace pqi_post_flag=0 if pqi_post_flag==.
tab pqi_post_flag year, col
tab pqi_post_flag year if _has_pqi==1, col
tab _has_pqi
tab _has_pqi year if missing(pqi_admsn_last)
gen pqi_pre_flag=1 if _has_pqi==1     & hcbs==1 &(hcbs_svc_first>pqi_admsn_first)
replace pqi_pre_flag=1 if _has_pqi==1 & hcbs==0 &(inst_svc_first>pqi_admsn_first)
replace pqi_pre_flag=0 if pqi_pre_flag==.
tab pqi_pre_flag year, col
tab pqi_pre_flag year if _has_pqi==1, col
**If the last hospitalization date < first date of inst/hcbs service = do not count as a hospitalization
gen pqi=1 if _has_pqi==1 & pqi_post_flag==0
replace pqi=0 if _has_pqi==0 | (_has_pqi==1 & pqi_post_flag==1)
tab pqi _has_pqi

save `data'\hcbs_`ver'_first, replace

	   
* e10. Exclude counties with zero or 100% of HCBS use, hospitalization, PQI Hospitalization - overall, by race, and by alz
forvalues n=1/5{
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
collapse (mean) hcbs hosp pqi, by(st_cnty)
gen exclusion_hcbs`n'=1 if hcbs==1|hcbs==0
replace exclusion_hcbs`n'=0 if hcbs>0&hcbs<1
tab exclusion_hcbs`n'

gen exclusion_hosp`n'=1 if hosp==1|hosp==0
replace exclusion_hosp`n'=0 if hosp>0&hosp<1
tab exclusion_hosp`n'

gen exclusion_pqi`n'=1 if pqi==1|pqi==0
replace exclusion_pqi`n'=0 if pqi>0&pqi<1
tab exclusion_pqi`n'

keep st_cnty exclusion_hcbs`n' exclusion_hosp`n' exclusion_pqi`n'
save `data'\exclusion`n', replace
restore
}


forvalues n=1/5{
merge m:1 st_cnty using `data'\exclusion`n'.dta
drop _merge
}
gen exclusion=1 if exclusion_hcbs1==1|exclusion_hcbs2==1|exclusion_hcbs3==1|exclusion_hcbs4==1| ///
				   exclusion_hcbs5==1| ///
				   exclusion_hosp1==1|exclusion_hosp2==1|exclusion_hosp3==1|exclusion_hosp4==1| ///
				   exclusion_hosp5==1| ///
				   exclusion_pqi1==1|exclusion_pqi2==1|exclusion_pqi3==1|exclusion_pqi4==1| ///
				   exclusion_pqi5==1				   
replace exclusion=0 if exclusion_hcbs1==0&exclusion_hcbs2==0&exclusion_hcbs3==0&exclusion_hcbs4==0& ///
				   exclusion_hcbs5==0& ///
				   exclusion_hosp1==0&exclusion_hosp2==0&exclusion_hosp3==0&exclusion_hosp4==0& ///
				   exclusion_hosp5==0& ///
				   exclusion_pqi1==0&exclusion_pqi2==0&exclusion_pqi3==0&exclusion_pqi4==0& ///
				   exclusion_pqi5==0		   
keep if exclusion==0

local r = `r'+1	
forvalues a=1/2{
preserve
if `a'==1{
keep if year==2005
}
else{
keep if year==2012
}
tab year
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'
restore
}

** e11. AZ, HI, NM, TN - Managed Care rate is high
tab state_drop, m
keep if state_drop==0
tab year  
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e12. AR, NJ, OH
drop if state_cd=="AR"|state_cd=="NJ"|state_cd=="OH"			 
tab year  
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

** e13. AK, CT: Diff direction of IV prediction
tab state_drop, m
drop if state_cd=="AK"|state_cd=="CT"			 
tab year  
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'

**e14. Exclude Maine in 2012
drop if state_cd=="ME"
tab year
local r = `r'+1	
mat s`a'[`r',1]=r(N) 
mat s`a'[`r',2]=s`a'[`r',1]/s`a'[`r'-1,1]*100
mat s`a'[`r',3]=s`a'[`r',1]/s`a'[1,1]*100
mat list s`a'
save `data'\hcbs_`ver', replace




tab hcbs_month_dur if hcbs==1
tab inst_month_dur if hcbs==0


gen iv_cnty_young=user2005 if year==2005
replace iv_cnty_young=user2012 if year==2012
tab hosp year, col
encode st_cnty, generate(st_cnty_num)	
encode st, generate(st_num)	


logit hosp i.hcbs i.age_cat i.female_ind i.race_5cat ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 

logit hcbs iv_cnty_young i.age_cat i.female_ind i.race_5cat  ///
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
logit hosp i.hcbs re i.age_cat i.female_ind i.race_5cat  ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)


margins, dydx(hcbs) 





logit pqi i.hcbs i.age_cat i.female_ind i.race_5cat  ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)
margins, dydx(hcbs) 

logit hcbs iv_cnty_young i.age_cat i.female_ind i.race_5cat  ///
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
logit pqi i.hcbs re i.age_cat i.female_ind i.race_5cat  ///
			 i.elig_ind i.cc_hyperp_ind i.cc_asthma_ind i.cc_atrial_fib_ind ///
			 i.cc_stroke_tia_ind i.cc_cataract_ind i.cc_chronickidney_ind ///
			 i.cc_copd_ind i.cc_chf_ind i.cc_diabetes_ind i.cc_glaucoma_ind ///
			 i.cc_ischemicheart_ind i.cc_depression_ind i.cc_osteoporosis_ind ///
			 i.cc_ra_oa_ind i.cc_other i.cc_anemia_ind i.cc_hyperl_ind ///
			 i.cc_hypert_ind i.cc_hypoth_ind i.ccw_both_alz_dem /// 
			 i.year i.st_cnty_num, robust cluster(st_cnty_num)


margins, dydx(hcbs) 
log close
