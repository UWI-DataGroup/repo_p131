** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          IARCHub_2020.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      26-OCT-2020
    // 	date last modified      27-OCT-2020
    //  algorithm task          Preparing 2008, 2013-2015 cancer dataset for quality assessment by IARC Hub per data use/sharing agreement
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013, 2014 data for export to IARC Hub via Sync link.
    //  methods                 Use 2008, 2013-2015 dataset + 5-yr age group WPP population from p117 v02

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
    log using "`logpath'\IARCHub_2020.smcl", replace
** HEADER -----------------------------------------------------

** LOAD cancer incidence dataset
use "`datapath'\version06\1-input\2008_2013_2014_2015_iarchub_nonsurvival" ,clear
