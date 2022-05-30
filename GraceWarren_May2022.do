** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          GraceWarren_May2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      30-MAY-2022
    // 	date last modified      30-MAY-2022
    //  algorithm task          Preparing 2008,2013-2015 cancer incidence dataset
    //  status                  Completed
    //  objective               To have one dataset limited to specific variables with 2008, 2013-2015 all cancers
    //  methods                 Format and save dataset using the 2008,2013-2015 cleaned and reportable dataset from 2015 annual report process

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
    log using "`logpath'\GraceWarren_May2022.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'\version12\1-input\2008_2013_2014_2015_iarchub_nonsurvival_reportable" ,clear

** Limit dataset to the variables needed for this request
keep siteiarc age sex dob dlc slc dot dxyr icd10

** Create dataset 
save "`datapath'\version12\3-output\2008_2013-2015_cancer_nonsurvival_reportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report and for Grace Warren's data request
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs