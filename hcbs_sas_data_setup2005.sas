/**************************************************************************/
/* Create derived variables for LTSS Users from the PS file               */
/* Get information on eligibility, managed care, clinicial groups, etc.   */
/**************************************************************************/


** see line 108, update year when switch between 2005,2012, and 2014 !!!! ;
*for MAX DUA, 2012 ;
/*
libname ps_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\ps';
libname ot_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\ot_gapadded';
libname lt_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\lt_gapadded';
libname ip_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\ip_gapadded';
*/
/*
*for MAX DUA, 2013 ;
libname ps_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\ps\sas';
libname ot_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\ot\sas';
libname lt_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\lt\sas';
libname ip_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\ip\sas';
*/

/*
*for MAX DUA, 2014 ;
libname ps_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\ps\sas';
libname ot_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\ot\sas';
libname lt_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\lt\sas';
libname ip_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\ip\sas';
*/
/*
libname ref '\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\data\hcbs';
libname desc_wk '\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\data\hcbs';
*/



*for TK's HCBS DUA: ;
libname ps_raw 'K:\Data\MAX\2005\ps\sas';
libname ot_raw 'K:\Data\MAX\2005\ot\sas';
libname lt_raw 'K:\Data\MAX\2005\lt\sas';
libname ip_raw 'K:\Data\MAX\2005\ip\sas';

libname ref '\\prfs.cri.uchicago.edu\medicaid-max\Users\gorges\data\reference_to_link';
libname desc_wk 'K:\Outputdata\DJ\2005_hcbs_max';

%macro get_char(st=,year=);

proc delete data=work._all_; run;

*merge in ps file variables to the ltss user dataset;
data ps_full;
set ps_raw.maxdata_&st._ps_&year.(keep=msis_id
bene_id
state_cd
el_age_grp_cd
EL_DOB
EL_DOD
el_sex_cd
el_race_ethncy_cd
el_mdcr_dual_ann
MDCR_RACE_ETHNCY_CD
EL_RSDNC_CNTY_CD_LTST
EL_RSDNC_ZIP_CD_LTST
EL_MAX_ELGBLTY_CD_LTST
EL_ELGBLTY_MO_CNT
MAX_WAIVER_TYPE_:
MAX_WAIVER_ID_:
el_pph_pln_mo_cnt_:
MC_COMBO_MO_:
TOT_MDCD_PYMT_AMT
TOT_MDCD_FFS_PYMT_AMT
TOT_MDCD_PREM_PYMT_AMT
FFS_PYMT_AMT_: );
msis_id=trim(msis_id);
run;

proc sort data=ps_full; by msis_id; run;

proc sort data=desc_wk.ltc_use_max_&year._&st._all; by msis_id; run;

data ltc_add_ps;
merge desc_wk.ltc_use_max_&year._&st._all(IN=In1) ps_full(IN=In2);
by msis_id;
if In1=1 then output ltc_add_ps;
run;

proc delete data=work.ps_full; run;

*proc freq data=ltc_add_ps ; 
*table inst_ltss_ind1 pace_plan_mogt0 hcbs_cltc_waiver hcbs_waiver_cltc: hcbs_1915c_ind 
cltc_14_ffs_3m_ind cltc_12_ind cltc_19_ind hcbs_cltc_nonwaiver_: cltc_exp_gt0_14_3m cltc_exp_gt0_: ltss_ind_: ; 
*run;

/***************************************************************************/
/*              Variables directly from the PS file                        */
/***************************************************************************/
*code eligibility categorical variable;

/*collapse eligibility categories into 4 main codes using the latest elig code variable
(could have done with the monthly variables; could matter for obs that change throughout the year)
0 = aged; 1 = blind,disabled; 2 = child; 3 = adult; 4 = unknown; 5=not eligible */

data ps_elig;
set ltc_add_ps;
if EL_MAX_ELGBLTY_CD_LTST in("11","21","31","41","51") then elig_cat=0 ; /*aged*/
if EL_MAX_ELGBLTY_CD_LTST in("12","22","32","42","52") then elig_cat=1 ; /*disabled*/
if EL_MAX_ELGBLTY_CD_LTST in("14","16","24","34","44","48","54") then elig_cat=2 ; /*child*/
if EL_MAX_ELGBLTY_CD_LTST in("15","17","25","35","45","55","3A") then elig_cat=3 ; /*adult*/
if EL_MAX_ELGBLTY_CD_LTST in("99") then elig_cat=4 ; /*unknown*/
if EL_MAX_ELGBLTY_CD_LTST in("00") then elig_cat=5 ; /*not eligible*/
label elig_cat="Eligibility category";
bene_id_missing=(bene_id="");
format el_dob date9.;
jan1='01jan2005'd;                                             /*note change this to 2012 when run for 2012 files!*/
el_age=(jan1-el_dob)/365;
if el_age<0 then el_age=0;
el_age_years_only=floor((jan1-el_dob)/365);
if el_age_years_only=-1 then el_age_years_only=0;
label el_age="Age, continuous, from Jan. 1 of the claims year";
label el_age_years_only="Age, floor years, from Jan 1 of the claims year";
run;


/*
proc freq data=ps_elig;
	title 'State=' &st. 'Year=' &year. 'Eligibility categories';
	table elig_cat /missprint; run;

proc freq data=ps_elig;
		title 'State=' &st. 'Year=' &year. 'Eligibility codes';
		table EL_MAX_ELGBLTY_CD_LTST /missprint; run;

proc freq data=ps_elig; table EL_ELGBLTY_MO_CNT /missprint; run;

*look at concordance between 2 measures: 0 elgibility months all have elg code 0 or 99;
proc sql;
	create table elgmo0 as
	select * from ps_elig where EL_ELGBLTY_MO_CNT=0;
quit;

proc freq data=elgmo0; title 'elig month count=0'; table EL_MAX_ELGBLTY_CD_LTST /missprint; run;
*/
/***************************************************************************/
/*              Managed LTSS                                               */
/***************************************************************************/
data get_mltss;
set ps_elig;
*look specifically at managed LTSS, note PACE plans identified in ltss code;
mltss_plan_mogt0=(el_pph_pln_mo_cnt_ltcm>0 & el_pph_pln_mo_cnt_ltcm~=.);
mltss_any=(mltss_plan_mogt0=1 | pace_plan_mogt0=1);
label mltss_any="Managed LTSS or PACE plan 1=yes any time in year");


*flag comprehensive managed care plan enrollment;
if el_pph_pln_mo_cnt_cmcp=0 then cmcp_enroll_cat=0;
if el_pph_pln_mo_cnt_cmcp>0 & el_pph_pln_mo_cnt_cmcp<12 then cmcp_enroll_cat=1;
if el_pph_pln_mo_cnt_cmcp=12 then cmcp_enroll_cat=2;
cmcp_enroll_ind=(cmcp_enroll_cat=1 | cmcp_enroll_cat=2);
label cmcp_enroll_cat="Comprehensive managed care plan, categorical"
	cmcp_enroll_ind="Comprensive managed care plan during year, 1=yes";
run;



/*****************************************************************************/
*get clinical categories, uses the ltss ffs utilization + diagnoses from claims + medpar information;
/*****************************************************************************/
*first step - collect diagnosis codes from IP, LT and OT files - limit to ffs records only;
data ip_1;
set ip_raw.maxdata_&st._ip_&year.(keep=msis_id type_clm_cd diag_cd_1-diag_cd_9 );
if type_clm_cd="1" then output ip_1;
msis_id=trim(msis_id);
run;

proc sql;
create table ip_msis_ids
as select * from ip_1
where msis_id in (select msis_id from ltc_add_ps);
quit;

proc delete data=work.ip_1; run;

data ip_dx_long(keep=msis_id dx );
set ip_msis_ids;
array list diag_cd_1-diag_cd_9;
do over list;
	if list~="" then do;
		dx=list;
		output;
		end;
		end;
run;

proc delete data=work.ip_msis_ids; run;

*lt file;
data lt_1;
set lt_raw.maxdata_&st._lt_&year.(keep=msis_id type_clm_cd diag_cd_1-diag_cd_5 );
if type_clm_cd="1" then output lt_1;
msis_id=trim(msis_id);
run;

proc sql;
create table lt_msis_ids
as select * from lt_1
where msis_id in (select msis_id from ltc_add_ps);
quit;

proc delete data=work.lt_1; run;

data lt_dx_long(keep=msis_id dx );
set lt_msis_ids;
array list diag_cd_1-diag_cd_5;
do over list;
	if list~="" then do;
		dx=list;
		output;
		end;
		end;
run;

proc delete data=work.lt_msis_ids; run;

*this has some addditional variables to use in the expenditures section later to avoid calling the full ot dataset more than 1x;
*get ot dx list;
data ot_1;
set ot_raw.maxdata_&st._ot_&year.(keep=msis_id type_clm_cd diag_cd_1 diag_cd_2 max_tos msis_top PLC_OF_SRVC_CD MDCD_PYMT_AMT CLTC_FLAG SRVC_BGN_DT);
if type_clm_cd="1" then output ot_1;
msis_id=trim(msis_id);
run;

proc sql;
create table ot_msis_ids
as select * from ot_1
where msis_id in (select msis_id from ltc_add_ps);
quit;

proc delete data=work.ot_1; run;



data ot_dx_long(keep=msis_id dx );
set ot_msis_ids;
array list diag_cd_1-diag_cd_2;
do over list;
	if list~="" then do;
		dx=list;
		output;
		end;
		end;
run;

