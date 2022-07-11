** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          GraceWarren_July2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      07-JUL-2022
    // 	date last modified      07-JUL-2022
    //  algorithm task          Preparing 2016-2018 UNCLEANED cancer incidence dataset
    //  status                  Completed
    //  objective               To have one dataset limited to specific variables with 2016-2018 all cancers
    //  methods                 Format and save dataset using the 2016-2018 prepared dataset from 2016-2018 annual report process

    ** General algorithm set-up
    version 17.0
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
    log using "`logpath'\GraceWarren_July2022.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'\version12\2-working\2016-2018_prepped cancer" ,clear
count //6862

** Remove duplicates and ineligibles
tab recstatus ,m
drop if recstatus==2|recstatus==3|recstatus==4|recstatus==5 //689 deleted
replace recstatus=1 if pid=="20172090" & regexm(cr5id,"T1")
replace checkstatus=1 if pid=="20172090" & regexm(cr5id,"T1")

tab resident ,m
drop if resident==9 //10 deleted

tab beh ,m
drop if beh!=3 //106 in-situ deleted

tab sex ,m
tab recstatus ,m

rename ICD10 icd10

** Limit dataset to the variables needed for this request
keep topography morph age sex dob dlc slc dot dxyr icd10

count //6057

** Create dataset 
save "`datapath'\version12\3-output\2016-2018_cancer_uncleaned", replace
label data "2016 2017 2018 BNR-Cancer prepared data - Non-survival BNR Uncleaned Dataset"
note: TS This dataset was used for 2016-2018 annual report and for Grace Warren's data request
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours