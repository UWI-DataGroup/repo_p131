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
    version 16
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
cd "C:\Users\CVD 03\Desktop\BNR_data\DM\data_requests\2022\deaths\versions\version01"

** Begin a Stata logfile
log using "logfiles\top5_deaths.smcl", replace

** Automatic page scrolling of output
set more off

** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************
use "C:\Users\CVD 03\Desktop\BNR_data\DM\data_requests\2022\deaths\versions\version01\data\2015-2020_deaths_for_matching.dta", clear

count //15,416

rename dd6yrs_* dd_*

tab dd_dodyear ,m 

//drop if dd_dodyear <2017 //7,500 deleted

count //7,916


** Create variable to classify the different causes of death
gen topcods = .
label define topcods_lab 1 "Cerebrovascular diseases" 2 "Ischemic heart diseases" 3 "Diabetes mellitus" ///
						 4 "Malignant neoplasm of prostate" 5 "Hypertensive diseases" 6 "Acute respiratory infection" , modify
label values topcods topcods_lab
label var topcods "Top Causes of Death"


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



************************************
** Malignant neoplasm of prostate **
************************************
** Identify prostate cancer deaths using variable called 'topcods'
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
tab topcods dd_dodyear ,m

***************************
** Hypertensive diseases **
***************************

*********************************
** Acute respiratory infection **
*********************************