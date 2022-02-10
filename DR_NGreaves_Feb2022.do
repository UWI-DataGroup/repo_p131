** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          DR_NGreaves_Feb2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      10-FEB-2022
    // 	date last modified      10-FEB-2022
    //  algorithm task          Preparing 2008,2013-2015 dataset per data request form
    //  status                  Completed
    //  objective               To have one dataset with cleaned 2008,2013-2015 hepatic, gall bladder, pancreatic duodenal, stomach,  and colorectal data
    //  methods                 Format and save dataset using the 2015 annual report dataset

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
    log using "`logpath'\DR_NGreaves_Feb2022.smcl", replace
** HEADER -----------------------------------------------------

** Using the 2015 annual report dataset that was generated for IARC-Hub's use
use "`datapath'\version09\1-input\2008_2013_2014_2015_iarchub_nonsurvival_reportable"

count //3588

/* Remove all variables except:
		Record ID
		Age
		Sex
		Status at last contact
		Date of last contact
		Date of death, where applicable
		Year of death, where applicable
		Date of incidence
		Year of incidence
		Topography
		Morphology
		ICD-10 code
		Behaviour
		Basis of Diagnosis
		Site (IARC/ICD-10 site)
		Cause(s) of death
*/
keep pid cr5id age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath dxyr fname lname natregno dd_cod1a cr5cod mpseq mptot


** Remove all sites except hepatic, gall bladder, pancreatic duodenal, stomach,  and colorectal cancers
labelbook siteiarc_lab

keep if siteiarc==11|siteiarc==13|siteiarc==14|siteiarc==16|siteiarc==17|siteiarc==18 //2761 deleted

count //827

** Check no missing in the above variables
tab pid ,m //none missing
tab age ,m //none missing
tab sex ,m //none missing
tab slc ,m //none missing
tab dlc ,m //none missing
tab dod ,m //187 missing - 187 alive
tab dodyear ,m //187 missing - 187 alive
tab dot ,m //none missing
tab dotyear ,m //none missing
tab dxyr ,m //none missing
tab topography ,m //none missing
tab morph ,m //none missing
tab icd10 ,m //none missing
tab beh ,m //none missing
tab basis ,m //none missing
tab siteiarc ,m //none missing
tab dd_coddeath ,m //212 missing
tab cr5cod ,m //116 missing

** Clean cause of death variable
count if slc==2 & dd_coddeath=="" //26
count if dd_coddeath=="" & dd_cod1a!="" //11
count if dd_coddeath=="" & cr5cod!="" & cr5cod!="99" //14
replace cr5cod = upper(rtrim(ltrim(itrim(cr5cod)))) //595 changes
count if slc!=2 & dd_cod1a!="" //1 - it's a dot
replace dd_cod1a="" if slc!=2 & dd_cod1a!="" //1 change
count if slc!=2 & cr5cod!="" & cr5cod!="99" //0

replace dd_coddeath=cr5cod if dd_coddeath==""  & cr5cod!="" & cr5cod!="99" //14 changes
replace dd_coddeath=dd_cod1a if dd_coddeath=="" & dd_cod1a!="" //8 changes

count if slc==2 & dd_coddeath=="" //4 - check these individually in REDCap death db - pids 20080611, 20130167, 20130690 cannot be found in death data
replace dd_coddeath="METASTATIC COLON CANCER" if pid=="20155029"
count if slc==2 & dd_coddeath=="" //3 - PIDs 20080611, 20130167, 20130690 cannot be found in death data

drop dxyr fname lname natregno dd_cod1a cr5cod

** Check if cancer is a MP
count if cr5id!="T1S1" //13
drop cr5id mpseq mptot

** Check labels of variables to ensure they are understandable
label var pid "Unique Patient ID"
//label var cr5id "Tumour + Source ID"
label var slc "Status at Last Contact"
label var dlc "Date of Last Contact"
label var dod "Date of Death"
label var morph "ICD-O-3 Morphology"
//label var mpseq "Tumour Sequence"
//label var mptot "Tumour Total"
label var sex "Sex"
label var beh "ICD-O-3 Behaviour"
label var basis "Most Valid Basis of Diagnosis"
label var dot "Date of Incidence"
label var topography "ICD-O-3 Topography"
label var icd10 "ICD-10"
label var siteiarc "IARC-ICD10 Site Classification"
label var dd_coddeath "Cause(s) of Death"
label var dotyear "Year of Incidence"
label var dodyear "Year of Death"

** Put variables in order they are to appear
sort siteiarc pid	  
order pid age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath
//order pid cr5id mpseq mptot age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath

count //827

