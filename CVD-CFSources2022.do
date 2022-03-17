** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          CVD-CFSources2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-MAR-2022
    // 	date last modified      16-MAR-2022
    //  algorithm task          Preparing 2019-2021 heart CF datasets
    //  status                  Completed
    //  objective               To have one dataset with heart CF records for 2019-2021 heart
    //  methods                 Format and save dataset using the 2019 + 2020 heart cleaning annual report dofiles (1a_prelim_heart_CF-Dis and 1b_prep_heart_CF)

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
    log using "`logpath'\CVD-CFSources2022.smcl", replace
** HEADER -----------------------------------------------------

**********
** 2019 **
**********

** LOAD and SAVE the first dataset (Casefinding Form)
import excel "`datapath'\version11\1-input\2020-10-20_CF_MAIN_AHPC.xlsx", firstrow case(lower)

save "`datapath'\version11\2-working\2019_heart_CF" ,replace

count //2394


**   Event Type   **
label var etype "Event Type"
label define etype_lab 	1 "Stroke" 2 "Heart" 3 "Both Heart & Stroke" 4 "Not Stated/ Not CVD", modify
label values etype etype_lab

tab etype ,m
/*
         Event Type |      Freq.     Percent        Cum.
--------------------+-----------------------------------
             Stroke |      1,232       51.46       51.46
              Heart |      1,084       45.28       96.74
Both Heart & Stroke |         70        2.92       99.67
Not Stated/ Not CVD |          5        0.21       99.87
                  . |          3        0.13      100.00
--------------------+-----------------------------------
              Total |      2,394      100.00
*/
//list pid if etype==.
//list pid if etype==4
** Remove the 3 blank CF records, non-CVD cases and Dummy records
drop if etype==. //3 deleted
replace etype=1 if pid==427 //stroke case selected as "Not Stated/ Not CVD"
drop if etype==4 //4 deleted

count if regexm(pname,"DUMMY") //4
drop if regexm(pname,"DUMMY") //4 deleted

count //2383

** Sex **
label var sex " Participant sex. 1=f 2=m 99=nd"
recode sex(2=99)(1=2)(0=1)
label define sex_lab 1 "Female" 2 "Male" 99 "ND" , modify
label values sex sex_lab

** Notification Location **
label var ward " Ward/Notification Location"

gen firstnf=1 if ward=="A1"|ward=="A2"|ward=="A3"|ward=="A4"|ward=="A5"|ward=="A6" ///
					|ward=="A7"|ward=="A8"|ward=="A9"|ward=="A10"|ward=="A11"|ward=="A12" ///
					|ward=="B1"|ward=="B2"|ward=="B3"|ward=="B4"|ward=="B5"|ward=="B6" ///
					|ward=="B7"|ward=="B8"|ward=="B9"|ward=="B10"|ward=="B11"|ward=="B12" ///
					|ward=="C1"|ward=="C2"|ward=="C3"|ward=="C4"|ward=="C5"|ward=="C6" ///
					|ward=="C7"|ward=="C8"|ward=="C9"|ward=="C10"|ward=="C11"|ward=="C12" ///
					|ward=="HDU"|ward=="MICU"|ward=="NICU"|ward=="PICU"|ward=="Recovery Room"|ward=="SICU"|ward=="Stroke Unit"|ward=="OT/Operating Theatre"
replace firstnf=2 if ward=="Med Rec"
replace firstnf=3 if ward=="Death Rec"
replace firstnf=4 if ward=="A&E"
replace firstnf=5 if cfsource==2
replace firstnf=6 if cfsource==7

label var firstnf "First Notification"
label define firstnf_lab 1 "Ward" 2 "Med Rec" 3 "Death Rec" 4 "A&E" 5 "Bay View" 6 "Emergency Clinic" , modify
label value firstnf firstnf_lab

tab firstnf ,m
/*
           First |
    Notification |      Freq.     Percent        Cum.
-----------------+-----------------------------------
            Ward |      1,609       67.52       67.52
             A&E |        774       32.48      100.00
-----------------+-----------------------------------
           Total |      2,383      100.00
*/
//list pid if firstnf==.

** Remove non-heart cases + Dummy records
tab etype ,m
/*
         Event Type |      Freq.     Percent        Cum.
--------------------+-----------------------------------
             Stroke |      1,231       51.66       51.66
              Heart |      1,083       45.45       97.10
Both Heart & Stroke |         69        2.90      100.00
--------------------+-----------------------------------
              Total |      2,383      100.00
*/
drop if etype==1 //1231 deleted

