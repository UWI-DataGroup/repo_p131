** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    1b_deaths_2014.do
    //  project:				        BNR
    //  analysts:				       	Jacqueline CAMPBELL
    //  date first created      12-FEB-2019
    // 	date last modified	    12-FEB-2019
    //  algorithm task			    Creating 'previously-matched' dataset
    //  status                  Completed
    //  objectve                To check and update any variables needed for survival analysis


    ** General algorithm set-up
    version 15
    clear all
    macro drop _all
    set more off
    set linesize 80

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
    log using "`logpath'\2014_cancer_deaths.smcl", replace
** HEADER -----------------------------------------------------



**************************
**   2014 CANCER DATA   **
** 2013-2017 DEATH DATA **
**************************
** Load the 2014 cancer dataset - note this dataset was already matched to 2013-2017 death data so just running some checks
use "`datapath'\version01\1-input\2014_cancer_sites_da.dta", clear

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

count if dlc==. //3
list pid fname lname deceased dod if dlc==.
replace dlc=dod if dlc==. //3 changes

count //927

** Save final 2014 cancer dataset to be used in cancer survival analysis
save "`datapath'\version01\3-output\datarequest_NAACCR-IACR_matched_2014.dta", replace
label data "2014 cancer and 2013-2017 deaths matched - NAACCR-IACR 2019 Submission"
