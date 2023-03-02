** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          criccs_update.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-NOV-2023
    // 	date last modified      17-NOV-2023
    //  algorithm task          Creating 2013-2015 cancer dataset for data submission to IARC-CI5
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2013-2015 data for inclusion in the CI5-XII submission.
    //  methods                 Update using:
	//							(1) analysis dataset from 2015 annual report process 
	//								(p117/version02 + VS Code branch: 2015AnnualReportV03);
	//							(2) feedback document from IARC-CI5 editorial board
	//								(see ...\Sync\DM\Data\Data Request\CI5\CI5 Response and Data Analysis)							

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
    log using "`logpath'\ci5 submission.smcl", replace
** HEADER -----------------------------------------------------

** Load cancer dataset from p117/version02: 2015AnnualReportV03 branch
use "`datapath'\version21\1-input\2013_2014_2015_cancer_nonsurvival", clear

** Run IARC conversion, consistency checks and MP check one last time
** Assign IARC flag values based on outcomes of these checks (use IARC DQ assessment outputs from Sarah where I checked some of these warnings already)

*****************************
** IARCcrgTools check + MP **
*****************************

** Copy the variables needed in Stata's Browse/Edit into an excel sheet in 2-working folder
//replace mpseq=1 if mpseq==0 //2918 changes
tab mpseq ,m //3 missing
//list pid fname lname mptot if mpseq==. //reviewed in Stata's Browse/Edit + CR5db
replace mptot=1 if mpseq==. & mptot==. //3 changes
replace mpseq=1 if mpseq==. //3 changes

tab icd10 ,m //none missing

** Create dates for use in IARCcrgTools
//drop dob_iarc dot_iarc

** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //27 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** Organize the variables to be used in IARCcrgTools to appear at start of the dataset in Browse/Edit
order pid sex top morph beh grade basis dot_iarc dob_iarc age mpseq mptot cr5id iarcflag
** Note: to copy results without value labels, I had to right-click Browse/Edit data, select Preferences --> Data Editor --> untick 'Copy value labels to the Clipboard instead of values'.
//Excel saved as .csv in 2-working\iarccrgtoolsV03.csv - added in mptot, cr5id + iarcflag to spot any errors in these fields

** Using the IARC Hub's guide, I prepared the excel sheet for use in IARCcrgTools, i.e. re-inserted leading zeros into topography.
** IARCcrgTools Check results
/*
IARC-Check program - Monday 01 November 2021-20:30
Input file: X:\The University of the West Indies\DataGroup - repo_data\data_p117\version21\2-working\Formatted dataset_20211101V02.prn
Output file: X:\The University of the West Indies\DataGroup - repo_data\data_p117\version21\2-working\Checked dataset_20211101V02.prn

2775 records processed. Summary statistics:

0 errors

75 warnings (73 individual records) recorded in X:\The University of the West Indies\DataGroup - repo_data\data_p117\version21\2-working\Formatted dataset_20211101V02.chk:

28 unlikely histology/site combination
21 unlikely grade/histology combination
25 unlikely basis/histology combination
1 unlikely age/site/histology combination
*/

** Assign IARC flag to the checked records then to all other records
replace iarcflag=2 if pid=="20130002" & cr5id=="T1S1"|pid=="20130093" & cr5id=="T1S1"|pid=="20130127" & cr5id=="T1S1"|pid=="20130137" & cr5id=="T1S1" ///
					  |pid=="20130169" & cr5id=="T1S1"|pid=="20130176" & cr5id=="T1S1"|pid=="20130192" & cr5id=="T1S1"|pid=="20130198" & cr5id=="T1S1" ///
					  |pid=="20130201" & cr5id=="T1S1"|pid=="20130226" & cr5id=="T1S1"|pid=="20130229" & cr5id=="T1S1"|pid=="20130251" & cr5id=="T1S1" ///
					  |pid=="20130264" & cr5id=="T1S1"|pid=="20130321" & cr5id=="T1S1"|pid=="20130341" & cr5id=="T1S1"|pid=="20130383" & cr5id=="T1S1" ///
					  |pid=="20130416" & cr5id=="T1S1"|pid=="20130426" & cr5id=="T1S1"|pid=="20130590" & cr5id=="T1S1"|pid=="20130594" & cr5id=="T1S1" ///
					  |pid=="20130727" & cr5id=="T1S1"|pid=="20130761" & cr5id=="T1S1"|pid=="20130819" & cr5id=="T1S1"|pid=="20139991" & cr5id=="T1S1" ///
					  |pid=="20139994" & cr5id=="T1S1"|pid=="20140058" & cr5id=="T1S1"|pid=="20140190" & cr5id=="T1S1"|pid=="20140228" & cr5id=="T1S1" ///
					  |pid=="20140256" & cr5id=="T1S1"|pid=="20140395" & cr5id=="T1S1"|pid=="20140525" & cr5id=="T1S1"|pid=="20140558" & cr5id=="T1S1" ///
					  |pid=="20140570" & cr5id=="T2S1"|pid=="20140573" & cr5id=="T1S1"|pid=="20140622" & cr5id=="T1S1"|pid=="20140687" & cr5id=="T1S1" ///
					  |pid=="20140707" & cr5id=="T1S1"|pid=="20141535" & cr5id=="T1S1"|pid=="20141542" & cr5id=="T1S1"|pid=="20141558" & cr5id=="T1S1" ///
					  |pid=="20145112" & cr5id=="T1S1"|pid=="20150019" & cr5id=="T1S1"|pid=="20150094" & cr5id=="T1S1"|pid=="20150096" & cr5id=="T1S1" ///
					  |pid=="20150132" & cr5id=="T1S1"|pid=="20150139" & cr5id=="T1S1"|pid=="20150165" & cr5id=="T1S1"|pid=="20150182" & cr5id=="T1S1" ///
					  |pid=="20150249" & cr5id=="T1S1"|pid=="20150293" & cr5id=="T1S1"|pid=="20150295" & cr5id=="T1S1"|pid=="20150336" & cr5id=="T1S1" ///
					  |pid=="20150373" & cr5id=="T1S1"|pid=="20150506" & cr5id=="T1S1"|pid=="20150574" & cr5id=="T1S1"|pid=="20151366" & cr5id=="T1S1" ///
					  |pid=="20155003" & cr5id=="T1S1"|pid=="20155008" & cr5id=="T1S1"|pid=="20155015" & cr5id=="T1S1"|pid=="20155035" & cr5id=="T1S1" ///
					  |pid=="20155047" & cr5id=="T1S1"|pid=="20155061" & cr5id=="T1S1"|pid=="20155197" & cr5id=="T1S1"|pid=="20155229" & cr5id=="T1S1" ///
					  |pid=="20155245" & cr5id=="T1S1"|pid=="20155255" & cr5id=="T1S1"|pid=="20159074" & cr5id=="T1S1"|pid=="20159077" & cr5id=="T1S1" ///
					  |pid=="20159102" & cr5id=="T1S1"|pid=="20159128" & cr5id=="T1S1"|pid=="20159129" & cr5id=="T1S1"|pid=="20180030" & cr5id=="T1S1"
//69 changes

replace iarcflag=1 if pid=="20130081" & cr5id=="T1S1" //1 change

replace top="069" if pid=="20130081" & cr5id=="T1S1"
replace topography=69 if pid=="20130081" & cr5id=="T1S1"
replace primarysite="MOUTH" if pid=="20130081" & cr5id=="T1S1"

tab iarcflag ,m
/*
  IARC Flag |      Freq.     Percent        Cum.
------------+-----------------------------------
         OK |         23        0.83        0.83
    Checked |         72        2.59        3.42
          . |      2,680       96.58      100.00
------------+-----------------------------------
      Total |      2,775      100.00
*/

replace iarcflag=1 if iarcflag==. //2680 changes

count if sourcetotal=="" //1,919
count if sourcetot==. //1,042
//Don't correct missing as not needed for CI5 Call for Data

count //2,774

append using "`datapath'\version21\2-working\criccs_preappend"

count //2,798
** 
destring sourcetotal ,replace

** 03nov2021 JC: Updating individual records based on review of CRICCS age<20 cases in CR5db, MEDData + DeathDb
replace sourcetotal=4 if pid=="20151381" & cr5id=="T1S1"
replace rx1=3 if pid=="20151381" & cr5id=="T1S1"
replace grade=6 if pid=="20151381" & cr5id=="T1S1"
replace rx1d=d(15dec2015) if pid=="20151381" & cr5id=="T1S1"
replace dlc=d(23jul2021) if pid=="20151381" & cr5id=="T1S1"
replace consrpt="FACILITY: DEPARTMENT OF ... LABORATORY MEDICINE DIVISION OF PATHOLOGY. CASE #: S16-879. FINDINGS: Lymph node biopsy (right cervical)-pre B cell lymphoblastic leukemia / lymphoma (see comment)." if pid=="20151381" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20150314" & cr5id=="T1S1"
replace rx2=3 if pid=="20150314" & cr5id=="T1S1"
replace rx2d=d(29feb2016) if pid=="20150314" & cr5id=="T1S1" //used unk day code as MEDData only had month and yr

replace sourcetotal=3 if pid=="20150303" & cr5id=="T1S1"
replace rx2=2 if pid=="20150303" & cr5id=="T1S1"
replace rx2d=d(11dec2018) if pid=="20150303" & cr5id=="T1S1"
replace dlc=d(01nov2021) if pid=="20150303" & cr5id=="T1S1"

replace sourcetotal=2 if pid=="20150096" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20150094" & cr5id=="T1S1"
replace consrpt="FACILITY: UHealth Pathology CASE #:UT15-3834...IHC: PLAP amd C-Kit postive, Keratin, CD30 and AFP negative." if pid=="20150094" & cr5id=="T1S1"
replace dot=d(04aug2015) if pid=="20150094" & cr5id=="T1S1"
replace dlc=d(19sep2021) if pid=="20150094" & cr5id=="T1S1"
replace rx1=3 if pid=="20150094" & cr5id=="T1S1"
replace rx1d=d(24aug2015) if pid=="20150094" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20150093" & cr5id=="T1S1"
replace dlc=d(03sep2021) if pid=="20150093" & cr5id=="T1S1"
replace rx1=3 if pid=="20150093" & cr5id=="T1S1"
replace rx1d=d(04jan2016) if pid=="20150093" & cr5id=="T1S1"
replace rx1=2 if pid=="20150093" & cr5id=="T1S1"
replace rx1d=d(12aug2016) if pid=="20150093" & cr5id=="T1S1"
replace mpseq=1 if pid=="20150093" & cr5id=="T1S1"
replace mptot=2 if pid=="20150093" & cr5id=="T1S1"
replace ptrectot=3 if pid=="20150093" & cr5id=="T1S1"
replace persearch=1 if pid=="20150093" & cr5id=="T1S1"

replace mpseq=2 if pid=="20150093" & cr5id=="T2S1"
replace mptot=2 if pid=="20150093" & cr5id=="T2S1"
replace patient=2 if pid=="20150093" & cr5id=="T2S1"
replace eidmp=2 if pid=="20150093" & cr5id=="T2S1"
replace persearch=2 if pid=="20150093" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20150093" & cr5id=="T2S1"
replace dcostatus=6 if pid=="20150093" & cr5id=="T2S1"

