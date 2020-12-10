
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20_analysis cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL / Kern ROCKE
    //  date first created      02-DEC-2019
    // 	date last modified      23-OCT-2020
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs (3) Survival
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2013, 2014 data for inclusion in 2015 cancer report.
    //  methods                 See 30_report cancer.do for detailed methods of each statistic

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
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'/20_analysis cancer.smcl", replace
** HEADER -----------------------------------------------------



***************************************************************************
* SECTION 1: NUMBERS 
*        (1.1) total number & number of multiple events
*        (1.2) DCOs
*    	 (1.3) tumours by age-group: 
*				NOTE: missing/unknown age (code 999) are 
*				to be included in the age group that has a median total if 
*			  	total number of unk age is small, i.e. 5 cases with unk age; 
*			  	if larger then they would be distributed amongst more than
*			  	one age groups with median totals (NS update on 14-Oct-2020)
****************************************************************************
 
** LOAD cancer incidence dataset INCLUDING DCOs
use "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival" ,clear

** CASE variable
*drop case
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //2744
tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |        852       31.05       31.05
       2014 |        857       31.23       62.28
       2015 |      1,035       37.72      100.00
------------+-----------------------------------
      Total |      2,744      100.00
*/
tab patient dxyr ,m //2691 patients & 53 MPs; 2015: 1011 patients & 24 MPs (Checked this)
/*
                |          DiagnosisYear
cancer patient |      2013       2014       2015 |     Total
---------------+---------------------------------+----------
       patient |       840        840      1,011 |     2,691 
separate event |        12         17         24 |        53 
---------------+---------------------------------+----------
         Total |       852        857      1,035 |     2,744
*/

** JC updated AR's 2008 code for identifying MPs
tab ptrectot ,m
tab ptrectot patient ,m
tab ptrectot dxyr ,m

tab eidmp dxyr,m

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid_analysis)
sort pid cr5id
count if mppid_analysis>0 //86
//list pid topography morph ptrectot eidmp cr5id icd10 dxyr if mppid_analysis>0 ,sepby(pid)
 
** Of 2691 patients, 53 had >1 tumour

** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m // 3908 malignant; 134 in-situ; 18 uncertain/benign
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
  Malignant |      2,744      100.00      100.00
------------+-----------------------------------
      Total |      2,744      100.00
*/

*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |       216 |       216 
        Clinical only |        99 |        99 