count //1152

tab firstnf ,m
/*
           First |
    Notification |      Freq.     Percent        Cum.
-----------------+-----------------------------------
            Ward |        787       68.32       68.32
             A&E |        365       31.68      100.00
-----------------+-----------------------------------
           Total |      1,152      100.00
*/


** Retrieval Source - check if this can be useful for this process
label var retsource " Retrieval Source "
label define retsource_lab 1 "QEH Ward" 2 "QEH A&E" 3 "QEH Med Rec" 4 "QEH Death Rec" ///
                          5 "Bay View" 6 "Sparman Clinic" 7 "Psychiatric Hospital" 8 "District Hospital" ///
						  9 "Geriatric Hospital" 10 "PP (D Corbin)" 11 "PP (S Marquez)" ///
						  12 "PP (S Moe/Dawn Scantlebury)" 13 "PP (R Ishmael/Jose Ettedgui/Ronald Henry)" ///
						  14 "PP (R Massay)" 15 "PP (K Goring)" 16 "Polyclinic (Black Rock)" ///
						  17 "Polyclinic (Edgar Cochrane)" 18 "Polyclinic (Glebe)" /// 
						  19 "Polyclinic (Maurice Byer)" 20 "Polyclinic (Randal Phillips)" ///
						  21 "Polyclinic (St. Philip)" 22 "Polyclinic (Warrens)" ///
						  23 "Polyclinic (Winston Scott)" 24 "Sandy Crest Medical Centre (SCMC)" ///
						  25 "FMH" 26 "Emergency Clinic" 98 "Other" 99 "ND" , modify 
label values retsource retsource_lab
tab retsource ,m
/*
                      Retrieval Source  |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                               QEH Ward |         17        1.48        1.48
                                QEH A&E |        234       20.31       21.79
                            QEH Med Rec |        711       61.72       83.51
                          QEH Death Rec |        190       16.49      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,152      100.00
*/

** Create variable with total number of CF records
gen cfrec_total=_N

** Save retrieval source dataset for comparison with other CF heart years
preserve

contract retsource cfrec_total
rename _freq retrec_number
gen retrec_percent=retrec_number/cfrec_total*100
replace retrec_percent=round(retrec_percent,2.0) if retsource==1
replace retrec_percent=round(retrec_percent,1.0) if retsource!=1
gen year=2019
order year retsource retrec_number cfrec_total retrec_percent
save "`datapath'\version11\2-working\2019_heart_retsources" ,replace

restore

** Save first notification dataset for comparison with other CF heart years
//preserve

contract firstnf cfrec_total
rename _freq cfrec_number
gen cfrec_percent=cfrec_number/cfrec_total*100
replace cfrec_percent=round(cfrec_percent,1.0)
gen year=2019
order year firstnf cfrec_number cfrec_total cfrec_percent
save "`datapath'\version11\2-working\2019_heart_cfsources" ,replace



append using "`datapath'\version11\2-working\2019_heart_retsources"

** Add in dataset from 2020 results report dofile with # of cases with full info for comparison
append using "`datapath'\version11\1-input\mort_heart"

** Format dataset in prep for comparison with 2020 and 2021 datasets
gen id=_n
order id
drop if mort_heart_ar!=3 & id>6
keep id year retsource retrec_number retrec_percent firstnf cfrec_number cfrec_total cfrec_percent mort_heart_ar year_2019 year_2020
fillmissing mort_heart_ar year_2019 year_2020
replace year=2020 if year==.
rename year_2019 absrec_number
replace absrec_number=year_2020 if year==2020
drop year_2020
destring absrec_number ,replace
stop - used REDCap reports instead (see BNRCVD_CORE db: Sources 2020 (HEART) and Sources 2021(HEART))
gen absrec_percent=absrec_number/cfrec_total*100 if year==2019
replace absrec_percent=round(absrec_percent,1.0)

gen cfabsrec_percent=absrec_number/cfrec_number*100 if year==2019 & firstnf!=.
replace cfabsrec_percent=round(cfabsrec_percent,1.0)

gen retabsrec_percent=absrec_number/retrec_number*100 if year==2019 & retsource!=.
replace retabsrec_percent=round(retabsrec_percent,1.0)

label var cfrec_percent "Proportion CF Source to CF Source Total"
label var absrec_percent "Proportion Db ABS to CF Source Total"
label var cfabsrec_percent "Proportion Db ABS to CF Source"
label var retrec_percent "Proportion Retrieval Source to CF Source Total"
label var cfabsrec_percent "Proportion Db ABS to Retrieval Source"