**

replace sourcetotal=4 if pid=="20150092" & cr5id=="T1S1"
replace consrpt="...IHC shows loss of INI-1, confirming this tumour." if pid=="20150092" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20150091" & cr5id=="T1S1"
replace consrpt="FACILITY: UHealth Pathology...IHC: Desmin, Myogenin and MYO-D1 positive." if pid=="20150091" & cr5id=="T1S1"
replace dlc=d(07oct2021) if pid=="20150091" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20150063" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20150013" & cr5id=="T1S1"
replace dot=d(04apr2015) if pid=="20150013" & cr5id=="T1S1"
replace top="414" if pid=="20150013" & cr5id=="T1S1"
replace topography=414 if pid=="20150013" & cr5id=="T1S1"
replace topcat=37 if pid=="20150013" & cr5id=="T1S1"
replace primarysite="BONE-ACETABULUM" if pid=="20150013" & cr5id=="T1S1"
replace rx1=3 if pid=="20150013" & cr5id=="T1S1"
replace rx1d=d(07dec2015) if pid=="20150013" & cr5id=="T1S1"
replace rx2=1 if pid=="20150013" & cr5id=="T1S1"
replace rx2d=d(29dec2017) if pid=="20150013" & cr5id=="T1S1"
replace grade=1 if pid=="20150013" & cr5id=="T1S1"

replace sourcetotal=9 if pid=="20150012" & cr5id=="T1S1"
replace rx1=3 if pid=="20150012" & cr5id=="T1S1"
replace rx1d=d(10sep2015) if pid=="20150012" & cr5id=="T1S1"

replace sourcetotal=7 if pid=="20150011" & cr5id=="T1S1"
replace rx1=3 if pid=="20150011" & cr5id=="T1S1"
replace rx1d=d(14jun2015) if pid=="20150011" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20141499" & cr5id=="T1S1"

replace sourcetotal=1 if pid=="20141482" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20141117" & cr5id=="T1S1"

replace sourcetotal=5 if pid=="20140838" & cr5id=="T1S1"
replace rx1=2 if pid=="20140838" & cr5id=="T1S1"
replace rx1d=d(30apr2016) if pid=="20140838" & cr5id=="T1S1"
replace rx1=3 if pid=="20140838" & cr5id=="T1S1"
replace rx1d=d(30jun2016) if pid=="20140838" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20140829" & cr5id=="T1S1"
replace rx1=3 if pid=="20140829" & cr5id=="T1S1"
replace rx1d=d(29mar2015) if pid=="20140829" & cr5id=="T1S1"

replace sourcetotal=2 if pid=="20140827" & cr5id=="T1S1"

replace sourcetotal=2 if pid=="20140826" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20140825" & cr5id=="T1S1"
replace dlc=d(25sep2021) if pid=="20140825" & cr5id=="T1S1"
replace rx1=3 if pid=="20140825" & cr5id=="T1S1"
replace rx1d=d(09apr2015) if pid=="20140825" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20140817" & cr5id=="T1S1"
replace dlc=d(03oct2021) if pid=="20140817" & cr5id=="T1S1"
replace rx1=3 if pid=="20140817" & cr5id=="T1S1"
replace rx1d=d(07mar2016) if pid=="20140817" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20140699" & cr5id=="T1S1"
replace grade=4 if pid=="20140699" & cr5id=="T1S1"
replace dlc=d(15oct2021) if pid=="20140699" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20140676" & cr5id=="T1S1"
replace grade=6 if pid=="20140676" & cr5id=="T1S1"
replace rx1=3 if pid=="20140676" & cr5id=="T1S1"
replace rx1d=d(31mar2015) if pid=="20140676" & cr5id=="T1S1"

replace sourcetotal=2 if pid=="20140434" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20140395" & cr5id=="T1S1"
replace grade=5 if pid=="20140395" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20130694" & cr5id=="T1S1"
replace grade=3 if pid=="20130694" & cr5id=="T1S1"
replace natregno=subinstr(natregno,"9999","0196",.) if pid=="20130694" & cr5id=="T1S1"
replace dlc=d(30sep2021) if pid=="20130694" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20130373" & cr5id=="T1S1"

replace sourcetotal=3 if pid=="20130369" & cr5id=="T1S1"

replace sourcetotal=5 if pid=="20130084" & cr5id=="T1S1"
replace dlc=d(29oct2021) if pid=="20130084" & cr5id=="T1S1"

replace sourcetotal=4 if pid=="20130072" & cr5id=="T1S1"


** For IARC-CRICCS submission 31-oct-2021, create time variable for time from:
** (1) incidence date to death
** (2) incidence date to 31-dec-2020 (death data being included in submission)
gen survtime_days=dod-dot
replace survtime_days=d(31dec2020)-dot
label var survtime_days "Survival Time in Days"

gen survtime_months=dod-dot
replace survtime_months=(d(31dec2020)-dot)/(365/12)
label var survtime_months "Survival Time in Months"

**************************************************************************
** Corrections based on feedback from IARC CI5's submission 17-Nov-2021 **
**************************************************************************
drop _merge

preserve
clear
import excel using "`datapath'\version21\2-working\CI5corrections20211117.xlsx" , firstrow case(lower)
tostring pid ,replace
tostring elec_nrn ,replace
save "`datapath'\version21\2-working\ci5update" ,replace
restore
merge 1:1 pid cr5id using "`datapath'\version21\2-working\ci5update" ,update replace
/*

*/
** Added DOB info to above excel sheet for pid 20139991 based on KWG's feedback via WhatsApp 17-Nov-2021
** Update variables with above corrected info
replace natregno = elec_nrn if elec_nrn!="" //21 changes
replace dob = elec_dob if elec_dob!=. //21 changes
replace addr = elec_addr if elec_addr!="" //10 changes
replace parish = elec_parish if elec_parish!=. //8 changes
replace dlc = elec_dlc if elec_dlc!=. //10 changes

** Update age with above corrected DOBs
gen elec_age = (dot - dob)/365.25 if elec_dob!=.
replace age = elec_age if elec_age!=. //21 changes

drop elec_* _merge

** Update other variables based on re-review of IARC CI5's queries
replace primarysite="BONE MARROW" if pid=="20139991" & cr5id=="T1S1"
replace top="421" if pid=="20139991" & cr5id=="T1S1"
replace topography=421 if pid=="20139991" & cr5id=="T1S1"
replace topcat=38 if pid=="20139991" & cr5id=="T1S1"

replace primarysite="BONE MARROW" if pid=="20150574" & cr5id=="T1S1"
replace top="421" if pid=="20150574" & cr5id=="T1S1"
replace topography=421 if pid=="20150574" & cr5id=="T1S1"
replace topcat=38 if pid=="20150574" & cr5id=="T1S1"

replace primarysite="BONE MARROW" if pid=="20180030" & cr5id=="T1S1"
replace top="421" if pid=="20180030" & cr5id=="T1S1"
replace topography=421 if pid=="20180030" & cr5id=="T1S1"
replace topcat=38 if pid=="20180030" & cr5id=="T1S1"

/*
replace basis=1 if pid=="20140228" cr5id=="T1S1"
replace basis=1 if pid=="20140256" cr5id=="T1S1"
replace basis=1 if pid=="20140570" & cr5id=="T2S1"
replace basis=1 if pid=="20140573" cr5id=="T1S1"
replace basis=1 if pid=="20140622" cr5id=="T1S1"
replace basis=1 if pid=="20141542" cr5id=="T1S1"
*/
*******************************************************************************

** Identify duplicate pids to assist with death matching
sort pid cr5id
drop dup_pid
duplicates tag pid, gen(dup_pid)
count if dup_pid>0 //88
count if dup_pid==0 //2710
//list pid cr5id dup_pid age if dup_pid>0, nolabel sepby(pid)
//list pid cr5id dup_pid age if dup_pid==0, nolabel sepby(pid)
count if age<20 & dup_pid>0  //2 - pid 20150093
//list pid cr5id fname lname patient if age<20 & dup_pid>0

count if age<20 //54

count //2798

