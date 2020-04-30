** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          RGill_colorectal.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      21-NOV-2019
    //  date last modified      21-NOV-2019
    //  algorithm task          Generate Incidence Rates by (IARC) site: colon and rectum
    //  status                  Completed
    //  objectve                To have one dataset with 2013 and 2014 data for request made by Dr Raymond Gill.

    ** DO FILE BASED ON
    * AMC Rose code for BNR Cancer 2008 annual report

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
    log using "`logpath'\RGill_colorectal.smcl", replace
** HEADER -----------------------------------------------------

**********
** 2013 **
**********
** Load the dataset
use "`datapath'\version02\1-input\2013_cancer_sites_da_v01", clear
drop pfu

tab staging ,m  
tab staging siteiarc if siteiarc>12 & siteiarc<15 //colorectal
/*
                      |   IARC CI5-XI sites
              Staging | Colon (C1  Rectum (C |     Total
----------------------+----------------------+----------
       Localised only |        27         10 |        37 
Regional: direct ext. |        17          9 |        26 
   Regional: LNs only |         9          1 |        10 
Regional: both dir. e |        15          8 |        23 
  Distant site(s)/LNs |        25         10 |        35 
    Unknown; DCO case |        14          6 |        20 
----------------------+----------------------+----------
                Total |       107         44 |       151 
*/
tab sex ,m
**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
***********************************************************
/*
** First, recode sex to match with the IR data
tab sex ,m
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label drop sex_lab
label define sex_lab 1 "female" 2 "male"
label values sex sex_lab
tab sex ,m
*/

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS
********************************************************************
** Using WHO World Standard Population
tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version02\1-input\bb2010_10-2"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               845  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

tab pop age_10  if sex==1 //female
tab pop age_10  if sex==2 //male

** COLON - stage 4 only
tab pop age_10  if siteiarc==13 & sex==1 & staging==7 //female
tab pop age_10  if siteiarc==13 & sex==2 & staging==7 //male

preserve
    drop if age_10==.
    drop if beh!=3 //9 deleted
    keep if siteiarc==13 & staging==7
    
    collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
    sort age sex
    ** now we have to add in the cases and popns for the missings: 
    ** M&F 0-14,15-24,25-34
    ** F 85+
    
    expand 2 in 1
    replace sex=1 in 12
    replace age_10=1 in 12
    replace case=0 in 12
    replace pop_bb=(26755) in 12
    sort age_10
    
    expand 2 in 1
    replace sex=2 in 13
    replace age_10=1 in 13
    replace case=0 in 13
    replace pop_bb=(28005) in 13
    sort age_10
    
    expand 2 in 1
    replace sex=1 in 14
    replace age_10=2 in 14
    replace case=0 in 14
    replace pop_bb=(18530) in 14
    sort age_10

    expand 2 in 1
    replace sex=2 in 15
    replace age_10=2 in 15
    replace case=0 in 15
    replace pop_bb=(18510) in 15
    sort age_10
    
    expand 2 in 1
    replace sex=1 in 16
    replace age_10=3 in 16
    replace case=0 in 16
    replace pop_bb=(19410) in 16
    sort age_10
    
    expand 2 in 1
    replace sex=2 in 17
    replace age_10=3 in 17
    replace case=0 in 17
    replace pop_bb=(18465) in 17
    sort age_10
    
    expand 2 in 1
    replace sex=2 in 18
    replace age_10=9 in 18
    replace case=0 in 18
    replace pop_bb=(1666) in 18
    sort age_10
    
    ** -distrate is a user written command.
    ** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version02\1-input\who2000_10-2",     /// 
                 stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F: STAGE 4)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   277814    9.00      6.47     4.15     9.70     1.36 |
  +------------------------------------------------------------+
*/
restore

** RECTUM - stage 4 only
tab pop age_10  if siteiarc==14 & sex==1 & staging==7 //female
tab pop age_10  if siteiarc==14 & sex==2 & staging==7 //male