save "`datapath'\version11\2-working\2019_heart_cfsources+abs" ,replace

restore

clear

*****************
** 2020 + 2021 **
*****************
import excel using "`datapath'\version11\1-input\BNRCVDCORE_DATA_2022-03-15_1309_excel.xlsx", firstrow

count //13,908 (1,217 vars)

save "`datapath'\version11\2-working\redcap_alldata" ,replace
*/
use "`datapath'\version11\2-working\redcap_alldata" ,clear

order record_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance redcap_data_access_group cfdoa cfdoat cfda sri srirec evolution sourcetype firstnf cfsource___1 cfsource___2 cfsource___3 cfsource___4 cfsource___5 cfsource___6 cfsource___7 cfsource___8 cfsource___9 cfsource___10 cfsource___11 cfsource___12 cfsource___13 cfsource___14 cfsource___15 cfsource___16 cfsource___17 cfsource___18 cfsource___19 cfsource___20 cfsource___21 cfsource___22 cfsource___23 cfsource___24 cfsource___25 cfsource___26 cfsource___27 cfsource___28 cfsource___29 cfsource___30 cfsource___31 cfsource___32 retsource oretsrce fname mname lname sex dob dobday dobmonth dobyear cfage cfage_da natregno nrnyear nrnmonth nrnday nrnnum recnum cfadmdate cfadmyr cfadmdatemon cfadmdatemondash initialdx hstatus slc dlc dlcyr dlcday dlcmonth dlcyear cfdod cfdodyr cfdodday cfdodmonth cfdodyear finaldx cfcods docname docaddr cstatus eligible ineligible pendrv duplicate duprec dupcheck requestdate1 requestdate2 requestdate3 nfdb nfdbrec reabsrec toabs copycf casefinding_complete


** Remove non-heart, re-abstraction and 2022 cases
drop if redcap_event_name!="heart_arm_2" //12,250 deleted
count if regexm(record_id,"-") //17
drop if regexm(record_id,"-") //17 deleted
tab cfadmyr ,m
/*
    cfadmyr |      Freq.     Percent        Cum.
------------+-----------------------------------
       2019 |          2        0.12        0.12
       2020 |        839       51.13       51.25
       2021 |        704       42.90       94.15
       2022 |         92        5.61       99.76
          . |          4        0.24      100.00
------------+-----------------------------------
      Total |      1,641      100.00
*/
//list record_id if cfadmyr==.
** Update the CF Adm Year based on date of death since these cases had CF admission date=99
replace cfadmyr=2020 if record_id=="540"
replace cfadmyr=2021 if record_id=="2830"
drop if record_id=="1945"|record_id=="2893" //stroke case + blank case - 2 deleted
replace cfadmyr=2020 if cfadmyr==2019 //2 cases that have event date=2020
tab cfadmyr edateyr
drop if cfadmyr==2022 //92 deleted
tab cfadmyr ,m
/*
    cfadmyr |      Freq.     Percent        Cum.
------------+-----------------------------------
       2020 |        842       54.43       54.43
       2021 |        705       45.57      100.00
------------+-----------------------------------
      Total |      1,547      100.00
*/

** Group first notification sources into one variable 
rename firstnf firstnf_redcap
label var firstnf_redcap "First Notification in REDCapdb"
label define firstnf_redcap_lab 1 "A1" 2 "A2" 3 "A3/HDU" 4 "A5" 5 "A6" 6 "MICU" 7 "SICU" 8 "B5" 9 "B6" 10 "B7" 11 "B8" 12 "C5" ///
								13 "C6" 14 "C7/PICU" 15 "C8" 16 "C9" 17 "C10/Stroke Unit" 18 "C12" 19 "Cardiac Unit" ///
								20 "Med Rec" 21 "Death Rec" 22 "A&E" 23 "Bay View hospital" 24 "Sparman Clinic (4H)" 25 "Polyclinic" ///
								26 "Private Physician" 27 "Emergency Clinic (e.g. SCMC, FMH, Coverley, etc)" 28 "Nursing Home" ///
								29 "District Hospital" 30 "Geriatric Hospital" 31 "Psychiatric Hospital" 32 "Member of Public" ///
								33 "Missing before 29-Sep-2020" , modify
label value firstnf_redcap firstnf_redcap_lab