Clinical Invest./Ult  |       115 |       115 
Exploratory surg./aut |        20 |        20 
Lab test (biochem/imm |         9 |         9 
        Cytology/Haem |       102 |       102 
           Hx of mets |        44 |        44 
        Hx of primary |     1,997 |     1,997 
        Autopsy w/ Hx |        19 |        19 
              Unknown |       123 |       123 
----------------------+-----------+----------
                Total |     2,744 |     2,744  
*/

tab basis dxyr ,m
/*

                      |          DiagnosisYear
     BasisOfDiagnosis |      2013       2014       2015 |     Total
----------------------+---------------------------------+----------
                  DCO |        43         39        134 |       216 
        Clinical only |        19         38         42 |        99 
Clinical Invest./Ult  |        50         29         36 |       115 
Exploratory surg./aut |        10          5          5 |        20 
Lab test (biochem/imm |         3          3          3 |         9 
        Cytology/Haem |        31         43         28 |       102 
           Hx of mets |        13         13         18 |        44 
        Hx of primary |       634        623        740 |     1,997 
        Autopsy w/ Hx |         6          9          4 |        19 
              Unknown |        43         55         25 |       123 
----------------------+---------------------------------+----------
                Total |       852        857      1,035 |     2,744 
*/
/* JC 03mar20 checked to see if any duplicated observations occurred but no, seems like a legitimate new prostate case
preserve
drop if dxyr!=2015 & siteiarc!=39
sort pid cr5id
quietly by pid cr5id :  gen duppidcr5id = cond(_N==1,0,_n)
sort pid cr5id
count if duppidcr5id>0 //0
list pid cr5id deathid eidmp ptrectot primarysite duppidcr5id if duppidcr5id>0
restore
*/
tab basis dxyr if patient==1
/*
                      |          DiagnosisYear
     BasisOfDiagnosis |      2013       2014       2015 |     Total
----------------------+---------------------------------+----------
                  DCO |        43         36        132 |       211 
        Clinical only |        19         36         41 |        96 
Clinical Invest./Ult  |        49         28         35 |       112 
Exploratory surg./aut |        10          5          5 |        20 
Lab test (biochem/imm |         3          3          3 |         9 
        Cytology/Haem |        30         43         28 |       101 
           Hx of mets |        13         13         18 |        44 
        Hx of primary |       624        614        720 |     1,958 
        Autopsy w/ Hx |         6          9          4 |        19 
              Unknown |        43         53         25 |       121 
----------------------+---------------------------------+----------
                Total |       840        840      1,011 |     2,691 
*/

//This section assesses DCO % in relation to tumour, patient and behaviour totals
**********
** 2015 **
**********
** As a percentage of all events: 12.95%
cii proportions 1035 134

** As a percentage of all events with known basis: 13.27%
cii proportions 1010 134

** As a percentage of all patients: 13.06%
cii proportions 1011 132

tab basis beh if dxyr==2015 ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |       134 |       134 
        Clinical only |        42 |        42 
Clinical Invest./Ult  |        36 |        36 
Exploratory surg./aut |         5 |         5 
Lab test (biochem/imm |         3 |         3 
        Cytology/Haem |        28 |        28 
           Hx of mets |        18 |        18 
        Hx of primary |       740 |       740 
        Autopsy w/ Hx |         4 |         4 
              Unknown |        25 |        25 
----------------------+-----------+----------
                Total |     1,035 |     1,035
*/
** Below no longer applicable as non-malignant dx were removed from ds (23-Oct-2020)
** As a percentage for all those which were non-malignant: 0%
//cii proportions 18 0
 
** As a percentage of all malignant tumours: 12.95%
//cii proportions 1035 134

**********
** 2014 **
**********
** As a percentage of all events: 4.46%
cii proportions 857 39

** As a percentage of all events with known basis: 4.86%
cii proportions 802 39
 
** As a percentage of all patients: 4.29%
cii proportions 840 36

tab basis beh if dxyr==2014 ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |        39 |        39 
        Clinical only |        38 |        38 
Clinical Invest./Ult  |        29 |        29 
Exploratory surg./aut |         5 |         5 
Lab test (biochem/imm |         3 |         3 
        Cytology/Haem |        43 |        43 
           Hx of mets |        13 |        13 
        Hx of primary |       623 |       623 
        Autopsy w/ Hx |         9 |         9 
              Unknown |        55 |        55 
----------------------+-----------+----------
                Total |       857 |       857
*/
** Below no longer applicable as non-malignant dx were removed from ds (23-Oct-2020)
** As a percentage for all those which were non-malignant: 0%
//cii proportions 23 0
 
** As a percentage of all malignant tumours: 4.58%
//cii proportions 874 40

**********
** 2013 **
**********
** As a percentage of all events: 5.05%
cii proportions 852 43

** As a percentage of all events with known basis: 5.32%
cii proportions 809 43
 
** As a percentage of all patients: 5.12%
cii proportions 840 43

tab basis beh if dxyr==2013 ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |        43 |        43 
        Clinical only |        19 |        19 
Clinical Invest./Ult  |        50 |        50 
Exploratory surg./aut |        10 |        10 
Lab test (biochem/imm |         3 |         3 
        Cytology/Haem |        31 |        31 
           Hx of mets |        13 |        13 
        Hx of primary |       634 |       634 
        Autopsy w/ Hx |         6 |         6 
              Unknown |        43 |        43 
----------------------+-----------+----------
                Total |       852 |       852
*/
** Below no longer applicable as non-malignant dx were removed from ds (23-Oct-2020)
** As a percentage for all those which were non-malignant: 0%
//cii proportions 9 0
 
** As a percentage of all malignant tumours: 4.92%
//cii proportions 874 43


*************************
** Number of cases by sex
*************************
tab sex ,m

tab sex patient,m

** Mean age by sex overall (where sex: male=1, female=2)... BY TUMOUR
ameans age
ameans age if sex==1
ameans age if sex==2

 
** Mean age by sex overall (where sex: male=1, female=2)... BY PATIENT
preserve
keep if patient==1 //15 obs deleted
ameans age
ameans age if sex==1
ameans age if sex==2
restore
 
***********************************
** 1.4 Number of cases by age-group
***********************************
** Age labelling
gen age5 = recode(age,4,9,14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,200)

recode age5 4=1 9=2 14=3 19=4 24=5 29=6 34=7 39=8 44=9 49=10 54=11 59=12 64=13 /// 
                        69=14 74=15 79=16 84=17 200=18

label define age5_lab 1 "0-4" 	 2 "5-9"    3 "10-14" ///
					  4 "15-19"  5 "20-24"  6 "25-29" ///
					  7 "30-34"  8 "35-39"  9 "40-44" ///
					 10 "45-49" 11 "50-54" 12 "55-59" ///
					 13 "60-64" 14 "65-69" 15 "70-74" ///
					 16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 age5_lab
gen age_10 = recode(age5,3,5,7,9,11,13,15,17,200)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 200=9

label define age_10_lab 1 "0-14"   2 "15-24"  3 "25-34" ///
                        4 "35-44"  5 "45-54"  6 "55-64" ///
                        7 "65-74"  8 "75-84"  9 "85 & over" , modify

label values age_10 age_10_lab

sort sex age_10

tab age_10 ,m
*/
** Save this new dataset without population data
label data "2013-2015 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data 
save "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", replace

*******************************************************************************************************************
* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************

drop if dxyr!=2015 //1709 deleted
count //1035

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //18 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64
tab siteiarc ,m //1044 - 18 in-situ; 38 O&U [check this - the last bit]
tab siteiarc patient

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
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
Prostate (C61)								217		28.33
Breast (C50)								198		25.85
Colon (C18)									114		14.88
Rectum (C19-20)								 47		 6.14
Corpus uteri (C54)							 44		 5.74
Stomach (C16)								 36		 4.70
Lung (incl. trachea and bronchus) (C33-34)	 30		 3.92
Multiple myeloma (C90)						 28		 3.66
Non-Hodgkin lymphoma (C82-86,C96)			 26		 3.39
Pancreas (C25)								 26		 3.39
*/
total count //766
restore

labelbook sex_lab
tab sex ,m

** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
gsort -top10
tab siteiarc top10 if top10!=0
tab siteiarc top10 if top10!=0 & sex==1 //female
tab siteiarc top10 if top10!=0 & sex==2 //male
contract siteiarc top10 sex if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
sex		siteiarc									count	percentage
male	Prostate (C61)								217		28.33
female	Breast (C50)								197		25.72
male	Colon (C18)									 60		 7.83
female	Colon (C18)									 54		 7.05
female	Corpus uteri (C54)							 44		 5.74
female	Rectum (C19-20)								 26		 3.39
female	Multiple myeloma (C90)						 21		 2.74
male	Lung (incl. trachea and bronchus) (C33-34)	 21		 2.74
male	Rectum (C19-20)								 21		 2.74
female	Stomach (C16)								 19		 2.48
male	Stomach (C16)								 17		 2.22
female	Non-Hodgkin lymphoma (C82-86,C96)			 14		 1.83
female	Pancreas (C25)								 14		 1.83
male	Pancreas (C25)								 12		 1.57
male	Non-Hodgkin lymphoma (C82-86,C96)			 12		 1.57
female	Lung (incl. trachea and bronchus) (C33-34)	  9		 1.17
male	Multiple myeloma (C90)						  7		 0.91
male	Breast (C50)								  1		 0.13
*/
total count //766
drop percentage
gen year=2015
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version02\2-working\2015_top10_sex" ,replace
restore


/*
** Below not used as it isn't what SF requested
** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex - FEMALE
preserve
drop if sex==2 //490 deleted
drop if siteiarc==25 | siteiarc>60 //21 deleted
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
siteiarc							count	percentage
Breast (C50)						197		46.68
Colon (C18)							 54		12.80
Corpus uteri (C54)					 44		10.43
Rectum (C19-20)						 26		 6.16
Multiple myeloma (C90)				 21		 4.98
Stomach (C16)						 19		 4.50
Ovary (C56)							 17		 4.03
Cervix uteri (C53)					 16		 3.79
Pancreas (C25)						 14		 3.32
Non-Hodgkin lymphoma (C82-86,C96)	 14		 3.32
*/
total count //422
drop percentage
gen year=2015
order year siteiarc count
save "`datapath'\version02\2-working\2015_top10_female" ,replace
restore

** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex - MALE
preserve
drop if sex==1 //545 deleted
drop if siteiarc==25 | siteiarc>60 //17 deleted
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
Prostate (C61)								217		55.93
Colon (C18)									 60		15.46
Rectum (C19-20)								 21		 5.41
Lung (incl. trachea and bronchus) (C33-34)	 21		 5.41
Stomach (C16)								 17		 4.38
Pancreas (C25)								 12		 3.09
Non-Hodgkin lymphoma (C82-86,C96)			 12		 3.09
Kidney (C64)								 10		 2.58
Bladder (C67)								 10		 2.58
Oesophagus (C15)							  8		 2.06
*/
total count //388
drop percentage
gen year=2015
order year siteiarc count
save "`datapath'\version02\2-working\2015_top10_male" ,replace
restore
*/

labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //490 deleted
drop if siteiarc>60 //21 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/545)*100 //all cancers excl. male(490)
gen alltotpercent=(count/1035)*100 //all cancers
/*
siteiarc				count	percentage	totpercent	alltotpercent
Breast (C50)			197		57.60		36.14679	19.03382
Colon (C18)				 54		15.79		 9.908257	 5.217391
Corpus uteri (C54)		 44		12.87		 8.073395	 4.251208
Rectum (C19-20)			 26		 7.60		 4.770642	 2.512077
Multiple myeloma (C90)	 21		 6.14		 3.853211	 2.028986
*/
total count //342
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2015
** MALE - using IARC's site groupings
preserve
drop if sex==1 //545 deleted
drop if siteiarc==25 | siteiarc>60 //17 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/490)*100 //all cancers excl. female(545)
gen alltotpercent=(count/1035)*100 //all cancers
/*
siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								217		64.58		44.28571	20.96618
Colon (C18)									 60		17.86		12.2449		 5.797101
Lung (incl. trachea and bronchus) (C33-34)	 21		 6.25		 4.285714	 2.028986
Rectum (C19-20)								 21		 6.25		 4.285714	 2.028986
Stomach (C16)								 17		 5.06		 3.469388	 1.642512
*/
total count //336
restore


*****************************
**   Data Quality Indices  **
*****************************
** Added on 04-June-2019 by JC as requested by NS for 2014 cancer annual report

*****************************
** Identifying & Reporting **
** 	 Data Quality Index	   **
** MV,DCO,O+U,UnkAge,CLIN  **
*****************************

tab basis ,m
tab siteicd10 basis ,m 
tab sex ,m //0 missing
tab age ,m //3 missing=999
tab sex age if age==.|age==999 //used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sex if sitecr5db==20 //site=O&U; used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
/*
gen boddqi=1 if basis>4 & basis <9 //782 changes; 
replace boddqi=2 if basis==0 //13 changes
replace boddqi=3 if basis>0 & basis<5 //77 changes
replace boddqi=4 if basis==9 //19 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

tab boddqi ,m
tab siteicd10 boddqi ,m
tab siteicd10 ,m //9 missing site - MPDs/MDS
//list pid top morph beh basis siteiarc icd10 if siteicd10==. //these are MPDs/MDS so exclude
tab siteicd10 boddqi if siteicd10!=.
** Use CanReg5 site groupings for basis DQI
tab sitecr5db ,m
tab sitecr5db boddqi if sex==1 & boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=20 //male: used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sitecr5db boddqi if sex==2 & boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=20 //female: used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sitecr5db boddqi if boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=20
*/

tab basis ,m
gen boddqi=1 if basis>4 & basis <9 //245 changes; 
replace boddqi=2 if basis==0 //134 changes
replace boddqi=3 if basis>0 & basis<5 //86 changes
replace boddqi=4 if basis==9 //25 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

gen siteagedqi=1 if siteiarc==61 //38 changes
replace siteagedqi=2 if age==.|age==999 //1 change
replace siteagedqi=3 if dob==. & siteagedqi!=2 //11 changes
replace siteagedqi=4 if siteiarc==61 & siteagedqi!=1 //0 changes
replace siteagedqi=5 if sex==.|sex==99 //0 changes
label define siteagedqi_lab 1 "O&U SITE" 2 "UNK.AGE" 3 "UNK.DOB" 4 "O&U+UNK.AGE/DOB" 5 "UNK.SEX", modify
label var siteagedqi "site/age DQI"
label values siteagedqi siteagedqi_lab

tab boddqi ,m
generate rectot=_N //1062
tab boddqi rectot,m

tab siteagedqi ,m
tab siteagedqi rectot,m

/*
preserve
** Append to above .docx for NS of basis,site,age but want to retain this dataset
** % tumours - basis by siteicd10
tab boddqi
contract boddqi siteicd10, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Basis"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,062)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteicd10 Site
rename boddqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_bod = data("Site Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-10-05_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore
*/


** Create variables for table by basis (DCO% + MV%) in Data Quality section of annual report
** This was done manually in excel for 2014 annual report so the above code has now been updated to be automated in Stata
tab sitecr5db boddqi if boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
                      |       basis DQI
          CR5db sites |        MV        DCO |     Total
----------------------+----------------------+----------
Mouth & pharynx (C00- |        24          0 |        24 
        Stomach (C16) |        23          9 |        32 
Colon, rectum, anus ( |       142         19 |       161 
       Pancreas (C25) |         7         10 |        17 
Lung, trachea, bronch |        13          7 |        20 
         Breast (C50) |       179         14 |       193 
         Cervix (C53) |        14          2 |        16 
Corpus & Uterus NOS ( |        43          4 |        47 
       Prostate (C61) |       168         33 |       201 
Lymphoma (C81-85,88,9 |        44          7 |        51 
   Leukaemia (C91-95) |        11          2 |        13 
----------------------+----------------------+----------
                Total |       668        107 |       775
*/
labelbook sitecr5db_lab

preserve
drop if boddqi==. | boddqi>2 | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
34	1	668	0
34	2	107	0
end

label define sitecr5db_lab ///
1 "Mouth & pharynx" ///
2 "Oesophagus" ///
3 "Stomach" ///
4 "Colon, rectum, anus" ///
5 "Liver" ///
6 "Pancreas" ///
7 "Larynx" ///
8 "Lung, trachea, bronchus" ///
9 "Melanoma of skin" ///
10 "Breast" ///
11 "Cervix" ///
12 "Corpus & Uterus NOS" ///
13 "Ovary & adnexa" ///
14 "Prostate" ///
15 "Testis" ///
16 "Kidney & urinary NOS" ///
17 "Bladder" ///
18 "Brain, nervous system" ///
19 "Thyroid" ///
20 "O&U" ///
21 "Lymphoma" ///
22 "Leukaemia" ///
23 "Other digestive" ///
24 "Nose, sinuses" ///
25 "Bone, cartilage, etc" ///
26 "Other skin" ///
27 "Other female organs" ///
28 "Other male organs" ///
29 "Other endocrine" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc" ///
34 "All sites (in this table)" , modify
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab
drop percentage
gen percentage=(count/25)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/25)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/32)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/32)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/163)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/163)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/17)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/17)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/20)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/20)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/195)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/195)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/47)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/47)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/203)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/203)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/52)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/52)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/783)*100 if sitecr5db==34 & boddqi==1
replace percentage=(count/783)*100 if sitecr5db==34 & boddqi==2
format percentage %04.1f