** Create LONG dataset as per CRICCS Call for Data
/*
preserve

gen mpseq2=mpseq
tostring mpseq2 ,replace
replace mpseq2="0"+mpseq2

tab sex ,m
labelbook sex_lab
label drop sex_lab
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label define sex_lab 1 "male" 2 "female" 9 "unknown", modify
label values sex sex_lab
label var sex "Sex"
tab sex ,m

count if dob==. //27
gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_criccs
label var dob_criccs "CRICCS BirthDate"
count if dob_criccs=="" //27
gen nrnyr1="19" if dob_criccs==""
gen nrnyr2 = substr(natregno,1,2) if dob_criccs==""
gen nrnyr = nrnyr1 + nrnyr2 + "9999" if dob_criccs==""
replace dob_criccs=nrnyr if dob_criccs=="" //27 changes

gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_criccs
label var dot_criccs "CRICCS IncidenceDate"

gen age_criccs_d = dot-dob
gen age_criccs_m = (dot-dob)/(365.25/12)
gen age_criccs_y = (dot-dob)/365.25
 
gen icdo=3 if dxyr==2013
label define icdo_lab 1 "ICD-O" 2 "ICD-O-2" 3 "ICD-O-3" ///
					  4 "ICD-O-3.1" 5 "ICD-O-3.2" 9 "unknown" , modify
label values icdo icdo_lab
replace icdo=4 if dxyr>2013 & dxyr<2020

label drop slc_lab
label define slc_lab 1 "alive" 2 "deceased" 9 "unknown", modify
label values slc slc_lab
replace slc=9 if slc==99 //0 changes
tab slc ,m 

replace dlc=dod if slc==2 //0 changes
gen DLCYR=year(dlc)
tostring DLCYR, replace
gen DLCMONTH=month(dlc)
gen str2 DLCMM = string(DLCMONTH, "%02.0f")
gen DLCDAY=day(dlc)
gen str2 DLCDD = string(DLCDAY, "%02.0f")
gen DLC=DLCYR+DLCMM+DLCDD
replace DLC="" if DLC=="..." //0 changes
drop DLCMONTH DLCDAY DLCYR DLCMM DLCDD
rename DLC dlc_criccs
label var dlc_criccs "CRICCS Date at Last Contact"

count if survtime_days==. & slc!=2 //0
count if survtime_months==. & slc!=2 //0

label drop iarcflag_lab
label define iarcflag_lab 0 "failed" 1 "OK" 2 "OK after verification" 9 "unknown", modify
label values iarcflag iarcflag_lab
replace iarcflag=9 if iarcflag==99 //0 changes
tab iarcflag ,m 

rename pid v03
rename mpseq2 v04
rename sex v05
rename dob_criccs v06
rename dot_criccs v07
rename age_criccs_d v09
rename age_criccs_m v10
rename age_criccs_y v11
rename topography v12
rename morph v13
rename beh v14
rename basis v16
rename icdo v17
rename slc v23
rename dlc_criccs v24
rename survtime_days v25
rename survtime_months v26
rename iarcflag v57

keep v*
order v03 v04 v05 v06 v07 v09 v10 v11 v12 v13 v14 v16 v17 v23 v24 v25 v26 v57
count if v05==. //0
count if v06=="" //0
count if v07=="" //0
count if v09==. //27
replace v09=99999 if v09==. //27 changes
count if v10==. //27
replace v10=9999 if v10==. //27 changes
count if v11==. //27
replace v11=999 if v11==. //27 changes
count if v12==. //0
count if v13==. //0
count if v14==. //0
count if v16==. //0
count if v17==. //0
count if v23==. //0
count if v24=="" //0
count if v25==. //0
count if v26==. //0
count if v57==. //0
count //2798
capture export_excel using "`datapath'\version21\3-output\CRICCS_LONG_V03.xlsx", sheet("2013-2015all_2016-2018child") firstrow(variables) nolabel replace

restore


** Create WIDE dataset as per CRICCS Call for Data
preserve

drop if age>19 //2744 deleted
count //54

gen mpseq2=mpseq
tostring mpseq2 ,replace
replace mpseq2="0"+mpseq2

tab sex ,m
labelbook sex_lab
label drop sex_lab
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label define sex_lab 1 "male" 2 "female" 9 "unknown", modify
label values sex sex_lab
label var sex "Sex"
tab sex ,m

count if dob==. //0
gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_criccs
label var dob_criccs "CRICCS BirthDate"
count if dob_criccs=="" //27
gen nrnyr1="19" if dob_criccs==""
gen nrnyr2 = substr(natregno,1,2) if dob_criccs==""
gen nrnyr = nrnyr1 + nrnyr2 + "9999" if dob_criccs==""
//replace dob_criccs=nrnyr if dob_criccs=="" // changes

gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_criccs
label var dot_criccs "CRICCS IncidenceDate"

gen CFYR=year(ptdoa)
tostring CFYR, replace
gen CFMONTH=month(ptdoa)
gen str2 CFMM = string(CFMONTH, "%02.0f")
gen CFDAY=day(ptdoa)
gen str2 CFDD = string(CFDAY, "%02.0f")
gen CF=CFYR+CFMM+CFDD
replace CF="" if CF=="..." //0 changes
drop CFMONTH CFDAY CFYR CFMM CFDD
rename CF ptdoa_criccs
label var ptdoa_criccs "CRICCS Casefinding Date"
count if ptdoa_criccs=="20000101" //7
replace ptdoa_criccs="20140310" if pid=="20130072" //1 change
replace ptdoa_criccs="20140505" if pid=="20130084" //1 change
replace ptdoa_criccs="20141215" if pid=="20130369" //1 change
replace ptdoa_criccs="20141013" if pid=="20130373" //1 change
replace ptdoa_criccs="20140310" if pid=="20130694" //1 change
replace ptdoa_criccs="20160219" if pid=="20140395" //1 change
replace ptdoa_criccs="20181129" if pid=="20140434" //1 change

gen age_criccs_d = dot-dob
gen age_criccs_m = (dot-dob)/(365.25/12)
gen age_criccs_y = (dot-dob)/365.25
 
gen icdo=3 if dxyr==2013
label define icdo_lab 1 "ICD-O" 2 "ICD-O-2" 3 "ICD-O-3" ///
					  4 "ICD-O-3.1" 5 "ICD-O-3.2" 9 "unknown" , modify
label values icdo icdo_lab
replace icdo=4 if dxyr>2013 & dxyr<2020

label drop slc_lab
label define slc_lab 1 "alive" 2 "deceased" 9 "unknown", modify
label values slc slc_lab
replace slc=9 if slc==99 //0 changes
tab slc ,m 

replace dlc=dod if slc==2 //0 changes
gen DLCYR=year(dlc)
tostring DLCYR, replace
gen DLCMONTH=month(dlc)
gen str2 DLCMM = string(DLCMONTH, "%02.0f")
gen DLCDAY=day(dlc)
gen str2 DLCDD = string(DLCDAY, "%02.0f")
gen DLC=DLCYR+DLCMM+DLCDD
replace DLC="" if DLC=="..." //0 changes
drop DLCMONTH DLCDAY DLCYR DLCMM DLCDD
rename DLC dlc_criccs
label var dlc_criccs "CRICCS Date at Last Contact"

count if survtime_days==. & slc!=2 //0
count if survtime_months==. & slc!=2 //0

label drop lat_lab
label define lat_lab 1 "unilateral, any side" 2 "bilateral" 3 "right" 4 "left" 9 "unknown", modify
label values lat lat_lab
replace lat=9 if lat==0 //40 changes
replace lat=3 if lat==1 //7 changes
replace lat=2 if lat==4 //0 changes
replace lat=4 if lat==2 //4 changes
replace lat=9 if lat==99 //0 changes
replace lat=9 if lat==8 //3 changes
tab lat ,m

gen stagesys=88
label define stagesys_lab 01 "Ann Arbor" 02 "Breslow" 03 "Dukes" 04"FIGO" 05 "Gleason" ///
						  06 "INGRSS" 07 "IRSS" 08 "Murphy" 09 "PRETEXT" 10 "St Jude" ///
						  11 "TNM" 12 "Toronto" 88 "other" 99 "not collected or unknown", modify
label values stagesys stagesys_lab
replace stagesys=99 if staging==8 //33 changes

replace staging=9 if staging==8|staging==. //48 changes
replace staging=3 if staging==3 //0 changes
replace staging=4 if staging==7 //2 changes
label drop staging_lab
label define staging_lab 0 "stage 0, stage 0a, stage 0is, carcinoma in situ, non-invasive" ///
						 1 "stage I, FIGO I, localized, localized limited (L), limited, Dukes A" ///
						 2 "stage II, FIGO II, localized advanced (A), locally advanced, advanced, direct extension, Dukes B" ///
						 3 "stage III, FIGO III, regional (with or without direct extension), R+, N+, Dukes C" ///
						 4 "stage IV, FIGO IV, metastatic, distant, M+, Dukes D" 9 "unknown" , modify
label values staging staging_lab
tab staging ,m

replace rx1d=. if rx1d==d(01jan2000)
replace rx2d=. if rx2d==d(01jan2000)
replace rx3d=. if rx3d==d(01jan2000)
replace rx4d=. if rx4d==d(01jan2000)
replace rx5d=. if rx5d==d(01jan2000)

gen sx=1 if rx1==1|rx2==1|rx3==1
replace sx=9 if sx==. //44 changes
label define sx_lab 1 "yes" 2 "no" 9 "unknown", modify
label values sx sx_lab

gen RX1YR=year(rx1d)
tostring RX1YR, replace
gen RX1MONTH=month(rx1d)
gen str2 RX1MM = string(RX1MONTH, "%02.0f")
gen RX1DAY=day(rx1d)
gen str2 RX1DD = string(RX1DAY, "%02.0f")
gen RX1=RX1YR+RX1MM+RX1DD
replace RX1="" if RX1=="..." //0 changes
drop RX1MONTH RX1DAY RX1YR RX1MM RX1DD
rename RX1 rx1d_criccs
label var rx1d_criccs "CRICCS Rx1 Date"

gen RX2YR=year(rx2d)
tostring RX2YR, replace
gen RX2MONTH=month(rx2d)
gen str2 RX2MM = string(RX2MONTH, "%02.0f")
gen RX2DAY=day(rx2d)
gen str2 RX2DD = string(RX2DAY, "%02.0f")
gen RX2=RX2YR+RX2MM+RX2DD
replace RX2="" if RX2=="..." //0 changes
drop RX2MONTH RX2DAY RX2YR RX2MM RX2DD
rename RX2 rx2d_criccs
label var rx2d_criccs "CRICCS Rx2 Date"

gen RX3YR=year(rx3d)
tostring RX3YR, replace
gen RX3MONTH=month(rx3d)
gen str2 RX3MM = string(RX3MONTH, "%02.0f")
gen RX3DAY=day(rx3d)
gen str2 RX3DD = string(RX3DAY, "%02.0f")
gen RX3=RX3YR+RX3MM+RX3DD
replace RX3="" if RX3=="..." //0 changes
drop RX3MONTH RX3DAY RX3YR RX3MM RX3DD
rename RX3 rx3d_criccs
label var rx3d_criccs "CRICCS Rx3 Date"

gen sxd=rx1d_criccs if rx1==1
replace sxd=rx2d_criccs if rx2==1
replace sxd=rx3d_criccs if rx3==1

gen chemo=1 if rx1==3|rx2==3|rx3==3
replace chemo=9 if chemo==. //32 changes
label define chemo_lab 1 "yes" 2 "no" 9 "unknown", modify
label values chemo chemo_lab

gen chemod=rx1d_criccs if rx1==3 //20 changes
replace chemod=rx2d_criccs if rx2==3 //2 changes
replace chemod=rx3d_criccs if rx3==3 //0 changes

gen rt=1 if rx1==2|rx2==2|rx3==2
replace rt=9 if rt==. //4 changes
label define rt_lab 1 "yes" 2 "no" 9 "unknown", modify
label values rt rt_lab

gen rtd=rx1d_criccs if rx1==2 //2 changes
replace rtd=rx2d_criccs if rx2==2 //2 changes
replace rtd=rx3d_criccs if rx3==2 //0 changes

gen rtunit=9 if rx1==2|rx2==2|rx3==2
label define rtunit_lab 1 "miliGray (mGy)" 2 "centiGray (cGy)" 3 "Gray (Gy)" 9 "unknown", modify
label values rtunit rtunit_lab

gen rtdose=99999 if rx1==2|rx2==2|rx3==2

gen rtmeth=9 if rx1==2|rx2==2|rx3==2
label define rtmeth_lab 1 "brachytherapy" 2 "stereotactic radiotherapy" 3 "RT2D (Conventional radiotherapy, bidimensional)" 4 "RT3D (Conformal radiotherapy, tridimensional)" 5 "IMRT (Intensity-modulated radiation therapy)" 6 "IGRT (Image-guided radiation therapy)" 7 "IORT (Intraoperative radiation therapy)" 8 "other" 9 "unknown", modify
label values rtmeth rtmeth_lab

gen rtbody=99 if rx1==2|rx2==2|rx3==2
label define rtbody_lab 01 "head / brain" 02 "neck" 03 "spine" 04 "thorax" 05 "abdomen" 06 "pelvis" 07 "testicular" 08 "arms" 09 "legs" 10 "total body irradiation (TBI)" 11 "combined fields" 88 "other" 99 "unknown", modify
label values rtbody rtbody_lab

gen rxend=9 if rx1!=. & rx1!=9 //34 changes
replace rxend=9 if rx2!=. & rx2!=9 //0 changes
replace rxend=9 if rx3!=. & rx3!=9 //0 changes
label define rxend_lab 1 "end of treatment" 2 "death" 3 "abandonment or refusal" 4 "side effects" 5 "migration" 6 "disease progression" 8 "other" 9 "unknown", modify
label values rxend rxend_lab

label drop iarcflag_lab
label define iarcflag_lab 0 "failed" 1 "OK" 2 "OK after verification" 9 "unknown", modify
label values iarcflag iarcflag_lab
replace iarcflag=9 if iarcflag==99 //0 changes
tab iarcflag ,m 

rename pid v03
rename mpseq2 v04
rename sex v05
rename dob_criccs v06
rename dot_criccs v07
rename ptdoa_criccs v08
rename age_criccs_d v09
rename age_criccs_m v10
rename age_criccs_y v11
rename topography v12
rename morph v13
rename beh v14
rename grade v15
rename basis v16
rename icdo v17
rename lat v18
rename stagesys v19
rename staging v20
rename slc v23
rename dlc_criccs v24
rename survtime_days v25
rename survtime_months v26
rename sx v33
rename sxd v34
rename chemo v46
rename chemod v47
rename rt v50
rename rtd v51
rename rtunit v52
rename rtdose v53
rename rtmeth v54
rename rtbody v55
rename rxend v56
rename iarcflag v57

keep v* mpseq
order v03 v04 v05 v06 v07 v08 v09 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v23 v24 v25 v26 v33 v34 v46 v47 v50 v51 v52 v53 v54 v55 v56 v57

count if v05==. //0
count if v06=="" //0
count if v07=="" //0
count if v08=="" //0
count if v09==. //0
count if v10==. //0
count if v11==. //0
count if v12==. //0
count if v13==. //0
count if v14==. //0
count if v15==. //0
count if v16==. //0
count if v17==. //0
count if v18==. //0
count if v19==. //0
count if v20==. //0
count if v23==. //0
count if v24=="" //0
count if v25==. //0
count if v26==. //0

count if v33==. //0
count if v34=="" //44
replace v34="99999999" if v34=="" //44 changes
count if v46==. //0
count if v47=="" //32
replace v47="99999999" if v47=="" //32 changes
count if v50==. //0
count if v51=="" //50
replace v51="99999999" if v51=="" //32 changes
count if v52==. //50
replace v52=9 if v52==. //50 changes
count if v53==. //50
replace v53=99999 if v53==. //50 changes
count if v54==. //50
replace v54=9 if v54==. //50 changes
count if v55==. //50
replace v55=99 if v55==. //50 changes
count if v56==. //20
replace v56=9 if v56==. //20 changes
count if v57==. //0

count //54

/*
destring v03 ,replace
reshape wide v04 v05 v06 v07 v08 v09 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v23 v24 v25 v26 v33 v34 v46 v47 v50 v51 v52 v53 v54 v55 v56 v57, i(v03) j(mpseq)
*/