*now merge and search through dx codes;
data dx_1;
set ip_dx_long lt_dx_long ot_dx_long;
dx2=trim(left(dx));
if dx2~="" then do;
*initialize variables;
array cond cond_dx_1-cond_dx_5;
do over cond;
	cond=0;
	end;


*IDD conditions;
if (substr(dx2,1,4)='7580' or /*downs syndrome*/
	 substr(dx2,1,3)='330' or /*dd chromosomal abnormalities*/
	 substr(dx2,1,4)='7581' or
	 substr(dx2,1,4)='7582' or
	 substr(dx2,1,5)='75831' or
	 substr(dx2,1,5)='75833' or
	 substr(dx2,1,5)='75839' or
	 substr(dx2,1,4)='7585' or
	 substr(dx2,1,4)='7587' or
	 substr(dx2,1,4)='7598' or
	 substr(dx2,1,4)='7685' or /*brain injury early childhood*/
	 substr(dx2,1,5)='76873' or
	 substr(dx2,1,4)='7747' or
	 substr(dx2,1,4)='7734' or
	 substr(dx2,1,4)='7797' or
	 substr(dx2,1,4)='3432' or /* cerebral palsy*/
	 substr(dx2,1,4)='3433' or
	 substr(dx2,1,4)='3434' or
	 substr(dx2,1,4)='3438' or
	 substr(dx2,1,4)='3439' or
	 substr(dx2,1,3)='345' or /*epilepsy*/
	 substr(dx2,1,3)='741' or /*spina bifida*/
	 substr(dx2,1,5)='76071' or /*fetal alcohol syndrome*/
	 substr(dx2,1,4)='2990' or /*other major cogn*/
	 substr(dx2,1,5)='29910' or
	 substr(dx2,1,5)='29980' or
	 substr(dx2,1,5)='29990' or
	 substr(dx2,1,4)='3141' or
	 substr(dx2,1,3)='318' or
	 substr(dx2,1,3)='319')
	  	and cond_dx_1=0
		then cond_dx_1=1;

*SMI conditions;
if (substr(dx2,1,3)='295' or /*psychoses wo affective disorders*/
	 substr(dx2,1,3)='297' or
	 substr(dx2,1,5)='29600' or /*major affective disorders*/
	 substr(dx2,1,5)='29602' or
	 substr(dx2,1,5)='29603' or
	 substr(dx2,1,5)='29604' or

	 substr(dx2,1,5)='29610' or
	 substr(dx2,1,5)='29612' or
	 substr(dx2,1,5)='29613' or
	 substr(dx2,1,5)='29614' or

	 substr(dx2,1,5)='29620' or
	 substr(dx2,1,5)='29622' or
	 substr(dx2,1,5)='29623' or
	 substr(dx2,1,5)='29624' or

	 substr(dx2,1,5)='29630' or
	 substr(dx2,1,5)='29632' or
	 substr(dx2,1,5)='29633' or
	 substr(dx2,1,5)='29634' or

 	 substr(dx2,1,5)='29640' or
	 substr(dx2,1,5)='29642' or
	 substr(dx2,1,5)='29643' or
	 substr(dx2,1,5)='29644' or

	 substr(dx2,1,5)='29650' or
	 substr(dx2,1,5)='29652' or
	 substr(dx2,1,5)='29653' or
	 substr(dx2,1,5)='29654' or

	 substr(dx2,1,5)='29660' or
	 substr(dx2,1,5)='29662' or
	 substr(dx2,1,5)='29663' or
	 substr(dx2,1,5)='29664' or

	 substr(dx2,1,4)='2967' or
	 substr(dx2,1,4)='2968' or
	 substr(dx2,1,5)='30001' or /*anxiety*/
	 substr(dx2,1,5)='30021' or
	 substr(dx2,1,4)='3003' or

	 substr(dx2,1,5)='29383' or /*other*/
	 substr(dx2,1,4)='2940' or
	 substr(dx2,1,4)='2948' or
	 substr(dx2,1,4)='3101')
	  	and cond_dx_2=0
		then cond_dx_2=1;

*Dementia;
if (substr(dx2,1,4)='2900' or
	 substr(dx2,1,4)='2901' or
	 substr(dx2,1,4)='2902' or
	 substr(dx2,1,4)='2903' or
	 substr(dx2,1,4)='2904' or
	 substr(dx2,1,4)='2911' or
	 substr(dx2,1,4)='2912' or
	 substr(dx2,1,5)='29282')
	  	and cond_dx_3=0
		then cond_dx_3=1;

*Alzheimers;
if (substr(dx2,1,4)='0941' or
	 substr(dx2,1,4)='3310' or
	 substr(dx2,1,4)='3311' or
	 substr(dx2,1,4)='3119' or
	 substr(dx2,1,5)='31182')
	  	and cond_dx_4=0
		then cond_dx_4=1;

*Alzheimers and dementia, dx list from ccw;
if (substr(dx2,1,4)='3310' or 
	substr(dx2,1,5)='33111' or 
	substr(dx2,1,5)='33119' or
	substr(dx2,1,4)='3312' or
	substr(dx2,1,4)='3317' or
	substr(dx2,1,4)='2900' or
	substr(dx2,1,5)='29010' or
	substr(dx2,1,5)='29011' or
	substr(dx2,1,5)='29012' or
	substr(dx2,1,5)='29013' or
	substr(dx2,1,5)='29020' or
	substr(dx2,1,5)='29021' or
	substr(dx2,1,4)='2903' or
	substr(dx2,1,5)='29040' or	
	substr(dx2,1,5)='29041' or
	substr(dx2,1,5)='29042' or
	substr(dx2,1,5)='29043' or
	substr(dx2,1,4)='2940' or
	substr(dx2,1,5)='29410' or
	substr(dx2,1,5)='29411' or
	substr(dx2,1,5)='29420' or
	substr(dx2,1,5)='29421' or
	substr(dx2,1,4)='2948' or
	substr(dx2,1,3)='797') 	  
		and cond_dx_5=0
		then cond_dx_5=1;
end;
run;

proc delete data=work.ip_dx_long; run;
proc delete data=work.lt_dx_long; run;
proc delete data=work.ot_dx_long; run;

*now count by msis_id;
proc sql;
create table dx_count_msisid as select distinct msis_id,
sum(cond_dx_1) as cond_1,
sum(cond_dx_2) as cond_2,
sum(cond_dx_3) as cond_3,
sum(cond_dx_4) as cond_4,
sum(cond_dx_5) as cond_5
from dx_1 group by msis_id;
quit;

data dx_2;
set dx_count_msisid;
array list_cond cond_1-cond_5;
array list_ind cond_ind_1-cond_ind_5;

do over list_cond;
	list_ind=0;
	if list_cond>0 then do;
		list_ind=1;
	end;
end;
run;

proc delete data=work.dx_count_msisid; run;
proc delete data=work.dx_1; run;
*merge in to main dataset;
proc sort data=dx_2; by msis_id; run;

proc sort data=get_mltss; by msis_id; run;

data clin_cat_1;
merge get_mltss(IN=In1) dx_2(IN=In2);
by msis_id;
if In1=1 then output clin_cat_1;
run;

proc delete data=work.get_mltss; run;
proc delete data=work.dx_2; run;

*create clinical subgroup indicators from waiver enrollment, ffs utilization, or dx;
data clin_cat_2;
set clin_cat_1(drop=cond_1 cond_2 cond_3 cond_4 cond_5);
cc_idd_ind=(wvr_1915c_mrdd_ind=1 | exp_tos5_gt0=1 | cond_ind_1=1);
cc_smi_ind=(wvr_1915c_mised_ind=1 | exp_tos2_gt0=1 | exp_tos4_gt0=1  | cond_ind_2=1);
cc_65_ind=(EL_AGE_GRP_CD in (6 7 8));
cc_lt65pd_ind=(cc_idd_ind=0 & cc_smi_ind=0 & cc_65_ind=0);
cc_dementia=(cond_ind_3=1);
cc_alz=(cond_ind_4=1);
cc_dem_alz_comb=(cond_ind_3=1 | cond_ind_4=1);
cc_ccwlist_demalz=(cond_ind_5=1);
label cc_idd_ind="IDD Clinical subgroup"
	cc_smi_ind="SMI Clinical subgroup"
	cc_65_ind="Age 65+ Clinical subgroup"
	cc_lt65pd_ind="Under 65, physical disabilities clin subgroup"
	cc_dementia="Dementia diagnosis"
	cc_alz="Alzheimer's disease diagnosis"
	cc_dem_alz_comb="Dementia or Alzheimer's dx"
	cc_ccwlist_demalz="Dementia or AD, CCW dx list";
drop cond_ind_1-cond_ind_5;
run;

proc delete data=work.clin_cat_1; run;

/***************************************************************************/
/*             Expenditures in categories                                  */
/***************************************************************************/
*open each of the claims files, limit to FFS claims, get total medicaid expenditures
by category for each msis_id, then merge across files to get total expenditures for ffs;


*start with OT file created above, limited vars and to ltss users;
**need to split OT file into hospital vs not hospital claims;
data ot_expend_1;
set ot_msis_ids(keep=msis_id type_clm_cd max_tos msis_top PLC_OF_SRVC_CD MDCD_PYMT_AMT CLTC_FLAG SRVC_BGN_DT);
if type_clm_cd="1" & MDCD_PYMT_AMT>0 then output ot_expend_1;
run;

proc delete data=work.ot_msis_ids; run;

