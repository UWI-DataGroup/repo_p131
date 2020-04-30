***************************************************************
********************** AC3 Data request **************** 
** This version01 (weeks01-52) prepared by NS
** 

 *************************************************************************
 *     	G A C D R C         A N A L Y S I S         C O D E
 *                                                              
 *     	DO FILE: Data request AC3
 *
 *  	AUTHOR : Natasha Sobers
 *
 *		LAST UPDATE: Apr 30, 2020
 *
 *    	ANALYSIS: AC3 Head and neck grant/paper 
 *
 *    	 PRODUCT: STATA SE Version 16.1
 *
 *      DATA: Datasets provided by JCampbell 
 *            2008_2013_2014_2015_cancer_nonsurvival.dta" 
 *            (2008 2013 2014 2015 BNR-Cancer analysed data - 
 *            Non-survival Reportable Dataset
 *		*          
 *     DETAILS: Updated by JCampbell to include histology codes,
 *				as requested by NSobers
 *			   
 *************************************************************************
 
    ** General algorithm set-up
    version 16.1
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
    log using "`logpath'\AC3HN_JC.smcl", replace
** HEADER -----------------------------------------------------


** Load the dataset  
use "`datapath'\version04\1-input\2008_2013_2014_2015_cancer_nonsurvival" 

count //3335

***This was used to determine the numbers used to represent each site
**label list siteiarc_lab


gen hdnk = 0 

#delimit ;

replace hdnk = 1 if siteiarc == 1 | siteiarc == 2 | siteiarc == 3 |
          siteiarc == 4 | siteiarc == 5| siteiarc ==6 | siteiarc == 7 |
          siteiarc == 8 | siteiarc == 9 | siteiarc == 19 | siteiarc == 20

;
#delimit cr

***Checking that the above variable was created correctly
**list hdnk if siteiarc == 19

list dot dob age sex siteicd icd10 siteiarc hx if hdnk == 1

outsheet dot dob age sex icd10 siteiarc hx if hdnk == 1 using "`datapath'\version04\2-working\hdnk.csv", comma replace

outsheet dot dob age sex morph icd10 siteiarc hx if hdnk == 1 using "`datapath'\version04\2-working\hdnk_morph.csv", comma replace
