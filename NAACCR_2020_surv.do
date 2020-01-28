** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          NAACCR_2020_surv.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-JAN-2020
    // 	date last modified      28-JAN-2020
    //  algorithm task          Performing survival analysis at 1yr, 3yrs, 5yrs, 10yrs on 2008, 2013, 2014 cancer incidence data
    //  status                  Completed
    //  objective               To have survival data on cancer incidence data for NS to use for NAACCR 2020 abstract.
    //  methods                 As described in ch.12 'Analysis of survival' pg 3 in publication..."" (ask NS)

    ** General algorithm set-up
    version 16.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p131"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p131

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\2020_naaccr_surv.smcl", replace
** HEADER -----------------------------------------------------
***********************
**  2008 2013 2014   **
** Survival Datasets **
***********************
/*
Data ineligible/excluded from survival analysis - taken from IARC 2012 summer school presented by Manuela Quaresma
Ineligible Criteria:
- Incomplete data
- Beh not=/3
- Not resident
- Inappropriate morph code

Excluded Criteria:
- Age 100+
- SLC unknown
- Duplicate
- Synchronous tumour
- Sex incompatible with site
- Dates invalid
- Inconsistency between dob, dot and dlc
- Multiple primary
- DCO / zero survival (true zero survival included i.e. dot=dod but not a DCO)
*/

**************************************************************************
* SURVIVAL ANALYSIS
* Survival analysis to 1 year, 3 years, 5 years and 10 years
**************************************************************************
** Load the dataset
use "`datapath'\version03\1-input\2008_2013_2014_cancer_survival", clear

/* Prepare survival dataset using DLC (data last contact) as 31-Dec-2018 
   (last date of death matching since we have death data up to end of 2018) 
   for 1yr, 3yr, 5yr and 10yr survival post diagnosis
   This method assumes that all cases not matched with a death record for death data up to 31-dec-2018 are 'alive'
   This will offset the censoring done when running Kaplan Meier (K-M) survival graphs giving a more 'accurate' picture
   in keeping with manually-calculated survival stats
*/

count //2250

** Remove previous survival variables from dataset so updated ones can be created
drop surv1yr_2008 surv3yr_2008 surv5yr_2008 surv10yr_2008 surv1yr_2013 surv3yr_2013 surv5yr_2013 surv1yr_2014 surv3yr_2014

** Below code added so that all 'censored' cases should have 
** newenddate = 31-dec-2018 if newenddate < 31-dec-2018
sort dot
//list deceased_1yr dot newenddate_1yr if deceased_1yr!=1
//list deceased_3yr dot newenddate_3yr if deceased_3yr!=1
//list deceased_5yr dot dlc newenddate_5yr if deceased_5yr!=1
//list deceased_10yr dot newenddate_10yr if deceased_10yr!=1
count if dlc>d(31dec2018) & deceased_1yr!=1 //0
count if dlc>d(31dec2018) & deceased_3yr!=1 //0
count if dlc>d(31dec2018) & deceased_5yr!=1 //0
count if dlc>d(31dec2018) & deceased_10yr!=1 //0

replace newenddate_1yr=d(31dec2018) if deceased_1yr!=1 & newenddate_1yr!=. & newenddate_1yr<d(31dec2018) //1462 changes
replace newenddate_3yr=d(31dec2018) if deceased_3yr!=1 & newenddate_3yr!=. & newenddate_3yr<d(31dec2018) //1099 changes
replace newenddate_5yr=d(31dec2018) if deceased_5yr!=1 & newenddate_5yr!=. & newenddate_5yr<d(31dec2018) //620 changes
replace newenddate_10yr=d(31dec2018) if deceased_10yr!=1 & newenddate_10yr!=. & newenddate_10yr<d(31dec2018) //234 changes

** JC to NS: I don't think K-M graphs use these time variables, 
** I think K-M generates its own time but I included in case I'm wrong
replace time_1yr=newenddate_1yr-dot if deceased_1yr!=1 & newenddate_1yr!=. //1462 changes
replace time_3yr=newenddate_3yr-dot if deceased_3yr!=1 & newenddate_3yr!=. //1099 changes
replace time_5yr=newenddate_5yr-dot if deceased_5yr!=1 & newenddate_5yr!=. //620 changes
replace time_10yr=newenddate_10yr-dot if deceased_10yr!=1 & newenddate_10yr!=. //234 changes