/*
proc freq ; table max_tos ; run;

data checkot;
set ot_expend_1;
if plc_of_srvc_cd~=21 then output checkot;
run;

proc freq ; table max_tos /missprint; run;
*/
*get just the hcbs indicators from the main ltc file;
data ltss_main;
set clin_cat_2(keep=
	msis_id cltc_14_ffs_3m_ind
	hcbs_cltc_nonwaiver_3 cltc_exp_gt0_11 cltc_exp_gt0_15);
	run;

/*	data test1;
	set clin_cat_2;
	run;
	proc freq data=test1; table hcbs_cltc_nonwaiver_3*cltc_19_ind; run;
*/
proc sort data=ltss_main; by msis_id; run;
proc sort data=ot_expend_1; by msis_id; run;

data ot_expend_2;
merge ot_expend_1(IN=In1) ltss_main(IN=In2);
by msis_id;
if In1=1 then output ot_expend_2;
run;

proc delete data=work.ot_expend_1; run;
proc delete data=work.ltss_main; run;

data ot_expend_3;
set ot_expend_2;
 if plc_of_srvc_cd=21 then cat_expend=1; *ip;
 if (cltc_flag in(11,13,15,16,17,18) & cat_expend=.) then cat_expend=2 ; *hcbs state plans;
 if (cltc_flag in(12,19) & plc_of_srvc_cd=12 & cat_expend=.) then cat_expend=2 ; *hcbs state plans - home pvt duty nursing and hospice;
 if (cltc_flag=14 & cltc_14_ffs_3m_ind=1 & cat_expend=.) then cat_expend=2 ; *hcbs state plans - 3m consec hh;
 if (cltc_flag in(30,31,32,33,34,35,36,37,38,39,40) & cat_expend=.) then cat_expend=2 ; *hcbs waivers;
 if (max_tos in(8,9,10,11,12,34,36,37) & cat_expend=.) then cat_expend=3 ; *prof/op hosp;
 if ( cat_expend=.) then cat_expend=4 ; *other;
 *new categorical variable for sub-set of hcbs spending to compare with form 64 expenditures at the state level;
 if (cltc_flag in(30,31,32,33,34,35,36,37,38,39,40) & cat_expend^=1) then expend_waivers=1; *1915c waivers;
 if (cltc_flag in(11) & cat_expend^=1) then expend_pc_sp=1; *state plan personal care;
 if (cltc_flag=14 & cltc_14_ffs_3m_ind=1 & cat_expend^=1) then expend_hh_sp=1; *state plan home health;
 *if (cltc_flag=00 & (msis_top=6|msis_top=7)) then expend_other_waivers=1; *Other waivers;
 if (cltc_flag in(18, 38) & cat_expend^=1 &plc_of_srvc_cd in(23,41,42)) then amb=1;
 
 *if ((msis_top=6|msis_top=7) & expend_waivers==. & expend_pc_sp==. & expend_hh_sp==.) then expend_other_waivers2=1; *Other waivers;
  if plc_of_srvc_cd=21 then svc_expend=1; *ip;
 if (cltc_flag in(30) & svc_expend=.) then wvr30_expend=1 ; *hcbs waivers;
 if (cltc_flag in(31) & svc_expend=.) then wvr31_expend=1 ; *hcbs waivers;
 if (cltc_flag in(32) & svc_expend=.) then wvr32_expend=1 ; *hcbs waivers;
 if (cltc_flag in(33) & svc_expend=.) then wvr33_expend=1 ; *hcbs waivers;
 if (cltc_flag in(34) & svc_expend=.) then wvr34_expend=1 ; *hcbs waivers;
 if (cltc_flag in(35) & svc_expend=.) then wvr35_expend=1 ; *hcbs waivers;
 if (cltc_flag in(36) & svc_expend=.) then wvr36_expend=1 ; *hcbs waivers;
 if (cltc_flag in(37) & svc_expend=.) then wvr37_expend=1 ; *hcbs waivers;
 if (cltc_flag in(38) & svc_expend=.) then wvr38_expend=1 ; *hcbs waivers;
 if (cltc_flag in(39) & svc_expend=.) then wvr39_expend=1 ; *hcbs waivers;
 if (cltc_flag in(40) & svc_expend=.) then wvr40_expend=1 ; *hcbs waivers;

 if (cltc_flag in(11) & svc_expend=.) then state11_expend=1 ; *hcbs state plan;
 if (cltc_flag in(12) & plc_of_srvc_cd=12 & svc_expend=.) then state12_expend=1 ; *hcbs state plan;
 if (cltc_flag in(13) & svc_expend=.) then state13_expend=1 ; *hcbs state plan;
 if (cltc_flag in(14) & cltc_14_ffs_3m_ind=1 & svc_expend=.) then state14_expend=1 ; *hcbs state plan;
 if (cltc_flag in(14) & svc_expend=.) then state14_wo_expend=1 ; *hcbs state plan;
 if (cltc_flag in(15) & svc_expend=.) then state15_expend=1 ; *hcbs state plan;
 if (cltc_flag in(16) & svc_expend=.) then state16_expend=1 ; *hcbs state plan;
 if (cltc_flag in(17) & svc_expend=.) then state17_expend=1 ; *hcbs state plan;
 if (cltc_flag in(18) & svc_expend=.) then state18_expend=1 ; *hcbs state plan;
 if (cltc_flag in(19) & plc_of_srvc_cd=12 & svc_expend=.) then state19_expend=1 ; *hcbs state plan;
run;


data ot_expend_3_sub;
set ot_expend_2;
 if plc_of_srvc_cd=21 then cat_expend=1; *ip;
 if (cltc_flag in(11,13,15,16,17,18) & cat_expend=.) then hcbs_flag=1 ; *hcbs state plans;
 if (cltc_flag in(12,19) & plc_of_srvc_cd=12 & cat_expend=.) then hcbs_flag=1 ; *hcbs state plans - home pvt duty nursing and hospice;
 if (cltc_flag=14 & cltc_14_ffs_3m_ind=1 & cat_expend=.) then hcbs_flag=1 ; *hcbs state plans - 3m consec hh;
 if (cltc_flag in(30,31,32,33,34,35,36,37,38,39,40) & cat_expend=.) then hcbs_flag=1 ; *hcbs waivers;
run;

data ot_expend_3_sub;
   set ot_expend_3_sub;
   if hcbs_flag=. THEN DELETE;
run;

proc sql;
create table ot_hcbs_dt1 as
select msis_id, min(SRVC_BGN_DT) as hcbs_svc_start format=date9.
from ot_expend_3_sub
group by msis_id;
quit;

proc sql;
create table ot_hcbs_dt2 as
select msis_id, max(SRVC_BGN_DT) as hcbs_svc_last format=date9.
from ot_expend_3_sub
group by msis_id;
quit;

proc delete data=work.ot_expend_2; run;
proc delete data=work.ot_expend_3_sub; run;

data desc_wk.ot_expend_4;
set ot_expend_3(keep=msis_id cat_expend MDCD_PYMT_AMT expend_waivers expend_pc_sp expend_hh_sp wvr30_expend wvr31_expend wvr32_expend wvr33_expend
wvr34_expend wvr35_expend wvr36_expend wvr37_expend wvr38_expend wvr39_expend wvr40_expend 
state11_expend state12_expend state13_expend state14_expend state15_expend state16_expend state17_expend state18_expend state19_expend state14_wo_expend  /*expend_other_waivers expend_other_waivers2*/ CLTC_FLAG);
array newvars expend1 expend2 expend3 expend4 expend5 ;
do i=1 to 5;
	if cat_expend=i then newvars[i]=mdcd_pymt_amt;	
	end;
if expend_waivers=1 then expend6=mdcd_pymt_amt;
if expend_pc_sp=1 then expend7=mdcd_pymt_amt;
if expend_hh_sp=1 then expend8=mdcd_pymt_amt;
if wvr30_expend=1 then expend30=mdcd_pymt_amt;
if wvr31_expend=1 then expend31=mdcd_pymt_amt;
if wvr32_expend=1 then expend32=mdcd_pymt_amt;
if wvr33_expend=1 then expend33=mdcd_pymt_amt;
if wvr34_expend=1 then expend34=mdcd_pymt_amt;
if wvr35_expend=1 then expend35=mdcd_pymt_amt;
if wvr36_expend=1 then expend36=mdcd_pymt_amt;
if wvr37_expend=1 then expend37=mdcd_pymt_amt;
if wvr38_expend=1 then expend38=mdcd_pymt_amt;
if wvr39_expend=1 then expend39=mdcd_pymt_amt;
if wvr40_expend=1 then expend40=mdcd_pymt_amt;
if amb=1 then expendamb=mdcd_pymt_amt;
if state11_expend=1 then expend11=mdcd_pymt_amt;
if state12_expend=1 then expend12=mdcd_pymt_amt;
if state13_expend=1 then expend13=mdcd_pymt_amt;
if state14_expend=1 then expend14=mdcd_pymt_amt;
if state15_expend=1 then expend15=mdcd_pymt_amt;
if state16_expend=1 then expend16=mdcd_pymt_amt;
if state17_expend=1 then expend17=mdcd_pymt_amt;
if state18_expend=1 then expend18=mdcd_pymt_amt;
if state19_expend=1 then expend19=mdcd_pymt_amt;
if state14_wo_expend=1 then expend14_wo=mdcd_pymt_amt;


*if expend_other_waivers=1 then expend9=mdcd_pymt_amt;
*if expend_other_waivers2=1 then expend10=mdcd_pymt_amt;
run;


proc delete data=work.ot_expend_3; run;
proc delete data=work.ot_expend_3_sub; run;

