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
 *		LAST UPDATE: Feb 21, 2020
 *
 *    	ANALYSIS: AC3 Head and neck grant/paper 
 *
 *    	 PRODUCT: STATA SE Version 15
 *
 *      DATA: Datasets provided by JCampbell 
 *            2008_2013_2014_2015_cancer_nonsurvival.dta" 
 *            (2008 2013 2014 2015 BNR-Cancer analysed data - 
 *            Non-survival Reportable Dataset
 *		*          
 *     DETAILS: 
 *			   
 *************************************************************************
 
 ** Stata version control
version 15

** Initialising the STATA log and allow automatic page scrolling
capture {
        program drop _all
	drop _all
	log close
	}

** Direct Stata to your dofile folder using the -cd- command
cd "X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\"

** Begin a Stata logfile
log using "X:\Dropbox\BNR\Data requests\AC3HN.smcl", replace

** Automatic page scrolling of output
set more off


** Load the dataset  
use "2-working\2008_2013_2014_2015_cancer_nonsurvival.dta" 

count

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

outsheet dot dob age sex icd10 siteiarc hx if hdnk == 1 using 2-working\hdnk.csv, comma replace
