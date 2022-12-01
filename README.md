# Is Being Home Good for your Health? Outcomes of Medicaid Home- and Community-Based Long-Term Services Relative to Nursing Home Care
## 1.	Data 
  ### a.	hcbs_sas_data_setup2005.sas
    i.	Use 2005 MAX raw data 
    ii.	Identify LTSS Use and create derived variables for LTSS Users
    iii.	Save files for STATA
  ### b.	hcbs_sas_data_setup2012.sas
    i.	Use 2012 MAX raw data 
    ii.	Identify LTSS Use and create derived variables for LTSS Users
    iii.	Save files for STATA
  ### c.	hcbs_sas_data_setup2014.sas
    i.	Use 2014 MAX raw data 
    ii.	Identify LTSS Use and create derived variables for LTSS Users
    iii.	Save files for STATA
  ### d.	hcbs_data_setup_stata_2005.do
    i.	2005 data
    ii.	Develop variables by state and merge into a single file 
    iii.	Deal with duplicates 
    iv.	Process max_cc and mbsf datafiles for merge
    v.	Merge max, max_cc, and mbsf data files
  ### e.	hcbs_data_setup_stata_2012.do
    i.	2012 data
    ii.	Develop variables by state and merge into a single file 
    iii.	Deal with duplicates 
    iv.	2012 data
    v.	Process max_cc and mbsf datafiles for merge
    vi.	Merge max, max_cc, and mbsf datafiles
  ### f.	hcbs_data_setup_stata_2014.do
    i.	2012 data
    ii.	Develop variables by state and merge into a single file 
    iii.	Deal with duplicates 
    iv.	2012 data
    v.	Process max_cc and mbsf datafiles for merge
    vi.	Merge max, max_cc, and mbsf datafiles
  ### g.	hcbs_iv_2005_2012.do
    i.	Instrumental variable development for 2005 and 2012
  ### h.	hcbs_iv_2005_2012_65.do
    i.	Instrumental variable development for 2005 and 2012: county-level percentage of HCBS use among long-term care users aged 65 and older
  ### i.	hcbs_iv_2005_2014.do
    i.	Instrumental variable development for 2005 and 2014
  ### j.	hcbs_data_setup_stata_inclusion.do
    i.	Merge 2005 and 2012 data
    ii.	Apply inclusion and exclusion criteria 
    iii.	Main Output – Sample Restrictions

## 2.	Analyses
  ### a.	hcbs_analysis_step1
    i.	Descriptive Analyses
    ii.	Main Output – Sample Characteristics by Care Setting
    iii.	Main Output – Sample Characteristics by Care Setting and Race
    iv.	Main Output – Sample Characteristics by Care Setting and Dementia
    v.	Main Output – Sample Characteristics by Quartile of HCBS Spending among HCBS Users
    vi.	Main Output – Sample Size by Month of First Long-Term Care Service
  ### b.	hcbs_analysis_step2
    i.	Regression analyses 
    ii.	Main Output – Marginal Effects (ME) of HCBS Use on Hospitalizations 
    iii.	Main Output – Marginal Effects of HCBS Use on Hospitalizations by Race and Dementia
    iv.	Main Output – Hausman Tests for Endogeneity
    v.	Main Output – Figure: Instrumental Variables Estimates of Marginal Effects of HCBS Use on Hospitalizations by HCBS Spending Quartile
    vi.	Main Output – Analysis based on 2005 and 2012 data, but using only states available in 2014
  ### c.	hcbs_analysis_step2_table3_row3
    i.	Merge 2005 and 2014 data
    ii.	Apply inclusion and exclusion criteria
    iii.	Main Output – Analysis based on “2005 and 2014 results for subset of states”
  ### d.	hcbs_analysis_step2_table3_row4
    i.	Merge 2005 and 2012 data
    ii.	Apply inclusion and exclusion criteria
    iii.	Main Output – Analysis based on “Used long-term care the entire year”
    iv.	Main Output –Estimates of Marginal Effects, Compare 2012 and 2014
  ### e.	hcbs_analysis_step2_table3_row5
    i.	Merge 2005 and 2012 data 
    ii.	Apply inclusion and exclusion criteria – Use alternative IV 
    iii.	Main Output – Analysis based on “Alternative IV: county-level percentage of HCBS use among long-term care users aged 65 and older”
    iv.	Main Output –Estimates of Marginal Effects, Compare 2012 and 2014
  ### f.	hcbs_analysis_step2_appendix 8
    i.	Merge 2005 and 2012 data 
    ii.	Apply inclusion and exclusion criteria – First service use: Jan 
    iii.	Main Output – Appendix table 8. Estimates of Marginal Effects, People who Started Their First Service in January.
