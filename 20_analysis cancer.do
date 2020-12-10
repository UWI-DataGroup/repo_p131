
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20_analysis cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      10-DEC-2020
    // 	date last modified      10-DEC-2020
    //  algorithm task          Producing: (1) Numbers (2) ASIRs for 2015 ONLY as indicated by NS via phone call
    //  status                  Completed
    //  objective               For Prof Prussia to use in letter to editor for NEJM review article.
    //  methods                 See MS Word output for detailed methods of each statistic

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
    log using "`logpath'/20_analysis cancer_pp.smcl", replace
** HEADER -----------------------------------------------------


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version07\1-input\2013_2014_2015_cancer_numbers", clear

/*
** Create table of histologies for corpus uteri
gen hist=morph
label define hist_lab 8000 "Neoplasm, malignant" 8010 "Carcinoma, NOS" 8070 "Squamous cell carcinoma" 8140 "Adenocarcinoma" ///
                      8262 "Villous adenocarcinoma" 8310 "Clear cell adenocarcinoma" 8380 "Endometrioid adenocarcinoma" ///
                      8441 "Serous cystadenocarcinoma" 8460 "Papillary serous cystadenocarcinoma" 8480 "Mucinous adenocarcinoma" ///
                      8890 "Leiomyosarcoma" 8930 "Endometrial stromal sarcoma" 8950 "Mullerian mixed tumour" ,modify
label values hist hist_lab
*/

****************************************************************************** 2015 ****************************************************************************************
drop if dxyr!=2015 //1709 deleted

count //1035


**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2015						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2015
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version07\1-input\pop_wpp_2015-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             1,035  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** CORPUS UTERI
/*
    This includes the below ICD-O-3 topography/site codes:
    C54.0 - Isthmus uteri
    C54.1 - Endometrium
    C54.2 - Myometrium
    C54.3 - Fundus uteri
    C54.8 - Overlapping lesion of the corpus uteri
    C54.9 - Corpus uteri/body of corpus
*/

** Create table of histologies for corpus uteri
/*
tab morph hist if siteiarc==33

preserve
keep if siteiarc==33 //38 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*

*/
drop if order_id>20 //29 deleted
save "`datapath'\version02\2-working\siteorder_2015" ,replace
restore
*/

** Create table of ASIRs for corpus uteri
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18761) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18963) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version07\1-input\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   147779   29.77     18.13    13.07    24.75     2.87 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
//gen year=2015
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1035*100
replace percent=round(percent,0.01)

//label define year_lab 1 "2008" 2 "2013" 3 "2014" 4 "2015" ,modify
//label values year year_lab

//append using "`datapath'\version07\2-working\ASIRs" 
//replace year=2015 if year==.
order number percent asir ci_lower ci_upper
sort number
save "`datapath'\version07\2-working\ASIRs" ,replace
restore


** Output for above ASIRs
preserve
use "`datapath'\version07\2-working\ASIRs", clear
format asir %04.2f
sort number

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *   ASIRs - CORPUS UTERI   *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs"), bold
putdocx paragraph, halign(center)
putdocx text ("Corpus Uteri for 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) Corpus uteri: Includes the below ICD-O-3 topography codes
putdocx textblock end
putdocx textblock begin
    C54.0 - Isthmus uteri
putdocx textblock end
putdocx textblock begin
    C54.1 - Endometrium
putdocx textblock end
putdocx textblock begin
    C54.2 - Myometrium
putdocx textblock end
putdocx textblock begin
    C54.3 - Fundus uteri
putdocx textblock end
putdocx textblock begin
    C54.8 - Overlapping lesion of the corpus uteri
putdocx textblock end
putdocx textblock begin
    C54.9 - Corpus uteri/body of corpus
putdocx textblock end
putdocx textblock begin
(2) ASIR by sex: Includes standardized case definition, i.e. includes unk residents, IARC non-reportable MPs but excludes non-malignant tumours; unk/missing ages were included in the median age group; stata command distrate used with pop_wpp_2015-10 for 2015 cancer incidence, ONLY, and world population dataset: who2000_10-2; (population datasets used: "`datapath'\version07\1-input\pop_wpp_2015-10"; cancer dataset used: "`datapath'\version07\1-input\2013_2014_2015_cancer_numbers")
putdocx textblock end
putdocx table tbl1 = data(number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx save "`datapath'\version07\3-output\2020-12-10_corpus uteri_stats.docx", replace
putdocx clear
restore

clear

