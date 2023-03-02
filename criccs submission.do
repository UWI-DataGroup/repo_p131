** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          criccs_update.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-JAN-2023
    // 	date last modified      17-JAN-2023
    //  algorithm task          Updating 2013-2018 CRICCS cancer dataset (age<20)
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2013-2018 data for inclusion in the CRICCS submission.
    //  methods                 Update using:
	//							(1) analysis dataset from 2016-2018 annual report process;
	//							(2) feedback document from CRICCS study group (see ...\Sync\DM\Data\Data Request\CRICCS\Responses for IARC)							

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
    log using "`logpath'\criccs submission.smcl", replace
** HEADER -----------------------------------------------------

/*
	JC 17jan2023: The datasets in this dofile were previously submitted to the CRICCS study on 31-oct-2021
*/
** LOAD deidentified cancer incidence dataset INCLUDING DCOs from p117/version09 (2016-2018 annual report cleaning and analysis)
use "`datapath'\version20\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

** Remove 2008 cases
drop dotyear
gen dotyear=year(dot)
tab dotyear ,m
/*
    dotyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |        815       12.20       12.20
       2013 |        884       13.23       25.43
       2014 |        884       13.23       38.66
       2015 |      1,092       16.34       55.00
       2016 |      1,070       16.01       71.01
       2017 |        977       14.62       85.63
       2018 |        960       14.37      100.00
------------+-----------------------------------
      Total |      6,682      100.00
*/

drop if dotyear==2008 //815 deleted

** Late 2021 death registrations were collected from the death registry post 2016-2018 annual report cleaning so 
** these were manually checked for matches with the incidence dataset (none found by JC on 17jan2023)

** For IARC-CRICCS submission 27-jan-2023, create time variable for time from:
** (1) incidence date to death
** (2) incidence date to 31-dec-2021 (death data being included in submission)
gen survtime_days=dod-dot
replace survtime_days=d(31dec2021)-dot
label var survtime_days "Survival Time in Days"

gen survtime_months=dod-dot
replace survtime_months=(d(31dec2021)-dot)/(365/12)
label var survtime_months "Survival Time in Months"


** Flagged cases checked and corrected in the excel file directly then imported below; IARC flag value added also
** Create IARC flag variable for CRICCS submission
gen iarcflag=.
label var iarcflag "IARC Flag"
label define iarcflag_lab 0 "Failed" 1 "OK" 2 "Checked" 9 "Unknown", modify
label values iarcflag iarcflag_lab

** Update based on previous CRICCS study submission LONG data file
replace iarcflag=2 if pid=="20130002"|pid=="20130093"|pid=="20130127"|pid=="20130137"|pid=="20130169" ///
					  |pid=="20130176"|pid=="20130192"|pid=="20130198"|pid=="20130201"|pid=="20130226" ///
					  |pid=="20130229"|pid=="20130251"|pid=="20130264"|pid=="20130321"|pid=="20130341" ///
					  |pid=="20130383"|pid=="20130416"|pid=="20130426"|pid=="20130590"|pid=="20130594" ///
					  |pid=="20130727"|pid=="20130761"|pid=="20130819"|pid=="20139991"|pid=="20139994" ///
					  |pid=="20140058"|pid=="20140190"|pid=="20140228"|pid=="20140256"|pid=="20140395" ///
					  |pid=="20140525"|pid=="20140558"|pid=="20140570"|pid=="20140573"|pid=="20140622" ///
					  |pid=="20140687"|pid=="20140707"|pid=="20141535"|pid=="20141542"|pid=="20141558" ///
					  |pid=="20145112"|pid=="20150019"|pid=="20150094"|pid=="20150096"|pid=="20150132" ///
					  |pid=="20150139"|pid=="20150165"|pid=="20150182"|pid=="20150249"|pid=="20150293" ///
					  |pid=="20150295"|pid=="20150336"|pid=="20150373"|pid=="20150506"|pid=="20150574" ///
					  |pid=="20151366"|pid=="20155003"|pid=="20155008"|pid=="20155015"|pid=="20155035" ///
					  |pid=="20155047"|pid=="20155061"|pid=="20155197"|pid=="20155229"|pid=="20155245" ///
					  |pid=="20155255"|pid=="20159074"|pid=="20159077"|pid=="20159102"|pid=="20159128" ///
					  |pid=="20159129"|pid=="20180030"|pid=="20181178"
//76 changes
replace iarcflag=1 if iarcflag==. //5791 changes

*******************************************************************************

** Identify duplicate pids to assist with death matching
sort pid cr5id
//drop dup_pid
duplicates tag pid, gen(dup_pid)
count if dup_pid>0 //88; 234
count if dup_pid==0 //2710; 5633
//list pid cr5id dup_pid age if dup_pid>0, nolabel sepby(pid)
//list pid cr5id dup_pid age if dup_pid==0, nolabel sepby(pid)
count if age<20 & dup_pid>0  //2 - pid 20150093
//list pid cr5id patient if age<20 & dup_pid>0

count if age<20 //56; 56

count //2798; 5867

** Create LONG dataset as per CRICCS Call for Data
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
capture export_excel using "`datapath'\version20\3-output\CRICCS_LONG_V04.xlsx", sheet("2013-2018all") firstrow(variables) nolabel replace

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
capture export_excel using "`datapath'\version20\3-output\CRICCS_WIDE_V04.xlsx", sheet("2013-2018child") firstrow(variables) nolabel replace

restore


** Save this corrected dataset with internationally reportable cases
save "`datapath'\version20\3-output\2013-2018_cancer_criccs", replace
label data "2013 2014 2015 2016 2017 2018 BNR-Cancer analysed data - CRICCS Study Submission Dataset"
note: TS This dataset was used for 2013-2018 CRICCS study submission (27jan2023)
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
