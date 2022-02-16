** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          top5cods.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL + Ashley HENRY
    //  date first created      31-JAN-2022
    // 	date last modified      31-JAN-2022
    //  algorithm task          Identifying top 5 / top 6 causes of death for 2018 - 2020 using cleaned death 2015-2020 dataset
    //  status                  Ongoing
    //  objective               To case numbers for top 5 / top 6 causes of death for a MHW policy brief
    //  methods                 Using similar analysis code from p131/PC+CVD2021/PC+CVD2021.do

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

** Direct Stata to your do file folder using the -cd- command
cd "L:\Sync\DM\Stata\Stata do files\data_requests\2022\deaths\versions\version01"

** Begin a Stata logfile
log using "logfiles\top5_deaths.smcl", replace

** Automatic page scrolling of output
set more off

** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************
use "L:\Sync\DM\Stata\Stata do files\data_requests\2022\deaths\versions\version01\data\2015-2020_deaths_for_matching.dta", clear

count //15,416

rename dd6yrs_* dd_*

tab dd_dodyear ,m 

drop if dd_dodyear <2018 //7,500 deleted

count //7,916

** Export deaths to excel for AROB to check for spelling errors in the ARI category
sort dd_record_id
/*
export_excel dd_record_id dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if dd_dodyear<2018 using "L:\Sync\BNR\Data Request\2022-01-31_2015-2017 deaths_ARI.xlsx", sheet("2015-2017 deaths") firstrow(variables) replace
export_excel dd_record_id dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if dd_dodyear>2017 using "L:\Sync\BNR\Data Request\2022-01-31_2018-2020 deaths_ARI.xlsx", sheet("2018-2020 deaths") firstrow(variables) replace
*/

** Create variable to classify the different causes of death
gen topcods = .
label define topcods_lab 1 "Cerebrovascular diseases (I60-I69)" 2 "Ischemic heart diseases (I20-I25)" 3 "Diabetes mellitus (E10-E14)" ///
						 4 "Malignant neoplasm of prostate (C61)" 5 "Hypertensive diseases (I10-I15)" 6 "Acute respiratory infection (J00-J22)" ///
						 7 "Malignant neoplasm of colon, rectosigmoid junction and rectum (C18-C20)" 8 "Malignant neoplasm of female breast (C50)" 99 "Other UCODs" , modify
label values topcods topcods_lab
label var topcods "Top Causes of Death"

