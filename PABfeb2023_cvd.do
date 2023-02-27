
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          PABfeb2023_cvd.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-FEB-2023
    // 	date last modified      27-FEB-2023
    //  algorithm task          Providing CVD 2021 statistics to NSobers for the BNR PAB meeting (28feb2023)
    //  status                  Completed
    //  objective               To have documents with preliminary cleaned and grouped data for inclusion in PAB presentation:
	//							- number of stroke cases for 2021 by month and sex
	//							- number of heart cases for 2021 by month and sex
    //  methods                 Using:
	//							- Complications dataset from 2021 Annual Report cleaning as the data was cleaned 
	//							  up to this point when this data request was made. 
	//							- Stata user-written commands asdoc and bysort for the outputs.

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
    log using "`logpath'/PABfeb2023_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned complications form dataset
use "X:/The University of the West Indies/DataGroup - repo_data/data_p116\version03\2-working\BNRCVDCORE_CleanedData_comp" ,clear

gen event_month=month(edate)
label define event_month_lab 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values event_month event_month_lab
label var event_month "Month of Event"
bysort event_month :tab sd_etype if sex==1 //F
bysort event_month :tab sd_etype if sex==2 //M
bysort event_month :tab sd_casetype if sex==1 & sd_etype==1 //F stroke
bysort event_month :tab sd_casetype if sex==2 & sd_etype==1 //M stroke
bysort event_month :tab sd_casetype if sex==1 & sd_etype==2 //F heart
bysort event_month :tab sd_casetype if sex==2 & sd_etype==2 //M heart

local listdate = string( d(`c(current_date)'), "%dCYND" )
asdoc bysort event_month :tab sex if sd_etype==1, save(X:/The University of the West Indies/DataGroup - repo_data/data_p131/version18/3-output/Counts_bymonth+sex_STROKE_`listdate', replace
asdoc bysort event_month :tab sex if sd_etype==2, save(X:/The University of the West Indies/DataGroup - repo_data/data_p131/version18/3-output/Counts_bymonth+sex_HEART_`listdate', replace


tab sex if sd_etype==1 //stroke
tab sex if sd_etype==2 //heart
//the above totals were added manually to the documents generated above