count if time_1yr==. //0
count if time_3yr==. //0
count if time_5yr==. & dxyr!=2014 //0
count if time_10yr==. & dxyr==2008 //0

** Check if time variables need to be rounded to nearest whole number
//tab time_1yr ,m //none to round
//tab time_3yr ,m //none to round
//tab time_5yr if dxyr!=2014 ,m //none to round
//tab time_10yr if dxyr==2008 ,m //none to round

tab deceased ,m 
tab deceased_1yr ,m
tab deceased_3yr ,m 
tab deceased_5yr ,m 
tab deceased_10yr ,m 

count //2250

tab deceased_1yr dxyr ,m
tab deceased_3yr dxyr ,m
tab deceased_5yr dxyr if dxyr!=2014 ,m
tab deceased_10yr dxyr if dxyr==2008 ,m


** Create survival variables by dxyr
gen surv1yr_2008=1 if deceased_1yr==1 & dxyr==2008
replace surv1yr_2008=0 if deceased_1yr==0 & dxyr==2008
gen surv3yr_2008=1 if deceased_3yr==1 & dxyr==2008
replace surv3yr_2008=0 if deceased_3yr==0 & dxyr==2008
gen surv5yr_2008=1 if deceased_5yr==1 & dxyr==2008
replace surv5yr_2008=0 if deceased_5yr==0 & dxyr==2008
gen surv10yr_2008=1 if deceased_10yr==1 & dxyr==2008
replace surv10yr_2008=0 if deceased_10yr==0 & dxyr==2008
gen surv1yr_2013=1 if deceased_1yr==1 & dxyr==2013
replace surv1yr_2013=0 if deceased_1yr==0 & dxyr==2013
gen surv3yr_2013=1 if deceased_3yr==1 & dxyr==2013
replace surv3yr_2013=0 if deceased_3yr==0 & dxyr==2013
gen surv5yr_2013=1 if deceased_5yr==1 & dxyr==2013
replace surv5yr_2013=0 if deceased_5yr==0 & dxyr==2013
gen surv1yr_2014=1 if deceased_1yr==1 & dxyr==2014
replace surv1yr_2014=0 if deceased_1yr==0 & dxyr==2014
gen surv3yr_2014=1 if deceased_3yr==1 & dxyr==2014
replace surv3yr_2014=0 if deceased_3yr==0 & dxyr==2014
label define surv_lab 0 "censored" 1 "dead", modify
label values surv1yr_2008 surv3yr_2008 surv5yr_2008 surv10yr_2008 surv1yr_2013 surv3yr_2013 surv5yr_2013 surv1yr_2014 surv3yr_2014 surv_lab
label var surv1yr_2008 "Survival at 1yr - 2008"
label var surv3yr_2008 "Survival at 3yrs - 2008"
label var surv5yr_2008 "Survival at 5yrs - 2008"
label var surv10yr_2008 "Survival at 10yrs - 2008"
label var surv1yr_2013 "Survival at 1yr - 2013"
label var surv3yr_2013 "Survival at 3yrs - 2013"
label var surv5yr_2013 "Survival at 5yrs - 2013"
label var surv1yr_2014 "Survival at 1yr - 2014"
label var surv3yr_2014 "Survival at 3yrs - 2014"

tab dxyr ,m
tab surv1yr_2008 if dxyr==2008 ,m
tab surv3yr_2008 if dxyr==2008 ,m
tab surv5yr_2008 if dxyr==2008 ,m
tab surv10yr_2008 if dxyr==2008 ,m
tab surv1yr_2013 if dxyr==2013 ,m
tab surv3yr_2013 if dxyr==2013 ,m
tab surv5yr_2013 if dxyr==2013 ,m
tab surv1yr_2014 if dxyr==2014 ,m
tab surv3yr_2014 if dxyr==2014 ,m