preserve
    drop if age_10==.
    drop if beh!=3 //9 deleted
    keep if siteiarc==14 & staging==7
    
    collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
    sort age sex
    ** now we have to add in the cases and popns for the missings:
    ** M&F 0-14,15-24,35-44,85+
    ** M 25-34,45-54,
    expand 2 in 1
    replace sex=1 in 9
    replace age_10=1 in 9
    replace case=0 in 9
    replace pop_bb=(26755) in 9
    sort age_10
    
    expand 2 in 1
    replace sex=2 in 10
    replace age_10=1 in 10
    replace case=0 in 10
    replace pop_bb=(28005) in 10
    sort age_10
    
    expand 2 in 1
    replace sex=1 in 11
    replace age_10=2 in 11
    replace case=0 in 11
    replace pop_bb=(18530) in 11
    sort age_10

    expand 2 in 1
    replace sex=2 in 12
    replace age_10=2 in 12
    replace case=0 in 12
    replace pop_bb=(18510) in 12
    sort age_10
    
    expand 2 in 1
    replace sex=1 in 13
    replace age_10=3 in 13
    replace case=0 in 13
    replace pop_bb=(19410) in 13
    sort age_10
    
    expand 2 in 1
    replace sex=1 in 14
    replace age_10=4 in 14
    replace case=0 in 14
    replace pop_bb=(21080) in 14
    sort age_10
    
    expand 2 in 1
    replace sex=2 in 15
    replace age_10=4 in 15
    replace case=0 in 15
    replace pop_bb=(19550) in 15
    sort age_10
    
    expand 2 in 1
    replace sex=1 in 16
    replace age_10=5 in 16
    replace case=0 in 16
    replace pop_bb=(21945) in 16
    sort age_10
    
    expand 2 in 1
    replace sex=1 in 17
    replace age_10=9 in 17
    replace case=0 in 17
    replace pop_bb=(3388) in 17
    sort age_10
    
    expand 2 in 1
    replace sex=2 in 18
    replace age_10=9 in 18
    replace case=0 in 18
    replace pop_bb=(1666) in 18
    sort age_10
    
    ** -distrate is a user written command.
    ** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version02\1-input\who2000_10-2",     /// 
                 stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F: STAGE 4)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   10   277814    3.60      2.73     1.29     5.15     0.94 |
  +------------------------------------------------------------+
*/
restore

** Save this new dataset without population data
label data "2013 BNR-Cancer analysed data - Sites"
note: TS This dataset includes population data 
save "`datapath'\version02\2-working\2013_cancer_rgill", replace

clear

**************
** SURVIVAL **
* COLORECTAL *
**************
** Load the dataset
use "`datapath'\version02\1-input\2013_1yr_survival_da_v01", clear

** 1-YEAR **

** COLON
tab deceased if siteiarc==13
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         67       63.21       63.21
                 dead |         39       36.79      100.00
----------------------+-----------------------------------
                Total |        106      100.00
*/
tab deceased if siteiarc==13 & staging==7
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |          9       36.00       36.00
                 dead |         16       64.00      100.00
----------------------+-----------------------------------
                Total |         25      100.00
*/

** RECTUM
tab deceased if siteiarc==14
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         28       63.64       63.64
                 dead |         16       36.36      100.00
----------------------+-----------------------------------
                Total |         44      100.00
*/
tab deceased if siteiarc==14 & staging==7
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |          3       30.00       30.00
                 dead |          7       70.00      100.00
----------------------+-----------------------------------
                Total |         10      100.00
*/

clear 

** Load the dataset
use "`datapath'\version02\1-input\2013_3yr_survival_da_v01", clear

** 3-YEAR **
** COLON
tab deceased if siteiarc==13
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         46       43.40       43.40
                 dead |         60       56.60      100.00
----------------------+-----------------------------------
                Total |        106      100.00
*/
tab deceased if siteiarc==13 & staging==7
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |          3       12.00       12.00
                 dead |         22       88.00      100.00
----------------------+-----------------------------------
                Total |         25      100.00
*/
** RECTUM
tab deceased if siteiarc==14
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         15       34.09       34.09
                 dead |         29       65.91      100.00
----------------------+-----------------------------------
                Total |         44      100.00
*/
tab deceased if siteiarc==14 & staging==7
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |          1       10.00       10.00
                 dead |          9       90.00      100.00
----------------------+-----------------------------------
                Total |         10      100.00
*/
clear 

** Load the dataset
use "`datapath'\version02\1-input\2014_1yr_survival_da", clear

** 1-YEAR **
** COLON
tab deceased if siteiarc==13
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         63       56.76       56.76
                 dead |         48       43.24      100.00
----------------------+-----------------------------------
                Total |        111      100.00
*/
** RECTUM
tab deceased if siteiarc==14
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         16       57.14       57.14
                 dead |         12       42.86      100.00
----------------------+-----------------------------------
                Total |         28      100.00
*/
clear 

** Load the dataset
use "`datapath'\version02\1-input\2014_3yr_survival_da", clear

** 3-YEAR **
** COLON
tab deceased if siteiarc==13
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         44       39.64       39.64
                 dead |         67       60.36      100.00
----------------------+-----------------------------------
                Total |        111      100.00
*/
** RECTUM
tab deceased if siteiarc==14
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |          9       32.14       32.14
                 dead |         19       67.86      100.00
----------------------+-----------------------------------
                Total |         28      100.00
*/