tab firstnf_redcap ,m
/*
         First Notification in REDCapdb |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                     C6 |          1        0.06        0.06
                                Med Rec |        439       28.38       28.44
                              Death Rec |         90        5.82       34.26
                                    A&E |        554       35.81       70.07
             Missing before 29-Sep-2020 |        463       29.93      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,547      100.00
*/
/*
tab cfsource___1 ,m
tab cfsource___2 ,m
tab cfsource___3 ,m
tab cfsource___4 ,m
tab cfsource___5 ,m
tab cfsource___6 ,m
tab cfsource___7 ,m
tab cfsource___8 ,m
tab cfsource___9 ,m
tab cfsource___10 ,m
tab cfsource___11 ,m
tab cfsource___12 ,m
tab cfsource___13 ,m
tab cfsource___14 ,m
tab cfsource___15 ,m
tab cfsource___16 ,m
tab cfsource___17 ,m
tab cfsource___18 ,m
tab cfsource___19 ,m
tab cfsource___20 ,m
tab cfsource___21 ,m
tab cfsource___22 ,m
tab cfsource___23 ,m
tab cfsource___24 ,m
tab cfsource___25 ,m
tab cfsource___26 ,m
tab cfsource___27 ,m
tab cfsource___28 ,m
tab cfsource___29 ,m
tab cfsource___30 ,m
tab cfsource___31 ,m
tab cfsource___32 ,m
*/

tab cfsource___1 if firstnf_redcap==33
tab cfsource___2 if firstnf_redcap==33
tab cfsource___3 if firstnf_redcap==33
tab cfsource___4 if firstnf_redcap==33
tab cfsource___5 if firstnf_redcap==33
tab cfsource___6 if firstnf_redcap==33
tab cfsource___7 if firstnf_redcap==33
tab cfsource___8 if firstnf_redcap==33
tab cfsource___9 if firstnf_redcap==33
tab cfsource___10 if firstnf_redcap==33
tab cfsource___11 if firstnf_redcap==33
tab cfsource___12 if firstnf_redcap==33
tab cfsource___13 if firstnf_redcap==33
tab cfsource___14 if firstnf_redcap==33
tab cfsource___15 if firstnf_redcap==33
tab cfsource___16 if firstnf_redcap==33
tab cfsource___17 if firstnf_redcap==33
tab cfsource___18 if firstnf_redcap==33
tab cfsource___19 if firstnf_redcap==33
tab cfsource___20 if firstnf_redcap==33
tab cfsource___21 if firstnf_redcap==33
tab cfsource___22 if firstnf_redcap==33
tab cfsource___23 if firstnf_redcap==33
tab cfsource___24 if firstnf_redcap==33
tab cfsource___25 if firstnf_redcap==33
tab cfsource___26 if firstnf_redcap==33
tab cfsource___27 if firstnf_redcap==33
tab cfsource___28 if firstnf_redcap==33
tab cfsource___29 if firstnf_redcap==33
tab cfsource___30 if firstnf_redcap==33
tab cfsource___31 if firstnf_redcap==33
tab cfsource___32 if firstnf_redcap==33

** Create grouped firstnf variable
gen firstnf=.
replace firstnf=1 if firstnf_redcap<20 //1 change
replace firstnf=2 if firstnf_redcap==20 //439 changes
replace firstnf=3 if firstnf_redcap==21 //90 changes
replace firstnf=4 if firstnf_redcap==22 //554 changes
replace firstnf=5 if firstnf_redcap==23 //0 changes
replace firstnf=6 if firstnf_redcap==27 //0 changes

label var firstnf "First Notification"
label define firstnf_lab 1 "Ward" 2 "Med Rec" 3 "Death Rec" 4 "A&E" 5 "Bay View" 6 "Emergency Clinic" , modify
label value firstnf firstnf_lab

tab firstnf ,m //463 still to be assigned to this variable


** Reassign 463 records with 'Missing before 29-Sep-2020' option from firstnf_redcap variable
** Ward
replace firstnf=1 if firstnf_redcap==33 & cfsource___1==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___2==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___3==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___4==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___5==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___6==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___7==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___8==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___9==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___10==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___11==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___12==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___13==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___14==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___15==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___16==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___17==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___18==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

replace firstnf=1 if firstnf_redcap==33 & cfsource___19==1 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

** Med Rec
replace firstnf=2 if firstnf_redcap==33 & cfsource___20==1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //45 changes

** Death Rec
replace firstnf=3 if firstnf_redcap==33 & cfsource___20!=1 & cfsource___21==1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //8 changes

** A&E
replace firstnf=4 if firstnf_redcap==33 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22==1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //61 changes

