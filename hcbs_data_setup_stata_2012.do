** Datasets created using hcbs_sas_data_setup2012.sas
** Set up the Stata datasets, variable names, labels, etc
** Merges all states into single dataset 

capture log close
clear all
set more off

local logpath * /*Change pathway*/
local datapath * /*Change pathway*/
local logpath * /*Change pathway*/
local data_max * /*Change pathway*/
local data * /*Change pathway*/

*path for mbsf, mbsf ccw, hospitalization outcomes at bene_id level
local mbsf2005 * /*Change pathway*/
local mbsf2012 * /*Change pathway*/

net set ado * /*Change pathway*/
adopath ++ * /*Change pathway*/
sysdir set PLUS * /*Change pathway*/

local ds all
local statelist ak al ar az ca co ct dc de fl ga hi ia id il in ks ky la ma md ///
    me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va  ///
    vt wa wi wv wy

foreach st in `statelist'{
clear
use `datapath'\ltc_use_max_2012_`st'_`ds'_2.dta
compress
******************************************************************
** Demographic variables
******************************************************************
gen year = 2012
rename *, lower

**Age
la def age_cat 0 "Age: Under 1" 1"1-5" 2 "6-14" 3 "15-20" 4 "21-44" ///
5 "45-64" 6 "65-74" 7 "75-84" 8 "85+" 9"Unknown/error"
la val  el_age_grp_cd age_cat
tab el_age_grp_cd, missing

**Gender
gen byte female_ind=1 if el_sex_cd=="F"
replace female_ind=0 if el_sex_cd=="M"
tab female_ind, missing

**Race and ethnicity
la def race_cat 1 "White, non-Hispanic" 2 "Black, non-Hispanic" 3 "American Indian or Alaska Native" ///
4"Asian" 5 "Hispanic" 6 "Native hawaiian or other PI" 7 "Hispanic" 8"More than one race, non-Hispanic" ///
9"Unknown"
destring el_race_ethncy_cd, replace
la val el_race_ethncy_cd race_cat
tab el_race_ethncy_cd, missing

gen race_eth_4cat=1 if el_race_ethncy_cd==1
replace race_eth_4cat=2 if el_race_ethncy_cd==2
replace race_eth_4cat=3 if inlist(el_race_ethncy_cd,5,7)
replace race_eth_4cat=4 if inlist(el_race_ethncy_cd,3,4,6,8)
replace race_eth_4cat=5 if el_race_ethncy_cd==9
la def race_cat4 1 "White, non-Hispanic" 2 "Black, non-Hispanic"  3 "Hispanic" ///
4 "Other" 5 "Unknown"
la val race_eth_4cat race_cat4
tab race_eth_4cat, missing

**Medicare dual elgibility
tab el_mdcr_dual_ann, missing

**should discuss this with Tamara,might need to distinguish between codes
gen mc_dual=(el_mdcr_dual_ann!="00")
tab mc_dual, missing
la var mc_dual "Medicare dual-eligible"

**rural urban continuum codes
la def rucc_2013 1 "Metro areas 1+ million pop" 2 "Metro area 250K-1M" ///
 3 "Metro area <250K" 4"Urban pop 20K+, adjacent metro" ///
 5 "Urban 20K+, not adjacent" 6"Urban 2,500-19,999, adjacent" ///
 7"Urban 2,500-19,999, not adjacent" 8"Completely rural, adjacent" ///
 9"Completely rural, not adjacent", replace
la val rucc_2013 rucc_2013
tab rucc_2013, missing

gen rural_ind=(inlist(rucc_2013,8,9))
tab rural_ind, missing
la var rural_ind "Rural county, 1=yes"

gen non_metro_ind=(inlist(rucc_2013,4,5,6,7,8,9))
tab non_metro_ind, missing
la var non_metro_ind "Non-metro (rural) county, 1=yes"

******************************************************************
** FFS Medicaid LTSS use
******************************************************************

**Medicaid eligibility code
la def elig_cat 0 "Aged" 1"Blind,disabled" 2"Child" 3"Adult" 4"Unknown" 5"Not eligible"
la val elig_cat elig_cat
tab elig_cat,missing

**Institutional LTSS (FFS)
la var inst_ltss_ind1 "Any institutional LTSS expenditures"
tab elig_cat inst_ltss_ind1, missing

la var exp_tos2_gt0 "Inst. LTSS IMD Hospital services for aged 65+"
la var exp_tos4_gt0 "Inst. LTSS Inpatient psychiatric under age 21"
la var exp_tos5_gt0 "Inst. LTSS ICF/MR"
la var exp_tos7_gt0 "Inst. LTSS Nursing facilities"

**Institutional LTSS (Managed care)
la var enc_tos_ind_2 "MC - Inst. LTSS IMD Hospital Aged"
la var enc_tos_ind_4 "MC - Inst. LTSS IP Psych <21"
la var enc_tos_ind_5 "MC - Inst. LTSS ICF/MR"
la var enc_tos_ind_7 "MC - Inst. LTSS Nursing facilities"

tab inst_mc_ind, missing

**HCBS - waivers
la var wvr_1915c_enroll_ind "HCBS - 1915c Waiver enrollment"
la var hcbs_tax_exp_gt0 "HCBS - Expenditures>0 for Waiver Services"

tab hcbs_1915c_ind, missing

**individual waiver HCBS services
la var hcbs_waiver_cltc30 "Other/Unspecified, 1915c waiver"
la var hcbs_waiver_cltc31 "Personal care, 1915c waiver"
la var hcbs_waiver_cltc32 "Private duty nursing, 1915c waiver"
la var hcbs_waiver_cltc33 "Adult day care, 1915c waiver"
la var hcbs_waiver_cltc34 "Home health, 1915c waiver"
la var hcbs_waiver_cltc35 "Residential care, 1915c waiver"
la var hcbs_waiver_cltc36 "Rehabilitation, 1915c waiver"
la var hcbs_waiver_cltc37 "Targeted case management, 1915c waiver"
la var hcbs_waiver_cltc38 "Transportation, 1915c waiver"
la var hcbs_waiver_cltc39 "Hospice, 1915c waiver"
la var hcbs_waiver_cltc40 "CME, 1915c waiver"

**HCBS - state plans (FFS)
tab hcbs_cltc_nonwaiver_1, missing
tab hcbs_cltc_nonwaiver_2, missing
tab hcbs_cltc_nonwaiver_3, missing
tab hcbs_cltc_nonwaiver_4, missing

la var cltc_exp_gt0_11 "Personal care, state plan"
la var cltc_exp_gt0_12 "Private duty nursing, state plan"
la var cltc_12_ind "Home-based Private duty nursing, state plan"
la var cltc_exp_gt0_13 "Adult day care, state plan"
la var cltc_exp_gt0_14 "Home health, state plan"
la var cltc_exp_gt0_15 "Residential care, state plan"
la var cltc_exp_gt0_16 "Rehabilitation services, state plan"
la var cltc_exp_gt0_17 "Targeted case management, state plan"
la var cltc_exp_gt0_18 "Transportation, state plan"
la var cltc_exp_gt0_19 "Hospice, state plan"
la var cltc_19_ind "Home hospice, state plan"

**HCBS - state plan managed care
la var enc_cltc_ind_11 "MC - Personal care, state plan"
la var enc_cltc_ind_12 "MC - Private duty nursing, state plan"
la var enc_cltc_ind_13 "MC - Adult day care, state plan"
la var enc_cltc_ind_14 "MC - Home health, state plan"
la var enc_cltc_ind_15 "MC - Residential care, state plan"
la var enc_cltc_ind_16 "MC - Rehabilitation services, state plan"
la var enc_cltc_ind_17 "MC - Targeted case management, state plan"
la var enc_cltc_ind_18 "MC - Transportation, state plan"
la var enc_cltc_ind_19 "MC - Hospice, state plan"

tab hcbs_state_plan_mc, missing

**PACE Plan enrollment - Classified as HCBS use
la var pace_plan_mogt0 "PACE"
***************************************************

***************************************************
**Four versions based on the four state plan definitions
** 1 = state plan cltc services 11-14, 16,17, no restrictions on 3m consec services (truven defn)
** 2 = same services as 1, requires 3m consecutive for 14 (home health)
** 3 = Adds services 15, 18, 19, requires private duty nursing 12 to be at home, keeps 3m consecutive for 14 (ahrq defn)
** 4 = Same as 3 but requires 90d home health, not 3 consecutive months
*************************************************** 
**hcbs - state plan, waivers, PACE
gen byte hcbs_all_ind1=1 if hcbs_1915c_ind==1 | hcbs_cltc_nonwaiver_1==1 | pace_plan_mogt0==1
replace hcbs_all_ind1=0 if hcbs_1915c_ind==0 & hcbs_cltc_nonwaiver_1==0 & pace_plan_mogt0==0
la var hcbs_all_ind1 "Any HCBS use, defn. 1"
tab hcbs_all_ind1, missing

gen byte hcbs_all_ind2=1 if hcbs_1915c_ind==1 | hcbs_cltc_nonwaiver_2==1 | pace_plan_mogt0==1
replace hcbs_all_ind2=0 if hcbs_1915c_ind==0 & hcbs_cltc_nonwaiver_2==0 & pace_plan_mogt0==0
la var hcbs_all_ind2 "Any HCBS use, defn. 2"
tab hcbs_all_ind2, missing

gen byte hcbs_all_ind3=1 if hcbs_1915c_ind==1 | hcbs_cltc_nonwaiver_3==1 | pace_plan_mogt0==1
replace hcbs_all_ind3=0 if hcbs_1915c_ind==0 & hcbs_cltc_nonwaiver_3==0 & pace_plan_mogt0==0
la var hcbs_all_ind3 "Any HCBS use, defn. 3"
tab hcbs_all_ind3, missing

gen byte hcbs_all_ind4=1 if hcbs_1915c_ind==1 | hcbs_cltc_nonwaiver_4==1 | pace_plan_mogt0==1
replace hcbs_all_ind4=0 if hcbs_1915c_ind==0 & hcbs_cltc_nonwaiver_4==0 & pace_plan_mogt0==0
la var hcbs_all_ind4 "Any HCBS use, defn. 4"
tab hcbs_all_ind4, missing


tab hcbs_all_ind1 hcbs_all_ind2, missing
tab hcbs_all_ind2 hcbs_all_ind3, missing
tab hcbs_all_ind1 hcbs_all_ind3, missing
tab hcbs_all_ind3 hcbs_all_ind4, missing

**LTSS use categories
tab hcbs_all_ind1 inst_ltss_ind1, missing

la def ltss_cat 0 "None" 1"Instutional only" 2"HCBS Only" 3"Inst and HCBS"

forvalues i=1/4{
	gen ltss_cat`i'=0 if inst_ltss_ind1==0 & hcbs_all_ind`i'==0
	replace ltss_cat`i'=1 if inst_ltss_ind1==1 & hcbs_all_ind`i'==0
	replace ltss_cat`i'=2 if  inst_ltss_ind1==0 & hcbs_all_ind`i'==1
	replace ltss_cat`i'=3 if  inst_ltss_ind1==1 & hcbs_all_ind`i'==1
	la val ltss_cat`i' ltss_cat
	}

la var ltss_cat1 "LTSS use - categorical, defn. 1"
la var ltss_cat2 "LTSS use - categorical, defn. 2"
la var ltss_cat3 "LTSS use - categorical, defn. 3"
la var ltss_cat4 "LTSS use - categorical, defn. 4"

tab ltss_cat1 elig_cat

*ltss indicators, 4 definitions + using Managed care encounter records
tab ltss_ind_1
tab ltss_ind_2
tab ltss_ind_3
tab ltss_ind_4
tab ltss_mc_or_ffs_ind
	
*comprehensive managed care plan enrollment indicators	
tab cmcp_enroll_ind, missing

la def cmcp_cat 0"None" 1"1-11 months" 2"Enrolled full 12m"
la val cmcp_enroll_cat cmcp_cat


**save dataset
save `datapath'\ltc_use_max_2012_`st'_`ds'_3.dta, replace
}

*****************************************************************
**keep only LTSS users, save into merged dataset with all states
**append into single dataset
*****************************************************************

use `datapath'\ltc_use_max_2012_ak_`ds'_3.dta   
   
