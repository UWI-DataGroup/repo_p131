** Stata version control
version 15.1

** Initialising the STATA log and allow automatic page scrolling
capture {
        program drop _all
	drop _all
	log close
	}

** Direct Stata to your do file folder using the -cd- command
cd "L:\BNR_data\DM\data_requests\2019\cancer\versions\NAACCR-IACR\"

** Begin a Stata logfile
log using "logfiles\naaccr-iacr_2013_2019.smcl", replace

** Automatic page scrolling of output
set more off

 ******************************************************************************
 *
 *	GA-C D R C      A N A L Y S I S         C O D E
 *                                                              
 *  DO FILE: 		1b_cancer_deaths_2013
 *					Dofile 1b: Death Data Matching
 *
 *	STATUS:			Completed
 *
 *  FIRST RUN: 		07feb2019
 *
 *	LAST RUN:		12feb2019
 *
 *  ANALYSIS: 		Matching 2013 cancer dataset with 2013-2017 death dataset
 *					JC uses for basis of survival code for abstract submission
 *					to NAACCR-IACR joint conference: deadline 15feb2019
 *
 *	OBJECTIVE:		To have one dataset with matched 'alive' cancer cases 
 *					with death info if they died. Steps for achieving objective:
 *					(1) Check for duplicates by name in merged cancer and deaths
 *					(2) If true duplicate but case didn't merge, check for 
 *						differences in lname, fname, sex, dod fields
 *					(3) Correct differences identified above so records will merge
 *					(4) After corrections complete, merge datasets again
 *
 * 	VERSION: 		version01
 *
 *  CODERS:			J Campbell/Stephanie Whiteman
 *     
 *  SUPPORT: 		Natasha Sobers/Ian R Hambleton
 *
 ******************************************************************************

	 
**************************
**   2013 CANCER DATA   **
** 2013-2017 DEATH DATA **
**************************
** Load the 2013 cancer dataset
use "data\raw\2013_updated_cancer_dataset_site.dta", clear

count // 846

** Create 'alive' cancer dataset
drop if vstatus==2 // 390 deleted
// 2013 cancer dataset has NO dod for alive patients but has dlc (date last contact)

count // 456

save "data\raw\datarequest_NAACCR-IACR_alive_2013.dta", replace

append using "data\raw\2014_cancer_deaths_dc.dta", force

count // 12742

** Create field to label records you match
gen match=.


/* 
Note: the unique identifier number for each dataset noted below:
	cancer dataset - pid is an 8-digit number starting with year followed by 4 sequential numbers starting with 0001 e.g. 20130063.
	death dataset  - deathid varies in length of digits and is sequential starting from 1.
*/

/*
Steps for checking below lists:
 (1) Look, first, for eid and then the deathid that has a name match with this eid
 (2) Check if natregno for eid matches the nrn for deathid
       (a) If natregno and nrn match (as well as dod) then 
	        (i) write on list "∆ match=1" (i.e. change match to equal 1)
			(ii) update dofile "replace match=1" code with pid and deathid
	   (b) If naregno and nrn do not match then
	        (i) Check pid (pid=first 8 digits of eid) in CR5db (CanReg5 database)
			(ii) Once logged into CR5db, click Browse/Edit then in field 'Edit/create Patient ID:' type pid in e.g. 20080497
			(iii) Check if field labelled 'NRN' has more up-to-date natregno info
			(iv)   If still no match then check the names by natregno(eid) and nrn(deathid) in the 'GACDRC_Electoral List.xlsx'
				   which is stored in the folder pathway BNR_data\data_requests\...\data\raw
					(If cannot find natregno or nrn in electoral list that may mean these are incorrect so may need 
					to search electoral list by filtering LastName and FirstName)
			(v)     Additional step is you can check the Stata data editor(browse), especially if deathid is missing nrn,
					by filtering by deathid to see 'cod1a'(cause of death) vs the primary site in CR5db or check address(deathid) vs villagetown(pid)
			(vi)     Once above done then you can conclude these do not match so write on list "no match"
  
  Note 1: the variable 'dod' on the cancer dataset (i.e. the data with eid) should really be 'dlc'(date last contact)
		  as these are alive patients so expect dod will not always match.
  Note 2: if you find any updates to e.g. natregno then these can be updated using the 'replace natregno=...' code below.
  
  For below you can ignore and continue checking other names on the list:
  Note 3: some of the duplicates will have only eid and no corresponding deathid for the same name - these are multiple primaries (more than one cancer).
  Note 4: some of the duplicates will have only deathid and no corresponding eid for the same name - these are deaths with same name but are different people.
*/