drop mpseq
** I'll manually make it a wide dataset
capture export_excel using "`datapath'\version21\3-output\CRICCS_WIDE_V03.xlsx", sheet("2013-2018child") firstrow(variables) nolabel replace

restore
*/

** Corrections for 2013-2015 CI5 dataset
drop if dxyr >2015 //21 deleted - removed CRICCS 2016-2018 cases
replace staging=1 if staging==0 //2 changes

** Create LONG (case listing) dataset as per CI5 Call for Data - save as .csv
preserve

count if pid=="" //0
label var pid "Patient ID"

gen mpseq2=mpseq
tostring mpseq2 ,replace
replace mpseq2="0"+mpseq2
drop mpseq
rename mpseq2 mpseq

count if mpseq=="" //0
label var mpseq "Tumour sequence #"

count if dob==. //27
gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_ci5
label var dob_ci5 "CI5 BirthDate"
count if dob_ci5=="" //27
gen nrnyr1="19" if dob_ci5==""
gen nrnyr2 = substr(natregno,1,2) if dob_ci5==""
gen nrnyr = nrnyr1 + nrnyr2 + "9999" if dob_ci5==""
replace dob_ci5=nrnyr if dob_ci5=="" //27 changes
count if dob_ci5=="" //0
label var dob_ci5 "Date of Birth"

tab sex ,m
labelbook sex_lab
label drop sex_lab
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label define sex_lab 1 "Male" 2 "Female" 9 "Unknown", modify
label values sex sex_lab
label var sex "Sex"
tab sex ,m

count if dot==. //0
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_ci5
label var dot_ci5 "Date of Incidence"

count if age==. //0
label var age "Age in Years"
/*
gen age_ci5 = (dot-dob)/365.25
label var age_ci5 "CI5 Age"
tab age_ci5 ,m
*/

count if top=="" //0
replace top="C"+top
count if !(strmatch(strupper(top), "C*")) //0
label var top "ICDO-3 Topography"

count if morph==. //0
label var morph "ICDO-3 Morphology"

count if beh==. //0
label var beh "ICDO-3 Behaviour"

count if basis==. //0
count if basis >7 //143
tab basis ,m
** reviewed 19 cases with code 8 to determine if to put them in code 6 or 7 field as CI5 doesn't collect code 8
replace basis=2 if basis==3 //20 changes
replace basis=6 if pid=="20130527" & cr5id=="T1S1" | pid=="20130724" & cr5id=="T1S1" //2 changes
replace basis=7 if basis==8 //17 changes
tab basis ,m

label drop basis_lab
label define basis_lab 0 "Death certificate only" 1 "Clinical" 2 "Clinical investigation" 4 "Specific tumor markers" ///
					   5 "Cytology" 6 "Histology of a metastasis" 7 "Histology of a primary tumor" 9 "Unknown", modify
label values basis basis_lab
label var basis "Basis of Diagnosis"
tab basis ,m

count if slc==. //0
tab slc ,m
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Dead" 3 "Lost to follow-up" 9 "Vital status not known" , modify
label values slc slc_lab
label var slc "Vital Status"
tab slc ,m

count if dlc==. //0
count if dod==. & slc==2 //0
replace dlc=dod if slc==2 //0 changes
gen DLCYR=year(dlc)
tostring DLCYR, replace
gen DLCMONTH=month(dlc)
gen str2 DLCMM = string(DLCMONTH, "%02.0f")
gen DLCDAY=day(dlc)
gen str2 DLCDD = string(DLCDAY, "%02.0f")
gen DLC=DLCYR+DLCMM+DLCDD
replace DLC="" if DLC=="..." //0 changes
drop DLCMONTH DLCDAY DLCYR DLCMM DLCDD
rename DLC dlc_ci5
label var dlc_ci5 "Date of Last Contact"

count if iarcflag==. //0
tab iarcflag ,m

count if staging==. & dxyr==2013 //0
tab staging dxyr ,m
replace staging=9 if staging==8 | staging==. //1942 changes
replace staging=1 if staging==0 //2 cahnges already made above
replace staging=2 if staging >2 & staging <7 //97 changes
replace staging=3 if staging==7 //164 changes
tab staging dxyr ,m

label drop staging_lab
label define staging_lab 1 "Localized" 2 "Regional" 3 "Distant metastases" ///
						 9 "Unknown if extension or metastasis (unstaged, unknown, or unspecified) Death certificate only case" , modify
label values staging staging_lab
label var staging "Clinical extent of disease"
tab staging ,m