foreach st in `statelist'{
	append using `datapath'\ltc_use_max_2012_`st'_`ds'_3.dta
}

tab race_eth_4cat , gen(race_eth_ind)

la var race_eth_ind1 "White, non-Hispanic"
la var race_eth_ind2 "Black, non-Hispanic"
la var race_eth_ind3 "Hispanic"
la var race_eth_ind4 "Other"
la var race_eth_ind5 "Unknown/Missing race"

**from medicare race variable (compare these with dual mbsf records!)
la def mdcr_race 0"Unknown" 1"White" 2"Black" 3"Other" 4 "Asian" 5"Hispanic" 6"North American Native"
la val mdcr_race_ethncy_cd mdcr_race

tab ltss_ind_1, missing
tab ltss_ind_3, missing

tab state_cd, missing

tab cmcp_enroll_ind ltss_ind_1

tab el_age_grp_cd

gen age_grp1=(el_age_grp_cd<4)
la var age_grp1 "Age Less than 21"
gen age_grp2=(el_age_grp_cd>3 & el_age_grp_cd<6)
la var age_grp2 "Age 21-64"
gen age_grp3=(el_age_grp_cd>5&el_age_grp_cd<8)
la var age_grp3 "Age 65-84"
gen age_grp4=(el_age_grp_cd==8)
la var age_grp4 "Age 85+"

forvalues i=1/4{
tab el_age_grp_cd age_grp`i', missing
}