proc sql;
create table ot_expend_5 as select distinct msis_id,
	sum(expend1) as expend_iphosp,
	sum(expend2) as expend_hcbs,
	sum(expend3) as expend_prof_op,
	sum(expend4) as expend_other,
	sum(expend5) as expend_instltc,
	sum(expend6) as expendhcbs_waivers,
	sum(expend7) as expendhcbs_pc_sp,
	sum(expend8) as expendhcbs_hh_sp,
	sum(expend30) as expend_wvr30,
	sum(expend31) as expend_wvr31,
	sum(expend32) as expend_wvr32,
	sum(expend33) as expend_wvr33,
	sum(expend34) as expend_wvr34,
	sum(expend35) as expend_wvr35,
	sum(expend36) as expend_wvr36,
	sum(expend37) as expend_wvr37,
	sum(expend38) as expend_wvr38,
	sum(expend39) as expend_wvr39,
	sum(expend40) as expend_wvr40,
	sum(expendamb) as expend_amb,
	sum(expend11) as expend_state11,
	sum(expend12) as expend_state12,
	sum(expend13) as expend_state13,
	sum(expend14) as expend_state14,
	sum(expend15) as expend_state15,
	sum(expend16) as expend_state16,
	sum(expend17) as expend_state17,
	sum(expend18) as expend_state18,
	sum(expend19) as expend_state19,
	sum(expend14_wo) as expend_state14_wo
/*sum(expend9) as expendhcbs_other_waivers,
sum(expend10) as expendhcbs_other_waivers2,*/
from desc_wk.ot_expend_4 group by msis_id;
quit;

proc delete data=desc_wk.ot_expend_4; run;



*********************************************************;
**now IP;
**everything from IP claims gets attributed to hospitalization category;
data ip_expend_1;
set ip_raw.maxdata_&st._ip_&year.(keep=msis_id type_clm_cd max_tos msis_top MDCD_PYMT_AMT );
if type_clm_cd="1" then output ip_expend_1;
msis_id=trim(msis_id);
run;

proc sql;
create table ip_expend_2
as select * from ip_expend_1
where msis_id in (select msis_id from ltc_add_ps);
quit;

*all attributed to IP;
proc sql;
create table ip_expend_3 as select distinct msis_id,
	sum(mdcd_pymt_amt) as expend_iphosp
from ip_expend_2 group by msis_id;
quit;

proc delete data=work.ip_expend_1; run;
proc delete data=work.ip_expend_2; run;
*****************************************************************;
**now ltc file, all attributed to inst ltc;
data lt_expend_1;
set lt_raw.maxdata_&st._lt_&year.(keep=msis_id type_clm_cd max_tos msis_top MDCD_PYMT_AMT SRVC_BGN_DT);
if type_clm_cd="1" then output lt_expend_1;
msis_id=trim(msis_id);
run;

proc sql;
create table lt_expend_2
as select * from lt_expend_1
where msis_id in (select msis_id from ltc_add_ps);
quit;


*attribute all to inst ltc;
proc sql;
create table lt_expend_3 as select distinct msis_id,
	sum(mdcd_pymt_amt) as expend_instltc
from lt_expend_2 group by msis_id;
quit;

proc sql;
create table lt_inst_dt1 as
select msis_id, min(SRVC_BGN_DT) as inst_svc_start format=date9.
from lt_expend_2
group by msis_id;
quit;
proc sql;
create table lt_inst_dt2 as
select msis_id, max(SRVC_BGN_DT) as inst_svc_last format=date9.
from lt_expend_2
group by msis_id;
quit;



proc delete data=work.lt_expend_1; run;
proc delete data=work.lt_expend_2; run;
proc delete data=work.ltc_add_ps; run;
*****************************************************************;
**now append all 3 file types into single ds;
data expend_comb_1;
set ot_expend_5 ip_expend_3 lt_expend_3 ;
run;

proc delete data=work.ot_expend_5; run;
proc delete data=work.ip_expend_3; run;
proc delete data=work.lt_expend_3; run;

**sum by category of spending;
proc sql;
create table expend_comb_2 as select distinct msis_id,
	sum(expend_iphosp) as expend_iphosp,
	sum(expend_hcbs) as expend_hcbs,
	sum(expend_prof_op) as expend_prof_op,
	sum(expend_other) as expend_other,
	sum(expend_instltc) as expend_instltc,
	sum(expendhcbs_waivers) as expendhcbs_waivers,
	sum(expendhcbs_pc_sp) as expendhcbs_pc_sp,
	sum(expendhcbs_hh_sp) as expendhcbs_hh_sp, /*,
	sum(expendhcbs_other_waivers) as expendhcbs_other_waivers,
	sum(expendhcbs_other_waivers2) as expendhcbs_other_waivers2*/
	sum(expend_wvr30) as expend_wvr30,
	sum(expend_wvr31) as expend_wvr31,
	sum(expend_wvr32) as expend_wvr32,
	sum(expend_wvr33) as expend_wvr33,
	sum(expend_wvr34) as expend_wvr34,
	sum(expend_wvr35) as expend_wvr35,
	sum(expend_wvr36) as expend_wvr36,
	sum(expend_wvr37) as expend_wvr37,
	sum(expend_wvr38) as expend_wvr38,
	sum(expend_wvr39) as expend_wvr39,
	sum(expend_wvr40) as expend_wvr40,
	sum(expend_amb) as expend_amb,
	sum(expend_state11) as expend_state11,
	sum(expend_state12) as expend_state12,
	sum(expend_state13) as expend_state13,
	sum(expend_state14) as expend_state14,
	sum(expend_state15) as expend_state15,
	sum(expend_state16) as expend_state16,
	sum(expend_state17) as expend_state17,
	sum(expend_state18) as expend_state18,
	sum(expend_state19) as expend_state19,
	sum(expend_state14_wo) as expend_state14_wo
	from expend_comb_1 group by msis_id;
quit;



proc delete data=work.expend_comb_1; run;
*merge in to main ps dataset to get totals;
proc sort data=clin_cat_2; by msis_id;
run;

proc sort data=expend_comb_2; by msis_id;
run;

data expend_1;
merge clin_cat_2 expend_comb_2 lt_inst_dt1 lt_inst_dt2 ot_hcbs_dt1 ot_hcbs_dt2; by msis_id;
if expend_iphosp=. then expend_iphosp=0;
if expend_hcbs=. then expend_hcbs=0;
if expend_prof_op=. then expend_prof_op=0;
if expend_other=. then expend_other=0;
if expend_instltc=. then expend_instltc=0;
if expendhcbs_waivers=. then expendhcbs_waivers=0;
if expendhcbs_pc_sp=. then expendhcbs_pc_sp=0;
if expendhcbs_hh_sp=. then expendhcbs_hh_sp=0;
if expend_wvr30=. then expend_vwr30=0;
if expend_wvr31=. then expend_vwr31=0;
if expend_wvr32=. then expend_vwr32=0;
if expend_wvr33=. then expend_vwr33=0;
if expend_wvr34=. then expend_vwr34=0;
if expend_wvr35=. then expend_vwr35=0;
if expend_wvr36=. then expend_vwr36=0;
if expend_wvr37=. then expend_vwr37=0;
if expend_wvr38=. then expend_vwr38=0;
if expend_wvr39=. then expend_vwr39=0;
if expend_wvr40=. then expend_vwr40=0;
if expend_amb=. then expend_amb=0;
if expend_state11=. then expend_vwr11=0;
if expend_state12=. then expend_vwr12=0;
if expend_state13=. then expend_vwr13=0;
if expend_state14=. then expend_vwr14=0;
if expend_state15=. then expend_vwr15=0;
if expend_state16=. then expend_vwr16=0;
if expend_state17=. then expend_vwr17=0;
if expend_state18=. then expend_vwr18=0;
if expend_state19=. then expend_vwr19=0;
if expend_state14_wo=. then expend_vwr14_wo=0;
/*if expendhcbs_other_waivers=. then expendhcbs_other_waivers=0;
if expendhcbs_other_waivers2=. then expendhcbs_other_waivers2=0;*/
expend_rx=ffs_pymt_amt_16;
total_ffs_expend=expend_iphosp+expend_instltc+expend_hcbs+expend_prof_op+expend_rx+expend_other;
diff = TOT_MDCD_FFS_PYMT_AMT-total_ffs_expend;
expend_other = expend_other + diff;
total_ffs_expend2=expend_iphosp+expend_instltc+expend_hcbs+expend_prof_op+expend_rx+expend_other;
diff2 = TOT_MDCD_FFS_PYMT_AMT-total_ffs_expend2;
run;

proc delete data=work.clin_cat_2; run;
proc delete data=work.expend_comb_2; run;



data expend_2;
set expend_1;
drop FFS_PYMT_AMT_: total_ffs_expend diff diff2;
label expend_iphosp="FFS Hospitalization expenditures";
label expend_instltc="FFS Inst LTSS expenditures";
label expend_hcbs="FFS HCBS expenditures";
label expend_prof_op="FFS Professional and outpatient expenditures";
label expend_rx="FFS Rx expenditures";
label expend_other="FFS Other services,unknown expenditures";
label expendhcbs_waivers="FFS Waiver Services expenditures";
label expendhcbs_pc_sp="FFS State Plan Personal Care expenditures";
label expendhcbs_hh_sp="FFS State Plan Home Health expenditures";
/*label expendhcbs_other_waivers="FFS Other Waiver Serivces expenditures";
label expendhcbs_other_waivers2="FFS Other Waiver Serivces expenditures2";*/
run;

/*************************************************************************/
/** Save this dataset for next steps                                    **/
/*************************************************************************/
data desc_wk.ltc_use_max_&year._&st._all_1;
set expend_2;
run;