gen icd10dqi="C00-14" if sitecr5db==1
replace icd10dqi="C16" if sitecr5db==3
replace icd10dqi="C18-21" if sitecr5db==4
replace icd10dqi="C25" if sitecr5db==6
replace icd10dqi="C33-34" if sitecr5db==8
replace icd10dqi="C50" if sitecr5db==10
replace icd10dqi="C53" if sitecr5db==11
replace icd10dqi="C54-55" if sitecr5db==12
replace icd10dqi="C61" if sitecr5db==14
replace icd10dqi="C81-85,88,90,96" if sitecr5db==21
replace icd10dqi="C91-95" if sitecr5db==22
replace icd10dqi="All" if sitecr5db==34

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Basis"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,035)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-10-23_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore

preserve
** % tumours - site,age
tab siteagedqi
contract siteagedqi, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=1,035)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-10-23_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_siteage.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Site,Age"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore
** Missing sex %
** Missing age %


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************
drop if dxyr!=2015 //1709 deleted

count //1035

** Determine sequential order of 2014 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Corpus uteri (C54) |
     |-------------------------------------------------------|
  6. |        6                                Stomach (C16) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8                       Multiple myeloma (C90) |
  9. |        9                               Pancreas (C25) |
 10. |       10            Non-Hodgkin lymphoma (C82-86,C96) |
     |-------------------------------------------------------|
 11. |       11                                 Kidney (C64) |
 12. |       12                                  Ovary (C56) |
 13. |       13                           Cervix uteri (C53) |
 14. |       14                                Bladder (C67) |
 15. |       15                                Thyroid (C73) |
     |-------------------------------------------------------|
 16. |       16                             Oesophagus (C15) |
 17. |       17                    Gallbladder etc. (C23-24) |
 18. |       18               Brain, nervous system (C70-72) |
 19. |       19                        Small intestine (C17) |
 20. |       20                       Melanoma of skin (C43) |
     |-------------------------------------------------------|
 21. |       21                     Uterus unspecified (C55) |
 22. |       22                                  Liver (C22) |
 23. |       23                                   Anus (C21) |
 24. |       24                     Lymphoid leukaemia (C91) |
 25. |       25                              Tongue (C01-02) |
     |-------------------------------------------------------|
 26. |       26                                 Larynx (C32) |
 27. |       27                   Myeloid leukaemia (C92-94) |
 28. |       28                            Nasopharynx (C11) |
 29. |       29           Myeloproliferative disorders (MPD) |
 30. |       30              Myelodysplastic syndromes (MDS) |
     |-------------------------------------------------------|
 31. |       31         Connective and soft tissue (C47+C49) |
 32. |       32                       Hodgkin lymphoma (C81) |
 33. |       33                                 Tonsil (C09) |
 34. |       34                               Mouth (C03-06) |
 35. |       35                  Leukaemia unspecified (C95) |
     |-------------------------------------------------------|
 36. |       36                                 Vagina (C52) |
 37. |       37                       Other oropharynx (C10) |
 38. |       38                                 Testis (C62) |
 39. |       39                  Nose, sinuses etc. (C30-31) |
 40. |       40                                Bone (C40-41) |
     |-------------------------------------------------------|
 41. |       41                                  Vulva (C51) |
 42. |       42                      Salivary gland (C07-08) |
 43. |       43                                    Eye (C69) |
 44. |       44            Other female genital organs (C57) |
 45. |       45                   Other urinary organs (C68) |
     |-------------------------------------------------------|
 46. |       46               Other thoracic organs (C37-38) |
 47. |       47                                  Penis (C60) |
 48. |       48                    Pharynx unspecified (C14) |
 49. |       49                                 Ureter (C66) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //29 deleted