tab female_ind
la var female_ind "Female"

tab elig_cat, gen(elig_cat_ind)
la var elig_cat_ind1 "Eligibility group - Aged"
la var elig_cat_ind2 "Disabled"
la var elig_cat_ind3 "Child"
la var elig_cat_ind4 "Adult"


*check for duplicates of bene_id, flag individuals that show up in
*more than one state in the same year and/or more than one 
*msis_id linked to the same bene_id within a state
*cannot do the same for msis_id
sort bene_id
duplicates tag bene_id if !missing(bene_id),gen(dup)
gen beneid_dup_flag=(dup>0 & !missing(dup))
drop dup
la var beneid_dup_flag "bene_id has more than one observation, 1=yes"
tab beneid_dup_flag, missing

save `datapath'\ltc_use_max_2012_comb_ltssonly_wdups.dta, replace

***************************************************************************
**now deal with duplicates, split into ds of just dups for processing purposes and append back in
**this makes it much faster
keep if beneid_dup_flag==1

**deal with duplicates
**case 1: same state but multiple msis_ids with same bene_id, about 25% of cases
**case 2: different state, same bene_id
by bene_id (state_cd), sort: gen same_state = state_cd[1] == state_cd[_N] if beneid_dup_flag==1
tab same_state if beneid_dup_flag ==1

gen state_cd2=state_cd
replace state_cd2="" if same_state==0 & beneid_dup_flag ==1

by bene_id (mc_dual), sort: gen same_dual = mc_dual[1] == mc_dual[_N] if beneid_dup_flag==1 
tab same_dual if same_state==1 & beneid_dup_flag==1, missing

by bene_id (el_dob), sort: gen same_dob = el_dob[1] == el_dob[_N] if beneid_dup_flag==1 
tab same_dob if same_state==1 & beneid_dup_flag==1, missing

*when look at race variable, if another variable to split by race, may want to reconsider this
by bene_id (race_eth_4cat), sort: gen same_race = race_eth_4cat[1] == race_eth_4cat[_N] if beneid_dup_flag==1 
tab same_race if same_state==1 & beneid_dup_flag==1, missing

by bene_id (female_ind), sort: gen same_sex = female_ind[1] == female_ind[_N] if beneid_dup_flag==1 
tab same_sex if same_state==1 & beneid_dup_flag==1, missing

**indicator for having no conflicts in dob, race, sex, dual status, elig category
gen byte dup_no_conflicts=(/*same_elig==1 &*/ same_dual==1 & same_dob==1 & same_race==1 & same_sex==1) if beneid_dup_flag==1
tab dup_no_conflicts if beneid_dup_flag==1 & same_state==1, missing
tab dup_no_conflicts if beneid_dup_flag==1 & same_state==0, missing
*eventually want to drop if dup_no_conflicts==0 & beneid_dup_flag==1

**combine 
local ivars exp_tos2_gt0 exp_tos4_gt0 exp_tos5_gt0 exp_tos7_gt0 inst_ltss_ind1 ///
wvr_1915c_enroll_ind pace_plan_mogt0 hcbs_waiver_cltc30 hcbs_waiver_cltc31 ///
hcbs_waiver_cltc32 hcbs_waiver_cltc33 hcbs_waiver_cltc34 hcbs_waiver_cltc35 ///
hcbs_waiver_cltc36 hcbs_waiver_cltc37 hcbs_waiver_cltc38 hcbs_waiver_cltc39 ///
hcbs_waiver_cltc40 hcbs_1915c_ind cltc_exp_gt0_14_3m cltc_12_ind cltc_19_ind ///
hcbs_cltc_nonwaiver_3 cltc_exp_gt0_11 cltc_exp_gt0_13 cltc_exp_gt0_15 ///
cltc_exp_gt0_16 cltc_exp_gt0_17 cltc_exp_gt0_18 ltss_ind_3 ///
ltss_ind_5 hcbs_1915c_ind_tax hcbs_txnmy_gt0_1 hcbs_txnmy_gt0_2 hcbs_txnmy_gt0_3 ///
hcbs_txnmy_gt0_4 hcbs_txnmy_gt0_5 hcbs_txnmy_gt0_6 hcbs_txnmy_gt0_7 hcbs_txnmy_gt0_8 ///
hcbs_txnmy_gt0_9 hcbs_txnmy_gt0_10 hcbs_txnmy_gt0_11 hcbs_txnmy_gt0_12 ///
hcbs_txnmy_gt0_13 hcbs_txnmy_gt0_14 hcbs_txnmy_gt0_15 hcbs_txnmy_gt0_16 ///
hcbs_txnmy_gt0_17 hcbs_txnmy_gt0_18
foreach v in `ivars'{
egen c_`v'=max(`v') if dup_no_conflicts==1, by(bene_id)
}