** Create Stata dictionaries for topography and morph based on CR5db data dictionary
label define topography_lab ///
000	"C00.0 External upper lip" ///
001	"C00.1 External lower lip" ///
002	"C00.2 External lip, NOS" ///
003	"C00.3 Mucosa of upper lip" ///
004	"C00.4 Mucosa of lower lip" ///
005	"C00.5 Mucosa of lip, NOS" ///
006	"C00.6 Commissure of lip" ///
008	"C00.8 Overl. lesion of lip" ///
009	"C00.9 Lip, NOS" ///
019	"C01.9 Base of tongue, NOS" ///
020	"C02.0 Dorsal surface of tongue, NOS" ///
021	"C02.1 Border of tongue" ///
022	"C02.2 Ventral surface of tongue, NOS" ///
023	"C02.3 Anterior 2/3 of tongue, NOS" ///
024	"C02.4 Lingual tonsil" ///
028	"C02.8 Overl. lesion of tongue" ///
029	"C02.9 Tongue, NOS" ///
030	"C03.0 Upper gum" ///
031	"C03.1 Lower gum" ///
039	"C03.9 Gum, NOS" ///
040	"C04.0 Anterior floor of mouth" ///
041	"C04.1 Lateral floor of mouth" ///
048	"C04.8 Overl. lesion of floor of mouth" ///
049	"C04.9 Floor of mouth, NOS" ///
050	"C05.0 Hard palate" ///
051	"C05.1 Soft palate, NOS" ///
052	"C05.2 Uvula" ///
058	"C05.8 Overl. lesion of palate" ///
059	"C05.9 Palate, NOS" ///
060	"C06.0 Cheek mucosa" ///
061	"C06.1 Vestibule of mouth" ///
062	"C06.2 Retromolar area" ///
068	"C06.8 Overl. lesion of other/unspec. parts of mouth" ///
069	"C06.9 Mouth, NOS" ///
079	"C07.9 Parotid gland" ///
080	"C08.0 Submandibular gland" ///
081	"C08.1 Sublingual gland" ///
088	"C08.8 Overl. lesion of major salivary gland" ///
089	"C08.9 Major salivary gland, NOS" ///
090	"C09.0 Tonsillar fossa" ///
091	"C09.1 Tonsillar pillar" ///
098	"C09.8 Overl. lesion of tonsil" ///
099	"C09.9 Tonsil, NOS" ///
100	"C10.0 Vallecula" ///
101	"C10.1 Anterior surface of epiglottis" ///
102	"C10.2 Lateral wall of oropharynx" ///
103	"C10.3 Posterior wall of oropharynx" ///
104	"C10.4 Branchial cleft" ///
108	"C10.8 Overl. lesion of oropharynx" ///
109	"C10.9 Oropharynx, NOS" ///
110	"C11.0 Superior wall of nasopharynx" ///
111	"C11.1 Posterior wall of nasopharynx" ///
112	"C11.2 Lateral wall of nasopharynx" ///
113	"C11.3 Anterior wall of nasopharynx" ///
118	"C11.8 Overl. lesion of nasopharynx" ///
119	"C11.9 Nasopharynx, NOS" ///
129	"C12.9 Pyriform sinus" ///
130	"C13.0 Postcricoid region" ///
131	"C13.1 Aryepiglottic fold" ///
132	"C13.2 Posterior wall of hypopharynx" ///
138	"C13.8 Overl. lesion of hypopharynx" ///
139	"C13.9 Laryngopharynx, Hypopharynx NOS" ///
140	"C14.0 Pharynx, NOS" ///
141	"C14.1 Laryngopharynx (OLD CODE, NOW C13.9)" ///
142	"C14.2 Waldeyer's ring, NOS" ///
148	"C14.8 Overl. lesion of lip, oral cavity, pharynx" ///
150	"C15.0 Cervical esophagus" ///
151	"C15.1 Thoracic esophagus" ///
152	"C15.2 Abdominal esophagus" ///
153	"C15.3 Upper third of esophagus" ///
154	"C15.4 Middle third of esophagus" ///
155	"C15.5 Lower third of esophagus" ///
158	"C15.8 Overl. lesion of esophagus" ///
159	"C15.9 Oesophagus, NOS" ///
160	"C16.0 Cardia, NOS" ///
161	"C16.1 Fundus of stomach" ///
162	"C16.2 Body of stomach" ///
163	"C16.3 Gastric antrum" ///
164	"C16.4 Pylorus" ///
165	"C16.5 Lesser curvature of stomach, NOS" ///
166	"C16.6 Greater curvature of stomach, NOS" ///
168	"C16.8 Overl. lesion of stomach" ///
169	"C16.9 Stomach, NOS" ///
170	"C17.0 Duodenum" ///
171	"C17.1 Jejunum" ///
172	"C17.2 Ileum" ///
173	"C17.3 Meckel's diverticulum" ///
178	"C17.8 Overl. lesion of small intestine" ///
179	"C17.9 Small intestine" ///
180	"C18.0 Cecum" ///
181	"C18.1 Appendix" ///
182	"C18.2 Ascending colon" ///
183	"C18.3 Hepatic flexure of colon" ///
184	"C18.4 Transverse colon" ///
185	"C18.5 Splenic flexure of colon" ///
186	"C18.6 Descending colon" ///
187	"C18.7 Sigmoid colon" ///
188	"C18.8 Overl. lesion of colon" ///
189	"C18.9 Colon, NOS" ///
199	"C19.9 Rectosigmoid junction" ///
209	"C20.9 Rectum, NOS" ///
210	"C21.0 Anus, NOS" ///
211	"C21.1 Anal canal" ///
212	"C21.2 Cloacogenic zone" ///
218	"C21.8 Overl. lesion rectum, anal canal" ///
220	"C22.0 Liver" ///
221	"C22.1 Intrahepatic bile duct" ///
239	"C23.9 Gallbladder" ///
240	"C24.0 Extrahepatic bile duct" ///
241	"C24.1 Ampulla of Vater" ///
248	"C24.8 Overl. lesion of biliary tract" ///
249	"C24.9 Biliary tract, NOS" ///
250	"C25.0 Head of pancreas" ///
251	"C25.1 Body of pancreas" ///
252	"C25.2 Tail of pancreas" ///
253	"C25.3 Pancreatic duct" ///
254	"C25.4 Islets of Langerhans" ///
257	"C25.7 Other specified parts of pancreas" ///
258	"C25.8 Overl. lesion of pancreas" ///
259	"C25.9 Pancreas, NOS" ///
260	"C26.0 Intestinal tract, NOS" ///
268	"C26.8 Overl. lesion of digestive system" ///
269	"C26.9 Gastrointestinal tract, NOS" ///
300	"C30.0 Nasal cavity" ///
301	"C30.1 Middle ear" ///
310	"C31.0 Maxillary sinus" ///
311	"C31.1 Ethmoid sinus" ///
312	"C31.2 Frontal sinus" ///
313	"C31.3 Sphenoid sinus" ///
318	"C31.8 Overl. lesion of accessory sinuses" ///
319	"C31.9 Accessory sinus, NOS" ///
320	"C32.0 Glottis" ///
321	"C32.1 Supraglottis" ///
322	"C32.2 Subglottis" ///
323	"C32.3 Laryngeal cartilage" ///
328	"C32.8 Overl. lesion of larynx" ///
329	"C32.9 Larynx, NOS" ///
339	"C33.9 Trachea" ///
340	"C34.0 Main bronchus" ///
341	"C34.1 Upper lobe, lung" ///
342	"C34.2 Middle lobe, lung" ///
343	"C34.3 Lower lobe, lung" ///
348	"C34.8 Overl. lesion of lung" ///
349	"C34.9 Lung, NOS" ///
379	"C37.9 Thymus" ///
380	"C38.0 Heart" ///
381	"C38.1 Anterior mediastinum" ///
382	"C38.2 Posterior mediastinum" ///
383	"C38.3 Mediastinum, NOS" ///
384	"C38.4 Pleura, NOS" ///
388	"C38.8 Overl. lesion of heart, mediastinum, pleura" ///
390	"C39.0 Upper respiratory tract" ///
398	"C39.8 Overl. lesion of respiratory system" ///
399	"C39.9 Ill-defined sites within respiratory system" ///
400	"C40.0 Long bones of upper limb, scapula" ///
401	"C40.1 Short bones of upper limb" ///
402	"C40.2 Long bones of lower limb" ///
403	"C40.3 Short bones of lower limb" ///
408	"C40.8 Overl. lesion of bones of limb" ///
409	"C40.9 Bone of limb, NOS" ///
410	"C41.0 Bones of skull and face" ///
411	"C41.1 Mandible" ///
412	"C41.2 Vertebral column" ///
413	"C41.3 Rib, Sternum, Clavicle" ///
414	"C41.4 Pelvic bones, Sacrum, Coccyx" ///
418	"C41.8 Overl. lesion of bones" ///
419	"C41.9 Bone, NOS" ///
420	"C42.0 Blood" ///
421	"C42.1 Bone marrow" ///
422	"C42.2 Spleen" ///
423	"C42.3 Reticuloendothelial system, NOS" ///
424	"C42.4 Hematopoietic system, NOS" ///
440	"C44.0 Skin of lip, NOS" ///
441	"C44.1 Eyelid" ///
442	"C44.2 External ear" ///
443	"C44.3 Skin, other & unspec parts of face" ///
444	"C44.4 Skin of scalp and neck" ///
445	"C44.5 Skin of trunk" ///
446	"C44.6 Skin of upper limb and shoulder" ///
447	"C44.7 Skin of lower limb and hip" ///
448	"C44.8 Overl. lesion of skin" ///
449	"C44.9 Skin, NOS" ///
470	"C47.0 Per. nerves & A.N.S. of head, face, neck" ///
471	"C47.1 Per. nerves & A.N.S. of upper limb, should" ///
472	"C47.2 Per. nerves & A.N.S. of lower limb, hip" ///
473	"C47.3 Per. nerves & A.N.S. of thorax" ///
474	"C47.4 Per. nerves & A.N.S. of abdomen" ///
475	"C47.5 Per. nerves & A.N.S. of pelvis" ///
476	"C47.6 Per. nerves & A.N.S. of trunk" ///
478	"C47.8 Overl. lesion of peripheral nerves & ANS" ///
479	"C47.9 Autonomic nervous system, NOS" ///
480	"C48.0 Retroperitoneum" ///
481	"C48.1 Specified parts of peritoneum" ///
482	"C48.2 Peritoneum, NOS" ///
488	"C48.8 Overl. lesion of retroperitoneum & peritoneum" ///
490	"C49.0 Soft tissues of head, face, & neck" ///
491	"C49.1 Soft tissues of upper limb, shoulder" ///
492	"C49.2 Soft tissues of lower limb and hip" ///
493	"C49.3 Soft tissues of thorax" ///
494	"C49.4 Soft tissues of abdomen" ///
495	"C49.5 Soft tissues of pelvis" ///
496	"C49.6 Soft tissues of trunk" ///
498	"C49.8 Overl. lesion of soft tissues" ///
499	"C49.9 Other soft tissues" ///
500	"C50.0 Nipple" ///
501	"C50.1 Central portion of breast" ///
502	"C50.2 Upper-inner quadrant of breast" ///
503	"C50.3 Lower-inner quadrant of breast" ///
504	"C50.4 Upper-outer quadrant of breast" ///
505	"C50.5 Lower-outer quadrant of breast" ///
506	"C50.6 Axillary tail of breast" ///
508	"C50.8 Overl. lesion of breast" ///
509	"C50.9 Breast, NOS" ///
510	"C51.0 Labium majus" ///
511	"C51.1 Labium minus" ///
512	"C51.2 Clitoris" ///
518	"C51.8 Overl. lesion of vulva" ///
519	"C51.9 Vulva, NOS" ///
529	"C52.9 Vagina, NOS" ///
530	"C53.0 Endocervix" ///
531	"C53.1 Exocervix" ///
538	"C53.8 Overl. lesion of cervix uteri" ///
539	"C53.9 Cervix uteri" ///
540	"C54.0 Isthmus uteri" ///
541	"C54.1 Endometrium" ///
542	"C54.2 Myometrium" ///
543	"C54.3 Fundus uteri" ///
548	"C54.8 Overl. lesion of corpus uteri" ///
549	"C54.9 Corpus uteri" ///
559	"C55.9 Uterus, NOS" ///
569	"C56.9 Ovary" ///
570	"C57.0 Fallopian tube" ///
571	"C57.1 Broad ligament" ///
572	"C57.2 Round ligament" ///
573	"C57.3 Parametrium" ///
574	"C57.4 Uterine adnexa" ///
577	"C57.7 Other parts of female genital organs" ///
578	"C57.8 Overl. lesion of female genital organs" ///
579	"C57.9 Female genital tract, NOS" ///
589	"C58.9 Placenta" ///
600	"C60.0 Prepuce" ///
601	"C60.1 Glans penis" ///
602	"C60.2 Body of penis" ///
608	"C60.8 Overl. lesion of penis" ///
609	"C60.9 Penis, NOS" ///
619	"C61.9 Prostate gland" ///
620	"C62.0 Undescended testis" ///
621	"C62.1 Descended testis" ///
629	"C62.9 Testis, NOS" ///
630	"C63.0 Epididymis" ///
631	"C63.1 Spermatic cord" ///
632	"C63.2 Scrotum, NOS" ///
637	"C63.7 Other parts of male genital organs" ///
638	"C63.8 Overl. lesion of male genital organs" ///
639	"C63.9 Male genital organs, NOS" ///
649	"C64.9 Kidney, NOS" ///
659	"C65.9 Renal pelvis" ///
669	"C66.9 Ureter" ///
670	"C67.0 Trigone of urinary bladder" ///
671	"C67.1 Dome of urinary bladder" ///
672	"C67.2 Lateral wall of urinary bladder" ///
673	"C67.3 Anterior wall of urinary bladder" ///
674	"C67.4 Posterior wall of urinary bladder" ///
675	"C67.5 Bladder neck" ///
676	"C67.6 Ureteric orifice" ///
677	"C67.7 Urachus" ///
678	"C67.8 Overl. lesion of bladder" ///
679	"C67.9 Urinary bladder, NOS" ///
680	"C68.0 Urethra" ///
681	"C68.1 Paraurethral gland" ///
688	"C68.8 Overl. lesion of urinary organs" ///
689	"C68.9 Urinary system, NOS" ///
690	"C69.0 Conjunctiva" ///
691	"C69.1 Cornea, NOS" ///
692	"C69.2 Retina" ///
693	"C69.3 Choroid" ///
694	"C69.4 Ciliary body" ///
695	"C69.5 Lacrimal gland, NOS" ///
696	"C69.6 Orbit, NOS" ///
698	"C69.8 Overl. lesion of eye, adnexa" ///
699	"C69.9 Eye, NOS" ///
700	"C70.0 Cerebral meninges" ///
701	"C70.1 Spinal meninges" ///
709	"C70.9 Meninges, NOS" ///
710	"C71.0 Cerebrum" ///
711	"C71.1 Frontal lobe" ///
712	"C71.2 Temporal lobe" ///
713	"C71.3 Parietal lobe" ///
714	"C71.4 Occipital lobe" ///
715	"C71.5 Ventricle, NOS" ///
716	"C71.6 Cerebellum, NOS" ///
717	"C71.7 Brain stem" ///
718	"C71.8 Overl. lesion of brain" ///
719	"C71.9 Brain, NOS" ///
720	"C72.0 Spinal cord" ///
721	"C72.1 Cauda equina" ///
722	"C72.2 Olfactory nerve" ///
723	"C72.3 Optic nerve" ///
724	"C72.4 Acoustic nerve" ///
725	"C72.5 Cranial nerve" ///
728	"C72.8 Overl. lesion of brain and CNS" ///
729	"C72.9 Nervous system, NOS" ///
739	"C73.9 Thyroid gland" ///
740	"C74.0 Cortex of adrenal gland" ///
741	"C74.1 Medulla of adrenal gland" ///
749	"C74.9 Adrenal gland, NOS" ///
750	"C75.0 Parathyroid gland" ///
751	"C75.1 Pituitary gland" ///
752	"C75.2 Craniopharyngeal duct" ///
753	"C75.3 Pineal gland" ///
754	"C75.4 Carotid body" ///
755	"C75.5 Aortic body and other paraganglia" ///
758	"C75.8 Overl. lesion of endocrine glands" ///
759	"C75.9 Endocrine gland, NOS" ///
760	"C76.0 Head, face or neck, NOS" ///
761	"C76.1 Thorax, NOS" ///
762	"C76.2 Abdomen, NOS" ///
763	"C76.3 Pelvis, NOS" ///
764	"C76.4 Upper limb, NOS" ///
765	"C76.5 Lower limb, NOS" ///
767	"C76.7 Other ill-defined sites" ///
768	"C76.8 Overl. lesion of ill-defined sites" ///
770	"C77.0 Lymph nodes of head, face and neck" ///
771	"C77.1 Intrathoracic lymph nodes" ///
772	"C77.2 Intra-abdominal lymph nodes" ///
773	"C77.3 Lymph nodes of axilla or arm" ///
774	"C77.4 Lymph nodes, inguinal region or leg" ///
775	"C77.5 Pelvic lymph nodes" ///
778	"C77.8 Lymph nodes of multiple regions" ///
779	"C77.9 Lymph node, NOS" ///
809	"C80.9 Unknown primary site" , modify
label values topography topography_lab

