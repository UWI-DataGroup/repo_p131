
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          AGrandison_CME_Aug2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      23-AUG-2022
    // 	date last modified      24-AUG-2022
    //  algorithm task          Providing COVID death-related statistics to Adanna Grandison for the BNR CME seminar
    //  status                  Completed
    //  objective               To have one document with cleaned and grouped data for inclusion in CME presentation:
	//							- number of covid deaths for 2020 and 2021
	//							- number of covid deaths with cancer for 2020 and 2021
    //  methods                 Taken from 5c_prep mort_2019+2020.do and 5e_prep mort_2021.do in 2016-2018AnnualReport branch.

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
    log using "`logpath'/AGrandison_CME_Aug2022.smcl", replace
** HEADER -----------------------------------------------------

****************
**	  2020    **
** ALL Deaths **
****************
** LOAD 2020 cleaned and formatted death dataset from p117/version09/5c_prep mort_2019+2020.do
use "`datapath'\version16\1-input\2020_prep mort_ALL_deidentified" ,clear

count //2602

** JC 23aug2022: For BNR CME 2022 webinar, Dr Adanna Grandison needs the number of covid deaths and number of covid deaths with cancer for 2020 and 2021 by patient
order record_id coddeath placeofdeath

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|regexm(coddeath,"CORONA") //95

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))) //4

count if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //0

** All 2020 deaths with COVID-related COD
count if !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //4

** Cases where POD=isolation facility but COD!=COVID
count if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*")) & !(strmatch(strupper(placeofdeath), "*HARRISONS ROAD*")) & !(strmatch(strupper(placeofdeath), "*BLACKMAN NORTH*"))
//0

egen covid = count(record_id) if !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen vaccine = count(record_id) if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen isolation = count(record_id) if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*")) & !(strmatch(strupper(placeofdeath), "*HARRISONS ROAD*")) & !(strmatch(strupper(placeofdeath), "*BLACKMAN NORTH*"))

gen total_deaths=_N

fillmissing covid vaccine isolation total_deaths

preserve
collapse dodyear covid vaccine isolation total_deaths
save "`datapath'\version16\2-working\covid_totals" ,replace
restore


****************
**	  2021    **
** ALL Deaths **
****************
** LOAD 2021 cleaned and formatted death dataset from p117/version09/5e_prep mort_2021.do
use "`datapath'\version16\1-input\2021_prep mort_ALL_deidentified" ,clear

count //3142

** JC 23aug2022: For BNR CME 2022 webinar, Dr Adanna Grandison needs the number of covid deaths and number of covid deaths with cancer for 2020 and 2021 by patient
order record_id coddeath placeofdeath

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|regexm(coddeath,"CORONA") //479

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))) //381

count if record_id!=36048 & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //380
//record_id 36048 COD states non related covid pneumonia

count if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //4

** All 2021 deaths with COVID-related COD
count if record_id!=36048 & !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //376
//record_id 36048 COD states non related covid pneumonia
//4 with COVID vaccine related deaths but no indication they contracted COVID

** Cases where POD=isolation facility but COD!=COVID
count if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*"))
//6 in total

egen covid = count(record_id) if record_id!=36048 & !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen vaccine = count(record_id) if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen isolation = count(record_id) if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*"))

gen total_deaths=_N

fillmissing covid vaccine isolation total_deaths


collapse dodyear covid vaccine isolation total_deaths
append using "`datapath'\version16\2-working\covid_totals"
replace vaccine=0 if vaccine==.
replace isolation=0 if isolation==.
sort dodyear
save "`datapath'\version16\2-working\covid_totals" ,replace


*******************
**	    2020	 **
** Cancer Deaths **
*******************
** LOAD 2020 cleaned and formatted death dataset from p117/version09/5c_prep mort_2019+2020.do
use "`datapath'\version16\1-input\2020_prep mort_cancer_deidentified" ,clear

count //653

** JC 23aug2022: For BNR CME 2022 webinar, Dr Adanna Grandison needs the number of covid deaths and number of covid deaths with cancer for 2020 and 2021 by patient
order record_id coddeath placeofdeath

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|regexm(coddeath,"CORONA") //1

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))) //0

count if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //0

** All 2020 deaths with COVID-related COD
count if !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //0

** Cases where POD=isolation facility but COD!=COVID
count if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*")) & !(strmatch(strupper(placeofdeath), "*HARRISONS ROAD*")) & !(strmatch(strupper(placeofdeath), "*BLACKMAN NORTH*"))
//0

egen covid = count(record_id) if !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen vaccine = count(record_id) if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen isolation = count(record_id) if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*")) & !(strmatch(strupper(placeofdeath), "*HARRISONS ROAD*")) & !(strmatch(strupper(placeofdeath), "*BLACKMAN NORTH*"))

gen total_cancer_deaths=_N //variable with total amount of cancer deaths

fillmissing covid vaccine isolation total_cancer_deaths

preserve
collapse dodyear covid vaccine isolation total_cancer_deaths
save "`datapath'\version16\2-working\covid_totals_cancer" ,replace
restore


*******************
**	    2021	 **
** Cancer Deaths **
*******************
** LOAD 2021 cleaned and formatted death dataset from p117/version09/5e_prep mort_2021.do
use "`datapath'\version16\1-input\2021_prep mort_cancer_deidentified" ,clear

count //693

** JC 23aug2022: For BNR CME 2022 webinar, Dr Adanna Grandison needs the number of covid deaths and number of covid deaths with cancer for 2020 and 2021 by patient
order record_id coddeath placeofdeath

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|regexm(coddeath,"CORONA") //18