**categorical variables
gen byte c_hcbs_all_ind3=1 if c_hcbs_1915c_ind==1 | c_hcbs_cltc_nonwaiver_3==1 | c_pace_plan_mogt0==1
replace c_hcbs_all_ind3=0 if c_hcbs_1915c_ind==0 & c_hcbs_cltc_nonwaiver_3==0 & c_pace_plan_mogt0==0
replace c_hcbs_all_ind3=. if dup_no_conflicts==0

local i 3
gen c_ltss_cat`i'=0 if c_inst_ltss_ind1==0 & c_hcbs_all_ind`i'==0
replace c_ltss_cat`i'=1 if c_inst_ltss_ind1==1 & c_hcbs_all_ind`i'==0
replace c_ltss_cat`i'=2 if  c_inst_ltss_ind1==0 & c_hcbs_all_ind`i'==1
replace c_ltss_cat`i'=3 if  c_inst_ltss_ind1==1 & c_hcbs_all_ind`i'==1
replace c_ltss_cat`i'=. if dup_no_conflicts==0

**expenditures variables
local expendv tot_mdcd_pymt_amt tot_mdcd_prem_pymt_amt tot_mdcd_ffs_pymt_amt  ///
expend_iphosp expend_instltc expend_hcbs expend_prof_op expend_rx  expend_other
foreach v in `expendv'{
egen c_`v'=total(`v') if dup_no_conflicts==1, by(bene_id)
}