** Bay View
replace firstnf=5 if firstnf_redcap==33 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23==1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27!=1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

** Emergency Clinic
replace firstnf=6 if firstnf_redcap==33 & cfsource___20!=1 & cfsource___21!=1 & cfsource___22!=1 & cfsource___23!=1 & cfsource___24!=1 & cfsource___25!=1 & cfsource___26!=1 & cfsource___27==1 & cfsource___28!=1 & cfsource___29!=1 & cfsource___30!=1 & cfsource___31!=1 & cfsource___32!=1 //0 changes

tab firstnf ,m //349 still to be assigned


tab cfsource___1 if firstnf==.
tab cfsource___2 if firstnf==.
tab cfsource___3 if firstnf==.
tab cfsource___4 if firstnf==.
tab cfsource___5 if firstnf==.
tab cfsource___6 if firstnf==.
tab cfsource___7 if firstnf==.
tab cfsource___8 if firstnf==.
tab cfsource___9 if firstnf==.
tab cfsource___10 if firstnf==.
tab cfsource___11 if firstnf==.
tab cfsource___12 if firstnf==.
tab cfsource___13 if firstnf==.
tab cfsource___14 if firstnf==.
tab cfsource___15 if firstnf==.
tab cfsource___16 if firstnf==.
tab cfsource___17 if firstnf==.
tab cfsource___18 if firstnf==.
tab cfsource___19 if firstnf==.
tab cfsource___20 if firstnf==.
tab cfsource___21 if firstnf==.
tab cfsource___22 if firstnf==.
tab cfsource___23 if firstnf==.
tab cfsource___24 if firstnf==.
tab cfsource___25 if firstnf==.
tab cfsource___26 if firstnf==.
tab cfsource___27 if firstnf==.
tab cfsource___28 if firstnf==.
tab cfsource___29 if firstnf==.
tab cfsource___30 if firstnf==.
tab cfsource___31 if firstnf==.
tab cfsource___32 if firstnf==.

count if (cfsource___20==1 & firstnf==.) & (cfsource___21==1 & firstnf==.) //6 = Med Rec + Death Rec
count if (cfsource___20==1 & firstnf==.) & (cfsource___22==1 & firstnf==.) //282 = Med Rec + A&E
count if (cfsource___21==1 & firstnf==.) & (cfsource___22==1 & firstnf==.) //66 = Death Rec + A&E

stop - figure out how best to assign/group these!


** Need to use cfsource variable to reassign the firstnf variable that="Missing before 29-Sep-2020" as this variable was only added into REDCapdb on 29sep2020
rename cfsource___1 A1
rename cfsource___2 A2
rename cfsource___3 HDU
rename cfsource___4 A5
rename cfsource___5 A6
rename cfsource___6 MICU
rename cfsource___7 SICU
rename cfsource___8 B5
rename cfsource___9 B6
rename cfsource___10 B7
rename cfsource___11 B8
rename cfsource___12 C5
rename cfsource___13 C6
rename cfsource___14 PICU
rename cfsource___15 C8
rename cfsource___16 C9
rename cfsource___17 Stroke_Unit
rename cfsource___18 C12
rename cfsource___19 Cardiac_Unit
rename cfsource___20 Med_Rec
rename cfsource___21 Death_Rec
rename cfsource___22 A&E
rename cfsource___23 Bay_View
rename cfsource___24 Sparman_Clinic
rename cfsource___25 Polyclinic
rename cfsource___26 Private_Physician
rename cfsource___27 Emergency_Clinic
rename cfsource___28 Nursing_Home
rename cfsource___29 District_Hospital
rename cfsource___30 Geriatric_Hospital
rename cfsource___31 Psychiatric_Hospital
rename cfsource___32 Member_of_Public

cfsource 
1, A1
2, A2
3, A3/HDU
4, A5
5, A6
6, MICU
7, SICU
8, B5
9, B6
10, B7
11, B8
12, C5
13, C6
14, C7/PICU
15, C8
16, C9
17, C10/Stroke Unit
18, C12
19, Cardiac Unit
20, Med Rec
21, Death Rec
22, A&E
23, Bay View hospital
24, Sparman Clinic (4H)
25, Polyclinic
26, Private Physician
27, Emergency Clinic (e.g. SCMC, FMH, Coverley, etc)
28, Nursing Home
29, District Hospital
30, Geriatric Hospital
31, Psychiatric Hospital
32, Member of Public
stop








save "`datapath'\version11\2-working\2020_2021_heart_CF" ,replace