%put proc export
data=desc_wk.ltc_use_max_&year._&st._all_1
outfile="K:\Outputdata\DJ\2005_hcbs_max\ltc_use_max_&year._&st._all_2.dta" replace;
run;

proc export
data=desc_wk.ltc_use_max_&year._&st._all_1
outfile="K:\Outputdata\DJ\2005_hcbs_max\ltc_use_max_&year._&st._all_2.dta" replace;
run;


%mend;

/*data instonly;
set expend_2;
if inst_ltss_ind1=1 & hcbs_1915c_ind=0 & hcbs_cltc_nonwaiver_3=0 & pace_plan_mogt0=0 then output instonly;
run;

proc means; variable total_ffs_expend expend_hcbs; run;

data check1;
set expend_2;
run;

proc freq; table hcbs_cltc_nonwaiver_3*cltc_exp_gt0_11; run;*/

*loop through state by state ;

*2014; /*
%get_char(st=ca,year=2014);
%get_char(st=ga,year=2014);
%get_char(st=ia,year=2014);
%get_char(st=id,year=2014);
%get_char(st=la,year=2014);
%get_char(st=mi,year=2014);
%get_char(st=mn,year=2014);
%get_char(st=mo,year=2014);
%get_char(st=ms,year=2014);
%get_char(st=nj,year=2014);

%get_char(st=pa,year=2014);
%get_char(st=sd,year=2014);
%get_char(st=tn,year=2014);
%get_char(st=ut,year=2014);
%get_char(st=vt,year=2014);
%get_char(st=wv,year=2014);
%get_char(st=wy,year=2014); 
*/
*2013; /*
%get_char(st=ca,year=2013);
%get_char(st=ga,year=2013);
%get_char(st=ia,year=2013);
%get_char(st=id,year=2013);
%get_char(st=la,year=2013);
%get_char(st=mi,year=2013);
%get_char(st=mn,year=2013);
%get_char(st=mo,year=2013);
%get_char(st=ms,year=2013);
%get_char(st=nj,year=2013);

%get_char(st=pa,year=2013);
%get_char(st=sd,year=2013);
%get_char(st=tn,year=2013);
%get_char(st=ut,year=2013);
%get_char(st=vt,year=2013);
%get_char(st=wv,year=2013);
%get_char(st=wy,year=2013);
*/
 *2012;
/* 
%get_char(st=ak,year=2012);
%get_char(st=al,year=2012);
%get_char(st=ar,year=2012);
%get_char(st=az,year=2012);
%get_char(st=ca,year=2012);
%get_char(st=co,year=2012);
%get_char(st=ct,year=2012);
%get_char(st=dc,year=2012);
%get_char(st=de,year=2012);
%get_char(st=fl,year=2012);

%get_char(st=ga,year=2012);
%get_char(st=hi,year=2012);
%get_char(st=ia,year=2012);
%get_char(st=id,year=2012);
%get_char(st=il,year=2012);
%get_char(st=in,year=2012);
%get_char(st=ks,year=2012);
%get_char(st=ky,year=2012);
%get_char(st=la,year=2012);
%get_char(st=ma,year=2012);

%get_char(st=md,year=2012);
%get_char(st=me,year=2012);
%get_char(st=mi,year=2012);
%get_char(st=mn,year=2012);
%get_char(st=mo,year=2012);
%get_char(st=ms,year=2012);
%get_char(st=mt,year=2012); 
%get_char(st=nc,year=2012);
%get_char(st=nd,year=2012);
%get_char(st=ne,year=2012);

%get_char(st=nh,year=2012);
%get_char(st=nj,year=2012);
%get_char(st=nm,year=2012);
%get_char(st=nv,year=2012);
%get_char(st=ny,year=2012);
%get_char(st=oh,year=2012);
%get_char(st=ok,year=2012);
%get_char(st=or,year=2012);
%get_char(st=pa,year=2012);
%get_char(st=ri,year=2012);

%get_char(st=sc,year=2012);
%get_char(st=sd,year=2012);
%get_char(st=tn,year=2012);
%get_char(st=tx,year=2012);
%get_char(st=ut,year=2012);
%get_char(st=va,year=2012);
%get_char(st=vt,year=2012);
%get_char(st=va,year=2012);
%get_char(st=wa,year=2012);
%get_char(st=wi,year=2012);
%get_char(st=wv,year=2012);

%get_char(st=wy,year=2012);
*/



%get_char(st=ak,year=2005);
%get_char(st=al,year=2005);
%get_char(st=ar,year=2005);
%get_char(st=az,year=2005);
%get_char(st=ca,year=2005);
%get_char(st=co,year=2005);
%get_char(st=ct,year=2005);
%get_char(st=dc,year=2005);
%get_char(st=de,year=2005);
%get_char(st=fl,year=2005);

%get_char(st=ga,year=2005);
%get_char(st=hi,year=2005);
%get_char(st=ia,year=2005);
%get_char(st=id,year=2005);
%get_char(st=il,year=2005);
%get_char(st=in,year=2005);
%get_char(st=ks,year=2005);
%get_char(st=ky,year=2005);
%get_char(st=la,year=2005);
%get_char(st=ma,year=2005);

%get_char(st=md,year=2005);
%get_char(st=me,year=2005);
%get_char(st=mi,year=2005);
%get_char(st=mn,year=2005);
%get_char(st=mo,year=2005);
%get_char(st=ms,year=2005);
%get_char(st=mt,year=2005); 
%get_char(st=nc,year=2005);
%get_char(st=nd,year=2005);
%get_char(st=ne,year=2005);

%get_char(st=nh,year=2005);
%get_char(st=nj,year=2005);
%get_char(st=nm,year=2005);
%get_char(st=nv,year=2005);
%get_char(st=ny,year=2005);
%get_char(st=oh,year=2005);
%get_char(st=ok,year=2005);
%get_char(st=or,year=2005);
%get_char(st=pa,year=2005);
%get_char(st=ri,year=2005);

%get_char(st=sc,year=2005);
%get_char(st=sd,year=2005);
%get_char(st=tn,year=2005);
%get_char(st=tx,year=2005);
%get_char(st=ut,year=2005);
%get_char(st=va,year=2005);
%get_char(st=vt,year=2005);
%get_char(st=va,year=2005);
%get_char(st=wa,year=2005);
%get_char(st=wi,year=2005);
%get_char(st=wv,year=2005);

%get_char(st=wy,year=2005);



/*merge county level variables from other sources
HCBS project, uses datasets created in code 2012_hcbs_descr_ps.sas, ltss_user_chars.sas program files
exports state datasets to Stata 

County level RUCC urban/rural code 2010
Zip code - HRR crosswalk 2012
County FIPS to HSA crosswalk (NCI modified version of health service areas)
HRR level average nursing home compare ratings for 2012

**note** at end need to change file path when switch between 2005 and 2012 years*/

libname ref '\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\data\reference_to_link' ;
libname desc_wk 'K:\Outputdata\DJ\2005_hcbs_max' ;
******************************************************************;
** preprocessing the reference data files                         ;
******************************************************************;

*first get list of state usps codes and fips codes;
*proc import datafile='\\prfs.cri.uchicago.edu\medicaid-max\Users\gorges\data\reference_to_link\state_fips.xlsx'
	out=ref.state_fips replace;
*	run;

data state_fips(keep=stfips2 state_cd);
set ref.state_fips;
length stfips2 $ 2;
stfips2=put(FIPS_State_Numeric_Code,z2.);
length state_cd $ 2;
state_cd=Official_USPS_Code;
run;

proc sort data=state_fips; by state_cd; run;

*list of county level urban/rural codes;
*proc import datafile='\\prfs.cri.uchicago.edu\medicaid-max\Users\gorges\data\reference_to_link\ruralurbancodes2013.xls '
	out=ref.rural_cnty replace;
*	run;

data rural_cnty;
set ref.rural_cnty(keep=fips rucc_2013);
length fips2 $ 5;
fips2=fips;
drop fips;
rename fips2=fips;
length stfips $2;
stfips=substr(fips,1,2);
length cntyfips $3;
cntyfips=substr(fips,3,3);
run;

proc sort data=rural_cnty; by fips; run;

/*proc freq data=rural_cnty; tables fips rucc_2013 /missprint; run;*/

*list of HSA by county fips code;
*proc import datafile='\\prfs.cri.uchicago.edu\medicaid-max\Users\gorges\data\reference_to_link\HealthServiceAreas.xlsx '
	out=ref.hsa_cnty replace;
*	run;

data hsa_cnty;
set ref.hsa_cnty;
rename HSA____NCI_Modified_=hsa;
length fips2 $ 5;
fips2=FIPS;
drop FIPS;
rename fips2=fips;
drop Health_Service_Area__NCI_Modifie;
drop State_county;
run;

proc sort data=hsa_cnty; by fips; run;

*merge the two county level datasets rucc and hsa;
data check_cnty_valid check_cnty_rucc_only;
	merge rural_cnty(in=a) hsa_cnty(in=b);
	by fips;
	if (a) then output check_cnty_valid;
	if (a and not b) then output check_cnty_rucc_only;
run;

*just rename rural list to include the dataset with additional hsa fields;
data rural_cnty;
set check_cnty_valid;
run;

*proc import datafile='\\prfs.cri.uchicago.edu\medicaid-max\Users\gorges\data\reference_to_link\zip_hrr_nhc_ratings_2012.csv'
	out=ref.zip_hrr_nhc_ratings_2012 replace;