*now drop dupicates and rename variables so match full ds names
bysort bene_id: gen seq=_n
keep if seq==1
drop seq 
drop same_*

local varlist `ivars' hcbs_all_ind3 ltss_cat3 `expendv'
foreach v in `varlist'{
drop `v'
rename c_`v' `v'
}

compress

save `datapath'\max_2012_dups_beneid_only.dta, replace

**now merge merged duplicates back into main dataset
use `datapath'\ltc_use_max_2012_comb_ltssonly_wdups.dta, clear
gen state_cd2=state_cd

drop if beneid_dup_flag==1

append using `datapath'\max_2012_dups_beneid_only.dta

*now check for duplicates again
sort bene_id
duplicates tag bene_id if !missing(bene_id),gen(dup)
tab dup, missing

label var state_cd2 "State code, missing if duplicate in mult. states"
label var beneid_dup_flag "Dup bene_id in orig dataset"

save `datapath'\ltc_use_max_2012_comb_ltssonly_`ds'.dta, replace


**ahrq ltss definition
tab ltss_cat3, missing
tab ltss_ind_3, missing

*keep if ltss_cat3!=0

*drop if missing age category
*drop if el_age_grp_cd==9

tab ltss_cat3, gen(ltss_cat_ind)
la var ltss_cat_ind1 "Institutional Only"
la var ltss_cat_ind2 "HCBS only"
la var ltss_cat_ind3 "Both"

save `datapath'\hcbs_max_analysis_ds_2012.dta, replace


******************************************************************
** First process the max ccw files
******************************************************************
** sort the max ccw files by msis id and state
** 2 steps, separately if have bene id vs not

use `data'\maxcc_2012.dta if !missing(bene_id), clear
sort bene_id
save `data'\maxcc_2012_benesorted.dta, replace

use `data'\maxcc_2012.dta if missing(bene_id), clear
sort msis_id state_cd
save `data'\maxcc_2012_msissorted.dta, replace

******************************************************************
** Next process the mbsf/mbsf-ccw files
******************************************************************
**by bene-id (there is no msis_id here)
**2012

clear
import delimited using `mbsf2012'\pqi_2012.csv
*drop hmo_ind_01-hmo_ind_12 dual_stus_cd_01-dual_stus_cd_12
tab bene_enrollmt_ref_yr _from_mbsf, missing
rename _from_mbsf merge_mbsf
label var merge_mbsf "Link to MBSF, 1=yes"

tab bene_hmo_cvrage_tot_mons, missing
gen ma_ind=(bene_hmo_cvrage_tot_mons>0)
replace ma_ind=. if bene_hmo_cvrage_tot_mons==.
tab bene_hmo_cvrage_tot_mons ma_ind, missing
label var ma_ind "Medicare Advantage indicator, any months, 1=yes"

** need to create this restriction, if alive all 12m, then 
 
** next variable is, if died, are they dual all months they are alive?
gen dod_dateformat=date(bene_death_dt,"DMY")
gen month_died=month(dod_dateformat)
gen year_died=year(dod_dateformat)
tab month_died, missing
tab year_died, missing

capture program drop monthdual
program define monthdual
	args mno mvar

*first make indicator each month if buy in=yes (part a or b or both)
gen buyin`mno'=(inlist(mdcr_entlmt_buyin_ind_`mvar',"A","B","C"))
gen alive`mno'=0
replace alive`mno'=1 if missing(dod_dateformat) //first if no death date, death date after 2012, set to alive=1
replace alive`mno'=1 if (month_died>=`mno' & year_died==2012 & !missing(dod_dateformat) & alive`mno'==0) //now set =1 if died in 2012 but later month

gen buyinalive`mno'=1 if buyin`mno'==1 & alive`mno'==1
replace buyinalive`mno'=0 if buyin`mno'==0 & alive`mno'==1 //if alive and dual then =1, 0 if alive but not dual, missing if dead
end
 
 monthdual 1 01
 monthdual 2 02
 monthdual 3 03
 monthdual 4 04
 monthdual 5 05
 monthdual 6 06
 monthdual 7 07
 monthdual 8 08
 monthdual 9 09
 monthdual 10 10
 monthdual 11 11
 monthdual 12 12

 **if any month variable indicates alive and not dual (=0) then does not meet dual inclusion criteria
 gen mc_dual_mbsf=1 if merge_mbsf==1
	foreach m in 1/12{
	replace mc_dual_mbsf=0 if buyinalive`m'==0 & merge_mbsf==1
 }

 tab mc_dual_mbsf, missing
 tab mc_dual_mbsf year_died, missing

** death during the year as outcome 
gen died_ind=!missing(dod_dateformat) & year_died==2012
tab died_ind, missing
la var died_ind "Died 1=yes"
 
** chronic conditions variable processing 
gen byte mbsf_enrl_crit=inlist(ami,2,3)

gen byte ccw_alz_date_ind=!missing(alzh_demen_ever)
label var ccw_alz_date_ind "MBSF-CCW AD/Dem diagnosis ever, 1=yes"

*variable for having dx within the lookback period
local cc ami alzh alzh_demen atrial_fib cataract chronickidney copd chf diabetes ///
glaucoma hip_fracture ischemicheart depression osteoporosis ra_oa stroke_tia ///
cancer_breast cancer_colorectal cancer_prostate cancer_lung cancer_endometrial ///
 anemia asthma hyperl hyperp hypert hypoth
foreach v in `cc' {
gen byte cc_`v'_ind=(inlist(`v',1,3))
}