*****************************
** DUPLICATE MATCH BY NAME **
*****************************
drop dupname
sort lname fname deathid pid
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname deathid pid
count if dupname>0 //1,091

order pid eid deathid fname lname nrn natregno dod cod1a primarysite address addr

sort lname fname dod dlc
list deathid pid fname lname nrn natregno dod if dupname>0
count if (regexm(lname, "^a")|regexm(lname, "^b")|regexm(lname, "^c") ///
	 |regexm(lname, "^d")|regexm(lname, "^e")|regexm(lname, "^f") ///
	 |regexm(lname, "^g")) & dupname>0 //519
count if (regexm(lname, "^h")|regexm(lname, "^i")|regexm(lname, "^j")|regexm(lname, "^k") ///
	 |regexm(lname, "^l")|regexm(lname, "^m")|regexm(lname, "^n") ///
	 |regexm(lname, "^o")|regexm(lname, "^p")|regexm(lname, "^q") ///
	 |regexm(lname, "^r")|regexm(lname, "^s")|regexm(lname, "^t") ///
	 |regexm(lname, "^u")|regexm(lname, "^v")|regexm(lname, "^w") ///
	 |regexm(lname, "^x")|regexm(lname, "^y")|regexm(lname, "^z")) & dupname>0 //572
	 
list fname lname nrn natregno dod deathid pid if ///
	 (regexm(lname, "^a")|regexm(lname, "^b")|regexm(lname, "^c") ///
	 |regexm(lname, "^d")|regexm(lname, "^e")|regexm(lname, "^f") ///
	 |regexm(lname, "^g")) & dupname>0

list fname lname nrn natregno dod deathid pid if ///
	 (regexm(lname, "^h")|regexm(lname, "^i")|regexm(lname, "^j")|regexm(lname, "^k") ///
	 |regexm(lname, "^l")|regexm(lname, "^m")|regexm(lname, "^n") ///
	 |regexm(lname, "^o")|regexm(lname, "^p")|regexm(lname, "^q") ///
	 |regexm(lname, "^r")|regexm(lname, "^s")|regexm(lname, "^t") ///
	 |regexm(lname, "^u")|regexm(lname, "^v")|regexm(lname, "^w") ///
	 |regexm(lname, "^x")|regexm(lname, "^y")|regexm(lname, "^z")) & dupname>0


** If you want to use an alternative format to lists above, the data and filter used above can be exported to excel
export_excel deathid pid fname lname nrn natregno dod cod1a primarysite histol address if dupname>0 ///
			 using "L:\BNR_data\DM\data_requests\2019\cancer\versions\NAACCR-IACR\data\raw\2019-02-12_2013_JC.xlsx", sheet("List1_2013") firstrow(variables) replace


