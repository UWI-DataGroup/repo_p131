** Stata version control
version 15.1

** Initialising the STATA log and allow automatic page scrolling
capture {
        program drop _all
	drop _all
	log close
	}

** Direct Stata to your do file folder using the -cd- command
cd "L:\BNR_data\DM\data_requests\2019\cancer\versions\NAACCR-IACR\"

** Begin a Stata logfile
log using "logfiles\naaccr-iacr_2014_2019.smcl", replace

** Automatic page scrolling of output
set more off

 ******************************************************************************
 *
 *	GA-C D R C      A N A L Y S I S         C O D E
 *                                                              
 *  DO FILE: 		1b_cancer_deaths_2014
 *					Dofile 1b: Death Data Matching
 *
 *	STATUS:			Completed
 *
 *  FIRST RUN: 		12feb2019
 *
 *	LAST RUN:		12feb2019
 *
 *  ANALYSIS: 		Matching 2008 cancer dataset with 2013-2017 death dataset
 *					JC uses for basis of survival code for abstract submission
 *					to NAACCR-IACR joint conference: deadline 15feb2019
 *
 *	OBJECTIVE:		To have one dataset with matched 'alive' cancer cases 
 *					with death info if they died. Steps for achieving objective:
 *					(1) Check for duplicates by name in merged cancer and deaths
 *					(2) If true duplicate but case didn't merge, check for 
 *						differences in lname, fname, sex, dod fields
 *					(3) Correct differences identified above so records will merge
 *					(4) After corrections complete, merge datasets again
 *
 * 	VERSION: 		version01
 *
 *  CODERS:			J Campbell/Stephanie Whiteman
 *     
 *  SUPPORT: 		Natasha Sobers/Ian R Hambleton
 *
 ******************************************************************************

	 
**************************
**   2014 CANCER DATA   **
** 2013-2017 DEATH DATA **
**************************
** Load the 2014 cancer dataset - note this dataset was already matched to 2013-2017 death data so just running some checks
use "data\raw\2014_cancer_sites_da.dta", clear

count //927

count if pid=="" & eid!="" //0
count if cod1a=="" & (cr5cod!="99" & cr5cod!="") //4
replace cod1a=cr5cod if cod1a=="" & (cr5cod!="99" & cr5cod!="") //4 changes


order pid deathid primarysite cod1a fname lname dod

** Updated cod field based on primarysite/hx vs cod1a
count if slc==2 & cod==. //0
count if deceased==1 & cod==. //0

** Check for DCOs to ensure dot=dod
count if basis==0 & dot!=dod //0
count if slc==2 & dod==. //0
count if patient==. //0
count if deceased==1 & dod==. //0

count //927

** Save final 2014 cancer dataset to be used in cancer survival analysis
save "data\clean\datarequest_NAACCR-IACR_matched_2014.dta", replace
label data "2014 cancer and 2013-2017 deaths matched - NAACCR-IACR 2019 Submission"