save "`datapath'\version02\2-working\siteorder_2015" ,replace
restore


**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2015						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2015
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2015-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             1,035  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** SF requested by email on 16-Oct-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2015
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'\version02\2-working\2015_top10_age+sex_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //0

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  | 1035   285327   362.74    231.95   217.36   247.33     7.57 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site year number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "breast" 4 "colon" 5 "rectum" 6 "corpus uteri" 7 "stomach" ///
							 8 "lung" 9 "multiple myeloma" 10 "non-hodgkin lymphoma" 11 "pancreas" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2015" 2 "2014" 3 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	drop if sex==2 //490 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  545   147779   368.79    228.37   208.29   249.98    10.50 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "breast" 3 "colon" 4 "corpus uteri" 5 "rectum" 6 "multiple myeloma" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** Next, IRs for invasive tumours MALE only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	drop if sex==1 //545 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
 +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  490   137548   356.24    239.16   217.89   262.09    11.13 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "rectum" 5 "lung" 6 "stomach" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==. //0 deleted
	drop if beh!=3 //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(26626) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19111)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18440) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  217   137548   157.76    102.34    88.97   117.34     7.09 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** PROSTATE - for male top5 table
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==. //0 deleted
	drop if beh!=3 //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(26626) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19111)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18440) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  217   137548   157.76    102.34    88.97   117.34     7.09 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore

** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25537) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18761) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  197   147779   133.31     89.54    76.79   103.90     6.78 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** BREAST - for female top5 table
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25537) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18761) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  197   147779   133.31     89.54    76.79   103.90     6.78 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  114   285327   39.95     24.16    19.78    29.32     2.37 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** COLON - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 //9 deleted: for breast cancer - female ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   54   147779   36.54     22.15    16.42    29.44     3.21 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** COLON - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 //9 deleted: for breast cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   60   137548   43.62     27.16    20.58    35.40     3.66 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   47   285327   16.47     10.85     7.84    14.70     1.69 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** RECTUM - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 // for rectal cancer - female ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   147779   17.59     10.27     6.42    15.78     2.29 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** RECTUM - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 // for rectal cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   137548   15.27     11.30     6.93    17.52     2.59 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18761) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18963) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   147779   29.77     18.13    13.07    24.75     2.87 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** CORPUS UTERI - for female top 5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18761) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18963) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   147779   29.77     18.13    13.07    24.75     2.87 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19218) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   36   285327   12.62      6.59     4.53     9.43     1.20 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** STOMACH - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19218) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 // for stomach cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (MALE)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   137548   12.36      7.68     4.41    12.71     2.02 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21585) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   30   285327   10.51      6.63     4.42     9.68     1.29 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** LUNG - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21585) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 // for lung cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   137548   15.27     10.71     6.58    16.66     2.46 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	** M 75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18761) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19111) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18963) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18440) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20315) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19218) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21585) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5564) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   285327    9.81      5.83     3.82     8.65     1.18 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** MULTIPLE MYELOMA - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	** M 75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18761) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19111) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18963) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18440) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20315) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19218) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21585) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5564) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 // for MM - female ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MM CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   147779   14.21      7.66     4.65    12.23     1.84 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** F   85+
	** M   55-64
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(25537) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(26626) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18761) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(19111) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(16493) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3975) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   285327    9.11      6.70     4.27    10.05     1.42 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PANCREAS 
tab pop_wpp age_10  if siteiarc==18 & sex==1 //female
tab pop_wpp age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F   45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25537) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(26626) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18761) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19111) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18963) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18440) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20315) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19218) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21585) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   285327    9.11      4.93     3.17     7.50     1.06 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/* Previously in top 10 before DCO trace-back completed
** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25537) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18761) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18963) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3975) in 9
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   147779   10.83      7.03     3.98    11.75     1.90 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** OVARY - for female top 5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25537) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18761) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18963) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3975) in 9
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   147779   10.83      7.03     3.98    11.75     1.90 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=6 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** KIDNEY 
tab pop_wpp age_10  if siteiarc==42 & sex==1 //female
tab pop_wpp age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,25-34,35-44,85+
	** F   15-24
	** M   45-54
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18761) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(18963) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18440) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(20315) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(19218) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19492) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3975) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   285327    5.61      3.78     2.12     6.33     1.03 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=12 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore
*/
clear


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2014 ****************************************************************************************
drop if dxyr!=2014 //1887 deleted
count //857

** Determine sequential order of 2014 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 // deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5   Lung (incl. trachea and bronchus) (C33-34) |
     |-------------------------------------------------------|
  6. |        6                       Multiple myeloma (C90) |
  7. |        7                              Rectum (C19-20) |
  8. |        8                                Bladder (C67) |
  9. |        9                                Stomach (C16) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11            Non-Hodgkin lymphoma (C82-86,C96) |
 12. |       12                           Cervix uteri (C53) |
 13. |       13                                  Liver (C22) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                  Ovary (C56) |
     |-------------------------------------------------------|
 16. |       16                    Gallbladder etc. (C23-24) |
 17. |       17                                 Kidney (C64) |
 18. |       18                             Oesophagus (C15) |
 19. |       19                       Melanoma of skin (C43) |
 20. |       20                                 Larynx (C32) |
     |-------------------------------------------------------|
 21. |       21         Connective and soft tissue (C47+C49) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23               Brain, nervous system (C70-72) |
 24. |       24                        Small intestine (C17) |
 25. |       25                  Nose, sinuses etc. (C30-31) |
     |-------------------------------------------------------|
 26. |       26                                 Tonsil (C09) |
 27. |       27                   Myeloid leukaemia (C92-94) |
 28. |       28                              Tongue (C01-02) |
 29. |       29                         Hypopharynx (C12-13) |
 30. |       30                       Other oropharynx (C10) |
     |-------------------------------------------------------|
 31. |       31           Myeloproliferative disorders (MPD) |
 32. |       32                       Hodgkin lymphoma (C81) |
 33. |       33                  Leukaemia unspecified (C95) |
 34. |       34                                  Penis (C60) |
 35. |       35                            Nasopharynx (C11) |
     |-------------------------------------------------------|
 36. |       36                                 Testis (C62) |
 37. |       37                                   Anus (C21) |
 38. |       38                           Mesothelioma (C45) |
 39. |       39                               Mouth (C03-06) |
 40. |       40                                 Vagina (C52) |
     |-------------------------------------------------------|
 41. |       41                                Bone (C40-41) |
 42. |       42                                  Vulva (C51) |
 43. |       43                      Salivary gland (C07-08) |
 44. |       44              Myelodysplastic syndromes (MDS) |
 45. |       45           Immunoproliferative diseases (C88) |
     |-------------------------------------------------------|
 46. |       46                        Other endocrine (C75) |
     +-------------------------------------------------------+