label define morph_lab ///
8000	"Neoplasm, malignant" ///
8001	"Tumor cells, malignant" ///
8002	"Malignant tumor, small cell type" ///
8003	"Malignant tumor, giant cell type" ///
8004	"Malignant tumor, spindle cell type" ///
8005	"Malignant tumor, clear cell type" ///
8010	"Carcinoma, NOS" ///
8011	"Epithelioma, malignant" ///
8012	"Large cell carcinoma, NOS" ///
8013	"Large cell neuroendocrine carcinoma" ///
8014	"Large cell carcinoma with rhabdoid phenotype" ///
8015	"Glassy cell carcinoma" ///
8020	"Carcinoma, undifferentiated, NOS" ///
8021	"Carcinoma, anaplastic, NOS" ///
8022	"Pleomorphic carcinoma" ///
8030	"Giant cell and spindle cell carcinoma" ///
8031	"Giant cell carcinoma" ///
8032	"Spindle cell carcinoma, NOS" ///
8033	"Pseudosarcomatous carcinoma" ///
8034	"Polygonal cell carcinoma" ///
8035	"Carcinoma with osteoclast-like giant cells" ///
8041	"Small cell carcinoma, NOS" ///
8042	"Oat cell carcinoma" ///
8043	"Small cell carcinoma, fusiform cell" ///
8044	"Small cell carcinoma, intermediate cell" ///
8045	"Combined small cell carcinoma" ///
8046	"Non-small cell carcinoma" ///
8050	"Papillary carcinoma, NOS" ///
8051	"Verrucous carcinoma, NOS" ///
8052	"Papillary squamous cell carcinoma" ///
8070	"Squamous cell carcinoma, NOS" ///
8071	"Squamous cell carcinoma, keratinizing, NOS" ///
8072	"Squamous cell carcinoma, large cell, nonkeratinizing" ///
8073	"Squamous cell carcinoma, small cell, nonkeratinizing" ///
8074	"Squamous cell carcinoma, spindle cell" ///
8075	"Squamous cell carcinoma, adenoid" ///
8076	"Squamous cell carcinoma, microinvasive" ///
8077	"squamous intraepithelial neoplasia, grade III" ///
8078	"Squamous cell carcinoma with horn formation" ///
8082	"Lymphoepithelial carcinoma" ///
8083	"Basaloid squamous cell carcinoma" ///
8084	"Squamous cell carcinoma, clear cell type" ///
8090	"Basal cell carcinoma, NOS" ///
8091	"Multifocal superficial basal cell carcinoma" ///
8092	"Infiltrating basal cell carcinoma, NOS" ///
8093	"Basal cell carcinoma, fibroepithelial" ///
8094	"Basosquamous carcinoma" ///
8095	"Metatypical carcinoma" ///
8097	"Basal cell carcinoma, nodular" ///
8098	"Adenoid basal carcinoma" ///
8102	"Trichilemmocarcinoma" ///
8110	"Pilomatrix carcinoma" ///
8120	"Transitional cell carcinoma, NOS" ///
8121	"Schneiderian carcinoma" ///
8122	"Transitional cell carcinoma, spindle cell" ///
8123	"Basaloid carcinoma" ///
8124	"Cloacogenic carcinoma" ///
8130	"Papillary transitional cell carcinoma" ///
8131	"Transitional cell carcinoma, micropapillary" ///
8140	"Adenocarcinoma, NOS" ///
8141	"Scirrhous adenocarcinoma" ///
8142	"Linitis plastica" ///
8143	"Superficial spreading adenocarcinoma" ///
8144	"Adenocarcinoma, intestinal type" ///
8145	"Carcinoma, diffuse type" ///
8147	"Basal cell adenocarcinoma" ///
8150	"Islet cell carcinoma" ///
8151	"Insulinoma, malignant" ///
8152	"Glucagonoma, malignant" ///
8153	"Gastrinoma, malignant" ///
8154	"Mixed islet cell and exocrine adenocarcinoma" ///
8155	"Vipoma, malignant" ///
8156	"Somatostatinoma, malignant" ///
8157	"Enteroglucagonoma, malignant" ///
8160	"Cholangiocarcinoma" ///
8161	"Bile duct cystadenocarcinoma" ///
8162	"Klatskin tumor" ///
8170	"Hepatocellular carcinoma, NOS" ///
8171	"Hepatocellular carcinoma, fibrolamellar" ///
8172	"Hepatocellular carcinoma, scirrhous" ///
8173	"Hepatocellular carcinoma, spindle cell" ///
8174	"Hepatocellular carcinoma, clear cell type" ///
8175	"Hepatocellular carcinoma, pleomorphic type" ///
8180	"Combined hepatocellular carcinoma and cholangiocarcinoma" ///
8190	"Trabecular adenocarcinoma" ///
8200	"Adenoid cystic carcinoma" ///
8201	"Cribriform carcinoma, NOS" ///
8210	"Adenocarcinoma in adenomatous polyp" ///
8211	"Tubular adenocarcinoma" ///
8214	"Parietal cell carcinoma" ///
8215	"Adenocarcinoma of anal glands" ///
8220	"Adenocarcinoma in adenomatous polyposis" ///
8221	"Adenocarcinoma in multiple adenomatous" ///
8230	"Solid carcinoma, NOS" ///
8231	"Carcinoma simplex" ///
8240	"Carcinoid tumor, NOS" ///
8241	"Enterochromaffin cell carcinoid" ///
8242	"Enterochromaffin-like cell tumor, malignant" ///
8243	"Goblet cell carcinoid" ///
8244	"Composite carcinoid" ///
8245	"Adenocarcinoid tumor" ///
8246	"Neuroendocrine carcinoma, NOS" ///
8247	"Merkel cell carcinoma" ///
8249	"A typical carcinoid tumor" ///
8250	"Bronchiolo-alveolar adenocarcinoma, NOS" ///
8251	"Alveolar adenocarcinoma" ///
8252	"Bronchiolo-alveolar carcinoma, non-mucinous" ///
8253	"Bronchiolo-alveolar carcinoma, mucinous" ///
8254	"Bronchiolo-alveolar carcinoma, mixed mucinous and non-mucinous" ///
8255	"Adenocarcinoma with mixed subtypes" ///
8260	"Papillary adenocarcinoma, NOS" ///
8261	"Adenocarcinoma in villous adenoma" ///
8262	"Villous adenocarcinoma" ///
8263	"Adenocarcinoma in tubulovillous adenoma" ///
8270	"Chromophobe carcinoma" ///
8272	"Pituitary carcinoma, NOS" ///
8280	"Acidophil carcinoma" ///
8281	"Mixed acidophil-basophil carcinoma" ///
8290	"Oxyphilic adenocarcinoma" ///
8300	"Basophil carcinoma" ///
8310	"Clear cell adenocarcinoma, NOS" ///
8312	"Renal cell carcinoma, NOS" ///
8313	"Clear cell adenocarcinofibroma" ///
8314	"Lipid-rich carcinoma" ///
8315	"Glycogen-rich carcinoma" ///
8316	"Cyst-associated renal cell carcinoma" ///
8317	"Renal cell carcinoma, chromophobe type" ///
8318	"Renal cell carcinoma, sarcomatoid" ///
8319	"Collecting duct carcinoma" ///
8320	"Granular cell carcinoma" ///
8322	"Water-clear cell adenocarcinoma" ///
8323	"Mixed cell adenocarcinoma" ///
8330	"Follicular adenocarcinoma, NOS" ///
8331	"Follicular adenocarcinoma, well differentiated" ///
8332	"Follicular adenocarcinoma, trabecular" ///
8333	"Fetal adenocarcinoma" ///
8335	"Follicular carcinoma, minimally invasive" ///
8337	"Insular carcinoma" ///
8340	"Papillary carcinoma, follicular variant" ///
8341	"Papillary microcarcinoma" ///
8342	"Papillary carcinoma, oxyphilic cell" ///
8343	"Papillary carcinoma, encapsulated" ///
8344	"Papillary carcinoma, columnar cell" ///
8345	"Medullary carcinoma with amyloid stroma" ///
8346	"Mixed medullary-follicular carcinoma" ///
8347	"Mixed medullary-papillary carcinoma" ///
8350	"Nonencapsulated sclerosing carcinoma" ///
8370	"Adrenal cortical carcinoma" ///
8380	"Endometrioid adenocarcinoma, NOS" ///
8381	"Endometrioid adenofibroma, malignant" ///
8382	"Endometrioid adenocarcinoma, secretory variant" ///
8383	"Endometrioid adenocarcinoma, ciliated cell variant" ///
8384	"Adenocarcinoma, endocervical type" ///
8390	"Skin appendage carcinoma" ///
8400	"Sweat gland adenocarcinoma" ///
8401	"Apocrine adenocarcinoma" ///
8402	"Nodular hidradenoma, malignant" ///
8403	"Malignant eccrine spiradenoma" ///
8407	"Sclerosing sweat duct carcinoma" ///
8408	"Eccrine papillary adenocarcinoma" ///
8409	"Eccrine poroma, malignant" ///
8410	"Sebaceous adenocarcinoma" ///
8413	"Eccrine adenocarcinoma" ///
8420	"Ceruminous adenocarcinoma" ///
8430	"Mucoepidermoid carcinoma" ///
8440	"Cystadenocarcinoma, NOS" ///
8441	"Serous cystadenocarcinoma, NOS" ///
8450	"Papillary cystadenocarcinoma, NOS" ///
8452	"Solid pseudopapillary carcinoma" ///
8453	"Intraductal papillary-mucinous carcinoma, invasive" ///
8460	"Papillary serous cystadenocarcinoma" ///
8461	"Serous surface papillary carcinoma" ///
8470	"Mucinous cystadenocarcinoma, NOS" ///
8471	"Papillary mucinous cystadenocarcinoma" ///
8480	"Mucinous adenocarcinoma" ///
8481	"Mucin-producing adenocarcinoma" ///
8482	"Mucinous adenocarcinoma, endocervical type" ///
8490	"Signet ring cell carcinoma" ///
8500	"Infiltrating duct carcinoma, NOS" ///
8501	"Comedocarcinoma, NOS" ///
8502	"Secretory carcinoma of breast" ///
8503	"Intraductal papillary adenocarcinoma with invasion" ///
8504	"Intracystic carcinoma, NOS" ///
8508	"Cystic hypersecretory carcinoma" ///
8510	"Medullary carcinoma, NOS" ///
8512	"Medullary carcinoma with lymphoid stroma" ///
8513	"Atypical medullary carcinoma" ///
8514	"Duct carcinoma, desmoplastic type" ///
8520	"Lobular carcinoma, NOS" ///
8521	"Infiltrating ductular carcinoma" ///
8522	"Infiltrating duct and lobular carcinoma" ///
8523	"Infiltrating duct mixed with other types of carcinoma" ///
8524	"Infiltrating lobular mixed with other types of carcinoma" ///
8525	"Polymorphous low grade adenocarcinoma" ///
8530	"Inflammatory carcinoma" ///
8540	"Paget disease, mammary" ///
8541	"Paget disease and infiltrating duct carcinoma of breast" ///
8542	"Paget disease, extramammary (except Paget disease of bone)" ///
8543	"Paget disease and intraductal carcinoma of breast" ///
8550	"Acinar cell carcinoma" ///
8551	"Acinar cell cystadenocarcinoma" ///
8560	"Adenosquamous carcinoma" ///
8562	"Epithelial-myoepithelial carcinoma" ///
8570	"Adenocarcinoma with squamous metaplasia" ///
8571	"Adenocarcinoma with cartilaginous and osseous metaplasia" ///
8572	"Adenocarcinoma with spindle cell metaplasia" ///
8573	"Adenocarcinoma with apocrine metaplasia" ///
8574	"Adenocarcinoma with neuroendocrine differentiation" ///
8575	"Metaplastic carcinoma, NOS" ///
8576	"Hepatoid adenocarcinoma" ///
8580	"Thymoma, malignant, NOS" ///
8581	"Thymoma, type A, malignant" ///
8582	"Thymoma, type AB, malignant" ///
8583	"Thymoma, type B1, malignant" ///
8584	"Thymoma, type B2, malignant" ///
8585	"Thymoma, type B3, malignant" ///
8586	"Thymic carcinoma, NOS" ///
8588	"Spindle epithelial tumor with thymus-like elements" ///
8589	"Carcinoma showing thymus-like elements" ///
8600	"Thecoma, malignant" ///
8620	"Granulosa cell tumor, malignant" ///
8630	"Androblastoma, malignant" ///
8631	"Sertoli-Leydig cell tumor, poorly differentiated" ///
8634	"Sertoli-Leydig cell, poorly diffn, with heterologous elements" ///
8640	"Sertoli cell carcinoma" ///
8650	"Leydig cell tumor, malignant" ///
8670	"Steroid cell tumor, malignant" ///
8680	"Paraganglioma, malignant" ///
8693	"Extra-adrenal paraganglioma, malignant" ///
8700	"Pheochromocytoma, malignant" ///
8710	"Glomangiosarcoma" ///
8711	"Glomus tumor, malignant" ///
8720	"Malignant melanoma, NOS (except juvenile melanoma)" ///
8721	"Nodular melanoma" ///
8722	"Balloon cell melanoma" ///
8723	"Malignant melanoma, regressing" ///
8728	"Meningeal melanomatosis" ///
8730	"Amelanotic melanoma" ///
8740	"Malignant melanoma in junctional nevus" ///
8741	"Malignant melanoma in precancerous" ///
8742	"Lentigo maligna melanoma" ///
8743	"Superficial spreading melanoma" ///
8744	"Acral lentiginous melanoma, malignant" ///
8745	"Desmoplastic melanoma, malignant" ///
8746	"Mucosal lentiginous melanoma" ///
8761	"Malignant melanoma in giant pigmented nevus" ///
8770	"Mixed epithelioid and spindle cell melanoma" ///
8771	"Epithelioid cell melanoma" ///
8772	"Spindle cell melanoma, NOS" ///
8773	"Spindle cell melanoma, type A" ///
8774	"Spindle cell melanoma, type B" ///
8780	"Blue nevus, malignant" ///
8800	"Sarcoma, NOS" ///
8801	"Spindle cell sarcoma" ///
8802	"Giant cell sarcoma (except of bone)" ///
8803	"Small cell sarcoma" ///
8804	"Epithelioid sarcoma" ///
8805	"Undifferentiated sarcoma" ///
8806	"Desmoplastic small round cell tumor" ///
8810	"Fibrosarcoma, NOS" ///
8811	"Fibromyxosarcoma" ///
8812	"Periosteal fibrosarcoma" ///
8813	"Fascial fibrosarcoma" ///
8814	"Infantile fibrosarcoma" ///
8815	"Solitary fibrous tumor, malignant" ///
8830	"Malignant fibrous histiocytoma" ///
8832	"Dermatofibrosarcoma, NOS" ///
8833	"Pigmented dermatofibrosarcoma protuberans" ///
8840	"Myxosarcoma" ///
8850	"Liposarcoma, NOS" ///
8851	"Liposarcoma, well differentiated" ///
8852	"Myxoid liposarcoma" ///
8853	"Round cell liposarcoma" ///
8854	"Pleomorphic liposarcoma" ///
8855	"Mixed liposarcoma" ///
8857	"Fibroblastic liposarcoma" ///
8858	"Dedifferentiated liposarcoma" ///
8890	"Leiomyosarcoma, NOS" ///
8891	"Epithelioid leiomyosarcoma" ///
8894	"Angiomyosarcoma" ///
8895	"Myosarcoma" ///
8896	"Myxoid leiomyosarcoma" ///
8900	"Rhabdomyosarcoma, NOS" ///
8901	"Pleomorphic rhabdomyosarcoma, adult type" ///
8902	"Mixed type rhabdomyosarcoma" ///
8910	"Embryonal rhabdomyosarcoma, NOS" ///
8912	"Spindle cell rhabdomyosarcoma" ///
8920	"Alveolar rhabdomyosarcoma" ///
8921	"Rhabdomyosarcoma with ganglionic differentiation" ///
8930	"Endometrial stromal sarcoma, NOS" ///
8931	"Endometrial stromal sarcoma, low grade" ///
8933	"Adenosarcoma" ///
8934	"Carcinofibroma" ///
8935	"Stromal sarcoma, NOS" ///
8936	"Gastrointestinal stromal sarcoma" ///
8940	"Mixed tumor, malignant, NOS" ///
8941	"Carcinoma in pleomorphic adenoma" ///
8950	"Mullerian mixed tumor" ///
8951	"Mesodermal mixed tumor" ///
8959	"Malignant cystic nephroma" ///
8960	"Nephroblastoma, NOS" ///
8963	"Malignant rhabdoid tumor" ///
8964	"Clear cell sarcoma of kidney" ///
8970	"Hepatoblastoma" ///
8971	"Pancreatoblastoma" ///
8972	"Pulmonary blastoma" ///
8973	"Pleuropulmonary blastoma" ///
8980	"Carcinosarcoma, NOS" ///
8981	"Carcinosarcoma, embryonal" ///
8982	"Malignant myoepithelioma" ///
8990	"Mesenchymoma, malignant" ///
8991	"Embryonal sarcoma" ///
9000	"Brenner tumor, malignant" ///
9014	"Serous adenocarcinofibroma" ///
9015	"Mucinous adenocarcinofibroma" ///
9020	"Phyllodes tumor, malignant" ///
9040	"Synovial sarcoma, NOS" ///
9041	"Synovial sarcoma, spindle cell" ///
9042	"Synovial sarcoma, epithelioid cell" ///
9043	"Synovial sarcoma, biphasic" ///
9044	"Clear cell sarcoma, NOS (except of kidney)" ///
9050	"Mesothelioma, malignant" ///
9051	"Fibrous mesothelioma, malignant" ///
9052	"Epithelioid mesothelioma, malignant" ///
9053	"Mesothelioma, biphasic, malignant" ///
9060	"Dysgerminoma" ///
9061	"Seminoma, NOS" ///
9062	"Seminoma, anaplastic" ///
9063	"Spermatocytic seminoma" ///
9064	"Germinoma" ///
9065	"Germ cell tumor, nonseminomatous" ///
9070	"Embryonal carcinoma, NOS" ///
9071	"Yolk sac tumor" ///
9072	"Polyembryoma" ///
9080	"Teratoma, malignant, NOS" ///
9081	"Teratocarcinoma" ///
9082	"Malignant teratoma, undifferentiated" ///
9083	"Malignant teratoma, intermediate" ///
9084	"Teratoma with malignant transformation" ///
9085	"Mixed germ cell tumor" ///
9090	"Struma ovarii, malignant" ///
9100	"Choriocarcinoma, NOS" ///
9101	"Choriocarcinoma combined with other germ cell elements" ///
9102	"Malignant teratoma, trophoblastic" ///
9105	"Trophoblastic tumor, epithelioid" ///
9110	"Mesonephroma, malignant" ///
9120	"Hemangiosarcoma" ///
9124	"Kupffer cell sarcoma" ///
9130	"Hemangioendothelioma, malignant" ///
9133	"Epithelioid hemangioendothelioma, malignant" ///
9140	"Kaposi sarcoma" ///
9150	"Hemangiopericytoma, malignant" ///
9170	"Lymphangiosarcoma" ///
9180	"Osteosarcoma, NOS" ///
9181	"Chondroblastic osteosarcoma" ///
9182	"Fibroblastic osteosarcoma" ///
9183	"Telangiectatic osteosarcoma" ///
9184	"Osteosarcoma in Paget disease of bone" ///
9185	"Small cell osteosarcoma" ///
9186	"Central osteosarcoma" ///
9187	"Intraosseous well differentiated osteosarcoma" ///
9192	"Parosteal osteosarcoma" ///
9193	"Periosteal osteosarcoma" ///
9194	"High grade surface osteosarcoma" ///
9195	"Intracortical osteosarcoma" ///
9220	"Chondrosarcoma, NOS" ///
9221	"Juxtacortical chondrosarcoma" ///
9230	"Chondroblastoma, malignant" ///
9231	"Myxoid chondrosarcoma" ///
9240	"Mesenchymal chondrosarcoma" ///
9242	"Clear cell chondrosarcoma" ///
9243	"Dedifferentiated chondrosarcoma" ///
9250	"Giant cell tumor of bone, malignant" ///
9251	"Malignant giant cell tumor of soft parts" ///
9252	"Malignant tenosynovial giant cell tumor" ///
9260	"Ewing sarcoma" ///
9261	"Adamantinoma of long bones" ///
9270	"Odontogenic tumor, malignant" ///
9290	"Ameloblastic odontosarcoma" ///
9310	"Ameloblastoma, malignant" ///
9330	"Ameloblastic fibrosarcoma" ///
9342	"Odontogenic carcinosarcoma" ///
9362	"Pineoblastoma" ///
9364	"Peripheral neuroectodermal tumor" ///
9365	"Askin tumor" ///
9370	"Chordoma, NOS" ///
9371	"Chondroid chordoma" ///
9372	"Dedifferentiated chordoma" ///
9380	"Glioma, malignant" ///
9381	"Gliomatosis cerebri" ///
9382	"Mixed glioma" ///
9390	"Choroid plexus carcinoma" ///
9391	"Ependymoma, NOS" ///
9392	"Ependymoma, anaplastic" ///
9393	"Papillary ependymoma" ///
9400	"Astrocytoma, NOS" ///
9401	"Astrocytoma, anaplastic" ///
9410	"Protoplasmic astrocytoma" ///
9411	"Gemistocytic astrocytoma" ///
9420	"Fibrillary astrocytoma" ///
9423	"Polar spongioblastoma" ///
9424	"Pleomorphic xanthoastrocytoma" ///
9430	"Astroblastoma" ///
9440	"Glioblastoma, NOS" ///
9441	"Giant cell glioblastoma" ///
9442	"Gliosarcoma" ///
9450	"Oligodendroglioma, NOS" ///
9451	"Oligodendroglioma, anaplastic" ///
9460	"Oligodendroblastoma" ///
9470	"Medulloblastoma, NOS" ///
9471	"Desmoplastic nodular medulloblastoma" ///
9472	"Medullomyoblastoma" ///
9473	"Primitive neuroectodermal tumor, NOS" ///
9474	"Large cell medulloblastoma" ///
9480	"Cerebellar sarcoma, NOS" ///
9490	"Ganglioneuroblastoma" ///
9500	"Neuroblastoma, NOS" ///
9501	"Medulloepithelioma, NOS" ///
9502	"Teratoid medulloepithelioma" ///
9503	"Neuroepithelioma, NOS" ///
9504	"Spongioneuroblastoma" ///
9505	"Ganglioglioma, anaplastic" ///
9508	"Atypical teratoid/rhabdoid tumor" ///
9510	"Retinoblastoma, NOS" ///
9511	"Retinoblastoma, differentiated" ///
9512	"Retinoblastoma, undifferentiated" ///
9513	"Retinoblastoma, diffuse" ///
9520	"Olfactory neurogenic tumor" ///
9521	"Olfactory neurocytoma" ///
9522	"Olfactory neuroblastoma" ///
9523	"Olfactory neuroepithelioma" ///
9530	"Meningioma, malignant" ///
9538	"Papillary meningioma" ///
9539	"Meningeal sarcomatosis" ///
9540	"Malignant peripheral nerve sheath tumor" ///
9560	"Neurilemoma, malignant" ///
9561	"Malig. peripheral nerve sheath tumor, rhabdomyoblastic differentiation" ///
9571	"Perineurioma, malignant" ///
9580	"Granular cell tumor, malignant" ///
9581	"Alveolar soft part sarcoma" ///
9590	"Malignant lymphoma, NOS" ///
9591	"Malignant lymphoma, non-Hodgkin, NOS" ///
9596	"Composite Hodgkin and non-Hodgkin lymphoma" ///
9650	"Hodgkin lymphoma, NOS" ///
9651	"Hodgkin lymphoma, lymphocyte-rich" ///
9652	"Hodgkin lymphoma, mixed cellularity, NOS" ///
9653	"Hodgkin lymphoma, lymphocyte depletion, NOS" ///
9654	"Hodgkin lymphoma, lymphocyte depletion, diffuse" ///
9655	"Hodgkin lymphoma, lymphocyte depletion, reticular" ///
9659	"Hodgkin lymphoma, nodular lymphocyte predominantly" ///
9661	"Hodgkin granuloma" ///
9662	"Hodgkin sarcoma" ///
9663	"Hodgkin lymphoma, nodular sclerosis, NOS" ///
9664	"Hodgkin lymphoma, nodular sclerosis, cellular phase" ///
9665	"Hodgkin lymphoma, nodular sclerosis, grade 1" ///
9667	"Hodgkin lymphoma, nodular sclerosis, grade 2" ///
9670	"Malignant lymphoma, small B lymphocytic, NOS" ///
9671	"Malignant lymphoma, lymphoplasmacytic" ///
9673	"Mantle cell lymphoma" ///
9675	"Malignant lymphoma, mixed small and large cell, diffuse" ///
9678	"Primary effusion lymphoma" ///
9679	"Mediastinal large B-cell lymphoma" ///
9680	"Malignant lymphoma, large B-cell, diffuse, NOS" ///
9684	"Malignant lymphoma, large B-cell, diffuse, immunoblastic NOS" ///
9687	"Burkitt lymphoma, NOS" ///
9689	"Splenic marginal zone B-cell lymphoma" ///
9690	"Follicular lymphoma, NOS" ///
9691	"Follicular lymphoma, grade 2" ///
9695	"Follicular lymphoma, grade 1" ///
9698	"Follicular lymphoma, grade 3" ///
9699	"Marginal zone B-cell lymphoma, NOS" ///
9700	"Mycosis fungoides" ///
9701	"Sezary syndrome" ///
9702	"Mature T-cell lymphoma, NOS" ///
9705	"Angioimmunoblastic T-cell lymphoma" ///
9708	"Subcutaneous panniculitis-like T-cell lymphoma" ///
9709	"Cutaneous T-cell lymphoma, NOS" ///
9714	"Anaplastic large cell lymphoma, T cell and Null cell type" ///
9716	"Hepatosplenic (gamma-delta) cell" ///
9717	"Intestinal T-cell lymphoma" ///
9718	"Primary cutaneous CD30+ T-cell lymphoproliferative" ///
9719	"NK/T-cell lymphoma, nasal and nasal-type" ///
9727	"Precursor cell lymphoblastic lymphoma, NOS" ///
9728	"Precursor B-cell lymphoblastic lymphoma" ///
9729	"Precursor T-cell lymphoblastic lymphoma" ///
9731	"Plasmacytoma, NOS" ///
9732	"Multiple myeloma" ///
9733	"Plasma cell leukemia" ///
9734	"Plasmacytoma, extramedullary (not occurring in bone)" ///
9740	"Mast cell sarcoma" ///
9741	"Malignant mastocytosis" ///
9742	"Mast cell leukemia" ///
9750	"Malignant histiocytosis" ///
9754	"Langerhans cell histiocytosis, disseminated" ///
9755	"Histiocytic sarcoma" ///
9756	"Langerhans cell sarcoma" ///
9757	"Interdigitating dendritic cell sarcoma" ///
9758	"Follicular dendritic cell sarcoma" ///
9760	"Immunoproliferative disease, NOS" ///
9761	"Waldenstrom macroglobulinemia" ///
9762	"Heavy chain disease, NOS" ///
9764	"Immunoproliferative small intestinal disease" ///
9800	"Leukemia, NOS" ///
9801	"Acute leukemia, NOS" ///
9805	"Acute biphenotypic leukemia" ///
9811	"B-lymphoblastic leukemia/lymphoma, NOS/Acute lymphoblastic leukemia" ///
9820	"Lymphoid leukemia, NOS" ///
9823	"B-cell chronic lymphocytic leukemia/small lymph" ///
9826	"Burkitt cell leukemia" ///
9827	"Adult T-cell leukemia/lymphoma (HTLV-1 positive)" ///
9832	"Prolymphocytic leukemia, NOS" ///
9833	"Prolymphocytic leukemia, B-cell type" ///
9834	"Prolymphocytic leukemia, T-cell type" ///
9835	"Precursor cell lymphoblastic leukemia, NOS" ///
9836	"Precursor B-cell lymphoblastic leukemia" ///
9837	"Precursor T-cell lymphoblastic leukemia" ///
9840	"Acute myeloid leukemia, M6 type" ///
9860	"Myeloid leukemia, NOS" ///
9861	"Acute myeloid leukemia, NOS" ///
9863	"Chronic myeloid leukemia, NOS" ///
9866	"Acute promyelocytic leukemia, t(15;17)(q22;q11-12)" ///
9867	"Acute myelomonocytic leukemia" ///
9870	"Acute basophilic leukemia" ///
9871	"Acute myeloid leukemia with abnormal marrow eosinophils" ///
9872	"Acute myeloid leukemia, minimal differentiation" ///
9873	"Acute myeloid leukemia without maturation" ///
9874	"Acute myeloid leukemia with maturation" ///
9875	"Chronic myelogenous leukemia, BCR/ABL" ///
9876	"Atypical chronic myeloid leukemia" ///
9891	"Acute monocytic leukemia" ///
9895	"Acute myeloid leukemia with multilineage dysplasia" ///
9896	"Acute myeloid leukemia, t(8;21)(q22;q22)" ///
9897	"Acute myeloid leukemia, 11q23 abnormalities" ///
9898	"Myeloid leukemia associated with Down syndrome" ///
9910	"Acute megakaryoblastic leukemia" ///
9920	"Therapy-related acute myeloid leukemia, NOS" ///
9930	"Myeloid sarcoma" ///
9931	"Acute panmyelosis with myelofibrosis" ///
9940	"Hairy cell leukemia" ///
9945	"Chronic myelomonocytic leukemia, NOS" ///
9946	"Juvenile myelomonocytic leukemia" ///
9948	"Aggressive NK-cell leukemia" ///
9950	"Polycythemia vera" ///
9960	"Chronic myeloproliferative disease, NOS (2001-2009 dx)" ///
9961	"Myelosclerosis with myeloid metaplasia" ///
9962	"Essential thrombocythemia" ///
9963	"Chronic neutrophilic leukemia" ///
9964	"Hypereosinophilic syndrome" ///
9975	"(Chronic) Myeloproliferative disease, NOS (2010 onwards dx)" ///
9980	"Refractory anemia" ///
9982	"Refractory anemia with sideroblasts" ///
9983	"Refractory anemia with excess blasts" ///
9984	"Refractory anemia with excess blasts in transformation" ///
9985	"Refractory cytopenia with multilineage dysplasia" ///
9986	"Myelodysplastic syndrome with 5q- syndrome" ///
9987	"Therapy-related myelodysplastic syndrome, NOS" ///
9989	"Myelodysplastic syndrome, NOS" , modify
label values morph morph_lab

order pid mpseq dob_ci5 sex dot_ci5 age top morph beh basis slc dlc_ci5 iarcflag staging
keep pid mpseq dob_ci5 sex dot_ci5 age top morph beh basis slc dlc_ci5 iarcflag staging
//outsheet using "`datapath'\version21\3-output\CI5_V01.csv" , comma nolabel replace
capture export_excel using "`datapath'\version21\3-output\CI5_tocheck_V02.xlsx", sheet("2013-2015") firstrow(varlabels) nolabel replace
clear
import excel  using "`datapath'\version21\3-output\CI5_tocheck_V02.xlsx", firstrow
export delimited using "`datapath'\version21\3-output\CI5_tosubmit_V02.txt", replace
//manually created .csv file from the above excel file so that leading zeros can be kept in
restore



** Save this corrected dataset with internationally reportable cases
save "`datapath'\version21\3-output\2013_2014_2015_cancer_ci5", replace
label data "2013 2014 2015 BNR-Cancer analysed data - CI5 Vol.XII Submission Dataset"
note: TS This dataset was used for 2013-2015 CI5 submission Vol. XII + CRICCS submission
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
