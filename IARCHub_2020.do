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

count //4059

** Per data use agreement, prep the cancer dataset
** Note: the population datasets were manually copied and pasted into excel workbook from the Stata Data Editor (Browse)
/*
Data Elements: Incidence data as individual anonymized case listings including all malignant tumours and non-malignant tumours (except benign tumours) of the bladder, collected for the period 2008 and 2013-2015. Each record should contain at least the following variables:
1.	Registration number that uniquely identifies each case but which cannot be used to identify patients
2.	CanReg5 record ID (8 digits) 
3.	Sex
4.	Ethnic group or race (optional)
5.	Birth date and/or age at incidence date
6.	Incidence date
7.	Date of diagnosis
8.	Tumour site (topography)
9.	Tumour morphology
10.	Tumour behaviour
11.	Grade
12.	Most valid basis of diagnosis.

Descriptions of the codes used for each variable are also required.

Population data by 5-year age group and gender for all years of reported incidence data are also required.

Time Period: 2008, 2013-2015

File Format: Microsoft Excel
*/

** Removing cases not included for reporting
drop if resident==2 //4 deleted - nonresident
drop if resident==99 //59 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //150 deleted - nonmalignant
drop if persearch>2 //64 deleted
//drop if siteiarc==25 //0 - nonreportable skin cancerscount

count //3782

** Create registration number that is a combination of pid + cr5id
sort pid
duplicates tag pid, gen(dup_id)
count if dup_id>0 //159
list pid cr5id patient eidmp persearch if dup_id>0, nolabel sepby(pid)


//Include below notes in data dictionary or some methods output
** Note 1: non-malignant tumours of the bladder were not included in the BNR case definition; the only non-malignant tumours collected were for the cervix
** Note 2: basal and squamous cell carcinomas of skin, non-genital sites were included in the BNR case definition for 2008 only
** Note 3: ethnic group or race not collected for any of the years
** Note 4: grade only collected for 2015 diagnoses

** Remove variables not needed for this dataset
keep pid cr5id sex dob age dot topography morph beh grade basis eidmp

** Prep and format variables
gen regnum=pid + "01" if eidmp==1 //3699
replace regnum=pid + "02" if regnum=="" //83 changes
label var regnum "Registration Number"

label var pid "CanReg5 Record ID"
label var sex "Sex"
label var dob "Birth Date"
label var age "Age at incidence"
label var dot "Incidence Date"
label var topography "Tumour Site"
label var morph "Tumour Morphology"
label var beh "Tumour Behaviour"
label var basis "Basis of Diagnosis"

** Remove variables not needed for this export
drop cr5id eidmp

** Create data dictionary
export excel using "`datapath'\version06\3-output\2008_2013_2014_2015_iarchub_variables.xlsx", sheet("data") first(variables) nolabel replace
export excel using "`datapath'\version06\3-output\2008_2013_2014_2015_iarchub_labels.xlsx", sheet("data") first(varlabels) replace

** Save coded labels and above notes into a Word document
preserve
cls
describe
translate @Results "`datapath'\version06\3-output\describe.txt" ,replace
restore

preserve
cls
label list sex_lab
translate @Results "`datapath'\version06\3-output\sex.txt" ,replace
restore

preserve
cls
label list beh_lab
translate @Results "`datapath'\version06\3-output\beh.txt" ,replace
restore

preserve
cls
label list grade_lab
translate @Results "`datapath'\version06\3-output\grade.txt" ,replace
restore

preserve
cls
label list basis_lab 
translate @Results "`datapath'\version06\3-output\basis.txt" ,replace
restore


				**********************
				*   MS WORD REPORT   *
				* NOTES + DATA CODES *
				**********************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("BNR-Cancer: Notes + Data Codes"), bold
putdocx paragraph
putdocx text ("Time Period: 2008, 2013-2015") 
putdocx paragraph
putdocx text ("Date Prepared: 26-OCT-2020") 
putdocx paragraph
putdocx text ("Prepared by: Jacqueline Campbell using Stata data release date: 26-Oct-2020")
putdocx paragraph, halign(center)
putdocx text ("Notes"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Exclusions: ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
putdocx textblock end
putdocx textblock begin
(2) Inclusions: basal and squamous cell carcinomas of skin, non-genital sites for 2008 diagnoses ONLY
putdocx textblock end
putdocx textblock begin
(3) Case Definition: non-malignant tumours of the bladder were NOT included in the BNR case definition; the only non-malignant tumours collected were for the cervix
putdocx textblock end
putdocx textblock begin
(4) Optional: ethnic group or race NOT collected for any of the years
putdocx textblock end
putdocx textblock begin
(5) Collected: grade collected for 2015 diagnoses ONLY
putdocx textblock end
putdocx textblock begin
(6) Populations: generated from World Population Prospects: "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Data Dictionary"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Description of Dataset:") ,bold
putdocx textfile "`datapath'\version06\3-output\describe.txt"
putdocx paragraph, halign(center)
putdocx text ("Data Codes"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Sex codes:") ,bold
putdocx textfile "`datapath'\version06\3-output\sex.txt"
putdocx paragraph
putdocx text ("Behaviour codes:") ,bold
putdocx textfile "`datapath'\version06\3-output\beh.txt"
//putdocx pagebreak
putdocx paragraph
putdocx text ("Grade codes:") ,bold
putdocx textfile "`datapath'\version06\3-output\grade.txt"
putdocx paragraph
putdocx text ("Basis of Diagnosis codes:") ,bold
putdocx textfile "`datapath'\version06\3-output\basis.txt"
putdocx save "`datapath'\version06\3-output\2020-10-26_notes + codes.docx", replace
putdocx clear

save "`datapath'\version06\3-output\2008_2013_2014_2015_iarchub", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset for IARC Hub's Data Request"
note: TS This dataset was used for data prep for IARC Hub's quality assessment (see p131 v06)
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
note: TS Includes basal and squamous cell carcinomas of skin, non-genital sites for 2008 diagnoses only