/*
label define topcods_lab 1 "Cerebrovascular diseases (CVD:I60-I69)" 2 "Ischemic heart diseases (IHD:I20-I25)" 3 "Diabetes mellitus (DM:E10-E14)" ///
						 4 "(PC:C61) Malignant neoplasm of prostate" 5 "(HD:I10-I15) Hypertensive diseases" 6 "(ARI:J00-J22) Acute respiratory infection" ///
						 7 "(CRC:C18-C20) Malignant neoplasm of colon, rectosigmoid junction & rectum" 8 "(BC:C50) Malignant neoplasm of female breast" 99 "Other CODs" , modify
label values topcods topcods_lab
*/
** Identify the underlying causes of death for each of the below categories
** Note the categories were checked against ICD-10 v2019
display `"{browse "https://icd.who.int/browse10/2019/en":ICD-10}"'


******************************
** Cerebrovascular diseases **
******************************
** Identify deaths frommCerebrovascular diseases(I60-I69) using variable called 'stroke'
replace topcods=1 if regexm(dd_cod1d, "CEREBROVASCULAR DISEASE") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBROVASCULAR DISEASE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBROVASCULAR DISEASE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //2 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBROVASCULAR DISEASE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //21 changes


replace topcods=1 if regexm(dd_cod1d, "STROKE") &  topcods==. //6 changes
replace topcods=1 if regexm(dd_cod1c, "STROKE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //23 changes
replace topcods=1 if regexm(dd_cod1b, "STROKE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //72 changes
replace topcods=1 if regexm(dd_cod1a, "STROKE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //459 changes


replace topcods=1 if regexm(dd_cod1d, "CVA") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "CVA")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "CVA")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "CVA") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //8 changes


replace topcods=1 if regexm(dd_cod1d, "CEREBRAL VASCULAR ACCIDENT") &  topcods==. //1 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBRAL VASCULAR ACCIDENT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //2 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBRAL VASCULAR ACCIDENT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //2 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBRAL VASCULAR ACCIDENT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //35 changes


replace topcods=1 if regexm(dd_cod1d, "CEREBRAL ACCIDENT") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBRAL ACCIDENT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBRAL ACCIDENT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBRAL ACCIDENT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //1 changes


replace topcods=1 if regexm(dd_cod1d, "CEREBROVASCULAR ACCIDENT") &  topcods==. //4 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBROVASCULAR ACCIDENT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //19 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBROVASCULAR ACCIDENT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //23 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBROVASCULAR ACCIDENT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //425 changes


replace topcods=1 if regexm(dd_cod1d, "CEREBRAL INFARCT") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBRAL INFARCT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBRAL INFARCT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //12 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBRAL INFARCT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //19 changes


replace topcods=1 if regexm(dd_cod1d, "SUBARACH") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "SUBARACH")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0
replace topcods=1 if regexm(dd_cod1b, "SUBARACH")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "SUBARACH") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //29 changes


replace topcods=1 if regexm(dd_cod1d, "INTRACEREBRAL") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "INTRACEREBRAL")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=1 if regexm(dd_cod1b, "INTRACEREBRAL")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //3 changes
replace topcods=1 if regexm(dd_cod1a, "INTRACEREBRAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //52 changes


replace topcods=1 if regexm(dd_cod1d, "MIDDLE CEREBRAL") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "MIDDLE CEREBRAL")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "MIDDLE CEREBRAL")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "MIDDLE CEREBRAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


replace topcods=1 if regexm(dd_cod1d, "POSTERIOR CEREBRAL") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "POSTERIOR CEREBRAL")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "POSTERIOR CEREBRAL")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "POSTERIOR CEREBRAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


replace topcods=1 if regexm(dd_cod1d, "THROMBOEMBOLIC CEREBRAL") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "THROMBOEMBOLIC CEREBRAL")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "THROMBOEMBOLIC CEREBRAL")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "THROMBOEMBOLIC CEREBRAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


replace topcods=1 if regexm(dd_cod1d, "NONTRAUMATIC SUBDURAL HAEMORRHAGE") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "NONTRAUMATIC SUBDURAL HAEMORRHAGE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "NONTRAUMATIC SUBDURAL HAEMORRHAGE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "NONTRAUMATIC SUBDURAL HAEMORRHAGE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes



replace topcods=1 if regexm(dd_cod1d, "CEREBRAL ATHEROSCLEROSIS") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBRAL ATHEROSCLEROSIS")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBRAL ATHEROSCLEROSIS")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBRAL ATHEROSCLEROSIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes

replace topcods=1 if regexm(dd_cod1d, "CEREBROVASCULAR ATTACK") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBROVASCULAR ATTACK")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBROVASCULAR ATTACK")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBROVASCULAR ATTACK") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //14 changes


replace topcods=1 if regexm(dd_cod1d, "INTRCEREBRAL") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "INTRCEREBRAL")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "INTRCEREBRAL")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "INTRCEREBRAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //3 changes


replace topcods=1 if regexm(dd_cod1d, "INTRA CEREBRAL") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "INTRA CEREBRAL")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=1 if regexm(dd_cod1b, "INTRA CEREBRAL")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "INTRA CEREBRAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //6 changes

replace topcods=1 if regexm(dd_cod1d, "INTRA-CEREBRAL") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "INTRA-CEREBRAL")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "INTRA-CEREBRAL")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "INTRA-CEREBRAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


replace topcods=1 if regexm(dd_cod1d, "CEREBRALVASCULAR ACCIDENT") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBRALVASCULAR ACCIDENT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBRALVASCULAR ACCIDENT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBRALVASCULAR ACCIDENT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //1 changes


replace topcods=1 if regexm(dd_cod1d, "CEREBRO VASCULAR ACCIDENT") &  topcods==. //1 changes
replace topcods=1 if regexm(dd_cod1c, "CEREBRO VASCULAR ACCIDENT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "CEREBRO VASCULAR ACCIDENT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "CEREBRO VASCULAR ACCIDENT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //13 changes

replace topcods=1 if regexm(dd_cod1d, "SUBARACHNOID HAEMORRHAGE") &  topcods==. //0 changes
replace topcods=1 if regexm(dd_cod1c, "SUBARACHNOID HAEMORRHAGE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1b, "SUBARACHNOID HAEMORRHAGE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=1 if regexm(dd_cod1a, "SUBARACHNOID HAEMORRHAGE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


tab dd_dodyear if topcods==1


*****************************
** Ischemic heart diseases **
*****************************
** Identify deaths from Ischaemic heart diseases(I20-I25)using variable called 'topcods'
replace topcods=2 if regexm(dd_cod1d, "CARDIAL INFARCT") &  topcods==. //2 changes
replace topcods=2 if regexm(dd_cod1c, "CARDIAL INFARCT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //18 changes
replace topcods=2 if regexm(dd_cod1b, "CARDIAL INFARCT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //37 changes
replace topcods=2 if regexm(dd_cod1a, "CARDIAL INFARCT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //596 changes


replace topcods=2 if regexm(dd_cod1d, "ANGINA") &  topcods==. //1 changes
replace topcods=2 if regexm(dd_cod1c, "ANGINA")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=2 if regexm(dd_cod1b, "ANGINA")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=2 if regexm(dd_cod1a, "ANGINA") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //6 changes


replace topcods=2 if regexm(dd_cod1d, "HEART ATTACK") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "HEART ATTACK")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "HEART ATTACK")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "HEART ATTACK") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //2 changes


replace topcods=2 if regexm(dd_cod1d, "ACUTE MYOCARDIAL INFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*"))  &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "ACUTE MYOCARDIAL INFARCTION")& !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*"))  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "ACUTE MYOCARDIAL INFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "ACUTE MYOCARDIAL INFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes

replace topcods=2 if regexm(dd_cod1d, "MYOCARDIALINFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "MYOCARDIALINFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*"))  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "MYOCARDIALINFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "MYOCARDIALINFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //3 changes

replace topcods=2 if regexm(dd_cod1d, "MYOCARDIAN INFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "MYOCARDIAN INFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*"))  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "MYOCARDIAN INFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "MYOCARDIAN INFARCTION") & !(strmatch(strupper(dd_cod1d),"*OLD MYOCARDIAL*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //2 changes

replace topcods=2 if regexm(dd_cod1d, "ELEVATION") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "ELEVATION")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "ELEVATION")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "ELEVATION") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes

replace topcods=2 if regexm(dd_cod1d, "CORONARY THROMB") & !(strmatch(strupper(dd_cod1d),"*MYOCARDIAL INFART*")) &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "CORONARY THROMB") & !(strmatch(strupper(dd_cod1d),"*MYOCARDIAL INFART*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "CORONARY THROMB") & !(strmatch(strupper(dd_cod1d),"*MYOCARDIAL INFART*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //6 changes
replace topcods=2 if regexm(dd_cod1a, "CORONARY THROMB") & !(strmatch(strupper(dd_cod1d),"*MYOCARDIAL INFART*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //10 changes

replace topcods=2 if regexm(dd_cod1d, "ISCHAEMIC HEART DISEASE") &  topcods==. //3 changes
replace topcods=2 if regexm(dd_cod1c, "AUTE ISCHAEMIC HEART DISEASE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "ACUTE ISCHAEMIC HEART DISEASE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "ACUTE ISCHAEMIC HEART DISEASE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes

replace topcods=2 if regexm(dd_cod1d, "ISCHEMIC HEART DISEASE") &  topcods==. //2 changes
replace topcods=2 if regexm(dd_cod1c, "ISCHEMIC HEART DISEASE")   &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //5 changes
replace topcods=2 if regexm(dd_cod1b, "ISCHEMIC HEART DISEASE") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //28 changes
replace topcods=2 if regexm(dd_cod1a, "ISCHEMIC HEART DISEASE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //64 changes


replace topcods=2 if regexm(dd_cod1d, "CORONARY SYNDROME") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "CORONARY SYNDROME")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=2 if regexm(dd_cod1b, "CORONARY SYNDROME")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=2 if regexm(dd_cod1a, "CORONARY SYNDROME") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //13 changes

replace topcods=2 if regexm(dd_cod1d, "ISCHAEMIC CARDIOMYOPATHY") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "ISCHAEMIC CARDIOMYOPATHY")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "ISCHAEMIC CARDIOMYOPATHY")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //3 changes
replace topcods=2 if regexm(dd_cod1a, "ISCHAEMIC CARDIOMYOPATHY") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //4 changes


replace topcods=2 if regexm(dd_cod1d, "CORONARY ARTERY ANEURYSM") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "CORONARY ARTERY ANEURYSM")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "CORONARY ARTERY ANEURYSM")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "CORONARY ARTERY ANEURYSM") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


replace topcods=2 if regexm(dd_cod1d, "HEART FAILURE") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "HEART FAILURE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "HEART FAILURE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "HEART FAILURE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


replace topcods=2 if regexm(dd_cod1d, "CORONARY HEART DISEASE") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "CORONARY HEART DISEASE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //1 changes
replace topcods=2 if regexm(dd_cod1b, "CORONARY HEART DISEASE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //3 changes
replace topcods=2 if regexm(dd_cod1a, "CORONARY HEART DISEASE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //6 changes


replace topcods=2 if regexm(dd_cod1d, "CORONARY ARTERY DISEASE") &  topcods==. //7 changes
replace topcods=2 if regexm(dd_cod1c, "CORONARY ARTERY DISEASE")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //12 changes
replace topcods=2 if regexm(dd_cod1b, "CORONARY ARTERY DISEASE")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //116 changes
replace topcods=2 if regexm(dd_cod1a, "CORONARY ARTERY DISEASE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //164 changes


replace topcods=2 if regexm(dd_cod1d, "MYOCARDIAL INFARCT") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "MYOCARDIAL INFARCT")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "MYOCARDIAL INFARCT")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "MYOCARDIAL INFARCT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes


replace topcods=2 if regexm(dd_cod1d, "MYOCARIDAL INFARCTION") &  topcods==. //0 changes
replace topcods=2 if regexm(dd_cod1c, "MYOCARIDAL INFARCTION")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1b, "MYOCARIDAL INFARCTION")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=2 if regexm(dd_cod1a, "MYOCARIDAL INFARCTION") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //4 changes

tab dd_dodyear if topcods==2


***********************
** Diabetes mellitus **
***********************
** Identify deaths from Diabetes Mellitus (E10-E14) using variable called 'topcods'
replace topcods=3 if regexm(dd_cod1d, "DIABETES MELLITUS") &  topcods==. //32 changes
replace topcods=3 if regexm(dd_cod1c, "DIABETES MELLITUS")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //110 changes
replace topcods=3 if regexm(dd_cod1b, "DIABETES MELLITUS")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //84 changes
replace topcods=3 if regexm(dd_cod1a, "DIABETES MELLITUS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //611 changes

replace topcods=3 if regexm(dd_cod1d, "DIABETES") &  topcods==. //15 changes
replace topcods=3 if regexm(dd_cod1c, "DIABETES")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //41 changes
replace topcods=3 if regexm(dd_cod1b, "DIABETES")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //48 changes
replace topcods=3 if regexm(dd_cod1a, "DIABETES") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //301 changes

replace topcods=3 if regexm(dd_cod1d, "DIABETIC") &  topcods==. //0 changes
replace topcods=3 if regexm(dd_cod1c, "DIABETIC")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //6 changes
replace topcods=3 if regexm(dd_cod1b, "DIABETIC")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //5 changes
replace topcods=3 if regexm(dd_cod1a, "DIABETIC") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //54 changes

replace topcods=3 if regexm(dd_cod1d, "DISBETIC") &  topcods==. //0 changes
replace topcods=3 if regexm(dd_cod1c, "DISBETIC")  &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=3 if regexm(dd_cod1b, "DISBETIC")  &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //0 changes
replace topcods=3 if regexm(dd_cod1a, "DISBETIC") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //1 changes

tab dd_dodyear if topcods==3


************************************
** Malignant neoplasm of prostate **
************************************
** Identify prostate cancer (C61) deaths using variable called 'topcods'
replace topcods=4 if regexm(dd_cod1d, "PROST") & !(strmatch(strupper(dd_cod1d),"*BENIGN PROST*")) &  topcods==. //9 changes
replace topcods=4 if regexm(dd_cod1c, "PROST") & !(strmatch(strupper(dd_cod1c),"*BENIGN PROST*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //29 changes
replace topcods=4 if regexm(dd_cod1b, "PROST") & !(strmatch(strupper(dd_cod1b),"*BENIGN PROST*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //59 changes
replace topcods=4 if regexm(dd_cod1a, "PROST") & !(strmatch(strupper(dd_cod1a),"*BENIGN PROST*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //228 changes

replace topcods=4 if regexm(dd_cod1d, "PRST") & !(strmatch(strupper(dd_cod1d),"*BENIGN PROST*")) &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "PRST") & !(strmatch(strupper(dd_cod1c),"*BENIGN PROST*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "PRST") & !(strmatch(strupper(dd_cod1b),"*BENIGN PROST*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "PRST") & !(strmatch(strupper(dd_cod1a),"*BENIGN PROST*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "PROSTATE CANCER") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "PROSTATE CANCER") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "PROSTATE CANCER") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "PROSTATE CANCER") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "PROSTATIC CANCER") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "PROSTATIC CANCER") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "PROSTATIC CANCER") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "PROSTATIC CANCER") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "CANCER PROSTATE") &  topcods==.  // changes
replace topcods=4 if regexm(dd_cod1c, "CANCER PROSTATE") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "CANCER PROSTATE") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "CANCER PROSTATE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "PROSTATIC CARCIN") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "PROSTATIC CARCIN") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "PROSTATIC CARCIN") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "PROSTATIC CARCIN") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "OMA OF THE PROSTATE") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "OMA OF THE PROSTATE") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "OMA OF THE PROSTATE") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "OMA OF THE PROSTATE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "PROSTATE CARCIN") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "PROSTATE CARCIN") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "PROSTATE CARCIN") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "PROSTATE CARCIN") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "CANCER OF PROSTATE") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "CANCER OF PROSTATE") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "CANCER OF PROSTATE") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "CANCER OF PROSTATE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "CANCER OF THE PROSTATE") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "CANCER OF THE PROSTATE") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "CANCER OF THE PROSTATE") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "CANCER OF THE PROSTATE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "PRSTATIC CARCIN") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "PRSTATIC CARCIN") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "PRSTATIC CARCIN") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "PRSTATIC CARCIN") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "PRSTATE") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "PRSTATE") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "PRSTATE") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "PRSTATE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=4 if regexm(dd_cod1d, "CARANOMA PROSTATE") &  topcods==. // changes
replace topcods=4 if regexm(dd_cod1c, "CARANOMA PROSTATE") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1b, "CARANOMA PROSTATE") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=4 if regexm(dd_cod1a, "CARANOMA PROSTATE") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

tab dd_dodyear if topcods==4


***************************
** Hypertensive diseases **
***************************
** Identify deaths from hypertensive diseases (I10-I15) using variable called 'topcods'
replace topcods=5 if regexm(dd_cod1d, "HYPERTENS") & !(strmatch(strupper(dd_cod1d),"*PULMONARY HYPERTENS*")) &  topcods==. //88 changes
replace topcods=5 if regexm(dd_cod1c, "HYPERTENS") & !(strmatch(strupper(dd_cod1c),"*PULMONARY HYPERTENS*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //234 changes
replace topcods=5 if regexm(dd_cod1b, "HYPERTENS") & !(strmatch(strupper(dd_cod1b),"*PULMONARY HYPERTENS*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //349 changes
replace topcods=5 if regexm(dd_cod1a, "HYPERTENS") & !(strmatch(strupper(dd_cod1a),"*PULMONARY HYPERTENS*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //38 changes

replace topcods=5 if regexm(dd_cod1d, "HYPERTENT") & !(strmatch(strupper(dd_cod1d),"*PULMONARY HYPERTENT*")) &  topcods==. // changes
replace topcods=5 if regexm(dd_cod1c, "HYPERTENT") & !(strmatch(strupper(dd_cod1c),"*PULMONARY HYPERTENT*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=5 if regexm(dd_cod1b, "HYPERTENT") & !(strmatch(strupper(dd_cod1b),"*PULMONARY HYPERTENT*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=5 if regexm(dd_cod1a, "HYPERTENT") & !(strmatch(strupper(dd_cod1a),"*PULMONARY HYPERTENT*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=5 if regexm(dd_cod1d, "HYPERTNS") & !(strmatch(strupper(dd_cod1d),"*PULMONARY HYPERTNS*")) &  topcods==. // changes
replace topcods=5 if regexm(dd_cod1c, "HYPERTNS") & !(strmatch(strupper(dd_cod1c),"*PULMONARY HYPERTNS*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=5 if regexm(dd_cod1b, "HYPERTNS") & !(strmatch(strupper(dd_cod1b),"*PULMONARY HYPERTNS*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=5 if regexm(dd_cod1a, "HYPERTNS") & !(strmatch(strupper(dd_cod1a),"*PULMONARY HYPERTNS*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes


tab dd_dodyear if topcods==5 //2608 in total for 2015-2020

order dd_record_id dd_cod1a dd_cod1b dd_cod1c dd_cod1d

sort dd_record_id
/*export_excel dd_record_id dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if topcods==. using "L:\Sync\BNR\Data Request\2022-01-31_2018-2020 deaths_HD.xlsx", sheet("2018-2020 deaths") firstrow(variables) replace
*/

*********************************
** Acute respiratory infection **
*********************************

** Identify Acute respiratory infections (J00-J22) deaths using variable called 'topcods'
replace topcods=6 if regexm(dd_cod1d, "NASOPHARYNGITIS") & !(strmatch(strupper(dd_cod1d),"*CHRONIC NASOPHARYNGITIS*")) &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "NASOPHARYNGITIS") & !(strmatch(strupper(dd_cod1c),"*CHRONIC NASOPHARYNGITIS*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "NASOPHARYNGITIS") & !(strmatch(strupper(dd_cod1b),"*CHRONIC NASOPHARYNGITIS*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "NASOPHARYNGITIS") & !(strmatch(strupper(dd_cod1a),"*CHRONIC NASOPHARYNGITIS*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE CORYZA") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE CORYZA") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE CORYZA") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE CORYZA") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE NASAL CATARRH") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE NASAL CATARRH") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE NASAL CATARRH") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE NASAL CATARRH") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if (regexm(dd_cod1d, "ACUTE RHINITIS")|regexm(dd_cod1d, "INFECTIVE RHINITIS")) &  topcods==. // changes
replace topcods=6 if (regexm(dd_cod1d, "ACUTE RHINITIS")|regexm(dd_cod1d, "INFECTIVE RHINITIS")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if (regexm(dd_cod1d, "ACUTE RHINITIS")|regexm(dd_cod1d, "INFECTIVE RHINITIS")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if (regexm(dd_cod1d, "ACUTE RHINITIS")|regexm(dd_cod1d, "INFECTIVE RHINITIS")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE") & regexm(dd_cod1d, "SINUSITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE") & regexm(dd_cod1c, "SINUSITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE") & regexm(dd_cod1b, "SINUSITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE") & regexm(dd_cod1a, "SINUSITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE") & regexm(dd_cod1d, "SINUS") & (regexm(dd_cod1d, "ABSCESS")|regexm(dd_cod1d, "EMPYEMA")|regexm(dd_cod1d, "INFECTION")|regexm(dd_cod1d, "INFLAMMATION")|regexm(dd_cod1d, "SUPPURATION")) &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE") & regexm(dd_cod1c, "SINUS") & (regexm(dd_cod1c, "ABSCESS")|regexm(dd_cod1c, "EMPYEMA")|regexm(dd_cod1c, "INFECTION")|regexm(dd_cod1c, "INFLAMMATION")|regexm(dd_cod1c, "SUPPURATION")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE") & regexm(dd_cod1b, "SINUS") & (regexm(dd_cod1b, "ABSCESS")|regexm(dd_cod1b, "EMPYEMA")|regexm(dd_cod1b, "INFECTION")|regexm(dd_cod1b, "INFLAMMATION")|regexm(dd_cod1b, "SUPPURATION")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE") & regexm(dd_cod1a, "SINUS") & (regexm(dd_cod1a, "ABSCESS")|regexm(dd_cod1a, "EMPYEMA")|regexm(dd_cod1a, "INFECTION")|regexm(dd_cod1a, "INFLAMMATION")|regexm(dd_cod1a, "SUPPURATION")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE") & regexm(dd_cod1d, "PHARYNGITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE") & regexm(dd_cod1c, "PHARYNGITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE") & regexm(dd_cod1b, "PHARYNGITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE") & regexm(dd_cod1a, "PHARYNGITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE") & regexm(dd_cod1d, "SORE THROAT") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE") & regexm(dd_cod1c, "SORE THROAT") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE") & regexm(dd_cod1b, "SORE THROAT") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE") & regexm(dd_cod1a, "SORE THROAT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "STREPTOCOC") & regexm(dd_cod1d, "PHARYNGITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "STREPTOCOC") & regexm(dd_cod1c, "PHARYNGITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "STREPTOCOC") & regexm(dd_cod1b, "PHARYNGITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "STREPTOCOC") & regexm(dd_cod1a, "PHARYNGITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "STREPTOCOC") & regexm(dd_cod1d, "SORE THROAT") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "STREPTOCOC") & regexm(dd_cod1c, "SORE THROAT") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "STREPTOCOC") & regexm(dd_cod1b, "SORE THROAT") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "STREPTOCOC") & regexm(dd_cod1a, "SORE THROAT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "TONSILLITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "TONSILLITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "TONSILLITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "TONSILLITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE") & regexm(dd_cod1d, "TONSILLITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE") & regexm(dd_cod1c, "TONSILLITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE") & regexm(dd_cod1b, "TONSILLITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE") & regexm(dd_cod1a, "TONSILLITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "STREPTOCOC") & regexm(dd_cod1d, "TONSILLITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "STREPTOCOC") & regexm(dd_cod1c, "TONSILLITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "STREPTOCOC") & regexm(dd_cod1b, "TONSILLITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "STREPTOCOC") & regexm(dd_cod1a, "TONSILLITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "LARYNGITIS") & !(strmatch(strupper(dd_cod1d),"*CHRONIC LARYNGITIS*")) &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "LARYNGITIS") & !(strmatch(strupper(dd_cod1c),"*CHRONIC LARYNGITIS*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "LARYNGITIS") & !(strmatch(strupper(dd_cod1b),"*CHRONIC LARYNGITIS*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "LARYNGITIS") & !(strmatch(strupper(dd_cod1a),"*CHRONIC LARYNGITIS*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "TRACHEITIS") & !(strmatch(strupper(dd_cod1d),"*CHRONIC TRACHEITIS*")) &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "TRACHEITIS") & !(strmatch(strupper(dd_cod1c),"*CHRONIC TRACHEITIS*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "TRACHEITIS") & !(strmatch(strupper(dd_cod1b),"*CHRONIC TRACHEITIS*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "TRACHEITIS") & !(strmatch(strupper(dd_cod1a),"*CHRONIC TRACHEITIS*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "LARYNGOTRACHEITIS") & !(strmatch(strupper(dd_cod1d),"*CHRONIC LARYNGOTRACHEITIS*")) &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "LARYNGOTRACHEITIS") & !(strmatch(strupper(dd_cod1c),"*CHRONIC LARYNGOTRACHEITIS*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "LARYNGOTRACHEITIS") & !(strmatch(strupper(dd_cod1b),"*CHRONIC LARYNGOTRACHEITIS*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "LARYNGOTRACHEITIS") & !(strmatch(strupper(dd_cod1a),"*CHRONIC LARYNGOTRACHEITIS*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "EPIGLOTTITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "EPIGLOTTITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "EPIGLOTTITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "EPIGLOTTITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE") & regexm(dd_cod1d, "RESPIRATORY INFECTION") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE") & regexm(dd_cod1c, "RESPIRATORY INFECTION") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE") & regexm(dd_cod1b, "RESPIRATORY INFECTION") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE") & regexm(dd_cod1a, "RESPIRATORY INFECTION") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "INFLUENZA") & (!(strmatch(strupper(dd_cod1d),"*HAEMOPHILUS*"))|!(strmatch(strupper(dd_cod1d),"*HEMOPHILUS*"))|!(strmatch(strupper(dd_cod1d),"*H.*"))|!(strmatch(strupper(dd_cod1d),"*H *"))) &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "INFLUENZA") & (!(strmatch(strupper(dd_cod1c),"*HAEMOPHILUS*"))|!(strmatch(strupper(dd_cod1c),"*HEMOPHILUS*"))|!(strmatch(strupper(dd_cod1c),"*H.*"))|!(strmatch(strupper(dd_cod1c),"*H *"))) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "INFLUENZA") & (!(strmatch(strupper(dd_cod1b),"*HAEMOPHILUS*"))|!(strmatch(strupper(dd_cod1b),"*HEMOPHILUS*"))|!(strmatch(strupper(dd_cod1b),"*H.*"))|!(strmatch(strupper(dd_cod1b),"*H *"))) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "INFLUENZA") & (!(strmatch(strupper(dd_cod1a),"*HAEMOPHILUS*"))|!(strmatch(strupper(dd_cod1a),"*HEMOPHILUS*"))|!(strmatch(strupper(dd_cod1a),"*H.*"))|!(strmatch(strupper(dd_cod1a),"*H *"))) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "SEASONAL") & regexm(dd_cod1d, "INFLUENZA") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "SEASONAL") & regexm(dd_cod1c, "INFLUENZA") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "SEASONAL") & regexm(dd_cod1b, "INFLUENZA") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "SEASONAL") & regexm(dd_cod1a, "INFLUENZA") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "PNEUMONIA") & (!(strmatch(strupper(dd_cod1d),"*ASPIRATION*"))|!(strmatch(strupper(dd_cod1d),"*CONGENITAL*"))|!(strmatch(strupper(dd_cod1d),"*ANAESTHES*"))|!(strmatch(strupper(dd_cod1d),"*ANESTHES*"))|!(strmatch(strupper(dd_cod1d),"*NEONATAL*"))|!(strmatch(strupper(dd_cod1d),"*INTERSTITIAL*"))|!(strmatch(strupper(dd_cod1d),"*LIPID*"))|!(strmatch(strupper(dd_cod1d),"*ORNITHOSIS*"))|!(strmatch(strupper(dd_cod1d),"*PNEUMOCYSTOSIS*"))|!(strmatch(strupper(dd_cod1d),"*ABSCESS OF LUNG*"))|!(strmatch(strupper(dd_cod1d),"*ABSCESS OF THE LUNG*"))|!(strmatch(strupper(dd_cod1d),"*LUNG ABSCESS*"))) &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "PNEUMONIA") & (!(strmatch(strupper(dd_cod1c),"*ASPIRATION*"))|!(strmatch(strupper(dd_cod1c),"*CONGENITAL*"))|!(strmatch(strupper(dd_cod1c),"*ANAESTHES*"))|!(strmatch(strupper(dd_cod1c),"*ANESTHES*"))|!(strmatch(strupper(dd_cod1c),"*NEONATAL*"))|!(strmatch(strupper(dd_cod1c),"*INTERSTITIAL*"))|!(strmatch(strupper(dd_cod1c),"*LIPID*"))|!(strmatch(strupper(dd_cod1c),"*ORNITHOSIS*"))|!(strmatch(strupper(dd_cod1c),"*PNEUMOCYSTOSIS*"))|!(strmatch(strupper(dd_cod1c),"*ABSCESS OF LUNG*"))|!(strmatch(strupper(dd_cod1c),"*ABSCESS OF THE LUNG*"))|!(strmatch(strupper(dd_cod1c),"*LUNG ABSCESS*"))) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "PNEUMONIA") & (!(strmatch(strupper(dd_cod1b),"*ASPIRATION*"))|!(strmatch(strupper(dd_cod1b),"*CONGENITAL*"))|!(strmatch(strupper(dd_cod1b),"*ANAESTHES*"))|!(strmatch(strupper(dd_cod1b),"*ANESTHES*"))|!(strmatch(strupper(dd_cod1b),"*NEONATAL*"))|!(strmatch(strupper(dd_cod1b),"*INTERSTITIAL*"))|!(strmatch(strupper(dd_cod1b),"*LIPID*"))|!(strmatch(strupper(dd_cod1b),"*ORNITHOSIS*"))|!(strmatch(strupper(dd_cod1b),"*PNEUMOCYSTOSIS*"))|!(strmatch(strupper(dd_cod1b),"*ABSCESS OF LUNG*"))|!(strmatch(strupper(dd_cod1b),"*ABSCESS OF THE LUNG*"))|!(strmatch(strupper(dd_cod1b),"*LUNG ABSCESS*"))) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "PNEUMONIA") & (!(strmatch(strupper(dd_cod1a),"*ASPIRATION*"))|!(strmatch(strupper(dd_cod1a),"*CONGENITAL*"))|!(strmatch(strupper(dd_cod1a),"*ANAESTHES*"))|!(strmatch(strupper(dd_cod1a),"*ANESTHES*"))|!(strmatch(strupper(dd_cod1a),"*NEONATAL*"))|!(strmatch(strupper(dd_cod1a),"*INTERSTITIAL*"))|!(strmatch(strupper(dd_cod1a),"*LIPID*"))|!(strmatch(strupper(dd_cod1a),"*ORNITHOSIS*"))|!(strmatch(strupper(dd_cod1a),"*PNEUMOCYSTOSIS*"))|!(strmatch(strupper(dd_cod1a),"*ABSCESS OF LUNG*"))|!(strmatch(strupper(dd_cod1a),"*ABSCESS OF THE LUNG*"))|!(strmatch(strupper(dd_cod1a),"*LUNG ABSCESS*"))) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "ACUTE") & regexm(dd_cod1d, "BRONCHITIS") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "ACUTE") & regexm(dd_cod1c, "BRONCHITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "ACUTE") & regexm(dd_cod1b, "BRONCHITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "ACUTE") & regexm(dd_cod1a, "BRONCHITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if dd_age<15 & regexm(dd_cod1d, "BRONCHITIS") &  topcods==. // changes
replace topcods=6 if dd_age<15 & regexm(dd_cod1c, "BRONCHITIS") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if dd_age<15 & regexm(dd_cod1b, "BRONCHITIS") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if dd_age<15 & regexm(dd_cod1a, "BRONCHITIS") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=6 if regexm(dd_cod1d, "COVID") &  topcods==. // changes
replace topcods=6 if regexm(dd_cod1c, "COVID") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1b, "COVID") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=6 if regexm(dd_cod1a, "COVID") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

tab dd_dodyear if topcods==6


*******************************************************************
** Malignant neoplasm of colon, rectosigmoid junction and rectum **
*******************************************************************
** Identify colorectal cancer (C18-C20) deaths using variable called 'topcods'
replace topcods=7 if regexm(dd_cod1d, "COLON") & !(strmatch(strupper(dd_cod1d),"*COLONIC LEAK*")) & !(strmatch(strupper(dd_cod1d),"*COLONIC DIVERTICU*")) &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "COLON") & !(strmatch(strupper(dd_cod1c),"*COLONIC LEAK*")) & !(strmatch(strupper(dd_cod1c),"*COLONIC DIVERTICU*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "COLON") & !(strmatch(strupper(dd_cod1b),"*COLONIC LEAK*")) & !(strmatch(strupper(dd_cod1b),"*COLONIC DIVERTICU*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "COLON") & !(strmatch(strupper(dd_cod1a),"*COLONIC LEAK*")) & !(strmatch(strupper(dd_cod1a),"*COLONIC DIVERTICU*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "LARGE INTESTIN") &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "LARGE INTESTIN") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "LARGE INTESTIN") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "LARGE INTESTIN") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "OF BOWEL") &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "OF BOWEL") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "OF BOWEL") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "OF BOWEL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "OF THE BOWEL") &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "OF THE BOWEL") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "OF THE BOWEL") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "OF THE BOWEL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "SIGMOID") & !(strmatch(strupper(dd_cod1d),"*SIGMOID HERNIA*")) & !(strmatch(strupper(dd_cod1d),"*SIGMOID VOLVULUS*")) &  topcods==. //0 changes
replace topcods=7 if regexm(dd_cod1c, "SIGMOID") & !(strmatch(strupper(dd_cod1c),"*SIGMOID HERNIA*")) & !(strmatch(strupper(dd_cod1c),"*SIGMOID VOLVULUS*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") //3 changes
replace topcods=7 if regexm(dd_cod1b, "SIGMOID") & !(strmatch(strupper(dd_cod1b),"*SIGMOID HERNIA*")) & !(strmatch(strupper(dd_cod1b),"*SIGMOID VOLVULUS*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //2 changes
replace topcods=7 if regexm(dd_cod1a, "SIGMOID") & !(strmatch(strupper(dd_cod1a),"*SIGMOID HERNIA*")) & !(strmatch(strupper(dd_cod1a),"*SIGMOID VOLVULUS*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") //1 changes

replace topcods=7 if regexm(dd_cod1d, "CECUM") & !(strmatch(strupper(dd_cod1d),"*DIVERTICULITIS OF CECUM*")) &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "CECUM") & !(strmatch(strupper(dd_cod1c),"*DIVERTICULITIS OF CECUM*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "CECUM") & !(strmatch(strupper(dd_cod1b),"*DIVERTICULITIS OF CECUM*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "CECUM") & !(strmatch(strupper(dd_cod1a),"*DIVERTICULITIS OF CECUM*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "CAECUM") & !(strmatch(strupper(dd_cod1d),"*DIVERTICULITIS OF CAECUM*")) &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "CAECUM") & !(strmatch(strupper(dd_cod1c),"*DIVERTICULITIS OF CAECUM*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "CAECUM") & !(strmatch(strupper(dd_cod1b),"*DIVERTICULITIS OF CAECUM*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "CAECUM") & !(strmatch(strupper(dd_cod1a),"*DIVERTICULITIS OF CAECUM*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "CECAL") &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "CECAL") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "CECAL") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "CECAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "CAECAL") &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "CAECAL") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "CAECAL") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "CAECAL") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "APPENDIX") & !(strmatch(strupper(dd_cod1d),"*RUPTURED APPENDIX*")) &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "APPENDIX") & !(strmatch(strupper(dd_cod1c),"*RUPTURED APPENDIX*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "APPENDIX") & !(strmatch(strupper(dd_cod1b),"*RUPTURED APPENDIX*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "APPENDIX") & !(strmatch(strupper(dd_cod1a),"*RUPTURED APPENDIX*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "APPENDIC") &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "APPENDIC") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "APPENDIC") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "APPENDIC") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "COLORECT") &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "COLORECT") &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "COLORECT") &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "COLORECT") &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=7 if regexm(dd_cod1d, "RECT") & !(strmatch(strupper(dd_cod1d),"*FOREIGN BODY IN RECTUM*")) &  topcods==. // changes
replace topcods=7 if regexm(dd_cod1c, "RECT") & !(strmatch(strupper(dd_cod1c),"*FOREIGN BODY IN RECTUM*")) &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1b, "RECT") & !(strmatch(strupper(dd_cod1b),"*FOREIGN BODY IN RECTUM*")) &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=7 if regexm(dd_cod1a, "RECT") & !(strmatch(strupper(dd_cod1a),"*FOREIGN BODY IN RECTUM*")) &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

** Manually correcting some erroneously written death certificate wherein the COD rules were misapplied
replace topcods=7 if dd_record_id==27623
replace topcods=7 if dd_record_id==26363
replace topcods=7 if dd_record_id==27422
//replace topcods=7 if dd_record_id==

tab dd_dodyear if topcods==7
/*
export_excel dd_record_id dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if topcods==. using "L:\Sync\BNR\Data Request\2022-01-31_2018-2020 deaths_COLORECTAL.xlsx", sheet("2018-2020 deaths") firstrow(variables) replace
*/

*****************************************
** Malignant neoplasm of female breast **
*****************************************
** Identify female breast cancer (C50) deaths using variable called 'topcods'
replace topcods=8 if regexm(dd_cod1d, "BREAST") & dd_sex!=2 &  topcods==. // changes
replace topcods=8 if regexm(dd_cod1c, "BREAST") & dd_sex!=2 &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=8 if regexm(dd_cod1b, "BREAST") & dd_sex!=2 &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=8 if regexm(dd_cod1a, "BREAST") & dd_sex!=2 &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace topcods=8 if regexm(dd_cod1d, "BREST") & dd_sex!=2 &  topcods==. // changes
replace topcods=8 if regexm(dd_cod1c, "BREST") & dd_sex!=2 &  topcods==. & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=8 if regexm(dd_cod1b, "BREST") & dd_sex!=2 &  topcods==. & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace topcods=8 if regexm(dd_cod1a, "BREST") & dd_sex!=2 &  topcods==. & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

tab dd_dodyear if topcods==8
/*
export_excel dd_record_id dd_sex dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if topcods==. using "L:\Sync\BNR\Data Request\2022-01-31_2018-2020 deaths_BREAST.xlsx", sheet("2018-2020 deaths") firstrow(variables) replace
*/

** List for AH to check the unidentified CODs do NOT belong to CVDs, IHDs, DMs
/*
export_excel dd_record_id dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if topcods==. using "L:\Sync\BNR\Data Request\2022-01-31_2018-2020 deaths_AH.xlsx", sheet("2018-2020 deaths") firstrow(variables) replace
*/

** List for AROB to check the unidentified CODs that should belong to Acute respiratory infections (ARI)
** Note AROB already checked up to record_id 24988 so continue the list after that record_id
/*
preserve
drop if dd_record_id<24989
export_excel dd_record_id dd_age dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if topcods==. using "L:\Sync\BNR\Data Request\2022-01-31_2018-2020 deaths_ARI_revised.xlsx", sheet("2018-2020 deaths") firstrow(variables) replace
restore
*/
** Reviewing SF's flagged cases wherein UCOD was improperly assigned
order dd_record_id dd_cod1d dd_cod1c dd_cod1b dd_cod1a topcods
count if topcods==. & (dd_record_id==26363|dd_record_id==27422|dd_record_id==29048|dd_record_id==25387|dd_record_id==26822 ///
		|dd_record_id==28362|dd_record_id==31923|dd_record_id==32141|dd_record_id==32708|dd_record_id==29564|dd_record_id==29085 ///
		|dd_record_id==33214|dd_record_id==29736|dd_record_id==29756|dd_record_id==25810|dd_record_id==28295|dd_record_id==28355 ///
		|dd_record_id==28915|dd_record_id==31738|dd_record_id==32196|dd_record_id==32429|dd_record_id==32549|dd_record_id==33747 ///
		|dd_record_id==33781|dd_record_id==33917|dd_record_id==33813|dd_record_id==25728|dd_record_id==26418|dd_record_id==26652 ///
		|dd_record_id==29013|dd_record_id==29581|dd_record_id==32501|dd_record_id==33288|dd_record_id==24310|dd_record_id==24369 ///
		|dd_record_id==24547|dd_record_id==24640|dd_record_id==24774|dd_record_id==24864|dd_record_id==25113|dd_record_id==25411 ///
		|dd_record_id==25436|dd_record_id==26297|dd_record_id==26463|dd_record_id==26534|dd_record_id==27132|dd_record_id==27507 ///
		|dd_record_id==27567|dd_record_id==27866|dd_record_id==28720|dd_record_id==28880|dd_record_id==29573|dd_record_id==31563 ///
		|dd_record_id==31910|dd_record_id==32170|dd_record_id==33036|dd_record_id==33052|dd_record_id==33474|dd_record_id==33706 ///
		|dd_record_id==33715)
//12

/* Stata Browse/Edit filter:
topcods==. & (dd_record_id==26363|dd_record_id==27422|dd_record_id==29048|dd_record_id==25387|dd_record_id==26822|dd_record_id==28362|dd_record_id==31923|dd_record_id==32141|dd_record_id==32708|dd_record_id==29564|dd_record_id==29085|dd_record_id==33214|dd_record_id==29736|dd_record_id==29756|dd_record_id==25810|dd_record_id==28295|dd_record_id==28355|dd_record_id==28915|dd_record_id==31738|dd_record_id==32196|dd_record_id==32429|dd_record_id==32549|dd_record_id==33747|dd_record_id==33781|dd_record_id==33917|dd_record_id==33813|dd_record_id==25728|dd_record_id==26418|dd_record_id==26652|dd_record_id==29013|dd_record_id==29581|dd_record_id==32501|dd_record_id==33288|dd_record_id==24310|dd_record_id==24369|dd_record_id==24547|dd_record_id==24640|dd_record_id==24774|dd_record_id==24864|dd_record_id==25113|dd_record_id==25411|dd_record_id==25436|dd_record_id==26297|dd_record_id==26463|dd_record_id==26534|dd_record_id==27132|dd_record_id==27507|dd_record_id==27567|dd_record_id==27866|dd_record_id==28720|dd_record_id==28880|dd_record_id==29573|dd_record_id==31563|dd_record_id==31910|dd_record_id==32170|dd_record_id==33036|dd_record_id==33052|dd_record_id==33474|dd_record_id==33706|dd_record_id==33715)
*/

** HD
replace topcods=5 if dd_record_id==28355|dd_record_id==28915|dd_record_id==29564|dd_record_id==29736|dd_record_id==29756 ///
					|dd_record_id==31738|dd_record_id==32196|dd_record_id==32708|dd_record_id==33214|dd_record_id==33813

** DM
replace topcods=3 if dd_record_id==33747|dd_record_id==24766

** CVD
replace topcods=1 if dd_record_id==26886|dd_record_id==25734|dd_record_id==26283|dd_record_id==29473|dd_record_id==27380 ///
				  |dd_record_id==32714|dd_record_id==33003|dd_record_id==26960|dd_record_id==27200|dd_record_id==26527 ///
				  |dd_record_id==26495|dd_record_id==29800|dd_record_id==29415|dd_record_id==24621|dd_record_id==26200 ///
				  |dd_record_id==26419|dd_record_id==26283|dd_record_id==28834|dd_record_id==28198|dd_record_id==32147 ///
				  |dd_record_id==32781|dd_record_id==33910|dd_record_id==31966|dd_record_id==32246|dd_record_id==29549 ///
				  |dd_record_id==34015|dd_record_id==24472|dd_record_id==26455|dd_record_id==26079|dd_record_id==26569 ///
				  |dd_record_id==25086|dd_record_id==24711|dd_record_id==24615|dd_record_id==24936|dd_record_id==26572 ///
				  |dd_record_id==30014|dd_record_id==26996|dd_record_id==27755|dd_record_id==27852|dd_record_id==28365 ///
				  |dd_record_id==28125|dd_record_id==28561|dd_record_id==33905

** Tables for brief (individual year tables manually copied into ...Sync\DM\Data\Data Request\MHW 2022\UCOD + premature NCD deaths tables.docx)
replace topcods=99 if topcods==.
sort topcods dd_dodyear
tab topcods dd_dodyear
/*
table (topcods) (dd_dodyear) , ///
statistic(frequency) ///
statistic(percent) ///
nototals

table (topcods) (dd_dodyear) , ///
statistic(frequency) ///
statistic(percent) 
*/
** 2018
table (topcods) if dd_dodyear==2018 , statistic(frequency) statistic(percent) 

** 2019
table (topcods) if dd_dodyear==2019, statistic(frequency) statistic(percent)

** 2020
table (topcods) if dd_dodyear==2020, statistic(frequency) statistic(percent)


collect levelsof topcods
collect label list topcods, all
collect dims

** List for SF to check the unidentified CODs do NOT belong to any of the above categories
/*
export_excel dd_record_id dd_dod dd_dodyear dd_cod1a dd_cod1b dd_cod1c dd_cod1d if topcods==. using "L:\Sync\BNR\Data Request\2022-02-01_2018-2020 deaths_SF.xlsx", sheet("2018-2020 deaths") firstrow(variables) replace
*/

/* Not used in the end
** Create data export for import to REDCap death db for project dashboard
preserve
rename dd_record_id record_id
export_excel record_id topcods if topcods==99 using "L:\Sync\DM\Stata\Stata do files\data_requests\2022\deaths\versions\version01\data\2022-02-01_2018-2020 topcods_forimport.xlsx", sheet("2018-2020 deaths") firstrow(variables) nolabel replace
restore
*/
******************************************************************** Premature deaths from NCDs ********************************************************************************

** Remove non-premature deaths
preserve

count //7,916
drop if dd_age<30 | dd_age>69 //5306 deleted
count //2610

** Create variable to classify the different causes of death
gen ncd = .
label define ncd_lab 1 "Yes" 2 "No" 88 "NA" 99 "ND" , modify
label values ncd ncd_lab
label var ncd "Premature NCD death"

replace ncd=1 if topcods!=. & topcods!=99 & topcods!=6 //859

** Add in other cancer diagnoses not flagged above using a new variable which will select out all the potential cancers
gen cancer=.
label define cancer_lab 1 "cancer" 2 "not cancer", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"

************************************
** UCOD (underlying COD) = Cancer **
************************************
** Identify all other cancer deaths using variable called 'topcods' + 'cancer'
replace cancer=1 if regexm(dd_cod1d, "CANCER") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "CANCER") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "CANCER") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "CANCER") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "TUMOUR") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "TUMOUR") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "TUMOUR") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "TUMOUR") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MALIGNANT") & !(strmatch(strupper(dd_cod1d),"*MALIGNANT HYPERTEN*")) &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MALIGNANT") & !(strmatch(strupper(dd_cod1c),"*MALIGNANT HYPERTEN*")) &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MALIGNANT") & !(strmatch(strupper(dd_cod1b),"*MALIGNANT HYPERTEN*")) &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MALIGNANT") & !(strmatch(strupper(dd_cod1a),"*MALIGNANT HYPERTEN*")) &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MALIGNANCY") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MALIGNANCY") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MALIGNANCY") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MALIGNANCY") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "NEOPLASM") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "NEOPLASM") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "NEOPLASM") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "NEOPLASM") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "CARCINOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "CARCINOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "CARCINOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "CARCINOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "CARCIMONA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "CARCIMONA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "CARCIMONA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "CARCIMONA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "CARINOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "CARINOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "CARINOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "CARINOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MYELOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MYELOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MYELOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MYELOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "LYMPHOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "LYMPHOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "LYMPHOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "LYMPHOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "LYMPHOMIA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "LYMPHOMIA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "LYMPHOMIA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "LYMPHOMIA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "LYMPHONA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "LYMPHONA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "LYMPHONA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "LYMPHONA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "SARCOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "SARCOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "SARCOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "SARCOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "TERATOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "TERATOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "TERATOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "TERATOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "LEUKEMIA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "LEUKEMIA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "LEUKEMIA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "LEUKEMIA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "LEUKAEMIA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "LEUKAEMIA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "LEUKAEMIA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "LEUKAEMIA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "HEPATOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "HEPATOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "HEPATOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "HEPATOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MENINGIOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MENINGIOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MENINGIOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MENINGIOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MYELOSIS") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MYELOSIS") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MYELOSIS") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MYELOSIS") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MYELOFIBROSIS") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MYELOFIBROSIS") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MYELOFIBROSIS") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MYELOFIBROSIS") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "CYTHEMIA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "CYTHEMIA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "CYTHEMIA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "CYTHEMIA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "CYTOSIS") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "CYTOSIS") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "CYTOSIS") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "CYTOSIS") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "BLASTOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "BLASTOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "BLASTOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "BLASTOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "METASTATIC") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "METASTATIC") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "METASTATIC") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "METASTATIC") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MASS") & !(strmatch(strupper(dd_cod1d),"*MASSIVE*")) &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MASS") & !(strmatch(strupper(dd_cod1c),"*MASSIVE*")) &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MASS") & !(strmatch(strupper(dd_cod1b),"*MASSIVE*")) &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MASS") & !(strmatch(strupper(dd_cod1a),"*MASSIVE*")) &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "METASTASES") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "METASTASES") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "METASTASES") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "METASTASES") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "METASTASIS") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "METASTASIS") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "METASTASIS") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "METASTASIS") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "REFRACTORY") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "REFRACTORY") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "REFRACTORY") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "REFRACTORY") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "FUNGOIDES") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "FUNGOIDES") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "FUNGOIDES") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "FUNGOIDES") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "HODGKIN") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "HODGKIN") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "HODGKIN") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "HODGKIN") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MELANOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MELANOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MELANOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MELANOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MYELODYS") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MYELODYS") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MYELODYS") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MYELODYS") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "ASTROCYTOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "ASTROCYTOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "ASTROCYTOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "ASTROCYTOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "CARCINOME") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "CARCINOME") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "CARCINOME") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "CARCINOME") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MALIGANCY") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MALIGANCY") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MALIGANCY") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MALIGANCY") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "MULTIFORME") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "MULTIFORME") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "MULTIFORME") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "MULTIFORME") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes

replace cancer=1 if regexm(dd_cod1d, "GLIOMA") &  topcods==99 // changes
replace cancer=1 if regexm(dd_cod1c, "GLIOMA") &  topcods==99 & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1b, "GLIOMA") &  topcods==99 & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes
replace cancer=1 if regexm(dd_cod1a, "GLIOMA") &  topcods==99 & (dd_cod1b==""|dd_cod1b=="99") & (dd_cod1c==""|dd_cod1c=="99") & (dd_cod1d==""|dd_cod1d=="99") // changes


tab cancer, missing //1682 missing

tab dd_dodyear cancer,m

** Check that all cancer CODs for 2018-2020 are eligible
sort dd_record_id
order dd_record_id dd_cod1d dd_cod1c dd_cod1b dd_cod1a topcods
//list dd_record_id dd_cod1a dd_cod1b dd_cod1c dd_cod1d if cancer!=1 & topcods==99 //1212 to check

count if ///
(regexm(dd_coddeath, "CANCER")|regexm(dd_coddeath, "TUMOUR")|regexm(dd_coddeath, "TUMOR")|regexm(dd_coddeath, "MALIGNANT") ///
|regexm(dd_coddeath, "MALIGNANCY")|regexm(dd_coddeath, "NEOPLASM")|regexm(dd_coddeath, "CARCINOMA")|regexm(dd_coddeath, "CARCIMONA") ///
|regexm(dd_coddeath, "CARINOMA")|regexm(dd_coddeath, "MYELOMA")|regexm(dd_coddeath, "LYMPHOMA")|regexm(dd_coddeath, "LYMPHOMIA") ///
|regexm(dd_coddeath, "LYMPHONA")|regexm(dd_coddeath, "SARCOMA")|regexm(dd_coddeath, "TERATOMA")|regexm(dd_coddeath, "LEUKEMIA") ///
|regexm(dd_coddeath, "LEUKAEMIA")|regexm(dd_coddeath, "HEPATOMA")|regexm(dd_coddeath, "MENINGIOMA")|regexm(dd_coddeath, "MYELOSIS") ///
|regexm(dd_coddeath, "MYELOFIBROSIS")|regexm(dd_coddeath, "CYTHEMIA")|regexm(dd_coddeath, "CYTOSIS")|regexm(dd_coddeath, "BLASTOMA") ///
|regexm(dd_coddeath, "METASTATIC")|regexm(dd_coddeath, "MASS")|regexm(dd_coddeath, "METASTASES")|regexm(dd_coddeath, "METASTASIS") ///
|regexm(dd_coddeath, "REFRACTORY")|regexm(dd_coddeath, "FUNGOIDES")|regexm(dd_coddeath, "HODGKIN")|regexm(dd_coddeath, "MELANOMA") ///
|regexm(dd_coddeath,"MYELODYS")|regexm(dd_coddeath,"ASTROCYTOMA")|regexm(dd_coddeath,"CARCINOME")|regexm(dd_coddeath,"MALIGANCY") ///
|regexm(dd_coddeath,"MULTIFORME")|regexm(dd_coddeath,"GLIOMA")) & cancer!=1 & topcods==99
//105
/*
Stata Browse/Edit filter:
(regexm(dd_coddeath, "CANCER")|regexm(dd_coddeath, "TUMOUR")|regexm(dd_coddeath, "TUMOR")|regexm(dd_coddeath, "MALIGNANT")|regexm(dd_coddeath, "MALIGNANCY")|regexm(dd_coddeath, "NEOPLASM")|regexm(dd_coddeath, "CARCINOMA")|regexm(dd_coddeath, "CARCIMONA")|regexm(dd_coddeath, "CARINOMA")|regexm(dd_coddeath, "MYELOMA")|regexm(dd_coddeath, "LYMPHOMA")|regexm(dd_coddeath, "LYMPHOMIA")|regexm(dd_coddeath, "LYMPHONA")|regexm(dd_coddeath, "SARCOMA")|regexm(dd_coddeath, "TERATOMA")|regexm(dd_coddeath, "LEUKEMIA")|regexm(dd_coddeath, "LEUKAEMIA")|regexm(dd_coddeath, "HEPATOMA")|regexm(dd_coddeath, "MENINGIOMA")|regexm(dd_coddeath, "MYELOSIS")|regexm(dd_coddeath, "MYELOFIBROSIS")|regexm(dd_coddeath, "CYTHEMIA")|regexm(dd_coddeath, "CYTOSIS")|regexm(dd_coddeath, "BLASTOMA")|regexm(dd_coddeath, "METASTATIC")|regexm(dd_coddeath, "MASS")|regexm(dd_coddeath, "METASTASES")|regexm(dd_coddeath, "METASTASIS")|regexm(dd_coddeath, "REFRACTORY")|regexm(dd_coddeath, "FUNGOIDES")|regexm(dd_coddeath, "HODGKIN")|regexm(dd_coddeath, "MELANOMA")|regexm(dd_coddeath,"MYELODYS")|regexm(dd_coddeath,"ASTROCYTOMA")|regexm(dd_coddeath,"CARCINOME")|regexm(dd_coddeath,"MALIGANCY")|regexm(dd_coddeath,"MULTIFORME")|regexm(dd_coddeath,"GLIOMA")) & cancer!=1 & topcods==99

list dd_record_id dd_cod1a dd_cod1b dd_cod1c dd_cod1d if ///
(regexm(dd_coddeath, "CANCER")|regexm(dd_coddeath, "TUMOUR")|regexm(dd_coddeath, "TUMOR")|regexm(dd_coddeath, "MALIGNANT") ///
|regexm(dd_coddeath, "MALIGNANCY")|regexm(dd_coddeath, "NEOPLASM")|regexm(dd_coddeath, "CARCINOMA")|regexm(dd_coddeath, "CARCIMONA") ///
|regexm(dd_coddeath, "CARINOMA")|regexm(dd_coddeath, "MYELOMA")|regexm(dd_coddeath, "LYMPHOMA")|regexm(dd_coddeath, "LYMPHOMIA") ///
|regexm(dd_coddeath, "LYMPHONA")|regexm(dd_coddeath, "SARCOMA")|regexm(dd_coddeath, "TERATOMA")|regexm(dd_coddeath, "LEUKEMIA") ///
|regexm(dd_coddeath, "LEUKAEMIA")|regexm(dd_coddeath, "HEPATOMA")|regexm(dd_coddeath, "MENINGIOMA")|regexm(dd_coddeath, "MYELOSIS") ///
|regexm(dd_coddeath, "MYELOFIBROSIS")|regexm(dd_coddeath, "CYTHEMIA")|regexm(dd_coddeath, "CYTOSIS")|regexm(dd_coddeath, "BLASTOMA") ///
|regexm(dd_coddeath, "METASTATIC")|regexm(dd_coddeath, "MASS")|regexm(dd_coddeath, "METASTASES")|regexm(dd_coddeath, "METASTASIS") ///
|regexm(dd_coddeath, "REFRACTORY")|regexm(dd_coddeath, "FUNGOIDES")|regexm(dd_coddeath, "HODGKIN")|regexm(dd_coddeath, "MELANOMA") ///
|regexm(dd_coddeath,"MYELODYS")|regexm(dd_coddeath,"ASTROCYTOMA")|regexm(dd_coddeath,"CARCINOME")|regexm(dd_coddeath,"MALIGANCY") ///
|regexm(dd_coddeath,"MULTIFORME")|regexm(dd_coddeath,"GLIOMA")) & cancer!=1 & topcods==99
*/


/*  2015 annual report mortality code
replace cancer=1 if regexm(dd_coddeath, "CANCER") & cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "TUMOUR") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "TUMOR") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MALIGNANT") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MALIGNANCY") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "NEOPLASM") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "CARCINOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "CARCIMONA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "CARINOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MYELOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "LYMPHOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "LYMPHOMIA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "LYMPHONA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "SARCOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "TERATOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "LEUKEMIA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "LEUKAEMIA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "HEPATOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "CARANOMA PROSTATE") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MENINGIOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MYELOSIS") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MYELOFIBROSIS") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "CYTHEMIA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "CYTOSIS") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "BLASTOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "METASTATIC") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MASS") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "METASTASES") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "METASTASIS") &  cancer==. // change
replace cancer=1 if regexm(dd_coddeath, "REFRACTORY") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "FUNGOIDES") &  cancer==. // change
replace cancer=1 if regexm(dd_coddeath, "HODGKIN") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath, "MELANOMA") &  cancer==. // change
replace cancer=1 if regexm(dd_coddeath,"MYELODYS") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath,"ASTROCYTOMA") &  cancer==. // changes
replace cancer=1 if regexm(dd_coddeath,"CARCINOME") &  cancer==. // change
replace cancer=1 if regexm(dd_coddeath,"MALIGANCY") &  cancer==. // change
replace cancer=1 if regexm(dd_coddeath,"MULTIFORME") &  cancer==. // change
replace cancer=1 if regexm(dd_coddeath,"GLIOMA") &  cancer==. // changes
*/

replace cancer=1 if dd_record_id==24593|dd_record_id==24890|dd_record_id==25025|dd_record_id==25132|dd_record_id==25152|dd_record_id==25344 ///
					|dd_record_id==25675|dd_record_id==25707|dd_record_id==25819|dd_record_id==25826|dd_record_id==26032|dd_record_id==26397 ///
					|dd_record_id==26597|dd_record_id==26742|dd_record_id==27794|dd_record_id==27952|dd_record_id==28066|dd_record_id==28069 ///
					|dd_record_id==28200|dd_record_id==28291|dd_record_id==28565|dd_record_id==28865|dd_record_id==29602|dd_record_id==31523 ///
					|dd_record_id==31969|dd_record_id==32209|dd_record_id==32899|dd_record_id==32991|dd_record_id==33035|dd_record_id==33144 ///
					|dd_record_id==33154|dd_record_id==33257|dd_record_id==33387|dd_record_id==33787|dd_record_id==33793|dd_record_id==34051 ///
					|dd_record_id==26355|dd_record_id==27136|dd_record_id==27443|dd_record_id==29040|dd_record_id==33048|dd_record_id==33230 ///
					|dd_record_id==27996|dd_record_id==28835
//44 changes of 105 records reviewed so 42% of the death certificates had UCOD improperly assigned.
					
replace cancer=. if dd_record_id==34006

replace ncd = 1 if cancer==1 //478 changes
replace ncd = 2 if ncd==. // changes

tab ncd dd_dodyear

** Tables for brief (individual year tables manually copied into ...Sync\DM\Data\Data Request\MHW 2022\UCOD + premature NCD deaths tables.docx)
** 2018
table (ncd) if dd_dodyear==2018 , statistic(frequency) statistic(percent) 

** 2019
table (ncd) if dd_dodyear==2019, statistic(frequency) statistic(percent)

** 2020
table (ncd) if dd_dodyear==2020, statistic(frequency) statistic(percent)

/* Not used in the end
rename dd_record_id record_id
export_excel record_id ncd if ncd!=1 using "L:\Sync\DM\Stata\Stata do files\data_requests\2022\deaths\versions\version01\data\2022-02-01_2018-2020 ncds_forimport.xlsx", sheet("2018-2020 deaths") firstrow(variables) nolabel replace
*/
restore

/*
** Create data export for import to REDCap death db for project dashboard
preserve
restore