** Export the data into an excel workbook
** Sheet 1 - variable labels
** Sheet 2 - variable values (no labels)
/*
local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid cr5id mpseq mptot age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Labels") firstrow(varlabels) replace

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid cr5id mpseq mptot age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Values") firstrow(variables) nolabel
*/

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Labels") firstrow(varlabels)

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Values") firstrow(variables) nolabel


** Save coded labels and above notes into a Word document
preserve
cls
describe
translate @Results "`datapath'\version09\2-working\describe.txt" ,replace
restore

preserve
cls
label list sex_lab
translate @Results "`datapath'\version09\2-working\sex.txt" ,replace
restore

preserve
cls
label list slc_lab 
translate @Results "`datapath'\version09\2-working\slc.txt" ,replace
restore

preserve
cls
label list beh_lab
translate @Results "`datapath'\version09\2-working\beh.txt" ,replace
restore

preserve
cls
label list basis_lab 
translate @Results "`datapath'\version09\2-working\basis.txt" ,replace
restore

preserve
cls
label list siteiarc_lab
translate @Results "`datapath'\version09\2-working\siteiarc.txt" ,replace
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
putdocx text ("Date Prepared: 10-FEB-2022") 
putdocx paragraph
putdocx text ("Prepared by: Jacqueline Campbell using Stata data release date: 13-Feb-2020")
putdocx paragraph, halign(center)
putdocx text ("Notes"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Exclusions: ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable Multiple Primaries
putdocx textblock end
putdocx textblock begin
(2) Inclusions: Hepatic, gall bladder, pancreatic duodenal, stomach, and colorectal cancers for 2008, 2013-2015 diagnoses ONLY
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Data Dictionary"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Description of Dataset:") ,bold
putdocx textfile "`datapath'\version09\2-working\describe.txt"
putdocx paragraph, halign(center)
putdocx text ("Data Codes"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Sex codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\sex.txt"
putdocx paragraph
putdocx text ("Status at Last Contact codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\slc.txt"
putdocx paragraph
putdocx text ("Basis of Diagnosis codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\basis.txt"
putdocx paragraph
putdocx text ("Behaviour codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\beh.txt"
putdocx pagebreak
putdocx paragraph
putdocx text ("IARC-ICD10 Site codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\siteiarc.txt"

putdocx save "`datapath'\version09\3-output\2022-02-10_notes + codes.docx", replace
putdocx clear


** For 2015 onwards using internationally reportable standards, as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
** Save this corrected dataset with reportable cases
save "`datapath'\version09\3-output\2008_2013-2015_dr_ngreaves", replace
label data "2008,2013-2015 BNR-Cancer analysed data - Limited Non-survival Data Request Dataset"
note: TS This dataset was used for 2022 data request for Natalie Greaves
note: TS Excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

/*
  mkdir c:/results

  cd c:/results

local listdate = string( d(`c(current_date)'), "%dCYND" )
asdoc labelbook, save(c:/NGreaves_`listdate'.xlsx, sheet("Labelbook")) replace

local listdate = string( d(`c(current_date)'), "%dCYND" )
asdocx codebook, save("`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Codebook")) replace
*/
/*
save "`datapath'\version09\3-output\2008_2013-2015_dr_ngreaves", replace

preserve

uselabel
describe
list

drop trunc
rename value labelvalue
label var labelvalue "Label's Coded Value"
rename label labelvalname
label var labelvalname "Label's Named Value"
rename lname labelname
label var labelname "Name of Label"

keep if labelname=="basis_lab"|labelname=="beh_lab"|labelname=="sex_lab"|labelname=="siteiarc_lab"|labelname=="slc_lab"

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
putdocx text ("Date Prepared: 10-FEB-2022") 
putdocx paragraph
putdocx text ("Prepared by: Jacqueline Campbell using Stata data release date: 13-Feb-2020")
putdocx paragraph, halign(center)
putdocx text ("Notes"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Exclusions: ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
putdocx textblock end
putdocx textblock begin
(2) Inclusions: Hepatic, gall bladder, pancreatic duodenal, stomach, and colorectal cancers for 2008, 2013-2015 diagnoses ONLY
putdocx textblock end
putdocx paragraph, halign(center)
rename labelname Name_of_Label
rename labelvalue Coded_Value_of_Label
rename labelvalname Named_Value_of_Label
putdocx table tbl1 = data("Name_of_Label Coded_Value_of_Label Named_Value_of_Label"), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

putdocx save "`datapath'\version09\3-output\2022-02-10_notes + codes.docx", replace
putdocx clear

restore
stop
** For 2015 onwards using internationally reportable standards, as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
** Save this corrected dataset with reportable cases
save "`datapath'\version09\3-output\2008_2013-2015_dr_ngreaves", replace
label data "2008,2013-2015 BNR-Cancer analysed data - Limited Non-survival Data Request Dataset"
note: TS This dataset was used for 2022 data request for Natalie Greaves
note: TS Excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
*/