drop ami-hypoth_ever alive1-buyinalive12 mdcr_entlmt_buyin_ind_01-mdcr_entlmt_buyin_ind_12
sort bene_id
save `mbsf2012'\mbsf_2012_sorted.dta, replace




******************************************************************
** 2012 data, drop variables and save  
******************************************************************
use `data_max'\ltc_use_max_2012_comb_ltssonly_all.dta if !missing(bene_id), clear 

******************************************************************
*merge in the max-cc flags
******************************************************************
merge 1:1 bene_id using `data'\maxcc_2012_benesorted.dta

gen merge_ccw_max=(_merge==3)
label var merge_ccw_max "MAX CCW file merged, 1=yes"

drop _merge

******************************************************************
*merge the mbsf variables
******************************************************************
merge 1:1 bene_id using `mbsf2012'\mbsf_2012_sorted.dta
drop if _merge==2
gen merge_medicare_check=(_merge==3)
label var merge_medicare_check "Link to Medicare files - merge check, 1=yes"

drop _merge

save `data'\hcbs_bene_2012.dta, replace

*now for those with no bene_id, can merge in max-cc by msis_id and state
use `data_max'\ltc_use_max_2012_comb_ltssonly_all.dta if missing(bene_id), clear 

sort msis_id state_cd
quietly by msis_id state_cd: gen temp_dup = cond(_N==1,0,_n)
tab temp_dup
drop if temp_dup==2

*merge in the max-cc flags
merge 1:1 msis_id state_cd using `data'\maxcc_2012_msissorted.dta
tab _merge beneid_dup_flag, missing
tab _merge mc_dual, missing
drop if _merge==2

gen merge_ccw_max=(_merge==3)
label var merge_ccw_max "MAX CCW file merged, 1=yes"

drop _merge

save `data'\hcbs_msis_2012.dta, replace

******************************************************************
*saves out old version so can import to sas for checks
******************************************************************
**append the two datasets
use `data'\hcbs_bene_2012.dta, clear
append using `data'\hcbs_msis_2012.dta

compress

**ahrq ltss definition
tab ltss_cat3 if year==2005, missing
tab ltss_cat3 if year==2012, missing
encode state_cd, gen(state_num)


**create, relabel ccw variables
tab ccw_alz_date_ind, missing

*this is missing if don't have an entry in the MBSF-CCW file
tab ccw_alz_date_ind ltss_cat3, missing

**combined flag for ad-dem using (1) any date in mbsf-ccw and/or (2) max diagnosis
gen byte ccw_both_alz_dem=0
replace ccw_both_alz_dem=1 if (ccw_alz_date_ind==1 | inlist(alzrdsd_medicaid,1,3))
replace ccw_both_alz_dem=. if merge_ccw_max==0 & merge_mbsf==0
la var ccw_both_alz_dem "AD/Dem Dx, MBSF-CCW and/or MAX-CCW"
tab ccw_both_alz_dem, missing

gen dob_dateformat=date(bene_birth_dt,"DMY")
gen endofyear = date("12/31/2012","MDY") if year==2012
replace endofyear = date("12/31/2005","MDY") if year==2005

gen age_mbsf = floor((endofyear-dob_dateformat)/365.25)
sum age_mbsf
replace age_mbsf=105 if age_mbsf>105 & !missing(age_mbsf)
label var age_mbsf "Age at end of ref year, MBSF DOB"

gen age_max = floor((endofyear-el_dob)/365.25)
sum age_max
replace age_max=105 if age_max>105 & !missing(age_max)
label var age_max "Age at end of ref year, MAX DOB"

gen age = age_mbsf if !missing(age_mbsf)
	replace age = age_max if missing(age_mbsf) & !missing(age_max)

*sex
drop female_ind
gen female_ind=1 if sex_ident_cd==2 & year==2012
*replace female_ind=1 if bene_sex_ident_cd==2 & year==2005
replace female_ind=0 if sex_ident_cd==1 & year==2012
*replace female_ind=0 if bene_sex_ident_cd==1 & year==2005
tab el_sex_cd female_ind, missing
label var female_ind "Female, 1=yes (mbsf)"
tab female_ind, missing

*MAX PS data - sex
tab el_sex_cd, nolabel
gen female_max=1 if el_sex_cd=="F"
	replace female_max=0 if el_sex_cd=="M"