*/
drop if order_id>20
save "`datapath'\version02\2-working\siteorder_2014" ,replace
restore


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2014
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //39 deleted
tab siteiarc sex ,m
contract siteiarc sex, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc sex
/*
     +----------------------------------------------------------------+
     | order_id                                     siteiarc      sex |
     |----------------------------------------------------------------|
  1. |        1                               Prostate (C61)     male |
  2. |        2                                 Breast (C50)   female |
  3. |        3                                  Colon (C18)   female |
  4. |        4                                  Colon (C18)     male |
  5. |        5                           Corpus uteri (C54)   female |
     |----------------------------------------------------------------|
  6. |        6   Lung (incl. trachea and bronchus) (C33-34)     male |
  7. |        7                           Cervix uteri (C53)   female |
  8. |        8                       Multiple myeloma (C90)     male |
  9. |        9                                Bladder (C67)     male |
 10. |       10                       Multiple myeloma (C90)   female |
     |----------------------------------------------------------------|
 11. |       11                              Rectum (C19-20)   female |
 12. |       12                                Stomach (C16)     male |
 13. |       13   Lung (incl. trachea and bronchus) (C33-34)   female |
 14. |       14                              Rectum (C19-20)     male |
 15. |       15            Non-Hodgkin lymphoma (C82-86,C96)     male |
     |----------------------------------------------------------------|
 16. |       16                               Pancreas (C25)     male |
 17. |       17                                  Ovary (C56)   female |
 18. |       18                                Bladder (C67)   female |
 19. |       19                                Thyroid (C73)   female |
 20. |       20                               Pancreas (C25)   female |
     |----------------------------------------------------------------|
 21. |       21                                Stomach (C16)   female |
 22. |       22                                  Liver (C22)     male |
 23. |       23                                 Larynx (C32)     male |
 24. |       24                                 Kidney (C64)   female |
 25. |       25                             Oesophagus (C15)     male |
     |----------------------------------------------------------------|
 26. |       26                    Gallbladder etc. (C23-24)     male |
 27. |       27                                  Liver (C22)   female |
 28. |       28                  Nose, sinuses etc. (C30-31)     male |
 29. |       29                       Melanoma of skin (C43)   female |
 30. |       30                       Melanoma of skin (C43)     male |
     |----------------------------------------------------------------|
 31. |       31                                 Tonsil (C09)     male |
 32. |       32         Connective and soft tissue (C47+C49)     male |
 33. |       33                                 Breast (C50)     male |
 34. |       34                     Lymphoid leukaemia (C91)     male |
 35. |       35                                 Kidney (C64)     male |
     |----------------------------------------------------------------|
 36. |       36                    Gallbladder etc. (C23-24)   female |
 37. |       37               Brain, nervous system (C70-72)     male |
 38. |       38                        Small intestine (C17)     male |
 39. |       39                     Lymphoid leukaemia (C91)   female |
 40. |       40                                  Penis (C60)     male |
     |----------------------------------------------------------------|
 41. |       41                       Other oropharynx (C10)     male |
 42. |       42         Connective and soft tissue (C47+C49)   female |
 43. |       43                             Oesophagus (C15)   female |
 44. |       44                         Hypopharynx (C12-13)     male |
 45. |       45                   Myeloid leukaemia (C92-94)   female |
     |----------------------------------------------------------------|
 46. |       46                              Tongue (C01-02)     male |
 47. |       47            Non-Hodgkin lymphoma (C82-86,C96)   female |
 48. |       48                  Leukaemia unspecified (C95)     male |
 49. |       49           Myeloproliferative disorders (MPD)     male |
 50. |       50                       Hodgkin lymphoma (C81)     male |
     |----------------------------------------------------------------|
 51. |       51                           Mesothelioma (C45)     male |
 52. |       52                                Bone (C40-41)     male |
 53. |       53                        Small intestine (C17)   female |
 54. |       54               Brain, nervous system (C70-72)   female |
 55. |       55                   Myeloid leukaemia (C92-94)     male |
     |----------------------------------------------------------------|
 56. |       56                                  Vulva (C51)   female |
 57. |       57                            Nasopharynx (C11)   female |
 58. |       58                                 Vagina (C52)   female |
 59. |       59                                 Testis (C62)     male |
 60. |       60                                 Larynx (C32)   female |
     |----------------------------------------------------------------|
 61. |       61           Myeloproliferative disorders (MPD)   female |
 62. |       62                  Leukaemia unspecified (C95)   female |
 63. |       63                         Hypopharynx (C12-13)   female |
 64. |       64                            Nasopharynx (C11)     male |
 65. |       65              Myelodysplastic syndromes (MDS)     male |
     |----------------------------------------------------------------|
 66. |       66                        Other endocrine (C75)     male |
 67. |       67                      Salivary gland (C07-08)     male |
 68. |       68                                   Anus (C21)   female |
 69. |       69                  Nose, sinuses etc. (C30-31)   female |
 70. |       70           Immunoproliferative diseases (C88)   female |
     |----------------------------------------------------------------|
 71. |       71                                Thyroid (C73)     male |
 72. |       72                                   Anus (C21)     male |
 73. |       73                                 Tonsil (C09)   female |
 74. |       74                               Mouth (C03-06)     male |
 75. |       75                              Tongue (C01-02)   female |
     |----------------------------------------------------------------|
 76. |       76                       Hodgkin lymphoma (C81)   female |
 77. |       77                               Mouth (C03-06)   female |
     +----------------------------------------------------------------+
*/
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
drop percentage order_id
gen year=2014
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version02\2-working\2014_top10_sex" ,replace
restore


**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2014						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2014
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2014-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             1
        from master                         0  (_merge==1)
        from using                          1  (_merge==2)

    matched                               857  (_merge==3)
    -----------------------------------------
*/

** SF requested by email on 16-Oct-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2014
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'\version02\2-working\2014_top10_age+sex_rates" ,replace
restore


** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //1 - missing age_10 from merge as noted below
//list pid cr5id siteiarc if age==.|age==999


** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

//drop if _merge==2 //1 deleted - no, doing so will change population totals
** There is 1 unmatched record (_merge==2) since 2014 data doesn't have any cases of females with age range 15-24
** age_10	site  dup	sex	 	pfu	pop_wpp	_merge
** 15-24	  .     .	female   .	18771	using only (2)
** The above age group will get dropped as the only case with this age group is in-situ


** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** F: 15-24
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_wpp=(18771) in 18
	sort age_10
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  857   284825   300.89    200.87   187.15   215.39     7.13 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=1 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(27062) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19032) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18491) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  176   137169   128.31     87.34    74.75   101.59     6.70 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==29 // breast only 
	drop if sex==2
	//excluded the 4 males as it would be potential confidential breach if reported separately
		
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25929) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18771) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  151   147656   102.26     68.54    57.64    81.03     5.84 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25929) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=1 in 16
	replace case=0 in 16
	replace pop_wpp=(27062) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(18771) in 17
	sort age_10

	expand 2 in 1
	replace sex=2 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_wpp=(19032) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  103   284825   36.16     23.47    19.04    28.71     2.40 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M 35-44,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25929) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(27062) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18771) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19032) in 14
	sort age_10

	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(19088) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18491) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19352) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2483) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   284825    9.13      5.95     3.84     8.91     1.24 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25929) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18771) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(19088) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   37   147656   25.06     15.78    11.03    22.10     2.72 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54,65-74
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25929) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27062) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18771) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19032) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19088) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18491) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20526) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21757) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_wpp=(11723) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      3.87     2.29     6.28     0.97 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44,45-54
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25929) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(27062) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18771) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19032) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19088) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18491) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20526) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19352) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21757) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(19547) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   33   284825   11.59      6.71     4.56     9.68     1.25 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,85+
	** F   35-44
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25929) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27062) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18771) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19032) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19088) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18491) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20526) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3974) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2483) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   284825   10.18      6.69     4.46     9.77     1.30 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,25-34
	** F   15-24,45-54,55-64,65-74,85+
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25929) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27062) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18771) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19088) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18491) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(21757) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_wpp=(18343) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(11723) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3974) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   284825    5.62      3.92     2.17     6.59     1.08 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PANCREAS 
tab pop_wpp age_10  if siteiarc==18 & sex==1 //female
tab pop_wpp age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F   55-64,85+
	** M   45-54
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25929) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(27062) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(18771) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19032) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(19088) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18491) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(20526) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(19352) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19547) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(18343) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3974) in 18
	sort age_10	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      4.12     2.48     6.59     1.00 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/* No longer in top 10 after 2015 DCO trace-back completed
** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 0-14,15-24,35-44,85+
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25929) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18771) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_wpp=(20526) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3974) in 9
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   10   147656    6.77      4.90     2.28     9.35     1.73 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** KIDNEY 
tab pop_wpp age_10  if siteiarc==42 & sex==1 //female
tab pop_wpp age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44,85+
	** F   45-54
	** M   75-84
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25929) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(27062) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18771) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(19032) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=3 in 11
	replace case=0 in 11
	replace pop_wpp=(19088) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(18491) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=4 in 13
	replace case=0 in 13
	replace pop_wpp=(20526) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(19352) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(21757) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=8 in 16
	replace case=0 in 16
	replace pop_wpp=(5431) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3974) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2483) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   10   284825    3.51      2.42     1.16     4.60     0.84 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=12 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore
*/
clear


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear


****************************************************************************** 2013 ****************************************************************************************
drop if dxyr!=2013 //1892 deleted
count //852

** Determine sequential order of 2013 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //37 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Cervix uteri (C53) |
     |-------------------------------------------------------|
  6. |        6                           Corpus uteri (C54) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8            Non-Hodgkin lymphoma (C82-86,C96) |
  9. |        9                                 Kidney (C64) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11                                Stomach (C16) |
 12. |       12                       Multiple myeloma (C90) |
 13. |       13                                Thyroid (C73) |
 14. |       14                   Myeloid leukaemia (C92-94) |
 15. |       15                                  Ovary (C56) |
     |-------------------------------------------------------|
 16. |       16                                Bladder (C67) |
 17. |       17                    Gallbladder etc. (C23-24) |
 18. |       18                                   Anus (C21) |
 19. |       19                                  Liver (C22) |
 20. |       20                             Oesophagus (C15) |
     |-------------------------------------------------------|
 21. |       21                       Hodgkin lymphoma (C81) |
 22. |       22                     Uterus unspecified (C55) |
 23. |       23                     Lymphoid leukaemia (C91) |
 24. |       24                               Mouth (C03-06) |
 25. |       25               Brain, nervous system (C70-72) |
     |-------------------------------------------------------|
 26. |       26                                 Larynx (C32) |
 27. |       27           Myeloproliferative disorders (MPD) |
 28. |       28                        Small intestine (C17) |
 29. |       29                       Other oropharynx (C10) |
 30. |       30                                 Vagina (C52) |
     |-------------------------------------------------------|
 31. |       31                       Melanoma of skin (C43) |
 32. |       32         Connective and soft tissue (C47+C49) |
 33. |       33                              Tongue (C01-02) |
 34. |       34                            Nasopharynx (C11) |
 35. |       35                      Salivary gland (C07-08) |
     |-------------------------------------------------------|
 36. |       36                    Pharynx unspecified (C14) |
 37. |       37                                  Penis (C60) |
 38. |       38            Other female genital organs (C57) |
 39. |       39                  Nose, sinuses etc. (C30-31) |
 40. |       40                  Leukaemia unspecified (C95) |
     |-------------------------------------------------------|
 41. |       41                                 Tonsil (C09) |
 42. |       42               Other thoracic organs (C37-38) |
 43. |       43                                Bone (C40-41) |
 44. |       44                         Hypopharynx (C12-13) |
 45. |       45                                  Vulva (C51) |
     |-------------------------------------------------------|
 46. |       46                           Mesothelioma (C45) |
     +-------------------------------------------------------+