** Top 10 cancer sites (in total) for all 3 years: 2008, 2013, 2014
** All sites excluding O&U (other & unknown), non-reportable skin cancers, in-situ, uncertain, CIN3 - using IARC CI5's site groupings
tab siteiarc ,m
labelbook siteiarc_lab

preserve
drop if siteiarc==25|siteiarc>60 //89 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Prostate (C61)								471		28.42
Breast (C50)								401		24.20
Colon (C18)									286		17.26
Corpus uteri (C54)							100		 6.04
Rectum (C19-20)								 93		 5.61
Lung (incl. trachea and bronchus) (C33-34)	 77		 4.65
Cervix uteri (C53)							 68		 4.10
Stomach (C16)								 63		 3.80
Multiple myeloma (C90)						 50		 3.02
Non-Hodgkin lymphoma (C82-86,C96)			 48		 2.90
*/
total count //1657
restore


** Top 10 cancer sites for 2008 only
** All sites excluding O&U (other & unknown), non-reportable skin cancers, in-situ, uncertain, CIN3 - using IARC CI5's site groupings
tab dxyr ,m

preserve
drop if siteiarc==25|siteiarc>60 //89 deleted
drop if dxyr!=2008 //1440 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Prostate (C61)								198		34.49
Breast (C50)								128		22.30
Colon (C18)									 84		14.63
Corpus uteri (C54)							 35		 6.10
Stomach (C16)								 30		 5.23
Rectum (C19-20)								 28		 4.88
Lung (incl. trachea and bronchus) (C33-34)	 26		 4.53
Cervix uteri (C53)							 18		 3.14
Multiple myeloma (C90)						 14		 2.44
Non-Hodgkin lymphoma (C82-86,C96)			 13		 2.26
*/
total count //574
restore

** Top 10 cancer sites for 2013 only
** All sites excluding O&U (other & unknown), non-reportable skin cancers, in-situ, uncertain, CIN3 - using IARC CI5's site groupings
preserve
drop if siteiarc==25|siteiarc>60 //89 deleted
drop if dxyr!=2013 //1465 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Breast (C50)								123		22.45
Prostate (C61)								122		22.26
Colon (C18)									106		19.34
Rectum (C19-20)								 40		 7.30
Cervix uteri (C53)							 35		 6.39
Corpus uteri (C54)							 30		 5.47
Lung (incl. trachea and bronchus) (C33-34)	 21		 3.83
Non-Hodgkin lymphoma (C82-86,C96)			 21		 3.83
Kidney (C64)								 18		 3.28
Pancreas (C25)								 16		 2.92
Stomach (C16)								 16		 2.92
*/
total count //548
restore

** Top 10 cancer sites for 2014 only
** All sites excluding O&U (other & unknown), non-reportable skin cancers, in-situ, uncertain, CIN3 - using IARC CI5's site groupings
preserve
drop if siteiarc==25|siteiarc>60 //89 deleted
drop if dxyr!=2014 //1417 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Prostate (C61)								151		25.90
Breast (C50)								150		25.73
Colon (C18)									 96		16.47
Corpus uteri (C54)							 35		 6.00
Lung (incl. trachea and bronchus) (C33-34)	 30		 5.15
Rectum (C19-20)								 25		 4.29
Multiple myeloma (C90)						 25		 4.29
Bladder (C67)								 24		 4.12
Stomach (C16)								 17		 2.92
Cervix uteri (C53)							 15		 2.57
Pancreas (C25)								 15		 2.57
*/
total count //583
restore