** Update match field for all cases with matching cancer and death data
replace match=1 if pid=="20130053"|deathid==5099
replace match=1 if pid=="20130154"|deathid==11801
replace match=1 if pid=="20130135"|deathid==17703
replace match=1 if pid=="20130161"|deathid==19202
replace match=1 if pid=="20130072"|deathid==22104
replace match=1 if pid=="20130409"|deathid==5406
replace match=1 if pid=="20130672"|deathid==19421
replace match=1 if pid=="20130153"|deathid==17921
replace match=1 if pid=="20130055"|deathid==3728
replace match=1 if pid=="20130091"|deathid==6714
replace match=1 if pid=="20130131"|deathid==16735
replace match=1 if pid=="20130274"|deathid==21945
replace match=1 if pid=="20130114"|deathid==14116
replace match=1 if pid=="20130173"|deathid==21211
replace match=1 if pid=="20130104"|deathid==24169
replace match=1 if pid=="20130345"|deathid==12550
replace match=1 if pid=="20130145"|deathid==21464
replace match=1 if pid=="20130677"|deathid==10007
replace match=1 if pid=="20130139"|deathid==13287
replace match=1 if pid=="20130082"|deathid==8318
replace match=1 if pid=="20130631"|deathid==3391
replace match=1 if pid=="20130625"|deathid==1023
replace match=1 if pid=="20130813"|deathid==18599
replace match=1 if pid=="20131003"|deathid==20328
replace match=1 if pid=="20130374"|deathid==4710
replace match=1 if pid=="20130128"|deathid==4397
replace match=1 if pid=="20130102"|deathid==8005
replace match=1 if pid=="20130156"|deathid==20168
replace match=1 if pid=="20130037"|deathid==9702
replace match=1 if pid=="20130163"|deathid==2664
replace match=1 if pid=="20130032"|deathid==18937
replace match=1 if pid=="20130606"|deathid==17734
replace match=1 if pid=="20130504"|deathid==23091
replace match=1 if pid=="20130063"|deathid==22892
replace match=1 if pid=="20130313"|deathid==13982
replace match=1 if pid=="20130150"|deathid==4545
replace match=1 if pid=="20130814"|deathid==23540
replace match=1 if pid=="20130818"|deathid==13141
replace match=1 if pid=="20130141"|deathid==24166
replace match=1 if pid=="20080539"|deathid==4308
replace match=1 if pid=="20130103"|deathid==16675
replace match=1 if pid=="20130038"|deathid==13142
replace match=1 if pid=="20130096"|deathid==10089
replace match=1 if pid=="20130027"|deathid==15892
replace match=1 if pid=="20130119"|deathid==2401
replace match=1 if pid=="20130073"|deathid==22526
replace match=1 if pid=="20130130"|deathid==744
replace match=1 if pid=="20130768"|deathid==20744
replace match=1 if pid=="20130044"|deathid==12503
replace match=1 if pid=="20130648"|deathid==17611
replace match=1 if pid=="20130127"|deathid==10403
replace match=1 if pid=="20130031"|deathid==12632
replace match=1 if pid=="20130885"|deathid==4218
replace match=1 if pid=="20130079"|deathid==4675
replace match=1 if pid=="20130319"|deathid==20859
replace match=1 if pid=="20130361"|deathid==8255
replace match=1 if pid=="20130396"|deathid==7677
replace match=1 if pid=="20130067"|deathid==10712
replace match=1 if pid=="20130886"|deathid==14134
replace match=1 if pid=="20130022"|deathid==1089
replace match=1 if pid=="20130661"|deathid==2759
replace match=1 if pid=="20130769"|deathid==18762
replace match=1 if pid=="20130696"|deathid==21663
replace match=1 if pid=="20130830"|deathid==1409
replace match=1 if pid=="20130362"|deathid==7764
replace match=1 if pid=="20130674"|deathid==21844
replace match=1 if pid=="20130426"|deathid==12948
replace match=1 if pid=="20130874"|deathid==19340

** Change all unmatched records to match=200
replace match=200 if match==. //12,605 changes

** Update vstatus and dod
replace vstatus=2 if match==1 //137 changes
replace deceased=1 if match==1 //137 changes
replace dlc=dod if match==1 //137 changes

** Update any data as necessary - below found in electoral list or CR5db
replace natregno="441219-0078" if pid=="20130772"
replace natregno="430916-0127" if pid=="20130361"
replace natregno="290210-0134" if pid=="20130396"
replace natregno="470831-0059" if pid=="20130886"
replace natregno="460928-0146" if pid=="20130814"
replace natregno="461123-0063" if pid=="20130818"
replace natregno="190511-0027" if pid=="20130661"
replace natregno="421121-9999" if pid=="20130650"
replace natregno="560725-0072" if pid=="20130696"
replace natregno="471124-0012" if pid=="20130830"
replace natregno="300608-0059" if pid=="20130362"
replace natregno="841016-0041" if pid=="20130674"
replace natregno="610630-0103" if pid=="20130631"
replace natregno="370126-0030" if pid=="20130426"
replace natregno="490110-0091" if pid=="20130813"
replace natregno="450902-0022" if pid=="20130374"
replace natregno="440214-0018" if pid=="20130874"