*	run;
/*
*some zips don't have hrr link, not sure what to do about them, for now just drop them;
data test;
set ref.zip_hrr_nhc_ratings_2012;
if hrrnum=. then output test;
run;
*/

data nhc1;
set ref.zip_hrr_nhc_ratings_2012;
if hrrnum=. then delete;
length zip2 $ 5;
zip2=put(zip,z5.);
drop zip;
rename zip2=zip;
run;

proc sort data=nhc1; by zip; run;

*list of zip codes to states for checking if ps file zip matches state that submitted the claim;
*proc import datafile='\\prfs.cri.uchicago.edu\medicaid-max\Users\gorges\data\reference_to_link\zcta_county_rel_10.xlsx'
	out=ref.zip_county replace;
*	run;

data zip_state;
set ref.zip_county(keep=zcta5 state);
length zip2 $ 5;
zip2=put(zcta5,z5.);
length state2 $ 2;
state2=put(state,z2.);
drop zcta5 state;
rename zip2=zip;
rename state2=stfips2_by_zip;
run;

proc sort data=zip_state; by zip stfips2_by_zip; run;


data zip_state1;
set zip_state;
by zip stfips2_by_zip;
if first.zip and first.stfips2_by_zip;
run;

data zip_state2;
set zip_state1;
by zip ;
if first.zip ;
run;

*same number of obs so zip don't cross state lines;

proc sort data=zip_state2; by zip; run;

******************************************************************;
** Macro to loop through states and bring in reference data       ;
******************************************************************;

%macro addcnty(st=,year=);

data ltc1;
set desc_wk.ltc_use_max_&year._&st._all_1;
zipfirst4=substr(EL_RSDNC_ZIP_CD_LTST,1,4);
length ziplast5 $ 5; 
ziplast5=put(EL_RSDNC_ZIP_CD_LTST,z5.);
rename ziplast5=zip;
run;

proc freq; tables zipfirst4 state_cd; run;

data ltc2;
merge ltc1(in=In1) state_fips(in=In2);
by state_cd;
if In1=1;
run;



*check if county code is valid for the state;
proc sql; 
create table valid_counties as select fips, stfips, cntyfips from
rural_cnty where stfips in (select stfips2 from ltc2);
quit;

proc sort data=valid_counties; by cntyfips; run;

data check_cnty;
set ltc2;
cntyfips=EL_RSDNC_CNTY_CD_LTST;
run;

proc sort data=check_cnty; by cntyfips; run;

data check_cnty_valid check_cnty_not;
	merge check_cnty(in=a) valid_counties(in=b);
	by cntyfips;
	if (a and b) then output check_cnty_valid;
	else if (a and not b) then output check_cnty_not;
run;

/*proc freq data=check_cnty_valid; table msisid_missing; run;
proc freq data=check_cnty_not; table msisid_missing; run;*/

/*proc freq data=check_cnty_valid; tables cntyfips; run;
proc freq data=check_cnty_not; tables cntyfips; run;
proc freq data=check_cnty; tables cntyfips /missprint; run;*/

data invalid_cnty_flag;
set check_cnty_not;
cnty_missing_ind=1;
run;

data invalid_cnty_flag2;
set check_cnty_valid;
cnty_missing_ind=0;
run;

data ltc2a;
set invalid_cnty_flag invalid_cnty_flag2;
run;

proc freq data=ltc2a; tables cnty_missing_ind; run;

*only assign full county code if the county is valid;
data ltc3;
set ltc2a(drop=zipfirst4);
length fips $ 5;
if cnty_missing_ind=0 then fips=trim(cat(stfips2,EL_RSDNC_CNTY_CD_LTST));
run;

/*proc freq; table EL_RSDNC_CNTY_CD_LTST*cnty_missing_ind fips*cnty_missing_ind; run;*/

*now merge in county urban rural code by fips;
*note some will remain blank rucc code if fips code is not valid, ex AK 3 county codes that dont match actual fips codes;
proc sort data=ltc3; by fips; run;

data ltc4;
merge ltc3(in=In1) rural_cnty(in=In2);
by fips;
if In1=1;
run;

/*proc freq data=ltc4; table rucc_2013*cnty_missing_ind /missprint; run; */

*merge in the hrr level nhc data by zip;
proc sort data=ltc4; by zip;
run;

data ltc5;
merge ltc4(in=In1) nhc1(in=In2);
by zip;
if In1=1;
run;

/*proc freq; tables msisid_missing; run;*/
/*proc means; var hrr_overall_rating; run;*/

proc sort data=ltc5; by zip; run;

*merge in state code to create flag for zip code not in the same state as state_cd indicates;
data ltc6;
merge ltc5(in=In1) zip_state2(in=In2);
by zip;
if In1=1;
run;

*save the datasets;
data desc_wk.ltc_use_max_&year._&st._all_2;
set ltc6;
zip_not_in_state_flag=(stfips2 ~= stfips2_by_zip);
run;

/*proc freq; tables zip_not_in_state_flag*stfips2_by_zip zip_not_in_state_flag*cnty_missing_ind; run;*/
 
*export to stata;

* filepaths for 2012 data;
%put proc export
data=desc_wk.ltc_use_max_&year._&st._all_2
outfile="K:\Outputdata\DJ\2005_hcbs_max\ltc_use_max_&year._&st._all_2.dta" replace;
run;

proc export
data=desc_wk.ltc_use_max_&year._&st._all_2
outfile="K:\Outputdata\DJ\2005_hcbs_max\ltc_use_max_&year._&st._all_2.dta" replace;
run;

/*
 *filepaths for 2005 data ;
%put proc export
data=desc_wk.ltc_use_max_&year._&st._all_2
outfile="Y:\Outputdata\RG\2005_hcbs_max\ltc_use_max_&year._&st._all_2.dta" replace;
run;

proc export
data=desc_wk.ltc_use_max_&year._&st._all_2
outfile="Y:\Outputdata\RG\2005_hcbs_max\ltc_use_max_&year._&st._all_2.dta" replace;
run;
*/

%mend;
/*
*2014;
%addcnty(st=ca,year=2014);
%addcnty(st=ga,year=2014);
%addcnty(st=ia,year=2014);
%addcnty(st=id,year=2014);
%addcnty(st=la,year=2014);
%addcnty(st=mi,year=2014);
%addcnty(st=mn,year=2014);
%addcnty(st=mo,year=2014);
%addcnty(st=ms,year=2014);
%addcnty(st=nj,year=2014);

%addcnty(st=pa,year=2014);
%addcnty(st=sd,year=2014);
%addcnty(st=tn,year=2014);
%addcnty(st=ut,year=2014);
%addcnty(st=vt,year=2014);
%addcnty(st=wv,year=2014);
%addcnty(st=wy,year=2014); 

*2013; 
%addcnty(st=ca,year=2013);
%addcnty(st=ga,year=2013);
%addcnty(st=ia,year=2013);
%addcnty(st=id,year=2013);
%addcnty(st=la,year=2013);
%addcnty(st=mi,year=2013);
%addcnty(st=mn,year=2013);
%addcnty(st=mo,year=2013);
%addcnty(st=ms,year=2013);
%addcnty(st=nj,year=2013);

%addcnty(st=pa,year=2013);
%addcnty(st=sd,year=2013);
%addcnty(st=tn,year=2013);
%addcnty(st=ut,year=2013);
%addcnty(st=vt,year=2013);
%addcnty(st=wv,year=2013);
%addcnty(st=wy,year=2013);
*/
/*
*2012;
%addcnty(st=ne,year=2012);
%addcnty(st=co,year=2012);
%addcnty(st=id,year=2012);
%addcnty(st=ks,year=2012);
%addcnty(st=ri,year=2012);

%addcnty(st=ak,year=2012);
%addcnty(st=al,year=2012);

%addcnty(st=ar,year=2012);
%addcnty(st=az,year=2012);
%addcnty(st=ca,year=2012);
%addcnty(st=ct,year=2012);
%addcnty(st=dc,year=2012);
%addcnty(st=de,year=2012);
%addcnty(st=fl,year=2012);
%addcnty(st=ga,year=2012);
%addcnty(st=hi,year=2012);
%addcnty(st=ia,year=2012);

%addcnty(st=il,year=2012);
%addcnty(st=in,year=2012);
%addcnty(st=ky,year=2012);
%addcnty(st=la,year=2012);
%addcnty(st=ma,year=2012);
%addcnty(st=md,year=2012);
%addcnty(st=me,year=2012);
%addcnty(st=mi,year=2012);
%addcnty(st=mn,year=2012);
%addcnty(st=mo,year=2012);

%addcnty(st=ms,year=2012);
%addcnty(st=mt,year=2012);
%addcnty(st=nc,year=2012);
%addcnty(st=nd,year=2012);
%addcnty(st=nh,year=2012);
%addcnty(st=nj,year=2012);
%addcnty(st=nm,year=2012);
%addcnty(st=nv,year=2012);
%addcnty(st=ny,year=2012);
%addcnty(st=oh,year=2012);

%addcnty(st=ok,year=2012);
%addcnty(st=or,year=2012);
%addcnty(st=pa,year=2012);
%addcnty(st=sc,year=2012);
%addcnty(st=sd,year=2012);
%addcnty(st=tn,year=2012);
%addcnty(st=tx,year=2012);
%addcnty(st=ut,year=2012);
%addcnty(st=va,year=2012);
%addcnty(st=vt,year=2012); 

%addcnty(st=wa,year=2012);
%addcnty(st=wi,year=2012);
%addcnty(st=wv,year=2012);
%addcnty(st=wy,year=2012); 
*/