** Top 10 survival at 1, 3, 5 years by diagnosis year
**********
** 2008 **
**********
** PROSTATE
tab surv1yr_2008 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2008 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2008 if siteiarc==39 //prostate 5-yr survival
tab surv10yr_2008 if siteiarc==39 //prostate 10-yr survival
** BREAST
tab surv1yr_2008 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2008 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2008 if siteiarc==29 //breast 5-yr survival
tab surv10yr_2008 if siteiarc==29 //breast 10-yr survival
** COLON
tab surv1yr_2008 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2008 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2008 if siteiarc==13 //colon 5-yr survival
tab surv10yr_2008 if siteiarc==13 //colon 10-yr survival
** CORPUS UTERI
tab surv1yr_2008 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2008 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2008 if siteiarc==33 //corpus uteri 5-yr survival
tab surv10yr_2008 if siteiarc==33 //corpus uteri 10-yr survival
** RECTUM
tab surv1yr_2008 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2008 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2008 if siteiarc==14 //rectum 5-yr survival
tab surv10yr_2008 if siteiarc==14 //rectum 10-yr survival
** LUNG
tab surv1yr_2008 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2008 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2008 if siteiarc==21 //lung 5-yr survival
tab surv10yr_2008 if siteiarc==21 //lung 10-yr survival
** CERVIX
tab surv1yr_2008 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2008 if siteiarc==32 //cervix 3-yr survival
tab surv5yr_2008 if siteiarc==32 //cervix 5-yr survival
tab surv10yr_2008 if siteiarc==32 //cervix 10-yr survival
** STOMACH
tab surv1yr_2008 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2008 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2008 if siteiarc==11 //stomach 5-yr survival
tab surv10yr_2008 if siteiarc==11 //stomach 10-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2008 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2008 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2008 if siteiarc==55 //mm  5-yr survival
tab surv10yr_2008 if siteiarc==55 //mm  10-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2008 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2008 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2008 if siteiarc==53 //nhl  5-yr survival
tab surv10yr_2008 if siteiarc==53 //nhl  10-yr survival

**********
** 2013 **
**********
** PROSTATE
tab surv1yr_2013 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2013 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2013 if siteiarc==39 //prostate 5-yr survival
** BREAST
tab surv1yr_2013 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2013 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2013 if siteiarc==29 //breast 5-yr survival
** COLON
tab surv1yr_2013 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2013 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2013 if siteiarc==13 //colon 5-yr survival
** CORPUS UTERI
tab surv1yr_2013 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2013 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2013 if siteiarc==33 //corpus uteri 5-yr survival
** RECTUM
tab surv1yr_2013 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2013 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2013 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2013 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2013 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2013 if siteiarc==21 //lung 5-yr survival
** CERVIX
tab surv1yr_2013 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2013 if siteiarc==32 //cervix 3-yr survival
tab surv5yr_2013 if siteiarc==32 //cervix 5-yr survival
** STOMACH
tab surv1yr_2013 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2013 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2013 if siteiarc==11 //stomach 5-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2013 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2013 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2013 if siteiarc==55 //mm  5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2013 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2013 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2013 if siteiarc==53 //nhl  5-yr survival

**********
** 2014 **
**********
** PROSTATE
tab surv1yr_2014 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2014 if siteiarc==39 //prostate 3-yr survival
** BREAST
tab surv1yr_2014 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2014 if siteiarc==29 //breast 3-yr survival
** COLON
tab surv1yr_2014 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2014 if siteiarc==13 //colon 3-yr survival
** CORPUS UTERI
tab surv1yr_2014 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2014 if siteiarc==33 //corpus uteri 3-yr survival
** RECTUM
tab surv1yr_2014 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2014 if siteiarc==14 //rectum 3-yr survival
** LUNG
tab surv1yr_2014 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2014 if siteiarc==21 //lung 3-yr survival
** CERVIX
tab surv1yr_2014 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2014 if siteiarc==32 //cervix 3-yr survival
** STOMACH
tab surv1yr_2014 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2014 if siteiarc==11 //stomach 3-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2014 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2014 if siteiarc==55 //mm  3-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2014 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2014 if siteiarc==53 //nhl  3-yr survival


count //2250

** Save this corrected dataset with only reportable cases
save "`datapath'\version03\3-output\2008_2013_2014_naaccr_survival", replace
label data "2008 2013 2014 BNR-Cancer analysed data - Survival Reportable Dataset"
note: TS This dataset was used for 2020 NAACCR abstract
note: TS Excludes dco, unk slc, age 100+, multiple primaries, ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
note: TS For survival analysis, use variables surv1yr_2008, surv1yr_2013, surv1yr_2014, surv3yr_2008, surv3yr_2013, surv3yr_2014, surv5yr_2008, surv5yr_2013, surv10yr_2008