count if regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))) //18

count if record_id!=36048 & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //18
//record_id 36048 COD states non related covid pneumonia

count if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //0

** All 2021 deaths with COVID-related COD
count if record_id!=36048 & !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*")))) //18
//record_id 36048 COD states non related covid pneumonia
//4 with COVID vaccine related deaths but no indication they contracted COVID

** Cases where POD=isolation facility but COD!=COVID
count if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*"))
//1

egen covid = count(record_id) if record_id!=36048 & !(strmatch(strupper(coddeath), "*VACCINE*")) & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen vaccine = count(record_id) if regexm(coddeath,"VACCINE") & (regexm(coddeath,"COV")|regexm(coddeath,"SARS")|(regexm(coddeath,"CORONA") & !(strmatch(strupper(coddeath), "*CORONARY*"))))

egen isolation = count(record_id) if (regexm(placeofdeath,"HARRISON")|regexm(placeofdeath,"BLACKMAN")|regexm(placeofdeath,"ISOLATION")) & !(strmatch(strupper(coddeath), "*COVID*")) & !(strmatch(strupper(coddeath), "*CORONA*")) & !(strmatch(strupper(placeofdeath), "*ISOLATION ROAD*")) & !(strmatch(strupper(coddeath), "*COVI9*"))

gen total_cancer_deaths=_N //variable with total amount of cancer deaths

preserve
drop if covid==.
keep dodyear siteiarc
contract dodyear siteiarc
drop _freq
sort siteiarc
count //12
save "`datapath'\version16\2-working\covid_cancer_sites" ,replace
restore

fillmissing covid vaccine isolation total_cancer_deaths

collapse dodyear covid vaccine isolation total_cancer_deaths
append using "`datapath'\version16\2-working\covid_totals_cancer"
replace covid=0 if covid==.
replace vaccine=0 if vaccine==.
replace isolation=0 if isolation==.
sort dodyear
save "`datapath'\version16\2-working\covid_totals_cancer" ,replace

preserve
use "`datapath'\version16\2-working\covid_totals" ,clear
** Create MS Word results table with absolute case totals by year
				**************************
				*	   MS WORD REPORT    *
				* 	   COVID Mortality   * 
				*         RESULTS        *
				**************************

putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("COVID Mortality: BNR CME 2022 Webinar"), bold
putdocx textblock begin
Date Prepared: 23-AUG-2022.
putdocx textblock end
putdocx textblock begin
Prepared by: Jacqueline Campbell
putdocx textblock end
putdocx textblock begin
Software used: Stata v17.0 and REDCap v12.3.3 (multi-year death database) data release date: 03-Aug-2022.
putdocx textblock end
putdocx textblock begin
Generated using Dofile: 5c_prep mort_2019+2020.do; 5e_prep mort_2021.do; AGrandison_CME_Aug2022.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the mortality dataset, the 2020 and 2021 annual report mortality datasets were used to organize the data into a format to perform this analysis (death datasets used: (2021) "p117\version09\3-output\2021_prep mort_ALL_deidentified"; (2020) "p117\version09\3-output\2020_prep mort_ALL_deidentified").
putdocx textblock end
putdocx textblock begin
(2) All the mortality datasets were checked to ensure the COVID-related COD truly had that attribute and flagged CODs without a COVID-related term but had Place Of Death as an isolation facility.
putdocx textblock end
putdocx textblock begin
(3) NOTE 1: 2022 registrations of 2021 deaths are still being collected at the Registration Department so this data reflects 2021 deaths as of the above noted data release date of 03-Aug-2022.
putdocx textblock end
putdocx textblock begin
(4) NOTE 2: "Facility_deaths_no_covid" are the instances wherein the Place of Death is an isolation facility but the COD does not contain a COVID-related term.
putdocx textblock end

putdocx paragraph, halign(center)
putdocx text ("Table: ALL Deaths with COVID-related COD (2020 + 2021)"), bold font(Helvetica,10,"blue")
putdocx paragraph
//putdocx pagebreak

rename dodyear Year
rename covid Covid_deaths
rename vaccine Covid_vaccine_deaths
rename isolation Facility_deaths_no_covid
rename total_deaths Total_deaths

putdocx table tbl1 = data(Year Covid_deaths Covid_vaccine_deaths Facility_deaths_no_covid Total_deaths), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version16\3-output\COVID_CMEStats_`listdate'.docx", replace
putdocx clear
restore

preserve
use "`datapath'\version16\2-working\covid_totals_cancer" ,clear

putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Table: Cancer Deaths with COVID-related COD (2020 + 2021)"), bold font(Helvetica,10,"blue")
putdocx paragraph

rename dodyear Year
rename covid Covid_deaths
rename vaccine Covid_vaccine_deaths
rename isolation Facility_deaths_no_covid
rename total_cancer_deaths Total_cancer_deaths

putdocx table tbl1 = data(Year Covid_deaths Covid_vaccine_deaths Facility_deaths_no_covid Total_cancer_deaths), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version16\3-output\COVID_CMEStats_`listdate'.docx", append
putdocx clear
restore

preserve
use "`datapath'\version16\2-working\covid_cancer_sites" ,clear

putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Table: SITES of Cancer Deaths with COVID-related COD (2020 + 2021)"), bold font(Helvetica,10,"blue")
putdocx paragraph

rename dodyear Year
rename siteiarc Site

putdocx table tbl1 = data(Year Site), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version16\3-output\COVID_CMEStats_`listdate'.docx", append
putdocx clear
restore