count //

** Create cancer dataset with unmatched
preserve
drop if pid=="" | match==1
count //386
save "data\raw\datarequest_NAACCR-IACR_cancer_unmatched_alive_2013.dta", replace
restore

** Create cancer dataset with match
preserve
drop if pid=="" | match==200
count //70
rename deathid deathid_dd
rename dod dod_dd
rename cod1a cod1a_dd
rename cod cod_dd 
rename nrn nrn_dd
rename address address_dd
rename age age_dd
rename sex sex_dd
rename mstatus mstatus_dd
rename parish parish_dd
rename vstatus vstatus_dd
rename regnum regnum_dd
rename pname pname_dd
rename cancer cancer_dd
rename mname mname_dd
rename namematch namematch_dd
rename certtype certtype_dd
rename nrnnd nrnnd_dd
rename occu occu_dd
rename deathyear deathyear_dd
rename regdate regdate_dd
rename dupdod dupdod_dd
rename dupname dupname_dd
drop dlc slc name6 duration* onset* cod1b cod1c cod1d cod2* certif* death_certif* _merge
save "data\raw\datarequest_NAACCR-IACR_cancer_matched_2013.dta", replace
restore

** Create death dataset with match
preserve
drop if deathid==. | match==200
count //68
drop _merge
save "data\raw\datarequest_NAACCR-IACR_death_matched_2013.dta", replace
restore

** Clear data and merge 2008 'alive' cancer dataset with matched death dataset
use "data\raw\datarequest_NAACCR-IACR_cancer_matched_2013.dta", clear

merge m:1 lname fname match using "data\raw\datarequest_NAACCR-IACR_death_matched_2013.dta"

/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                             1
        from master                         1  (_merge==1)
        from using                          0  (_merge==2)

    matched                                69  (_merge==3)
    -----------------------------------------

	    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                                70  (_merge==3)
    -----------------------------------------
*/

** Check which one didn't merge
**list pid deathid fname lname match if _merge==1 //20130345 - incorrect deathid replaced for this pid in above code

drop *_dd*
** Save merged dataset
save "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2013.dta", replace


** Save merged dataset
save "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2013.dta", replace


*************************
**   2008 CANCER DATA  **
**   FINAL DATASETS    **
*************************

** Create alive cancer dataset wtih merged dataset and unmatched alive cases
use "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2013.dta", clear

count //70

append using "data\raw\datarequest_NAACCR-IACR_cancer_unmatched_alive_2013.dta"

count //456

save "data\raw\datarequest_NAACCR-IACR_cancer_alive_un&matched_2013.dta", replace

** Create 2013 cancer dataset with alive and previously-matched dead cases
use "data\raw\2013_updated_cancer_dataset_site.dta", clear


count //846
drop if vstatus!=2 //456 deleted

count //390

append using "data\raw\datarequest_NAACCR-IACR_cancer_alive_un&matched_2013.dta"

count //846

count if pid=="" & eid!="" //0
count if cod1a=="" & causeofdeath!="" //383
replace cod1a=causeofdeath if cod1a=="" & causeofdeath!="" //383 changes

drop name6

order pid deathid primarysite cod1a fname lname dod

** Updated cod field based on primarysite/hx vs cod1a
count if vstatus==2 & cod==. //0
count if deceased==1 & cod==. //0

** Check for DCOs to ensure dot=dod
count if basis==0 & dot!=dod //0
list pid deathid vstatus deceased dot dod if basis==0 & dot!=dod
replace basis=9 if pid=="20130800"
count if vstatus==2 & dod==. //0
count if patient==. //0
count if deceased==1 & dod==. //0

count //846

** Save final 2013 cancer dataset to be used in cancer survival analysis
save "data\clean\datarequest_NAACCR-IACR_matched_2013.dta", replace
label data "2013 cancer and 2013-2017 deaths matched - NAACCR-IACR 2019 Submission"