%addcnty(st=ak,year=2005);
%addcnty(st=al,year=2005);
%addcnty(st=ar,year=2005);
%addcnty(st=az,year=2005);
%addcnty(st=ca,year=2005);
%addcnty(st=co,year=2005);
%addcnty(st=ct,year=2005);
%addcnty(st=dc,year=2005);
%addcnty(st=de,year=2005);
%addcnty(st=fl,year=2005);

%addcnty(st=ga,year=2005);
%addcnty(st=hi,year=2005);
%addcnty(st=ia,year=2005);
%addcnty(st=id,year=2005);
%addcnty(st=il,year=2005);
%addcnty(st=in,year=2005);
%addcnty(st=ks,year=2005);
%addcnty(st=ky,year=2005);
%addcnty(st=la,year=2005);
%addcnty(st=ma,year=2005);

%addcnty(st=md,year=2005);
%addcnty(st=me,year=2005);
%addcnty(st=mi,year=2005);
%addcnty(st=mn,year=2005);
%addcnty(st=mo,year=2005);
%addcnty(st=ms,year=2005);
%addcnty(st=mt,year=2005); 
%addcnty(st=nc,year=2005);
%addcnty(st=nd,year=2005);
%addcnty(st=ne,year=2005);

%addcnty(st=nh,year=2005);
%addcnty(st=nj,year=2005);
%addcnty(st=nm,year=2005);
%addcnty(st=nv,year=2005);
%addcnty(st=ny,year=2005);
%addcnty(st=oh,year=2005);
%addcnty(st=ok,year=2005);
%addcnty(st=or,year=2005);
%addcnty(st=pa,year=2005);
%addcnty(st=ri,year=2005);

%addcnty(st=sc,year=2005);
%addcnty(st=sd,year=2005);
%addcnty(st=tn,year=2005);
%addcnty(st=tx,year=2005);
%addcnty(st=ut,year=2005);
%addcnty(st=va,year=2005);
%addcnty(st=vt,year=2005);
%addcnty(st=va,year=2005);
%addcnty(st=wa,year=2005);
%addcnty(st=wi,year=2005);
%addcnty(st=wv,year=2005);

%addcnty(st=wy,year=2005);



** see line 88, update year when switch between 2005 and 2012 !!!! ;
*for MAX DUA, 2012 ;
/*
libname ps_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\ps';
libname ot_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\ot_gapadded';
libname lt_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\lt_gapadded';
libname ip_raw '\\prfs.cri.uchicago.edu\medicaid-max\Users\shared\data\2012\sas\ip_gapadded';
*/
/*
*for MAX DUA, 2013 ;
libname ps_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\ps\sas';
libname ot_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\ot\sas';
libname lt_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\lt\sas';
libname ip_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2013\ip\sas';
*/

/*
*for MAX DUA, 2014 ;
libname ps_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\ps\sas';
libname ot_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\ot\sas';
libname lt_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\lt\sas';
libname ip_raw '\\prfs.cri.uchicago.edu\medicaid-max\data\2014\ip\sas';
*/
/*
libname ref '\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\data\hcbs';
libname desc_wk '\\prfs.cri.uchicago.edu\medicaid-max\Users\jung\data\hcbs';
*/



*for TK's HCBS DUA: ;
libname ps_raw 'K:\Data\MAX\2005\ps\sas';
libname ot_raw 'K:\Data\MAX\2005\ot\sas';
libname lt_raw 'K:\Data\MAX\2005\lt\sas';
libname ip_raw 'K:\Data\MAX\2005\ip\sas';

libname ref '\\prfs.cri.uchicago.edu\medicaid-max\Users\gorges\data\reference_to_link';
libname desc_wk 'K:\Outputdata\DJ\2005_hcbs_max';



%macro get_char(st=,year=);

proc delete data=work._all_; run;

*merge in ps file variables to the ltss user dataset;
data ps_full;
set ps_raw.maxdata_&st._ps_&year.(keep=msis_id
bene_id
EL_MAX_ELGBLTY_CD_LTST
EL_ELGBLTY_MO_CNT
MAX_WAIVER_TYPE_:
MAX_WAIVER_ID_:
el_pph_pln_mo_cnt_:
MC_COMBO_MO_:
HCBS_TXNMY_MDCD_PYMT_AMT_:
TOT_MDCD_PYMT_AMT
TOT_MDCD_FFS_PYMT_AMT
TOT_MDCD_PREM_PYMT_AMT
FFS_PYMT_AMT_: );
msis_id=trim(msis_id);
run;

proc sort data=ps_full; by msis_id; run;

proc sort data=desc_wk.ltc_use_max_&year._&st._all; by msis_id; run;

data ltc_add_ps;
merge desc_wk.ltc_use_max_&year._&st._all(IN=In1) ps_full(IN=In2);
by msis_id;
if In1=1 then output ltc_add_ps;
run;

proc delete data=work.ps_full; run;


/***************************************************************************/
/*              Variables directly from the PS file                        */
/***************************************************************************/
*code eligibility categorical variable;

/*collapse eligibility categories into 4 main codes using the latest elig code variable
(could have done with the monthly variables; could matter for obs that change throughout the year)
0 = aged; 1 = blind,disabled; 2 = child; 3 = adult; 4 = unknown; 5=not eligible */

data ps_elig;
set ltc_add_ps;
if EL_MAX_ELGBLTY_CD_LTST in("11","21","31","41","51") then elig_cat=0 ; /*aged*/
if EL_MAX_ELGBLTY_CD_LTST in("12","22","32","42","52") then elig_cat=1 ; /*disabled*/
if EL_MAX_ELGBLTY_CD_LTST in("14","16","24","34","44","48","54") then elig_cat=2 ; /*child*/
if EL_MAX_ELGBLTY_CD_LTST in("15","17","25","35","45","55","3A") then elig_cat=3 ; /*adult*/
if EL_MAX_ELGBLTY_CD_LTST in("99") then elig_cat=4 ; /*unknown*/
if EL_MAX_ELGBLTY_CD_LTST in("00") then elig_cat=5 ; /*not eligible*/
label elig_cat="Eligibility category";
bene_id_missing=(bene_id="");
run;



/***************************************************************************/
/*              Managed LTSS                                               */
/***************************************************************************/


data get_mltss;
set ps_elig;
*look specifically at managed LTSS, note PACE plans identified in ltss code;
mltss_plan_mogt0=(el_pph_pln_mo_cnt_ltcm>0 & el_pph_pln_mo_cnt_ltcm~=.);
mltss_any=(mltss_plan_mogt0=1 | pace_plan_mogt0=1);
label mltss_any="Managed LTSS or PACE plan 1=yes any time in year");


*flag comprehensive managed care plan enrollment;
if el_pph_pln_mo_cnt_cmcp=0 then cmcp_enroll_cat=0;
if el_pph_pln_mo_cnt_cmcp>0 & el_pph_pln_mo_cnt_cmcp<12 then cmcp_enroll_cat=1;
if el_pph_pln_mo_cnt_cmcp=12 then cmcp_enroll_cat=2;
cmcp_enroll_ind=(cmcp_enroll_cat=1 | cmcp_enroll_cat=2);
label cmcp_enroll_cat="Comprehensive managed care plan, categorical"
	cmcp_enroll_ind="Comprensive managed care plan during year, 1=yes";
run;


/*****************************************************************************/
*get clinical categories, uses the ltss ffs utilization + diagnoses from claims + medpar information;
/*****************************************************************************/
*first step - collect diagnosis codes from IP, LT and OT files - limit to ffs records only;
data ip_1;
set ip_raw.maxdata_&st._ip_&year.(keep=msis_id type_clm_cd diag_cd_1-diag_cd_9 );
if type_clm_cd="1" then output ip_1;
msis_id=trim(msis_id);
run;

proc sql;
create table ip_msis_ids
as select * from ip_1
where msis_id in (select msis_id from ltc_add_ps);
quit;

proc delete data=work.ip_1; run;

data ip_dx_long(keep=msis_id dx );
set ip_msis_ids;
array list diag_cd_1-diag_cd_9;
do over list;
	if list~="" then do;
		dx=list;
		output;
		end;
		end;
run;

proc delete data=work.ip_msis_ids; run;

*lt file;
data lt_1;
set lt_raw.maxdata_&st._lt_&year.(keep=msis_id type_clm_cd diag_cd_1);
if type_clm_cd="1" then output lt_1;
msis_id=trim(msis_id);
run;

proc sql;
create table lt_msis_ids
as select * from lt_1
where msis_id in (select msis_id from ltc_add_ps);
quit;

proc delete data=work.lt_1; run;

data lt_dx_long(keep=msis_id dx );
set lt_msis_ids;
array list diag_cd_1;
do over list;
	if list~="" then do;
		dx=list;
		output;
		end;
		end;
run;

proc delete data=work.lt_msis_ids; run;

*this has some addditional variables to use in the expenditures section later to avoid calling the full ot dataset more than 1x;
*get ot dx list;
data ot_1;
set ot_raw.maxdata_&st._ot_&year.(keep=msis_id type_clm_cd diag_cd_1 diag_cd_2 max_tos msis_top PLC_OF_SRVC_CD MDCD_PYMT_AMT CLTC_FLAG SRVC_BGN_DT);
if type_clm_cd="1" then output ot_1;
msis_id=trim(msis_id);
run;

proc sql;
create table ot_msis_ids
as select * from ot_1
where msis_id in (select msis_id from ltc_add_ps);
quit;

proc delete data=work.ot_1; run;