tab female_max, m

*race
drop el_race_ethncy_cd mdcr_race_ethncy_cd race_eth_4cat race_eth_ind1 ///
	race_eth_ind2 race_eth_ind3 race_eth_ind4 race_eth_ind5 bene_race_cd
la def rti_race 0 "Unknown" 1 "White, non-Hispanic" 2 "Black" 3 "Other" 4 "Asian/PI" ///
5"Hispanic" 6 "American Indian/Alaska Native"
la val rti_race_cd rti_race

gen race_5cat=1 if rti_race_cd==1
replace race_5cat=2 if rti_race_cd==2
replace race_5cat=3 if rti_race_cd==5
replace race_5cat=4 if rti_race_cd==4
replace race_5cat=5 if rti_race_cd==3 | rti_race_cd==6

la var race_5cat "Race, categorical, RTI comb other,NA"
la def race_5cat 1 "White, non-Hispanic" 2 "Black" 3 "Hispanic" ///
 4 "Asian/PI" 5 "Other Race" 
la val race_5cat race_5cat
tab rti_race_cd race_5cat, missing

tab race_5cat, gen(race_eth_ind)
la var race_eth_ind1 "White, non-Hispanic"
la var race_eth_ind2 "Black, non-Hispanic"
la var race_eth_ind3 "Hispanic"
la var race_eth_ind4 "Asian/Pacific Islander"
la var race_eth_ind5 "Other Race"

gen race_max=race_5cat

**dual status	
tab mc_dual_mbsf, missing
drop dual_elgbl_mons mc_dual dm_source
*gen mc_dual_mbsf = (merge_mbsf==1)
*label var mc_dual_mbsf "Dual, link to MBSF"

**ma status
tab ma_ind if mc_dual_mbsf==1, missing
tab ma_ind if mc_dual_mbsf==1 & year==2005, missing
tab ma_ind if mc_dual_mbsf==1 & year==2012, missing

**zip code
rename  zip_cd bene_zip_cd
label var bene_zip_cd "ZIP code 9 digits(MBSF)"
label var zip "ZIP code (MAX PS)"

/*
*check difference in dob between MBSF and MAX
tab year if missing(age_max)
gen check=1 if el_dob==date(bene_birth_dt,"DMY")
keep el_dob bene_birth_dt age_max check year bene_age_at_end_ref_yr

keep if missing(check)
mat s1=J(4,1,.)
local r=1
tab year if !missing(el_dob) & !missing(bene_birth_dt)
mat s1[`r',1]=r(N)
mat list s1
tab year if missing(el_dob) & !missing(bene_birth_dt)
local r = `r'+1
mat s1[`r',1]=r(N)
mat list s1
keep if !missing(bene_birth_dt)
tab year if !missing(el_dob) & age_max<65 &bene_age_at_end_ref_yr>64
local r = `r'+1
mat s1[`r',1]=r(N)
mat list s1
tab year if !missing(el_dob) & age_max>64 &bene_age_at_end_ref_yr<65
local r = `r'+1
mat s1[`r',1]=r(N)
mat list s1


local logpath K:\Outputdata\DJ\logs
frmttable using `logpath'/hcbs_age , statmat(s1) sdec(0,2) ///
title("Compare Date of Birth between MAX and MBSF") ///
rtitles("Age in MAX and MBSF, but not same" \ ///
"Age in MBSF, but not in MAX - note 1" \ ///
"MAX: under 65, MBSF: 65 or older" \ ///
"MAX: 65 or older, MBSF: under 65")  ///
ctitles("","N") ///
note("1. Use MBSF?") ///
replace
*/
********************************************************
**generate racexdementia categorical variable
gen ccw_no_alz_dem=(ccw_both_alz_dem==0)
replace ccw_no_alz_dem=. if missing(ccw_both_alz_dem)

gen race_dem_cat=1 if race_eth_ind1==1 & ccw_both_alz_dem==0
replace race_dem_cat=2 if race_eth_ind2==1 & ccw_both_alz_dem==0
replace race_dem_cat=3 if race_eth_ind3==1 & ccw_both_alz_dem==0
replace race_dem_cat=4 if race_eth_ind4==1 & ccw_both_alz_dem==0

replace race_dem_cat=5 if race_eth_ind1==1 & ccw_both_alz_dem==1
replace race_dem_cat=6 if race_eth_ind2==1 & ccw_both_alz_dem==1
replace race_dem_cat=7 if race_eth_ind3==1 & ccw_both_alz_dem==1
replace race_dem_cat=8 if race_eth_ind4==1 & ccw_both_alz_dem==1

tab race_dem_cat, missing

**recode age variable, max at 100
tab age
replace age=100 if age>99 & !missing(age)
gen age65_ind=1 if age>=65 & !missing(age)
	replace age65_ind=0 if age<65 & !missing(age)
tab age65_ind
	
**chronic conditions count variable
gen cc_count_mbsf=0