*/
drop if order_id>20
save "`datapath'\version02\2-working\siteorder_2013" ,replace
restore


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2013
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
tab siteiarc sex ,m
contract siteiarc sex, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc sex
/*
     +----------------------------------------------------------------+
     | order_id                                     siteiarc      sex |
     |----------------------------------------------------------------|
  1. |        1                               Prostate (C61)     male |
  2. |        2                                 Breast (C50)   female |
  3. |        3                                  Colon (C18)   female |
  4. |        4                                  Colon (C18)     male |
  5. |        5                           Cervix uteri (C53)   female |
     |----------------------------------------------------------------|
  6. |        6                           Corpus uteri (C54)   female |
  7. |        7                              Rectum (C19-20)     male |
  8. |        8   Lung (incl. trachea and bronchus) (C33-34)     male |
  9. |        9                              Rectum (C19-20)   female |
 10. |       10            Non-Hodgkin lymphoma (C82-86,C96)     male |
     |----------------------------------------------------------------|
 11. |       11                                 Kidney (C64)     male |
 12. |       12                                Stomach (C16)     male |
 13. |       13                               Pancreas (C25)     male |
 14. |       14                                  Ovary (C56)   female |
 15. |       15                                Thyroid (C73)   female |
     |----------------------------------------------------------------|
 16. |       16                       Multiple myeloma (C90)     male |
 17. |       17            Non-Hodgkin lymphoma (C82-86,C96)   female |
 18. |       18                               Pancreas (C25)   female |
 19. |       19                   Myeloid leukaemia (C92-94)   female |
 20. |       20                                 Kidney (C64)   female |
     |----------------------------------------------------------------|
 21. |       21                                Bladder (C67)     male |
 22. |       22   Lung (incl. trachea and bronchus) (C33-34)   female |
 23. |       23                    Gallbladder etc. (C23-24)   female |
 24. |       24                                Stomach (C16)   female |
 25. |       25                               Mouth (C03-06)     male |
     |----------------------------------------------------------------|
 26. |       26                                   Anus (C21)   female |
 27. |       27                     Uterus unspecified (C55)   female |
 28. |       28                                   Anus (C21)     male |
 29. |       29                    Gallbladder etc. (C23-24)     male |
 30. |       30                                 Larynx (C32)     male |
     |----------------------------------------------------------------|
 31. |       31                                  Liver (C22)     male |
 32. |       32                       Multiple myeloma (C90)   female |
 33. |       33                       Hodgkin lymphoma (C81)   female |
 34. |       34                              Tongue (C01-02)     male |
 35. |       35                                Bladder (C67)   female |
     |----------------------------------------------------------------|
 36. |       36                       Other oropharynx (C10)     male |
 37. |       37                                Thyroid (C73)     male |
 38. |       38                             Oesophagus (C15)     male |
 39. |       39                                 Breast (C50)     male |
 40. |       40                             Oesophagus (C15)   female |
     |----------------------------------------------------------------|
 41. |       41                     Lymphoid leukaemia (C91)   female |
 42. |       42                                 Vagina (C52)   female |
 43. |       43                   Myeloid leukaemia (C92-94)     male |
 44. |       44               Brain, nervous system (C70-72)   female |
 45. |       45                                  Liver (C22)   female |
     |----------------------------------------------------------------|
 46. |       46            Other female genital organs (C57)   female |
 47. |       47           Myeloproliferative disorders (MPD)     male |
 48. |       48                                  Penis (C60)     male |
 49. |       49                    Pharynx unspecified (C14)     male |
 50. |       50         Connective and soft tissue (C47+C49)     male |
     |----------------------------------------------------------------|
 51. |       51                            Nasopharynx (C11)     male |
 52. |       52               Brain, nervous system (C70-72)     male |
 53. |       53                       Hodgkin lymphoma (C81)     male |
 54. |       54                     Lymphoid leukaemia (C91)     male |
 55. |       55                       Melanoma of skin (C43)     male |
     |----------------------------------------------------------------|
 56. |       56           Myeloproliferative disorders (MPD)   female |
 57. |       57                        Small intestine (C17)   female |
 58. |       58                       Melanoma of skin (C43)   female |
 59. |       59                      Salivary gland (C07-08)     male |
 60. |       60                  Leukaemia unspecified (C95)   female |
     |----------------------------------------------------------------|
 61. |       61                                Bone (C40-41)     male |
 62. |       62               Other thoracic organs (C37-38)     male |
 63. |       63                  Leukaemia unspecified (C95)     male |
 64. |       64                      Salivary gland (C07-08)   female |
 65. |       65                         Hypopharynx (C12-13)   female |
     |----------------------------------------------------------------|
 66. |       66                                 Tonsil (C09)     male |
 67. |       67                           Mesothelioma (C45)     male |
 68. |       68                  Nose, sinuses etc. (C30-31)   female |
 69. |       69         Connective and soft tissue (C47+C49)   female |
 70. |       70                  Nose, sinuses etc. (C30-31)     male |
     |----------------------------------------------------------------|
 71. |       71                        Small intestine (C17)     male |
 72. |       72                                  Vulva (C51)   female |
     +----------------------------------------------------------------+
*/
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
drop percentage order_id
gen year=2013
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version02\2-working\2013_top10_sex" ,replace
restore


**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2013						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2013
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2013-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               852  (_merge==3)
    -----------------------------------------
*/
** None unmatched

** SF requested by email on 16-Oct-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2013
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'\version02\2-working\2013_top10_age+sex_rates" ,replace
restore


** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //0

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male



** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  852   284294   299.69    203.76   189.86   218.46     7.22 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=1 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(27452) in 6
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18950) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18555) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19473) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  176   136769   128.68     89.97    77.03   104.62     6.89 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==29 // breast only 
	drop if sex==2
	//excluded the 3 males as it would be potential confidential breach if reported separately
		
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(26307) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18763) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  134   147525   90.83     61.58    51.13    73.66     5.62 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18950) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(19213) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18555) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  109   284294   38.34     24.25    19.79    29.51     2.41 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** F   25-34,35-44
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18950) in 16
	sort age_10

	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(19213) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(20732) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   284294   15.48     10.12     7.26    13.81     1.61 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44,85+
	expand 2 in 1
	replace sex=1 in 5
	replace age_10=1 in 5
	replace case=0 in 5
	replace pop_wpp=(26307) in 5
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=2 in 6
	replace case=0 in 6
	replace pop_wpp=(18763) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=3 in 7
	replace case=0 in 7
	replace pop_wpp=(19213) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_wpp=(20732) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3942) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   31   147525   21.01     13.82     9.35    19.90     2.59 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,45-54,85+
	** F   35-44
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(26307) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(27452) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(18763) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18950) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(19213) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18555) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(20732) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(21938) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19611) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3942) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2466) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   284294    5.98      3.97     2.29     6.51     1.03 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	** F   85+
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26307) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27452) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18763) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18950) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19213) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18555) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20732) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19473) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3942) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   284294    9.85      6.50     4.29     9.54     1.29 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F   55-64,75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(26307) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(27452) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18763) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18950) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19213) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18555) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20732) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19473) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(17777) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(7493) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   284294    5.28      3.46     1.90     5.91     0.98 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14
	** F   15-24,35-44,45-54
	** M   25-34
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18555) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20732) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21938) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   24   284294    8.44      6.12     3.81     9.36     1.36 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PANCREAS 
tab pop_wpp age_10  if siteiarc==18 & sex==1 //female
tab pop_wpp age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18950) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(19213) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18555) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   284294    7.74      5.05     3.11     7.85     1.16 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/* No longer in top 10 after 2015 DCO trace-back completed
** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 15-24,45-54
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18763) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=5 in 9
	replace case=0 in 9
	replace pop_wpp=(21938) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   12   147525    8.13      6.51     3.16    11.84     2.13 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** KIDNEY 
tab pop_wpp age_10  if siteiarc==42 & sex==1 //female
tab pop_wpp age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 15-24,25-34,85+
	** F   45-54
	** M   0-14
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27452) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18763) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18950) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19213) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18555) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(21938) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3942) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2466) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   284294    7.39      5.38     3.27     8.40     1.26 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=12 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore
*/
clear