data ot_dx_long(keep=msis_id dx );
set ot_msis_ids;
array list diag_cd_1-diag_cd_2;
do over list;
	if list~="" then do;
		dx=list;
		output;
		end;
		end;
run;

*now merge and search through dx codes;
data dx_1;
set ip_dx_long lt_dx_long ot_dx_long;
dx2=trim(left(dx));
if dx2~="" then do;
*initialize variables;
array cond cond_dx_1;
do over cond;
	cond=0;
	end;


*IDD conditions;
if (substr(dx2,1,4)='7580')
	  	and cond_dx_1=0
		then cond_dx_1=1;

end;
run;

proc delete data=work.ip_dx_long; run;
proc delete data=work.lt_dx_long; run;
proc delete data=work.ot_dx_long; run;

*now count by msis_id;
proc sql;
create table dx_count_msisid as select distinct msis_id,
sum(cond_dx_1) as cond_1
from dx_1 group by msis_id;
quit;

data dx_2;
set dx_count_msisid;
array list_cond cond_1;
array list_ind cond_ind_1;

do over list_cond;
	list_ind=0;
	if list_cond>0 then do;
		list_ind=1;
	end;
end;
run;

proc delete data=work.dx_count_msisid; run;
proc delete data=work.dx_1; run;
*merge in to main dataset;
proc sort data=dx_2; by msis_id; run;

proc sort data=get_mltss; by msis_id; run;

data clin_cat_1;
merge get_mltss(IN=In1) dx_2(IN=In2);
by msis_id;
if In1=1 then output clin_cat_1;
run;

proc delete data=work.get_mltss; run;
proc delete data=work.dx_2; run;

*create clinical subgroup indicators from waiver enrollment, ffs utilization, or dx;
data clin_cat_2;
set clin_cat_1(drop=cond_1);
run;

proc delete data=work.clin_cat_1; run;



/***************************************************************************/
/*             Expenditures in categories                                  */
/***************************************************************************/
*open each of the claims files, limit to FFS claims, get total medicaid expenditures
by category for each msis_id, then merge across files to get total expenditures for ffs;


*start with OT file created above, limited vars and to ltss users;
**need to split OT file into hospital vs not hospital claims;
data ot_expend_1;
set ot_msis_ids(keep=msis_id type_clm_cd max_tos msis_top PLC_OF_SRVC_CD MDCD_PYMT_AMT CLTC_FLAG SRVC_BGN_DT);
if type_clm_cd="1" & MDCD_PYMT_AMT>0 then output ot_expend_1;
run;

proc delete data=work.ot_msis_ids; run;

/*
proc freq ; table max_tos ; run;

data checkot;
set ot_expend_1;
if plc_of_srvc_cd~=21 then output checkot;
run;

proc freq ; table max_tos /missprint; run;
*/
*get just the hcbs indicators from the main ltc file;
data ltss_main;
set clin_cat_2(keep=
	msis_id cltc_14_ffs_3m_ind
	hcbs_cltc_nonwaiver_3 cltc_exp_gt0_11 cltc_exp_gt0_15);
	run;

/*	data test1;
	set clin_cat_2;
	run;
	proc freq data=test1; table hcbs_cltc_nonwaiver_3*cltc_19_ind; run;
*/
proc sort data=ltss_main; by msis_id; run;
proc sort data=ot_expend_1; by msis_id; run;

data ot_expend_2;
merge ot_expend_1(IN=In1) ltss_main(IN=In2);
by msis_id;
if In1=1 then output ot_expend_2;
run;

proc delete data=work.ot_expend_1; run;
proc delete data=work.ltss_main; run;

data ot_expend_3_sub;
set ot_expend_2;
 if plc_of_srvc_cd=21 then cat_expend=1; *ip;
 if (cltc_flag in(11,13,15,16,17,18) & cat_expend=.) then hcbs_flag=1 ; *hcbs state plans;
 if (cltc_flag in(12,19) & plc_of_srvc_cd=12 & cat_expend=.) then hcbs_flag=1 ; *hcbs state plans - home pvt duty nursing and hospice;
 if (cltc_flag=14 & cltc_14_ffs_3m_ind=1 & cat_expend=.) then hcbs_flag=1 ; *hcbs state plans - 3m consec hh;
 if (cltc_flag in(30,31,32,33,34,35,36,37,38,39,40) & cat_expend=.) then hcbs_flag=1 ; *hcbs waivers;
run;

data ot_expend_3_sub;
   set ot_expend_3_sub;
   if hcbs_flag=. THEN DELETE;
run;

proc sql;
create table ot_hcbs_dt as
select msis_id, max(SRVC_BGN_DT) as hcbs_svc_last format=date9.
from ot_expend_3_sub
group by msis_id;
quit;



*****************************************************************;
**now ltc file, all attributed to inst ltc;
data lt_expend_1;
set lt_raw.maxdata_&st._lt_&year.(keep=msis_id type_clm_cd max_tos msis_top MDCD_PYMT_AMT SRVC_BGN_DT);
if type_clm_cd="1" then output lt_expend_1;
msis_id=trim(msis_id);
run;

proc sql;
create table lt_expend_2
as select * from lt_expend_1
where msis_id in (select msis_id from ltc_add_ps);
quit;


*attribute all to inst ltc;
proc sql;
create table lt_expend_3 as select distinct msis_id,
	sum(mdcd_pymt_amt) as expend_instltc
from lt_expend_2 group by msis_id;
quit;

proc sql;
create table lt_inst_dt as
select msis_id, max(SRVC_BGN_DT) as inst_svc_last format=date9.
from lt_expend_2
group by msis_id;
quit;


proc delete data=work.lt_expend_1; run;
proc delete data=work.lt_expend_2; run;
*****************************************************************;


data expend_1;
merge clin_cat_2 lt_inst_dt ot_hcbs_dt; by msis_id;

run;

proc delete data=work.clin_cat_2; run;


data expend_2;
set expend_1 (keep =msis_id bene_id inst_svc_last hcbs_svc_last) ;
run;



/*************************************************************************/
/** Save this dataset for next steps                                    **/
/*************************************************************************/
data desc_wk.ltc_use_max_&year._&st._sub;
set expend_2;
run;

%mend;


*loop through state by state ;

*2014; /*
%get_char(st=ca,year=2014);
%get_char(st=ga,year=2014);
%get_char(st=ia,year=2014);
%get_char(st=id,year=2014);
%get_char(st=la,year=2014);
%get_char(st=mi,year=2014);
%get_char(st=mn,year=2014);
%get_char(st=mo,year=2014);
%get_char(st=ms,year=2014);
%get_char(st=nj,year=2014);

%get_char(st=pa,year=2014);
%get_char(st=sd,year=2014);
%get_char(st=tn,year=2014);
%get_char(st=ut,year=2014);
%get_char(st=vt,year=2014);
%get_char(st=wv,year=2014);
%get_char(st=wy,year=2014); 
*/
*2013; /*
%get_char(st=ca,year=2013);
%get_char(st=ga,year=2013);
%get_char(st=ia,year=2013);
%get_char(st=id,year=2013);
%get_char(st=la,year=2013);
%get_char(st=mi,year=2013);
%get_char(st=mn,year=2013);
%get_char(st=mo,year=2013);
%get_char(st=ms,year=2013);
%get_char(st=nj,year=2013);

%get_char(st=pa,year=2013);
%get_char(st=sd,year=2013);
%get_char(st=tn,year=2013);
%get_char(st=ut,year=2013);
%get_char(st=vt,year=2013);
%get_char(st=wv,year=2013);
%get_char(st=wy,year=2013);
*/
 *2012;

*%get_char(st=ak,year=2012);
%get_char(st=al,year=2005);
*%get_char(st=ar,year=2012);
*%get_char(st=az,year=2012);
%get_char(st=ca,year=2005);
%get_char(st=co,year=2005);
*%get_char(st=ct,year=2012);
%get_char(st=dc,year=2005);
%get_char(st=de,year=2005);
%get_char(st=fl,year=2005);

%get_char(st=ga,year=2005);
*%get_char(st=hi,year=2012);
%get_char(st=ia,year=2005);
%get_char(st=id,year=2005);
%get_char(st=il,year=2005);
%get_char(st=in,year=2005);
%get_char(st=ks,year=2005);
%get_char(st=ky,year=2005);
%get_char(st=la,year=2005);
%get_char(st=ma,year=2005);

%get_char(st=md,year=2005);
%get_char(st=me,year=2005);
%get_char(st=mi,year=2005);
%get_char(st=mn,year=2005);
%get_char(st=mo,year=2005);
%get_char(st=ms,year=2005);
%get_char(st=mt,year=2005); 
%get_char(st=nc,year=2005);
%get_char(st=nd,year=2005);
%get_char(st=ne,year=2005);

*%get_char(st=nh,year=2012);
*%get_char(st=nj,year=2012);
%get_char(st=nm,year=2005);
%get_char(st=nv,year=2005);
%get_char(st=ny,year=2005);
*%get_char(st=oh,year=2012);
%get_char(st=ok,year=2005);
%get_char(st=or,year=2005);
%get_char(st=pa,year=2005);
%get_char(st=ri,year=2005);

%get_char(st=sc,year=2005);
%get_char(st=sd,year=2005);
*%get_char(st=tn,year=2005);
%get_char(st=tx,year=2005);
%get_char(st=ut,year=2005);
%get_char(st=va,year=2005);
%get_char(st=vt,year=2005);
%get_char(st=va,year=2005);
%get_char(st=wa,year=2005);
%get_char(st=wi,year=2005);
%get_char(st=wv,year=2005);

%get_char(st=wy,year=2005);