local cc_excl_ad ami /*alzh alzh_demen*/ atrial_fib cataract chronickidney copd chf diabetes ///
glaucoma hip_fracture ischemicheart depression osteoporosis ra_oa stroke_tia ///
cancer_breast cancer_colorectal cancer_prostate cancer_lung cancer_endometrial ///
 anemia asthma hyperl hyperp hypert hypoth
foreach v in `cc_excl_ad'{
replace cc_count_mbsf=cc_count_mbsf+cc_`v'_ind
}
la var cc_count_mbsf "Count chronic conditions, excl AD/Dem, MBSF"
tab cc_count_mbsf, missing
sum cc_count_mbsf, detail

gen cc_count_ge4=(cc_count_mbsf>3)
la var cc_count_ge4 "4+ Chronic conditions excl AD/Dem, MBSF"

*indicators for ltss categories
tab ltss_cat3 if ltss_cat3!=0, gen(ltss_cat_ind)
la var ltss_cat_ind1 "Institutional Only"
la var ltss_cat_ind2 "HCBS only"
la var ltss_cat_ind3 "Both"

tab ltss_cat3
tab ltss_cat_ind1
*new eligibility category variables
foreach v in elig_cat_ind4 elig_cat_ind5 elig_cat_ind6 {
	replace elig_cat_ind3=1 if `v'==1
	}
drop elig_cat_ind4 elig_cat_ind5 elig_cat_ind6
tab elig_cat elig_cat_ind1, missing
tab elig_cat elig_cat_ind2, missing
tab elig_cat elig_cat_ind3, missing
la var elig_cat_ind3 "Other (child, adult, unknown)"
tab elig_cat
*pqi indicators
** first utilization, pqi's
label var pqi_1 "PQI-1 Diabetes short-term compl. count"
label var pqi_2 "PQI-2 Perforated appendix count"
label var pqi_3 "PQI-3 Diabetes long-term compl. count"
label var pqi_5 "PQI-5 COPD count"
label var pqi_7 "PQI-7 Hypertension count"
label var pqi_8 "PQI-8 Heart failure count"
label var pqi_10 "PQI-10 Dehydration count"
label var pqi_11 "PQI-11 Bacterial pneumonia count"
label var pqi_12 "PQI-12 UTI count"
label var pqi_14 "PQI-14 Uncontrolled diabetes count"
label var pqi_16 "PQI-16 Lower extrem amputation, diabetes count"
label var _has_hosp "Any Hospitalization, 1=yes"
label var _has_pqi "Any PQI, 1=yes"
label var _total_hosp "Count hospitalizations"
label var _total_pqi "Count PQI hospitalizations"
label var mdcr_pmt_amt "Medicare hospitalization expenditures"

tab _has_hosp
** create binary variables from pqi count variables
local pqi 1 2 3 5 7 8 10 11 12 14 16
foreach i in `pqi'{
gen byte pqi_ind_`i'=(pqi_`i'>0)
}

label var pqi_ind_1 "PQI-1 Diabetes short-term compl. 1=yes"
label var pqi_ind_2 "PQI-2 Perforated appendix 1=yes"
label var pqi_ind_3 "PQI-3 Diabetes long-term compl. 1=yes"
label var pqi_ind_5 "PQI-5 COPD 1=yes"
label var pqi_ind_7 "PQI-7 Hypertension 1=yes"
label var pqi_ind_8 "PQI-8 Heart failure 1=yes"
label var pqi_ind_10 "PQI-10 Dehydration 1=yes"
label var pqi_ind_11 "PQI-11 Bacterial pneumonia 1=yes"
label var pqi_ind_12 "PQI-12 UTI 1=yes"
label var pqi_ind_14 "PQI-14 Uncontrolled diabetes 1=yes"
label var pqi_ind_16 "PQI-16 Lower extrem amputation, diabetes 1=yes"
******************************************************************


**create demeaned expenditures variables, zip code for the main analysis sample 
rename tot_mdcd_pymt_amt expend_total
rename tot_mdcd_prem_pymt_amt expend_prem
rename tot_mdcd_ffs_pymt_amt expend_ffs

gen iphosp_total=expend_iphosp + mdcr_pmt_amt
la var iphosp_total "IP Hosp Spending, Medicaid+Medicare"
la var mdcr_pmt_amt "Medicare IP Hosp. spending"

local expendv expend_total expend_prem expend_ffs  ///
expend_iphosp expend_instltc expend_hcbs expend_prof_op expend_rx expend_other ///
mdcr_pmt_amt iphosp_total

foreach v in `expendv'{

*zip
		egen mean`v'=mean(`v'), by(zip)
		gen `v'21_zip=`v'-mean`v'
		drop mean`v'
*no geography adjustment, just dual-year categories
		sum `v' 
		gen `v'_21=`v'-r(mean)

	}

	* suffix legend
	* _21 = 2012, Duals

	

save `data_tk'\hcbs_max_12_iv_sample_v2.dta, replace
******************************************************************
log close



