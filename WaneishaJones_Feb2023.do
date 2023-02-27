** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          WaneishaJones_Feb2023.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-FEB-2023
    // 	date last modified      27-FEB-2023
    //  algorithm task          Preparing 2016-2018 CLEANED cancer incidence dataset
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
    log using "`logpath'\WaneishaJones_Feb2023.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'\version19\1-input\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear
count //6682

tab resident ,m
drop if resident==9 //0 deleted

tab beh ,m
drop if beh!=3 //0 in-situ deleted

tab sex ,m
tab recstatus ,m

//rename ICD10 icd10

** Limit dataset to the variables needed for this request
keep pid cr5id eidmp age sex slc dlc dod dodyear dot dxyr beh basis topography morph siteiarc icd10 cod dd_coddeath
order pid cr5id eidmp age sex slc dlc dod dodyear dot dxyr beh basis topography morph siteiarc icd10 cod dd_coddeath

count //6682

** JC 27feb2023: via WhatsApp NS confirmed years requested should be 2008, 2013-2018 and NOT 2008, 2013-2015 as noted on data request form; Also NS confirmed COD variables that were required.

** Create dataset 
save "`datapath'\version19\3-output\2008_2013-2018_nonsurvival_cancer", replace
label data "2008, 2013-2018 BNR-Cancer prepared data - Non-survival BNR Cleaned Dataset"
note: TS This dataset was used for Waneisha Jones' data request
note: TS excludes ineligible case definition and non-residents, unk sex, includes non-malignant tumours