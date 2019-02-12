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
log using "logfiles\naaccr-iacr_2008_2019.smcl", replace

** Automatic page scrolling of output
set more off

 ******************************************************************************
 *
 *	GA-C D R C      A N A L Y S I S         C O D E
 *                                                              
 *  DO FILE: 		1b_cancer_deaths_2008
 *					Dofile 1b: Death Data Matching
 *
 *	STATUS:			Completed
 *
 *  FIRST RUN: 		06feb2019
 *
 *	LAST RUN:		12feb2019
 *
 *  ANALYSIS: 		Matching 2008 cancer dataset with 2013-2017 death dataset
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
**   2008 CANCER DATA   **
** 2013-2017 DEATH DATA **
**************************
** Load the 2008 cancer dataset
use "data\raw\2008_updated_cancer_dataset_site.dta", clear
rename eid2 pid

count //1,204

** Create 'alive' cancer dataset
drop if vstatus==2 //450 deleted
// 2008 cancer dataset has dod for alive patients but it should really be dlc (date last contact)

rename dod dlc
count //754

save "data\raw\datarequest_NAACCR-IACR_alive_2008.dta", replace

append using "data\raw\2014_cancer_deaths_dc.dta", force

count //13,040

** Create field to label records you match
gen match=.


/* 
Note: the unique identifier number for each dataset noted below:
	cancer dataset - pid is an 8-digit number starting with year followed by 4 sequential numbers starting with 0001 e.g. 20130063.
					 eid is a 12-digit number - first 8 digits match pid then last 4 digits indicate tumour sequence (patient can have multiple tumours).
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
sort lname fname deathid eid
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname deathid eid
count if dupname>0 //1,294

order pid eid deathid fname lname nrn natregno dod cod1a primarysite address villagetown

sort lname fname vstatus
list deathid eid fname lname nrn natregno dod if dupname>0
count if (regexm(lname, "^a")|regexm(lname, "^b")|regexm(lname, "^c") ///
	 |regexm(lname, "^d")|regexm(lname, "^e")|regexm(lname, "^f") ///
	 |regexm(lname, "^g")) & dupname>0 //640
count if (regexm(lname, "^h")|regexm(lname, "^i")|regexm(lname, "^j")|regexm(lname, "^k") ///
	 |regexm(lname, "^l")|regexm(lname, "^m")|regexm(lname, "^n") ///
	 |regexm(lname, "^o")|regexm(lname, "^p")|regexm(lname, "^q") ///
	 |regexm(lname, "^r")|regexm(lname, "^s")|regexm(lname, "^t") ///
	 |regexm(lname, "^u")|regexm(lname, "^v")|regexm(lname, "^w") ///
	 |regexm(lname, "^x")|regexm(lname, "^y")|regexm(lname, "^z")) & dupname>0 //654
	 
list fname lname nrn natregno dod deathid eid if ///
	 (regexm(lname, "^a")|regexm(lname, "^b")|regexm(lname, "^c") ///
	 |regexm(lname, "^d")|regexm(lname, "^e")|regexm(lname, "^f") ///
	 |regexm(lname, "^g")) & dupname>0

list fname lname nrn natregno dod deathid eid if ///
	 (regexm(lname, "^h")|regexm(lname, "^i")|regexm(lname, "^j")|regexm(lname, "^k") ///
	 |regexm(lname, "^l")|regexm(lname, "^m")|regexm(lname, "^n") ///
	 |regexm(lname, "^o")|regexm(lname, "^p")|regexm(lname, "^q") ///
	 |regexm(lname, "^r")|regexm(lname, "^s")|regexm(lname, "^t") ///
	 |regexm(lname, "^u")|regexm(lname, "^v")|regexm(lname, "^w") ///
	 |regexm(lname, "^x")|regexm(lname, "^y")|regexm(lname, "^z")) & dupname>0

/*
** If you want to use an alternative format to lists above, the data and filter used above can be exported to excel
export_excel deathid eid fname lname nrn natregno dod if dupname>0 ///
			 using "L:\BNR_data\DM\data_requests\2019\cancer\versions\NAACCR-IACR\data\raw\2019-02-07_2008_JC.xlsx", sheet("List1_2008") firstrow(variables)
*/

** Update match field for all cases with matching cancer and death data
replace match=1 if pid==20080497|deathid==11744
replace match=2 if pid==20080320|deathid==19308
replace match=3 if pid==20080022|deathid==21675
replace match=4 if pid==20080019|deathid==22730
replace match=5 if pid==20080013|deathid==21088
replace match=6 if pid==20080730|deathid==18140
replace match=7 if pid==20080252|deathid==817
replace match=8 if pid==20080166|deathid==19225
replace match=9 if pid==20080668|deathid==3173
replace match=10 if pid==20080230|deathid==22895
replace match=11 if pid==20080017|deathid==21696
replace match=12 if pid==20080689|deathid==1091
replace match=13 if pid==20080154|deathid==14185
replace match=14 if pid==20080677|deathid==23941
replace match=15 if pid==20080337|deathid==18167
replace match=16 if pid==20080714|deathid==7768
replace match=17 if pid==20080620|deathid==23518
replace match=18 if pid==20080216|deathid==1099
replace match=19 if pid==20080684|deathid==852
replace match=20 if pid==20080539|deathid==4308
replace match=21 if pid==20080306|deathid==8358
replace match=22 if pid==20080023|deathid==14600
replace match=23 if pid==20080365|deathid==16703
replace match=24 if pid==20080345|deathid==5059
replace match=25 if pid==20080305|deathid==9778
replace match=26 if pid==20080276|deathid==11344
replace match=27 if pid==20080738|deathid==12603
replace match=28 if pid==20080540|deathid==10939
replace match=29 if pid==20080044|deathid==7950
replace match=30 if pid==20080041|deathid==11345
replace match=31 if pid==20080628|deathid==19688
replace match=32 if pid==20080034|deathid==20438
replace match=33 if pid==20080233|deathid==10116
replace match=34 if pid==20080200|deathid==1247
replace match=35 if pid==20080211|deathid==19796
replace match=36 if pid==20080373|deathid==17456
replace match=37 if pid==20080316|deathid==21980
replace match=38 if pid==20080751|deathid==12522
replace match=39 if pid==20080488|deathid==19740
replace match=40 if pid==20080686|deathid==15824
replace match=41 if pid==20080570|deathid==1137
replace match=42 if pid==20080487|deathid==13509
replace match=43 if pid==20080045|deathid==21853
replace match=44 if pid==20080027|deathid==20512
replace match=45 if pid==20080353|deathid==4030
replace match=46 if pid==20080531|deathid==494
replace match=47 if pid==20080416|deathid==8462
replace match=48 if pid==20080026|deathid==19258
replace match=49 if pid==20080031|deathid==7816
replace match=50 if pid==20080325|deathid==6020
replace match=51 if pid==20080253|deathid==3019
replace match=52 if pid==20080043|deathid==1692
replace match=53 if pid==20080290|deathid==7026
replace match=54 if pid==20080517|deathid==15461
replace match=55 if pid==20080680|deathid==16251
replace match=56 if pid==20080181|deathid==19266
replace match=57 if pid==20080509|deathid==10543
replace match=58 if pid==20080434|deathid==12648
replace match=59 if pid==20080508|deathid==3642
replace match=60 if pid==20081064|deathid==13711
replace match=61 if pid==20080594|deathid==5413
replace match=62 if pid==20080238|deathid==5989
replace match=63 if pid==20080054|deathid==2837
replace match=64 if pid==20080349|deathid==22950
replace match=65 if pid==20080059|deathid==21487
replace match=66 if pid==20080243|deathid==11065
replace match=67 if pid==20080150|deathid==11405
replace match=68 if pid==20080642|deathid==7979
replace match=69 if pid==20080505|deathid==3761 
replace match=70 if pid==20080472|deathid==13535 
replace match=71 if pid==20080435|deathid==15856 
replace match=72 if pid==20080137|deathid==23893 
replace match=73 if pid==20080543|deathid==10676 
replace match=74 if pid==20080221|deathid==12670 
replace match=75 if pid==20080410|deathid==9275 
replace match=76 if pid==20080565|deathid==21177 
replace match=77 if pid==20080883|deathid==2388 
replace match=78 if pid==20080065|deathid==1665 
replace match=79 if pid==20080348|deathid==8798 
**replace match=80 if pid==20080279 
replace match=81 if pid==20080330|deathid==3421 
replace match=82 if pid==20080234|deathid==17723 
replace match=83 if pid==20080578|deathid==9374 
replace match=84 if pid==20080636|deathid==4454 
replace match=85 if pid==20080208|deathid==5256 
replace match=86 if pid==20080341|deathid==19048 
replace match=87 if pid==20080327|deathid==14174 
replace match=88 if pid==20080412|deathid==13162 
replace match=89 if pid==20080562|deathid==21086 
replace match=90 if pid==20080213|deathid==4317 
replace match=91 if pid==20080601|deathid==2167 
replace match=92 if pid==20080155|deathid==2424 
replace match=93 if pid==20080574|deathid==12086 
replace match=94 if pid==20080622|deathid==5187 
replace match=95 if pid==20080257|deathid==11162 
replace match=96 if pid==20080063|deathid==4644 
replace match=97 if pid==20080544|deathid==10577 
replace match=98 if pid==20080775|deathid==16789 
replace match=99 if pid==20080174|deathid==17010 
replace match=100 if pid==20080360|deathid==18710 
replace match=101 if pid==20080169|deathid==13263 
replace match=102 if pid==20080250|deathid==8339 
replace match=103 if pid==20080661|deathid==12001 
replace match=104 if pid==20080212|deathid==3321 
replace match=105 if pid==20080576|deathid==18444 
replace match=106 if pid==20080553|deathid==9000 
replace match=107 if pid==20080292|deathid==15476
//216; 215 changes

** Change all unmatched records to match=200
replace match=200 if match==. //12,824 changes

** Update vstatus and dod
replace vstatus=2 if match!=200 //215 changes
replace deceased=1 if match!=200 //196 changes
replace dlc=dod if match>0 & match<108 //215 changes

** Update any data as necessary - below found in electoral list or CR5db
replace natregno="210620-0062" if pid==20080497
replace natregno="201130-0080" if pid==20080730
replace natregno="260722-7002" if pid==20080457
replace natregno="250323-0068" if pid==20081054
replace natregno="341125-0024" if pid==20080305
replace natregno="430906-7017" if pid==20080739
replace natregno="250612-8012" if pid==20080738
replace natregno="270715-0039" if pid==20080462
replace natregno="500612-8002" if pid==20080686
replace natregno="240612-0010" if pid==20080484
replace natregno="340429-0011" if pid==20080353
replace natregno="200830-0093" if pid==20080416
replace natregno="300620-0046" if pid==20080043
replace natregno="250312-0012" if pid==20080434
replace natregno="310330-0038" if pid==20081064
replace natregno="250808-0104" if pid==20080432
replace natregno="300408-0010" if pid==20080472
replace natregno="170830-8000" if pid==20080435
replace natregno="360916-0068" if pid==20080543
replace natregno="360713-8033" if pid==20080410
replace natregno="300902-0011" if pid==20080578
replace natregno="471204-0015" if pid==20080341
replace natregno="430601-8054" if pid==20080719
replace natregno="321017-0076" if pid==20080327
replace natregno="220929-0051" if pid==20080775
replace natregno="270112-0038" if pid==20080576

count //13,040

** Create cancer dataset with unmatched
preserve
drop if eid==. | match!=200
count //644; 645
save "data\raw\datarequest_NAACCR-IACR_cancer_unmatched_alive_2008.dta", replace
restore

** Create cancer dataset with match
preserve
drop if eid==. | match==200
count //754; 110; 109
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
drop dlc slc name6 duration* onset* cod1b cod1c cod1d cod2* certif* death_certif*
save "data\raw\datarequest_NAACCR-IACR_cancer_matched_2008.dta", replace
restore

** Create death dataset with match
preserve
drop if deathid==. | match==200
count //860; 106
save "data\raw\datarequest_NAACCR-IACR_death_matched_2008.dta", replace
restore

** Clear data and merge 2008 'alive' cancer dataset with matched death dataset
use "data\raw\datarequest_NAACCR-IACR_cancer_matched_2008.dta", clear

merge m:1 lname fname match using "data\raw\datarequest_NAACCR-IACR_death_matched_2008.dta"

/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                             1
        from master                         1  (_merge==1)
        from using                          0  (_merge==2)

    matched                               109  (_merge==3)
    -----------------------------------------

	    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               109  (_merge==3)
    -----------------------------------------

*/

** Check which one didn't merge
**list pid deathid fname lname match if _merge==1 //pid 20080279 which is deceased but in 2010 so un-do replace above so this case will become 'unmatched'

drop *_dd*
** Save merged dataset
save "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2008.dta", replace

	 
**************************
**   2008 CANCER DATA   **
** 2008-2012 DEATH DATA **
**************************
/*
While matching 2013-2017 deaths with 2008 data I found cases where patient died before 2013 but were 'alive' in cancer dataset
so now I need to check those against 2008-2012 deaths before creating final dataset for survival analysis
*/
** Load the 2008 'unmatched' cancer dataset
use "data\raw\datarequest_NAACCR-IACR_cancer_unmatched_alive_2008.dta", clear
drop name6

count //645

append using "data\raw\datarequest_NAACCR-IACR_death_prep_2008-2012.dta", force

count //12,535

** Create field to label records you match
replace match=. //645 changes

/* 
Note: the unique identifier number for each dataset noted below:
	cancer dataset - eid
	death dataset  - deathid
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
sort lname fname deathid eid
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname deathid eid
count if dupname>0 //1,174

order pid eid deathid fname lname nrn natregno dod cod1a primarysite address villagetown

sort lname fname dod
list deathid eid fname lname nrn natregno dod if dupname>0
count if (regexm(lname, "^a")|regexm(lname, "^b")|regexm(lname, "^c") ///
	 |regexm(lname, "^d")|regexm(lname, "^e")|regexm(lname, "^f") ///
	 |regexm(lname, "^g")) & dupname>0 //577
count if (regexm(lname, "^h")|regexm(lname, "^i")|regexm(lname, "^j")|regexm(lname, "^k") ///
	 |regexm(lname, "^l")|regexm(lname, "^m")|regexm(lname, "^n") ///
	 |regexm(lname, "^o")|regexm(lname, "^p")|regexm(lname, "^q") ///
	 |regexm(lname, "^r")|regexm(lname, "^s")|regexm(lname, "^t") ///
	 |regexm(lname, "^u")|regexm(lname, "^v")|regexm(lname, "^w") ///
	 |regexm(lname, "^x")|regexm(lname, "^y")|regexm(lname, "^z")) & dupname>0 //597
	 
list fname lname nrn natregno dod deathid eid if ///
	 (regexm(lname, "^a")|regexm(lname, "^b")|regexm(lname, "^c") ///
	 |regexm(lname, "^d")|regexm(lname, "^e")|regexm(lname, "^f") ///
	 |regexm(lname, "^g")) & dupname>0

list fname lname nrn natregno dod deathid eid if ///
	 (regexm(lname, "^h")|regexm(lname, "^i")|regexm(lname, "^j")|regexm(lname, "^k") ///
	 |regexm(lname, "^l")|regexm(lname, "^m")|regexm(lname, "^n") ///
	 |regexm(lname, "^o")|regexm(lname, "^p")|regexm(lname, "^q") ///
	 |regexm(lname, "^r")|regexm(lname, "^s")|regexm(lname, "^t") ///
	 |regexm(lname, "^u")|regexm(lname, "^v")|regexm(lname, "^w") ///
	 |regexm(lname, "^x")|regexm(lname, "^y")|regexm(lname, "^z")) & dupname>0

/*
** If you want to use an alternative format to lists above, the data and filter used above can be exported to excel
export_excel deathid eid fname lname nrn natregno dod if dupname>0 ///
			 using "L:\BNR_data\DM\data_requests\2019\cancer\versions\NAACCR-IACR\data\raw\2019-02-07_2008-2012_JC.xlsx", sheet("List3&4_2008") firstrow(variables) replace
*/

** Update match field for all cases with matching cancer and death data
replace match=201 if pid==20080586|deathid==6496
replace match=202 if pid==20080421|deathid==9574
replace match=203 if pid==20080011|deathid==11650
replace match=204 if pid==20080161|deathid==9763
replace match=205 if pid==20080177|deathid==11208
replace match=206 if pid==20080269|deathid==10974
replace match=207 if pid==20080347|deathid==8483
replace match=208 if pid==20080344|deathid==4404
replace match=209 if pid==20080346|deathid==6057
replace match=210 if pid==20080465|deathid==3608
replace match=211 if pid==20080182|deathid==9794
replace match=212 if pid==20080301|deathid==7939
replace match=213 if pid==20080377|deathid==8917
replace match=214 if pid==20080631|deathid==7522
replace match=215 if pid==20080654|deathid==3161
replace match=216 if pid==20080461|deathid==4878
replace match=217 if pid==20080387|deathid==4374
replace match=218 if pid==20080535|deathid==3314
replace match=219 if pid==20080616|deathid==9462
replace match=220 if pid==20080533|deathid==10333
replace match=221 if pid==20080324|deathid==8890
replace match=222 if pid==20080029|deathid==11204
replace match=223 if pid==20080042|deathid==11206
replace match=224 if pid==20080608|deathid==5393
replace match=225 if pid==20080597|deathid==2206
replace match=226 if pid==20080367|deathid==6484
replace match=227 if pid==20080545|deathid==4055
replace match=228 if pid==20080047|deathid==1762
replace match=229 if pid==20080323|deathid==9263
replace match=230 if pid==20080321|deathid==6533
replace match=231 if pid==20080057|deathid==11523
replace match=232 if pid==20080504|deathid==4282
replace match=233 if pid==20080286|deathid==11245
replace match=234 if pid==20080476|deathid==6776
replace match=235 if pid==20080381|deathid==4117
replace match=236 if pid==20080279|deathid==5862
replace match=237 if pid==20080328|deathid==10655
replace match=238 if pid==20080385|deathid==10735
replace match=239 if pid==20080296|deathid==3519
replace match=240 if pid==20080561|deathid==9566
replace match=241 if pid==20080581|deathid==3637
replace match=242 if pid==20080136|deathid==10298
replace match=243 if pid==20080205|deathid==7199
replace match=244 if pid==20080187|deathid==10148
replace match=245 if pid==20080278|deathid==9385
replace match=246 if pid==20080720|deathid==1828
replace match=247 if pid==20080580|deathid==4783
replace match=248 if pid==20080469|deathid==7239
replace match=249 if pid==20080123|deathid==10696
replace match=250 if pid==20080479|deathid==5489
replace match=251 if pid==20080203|deathid==9863

** Update vstatus and dod
replace vstatus=2 if match!=. //104 changes
replace deceased=1 if match!=. //64 changes
replace dlc=dod if match>200 & match<252 //104 changes

** Update any data as necessary - below found in electoral list or CR5db
replace natregno="190923-0052" if pid==20080421
replace natregno="590829-9999" if pid==20080177
replace natregno="291003-0077" if pid==20080344
replace natregno="430715-0054" if pid==20080766
replace natregno="240826-0038" if pid==20080465
replace natregno="320518-0056" if pid==20080592
replace natregno="230104-0040" if pid==20080301
replace natregno="221127-0018" if pid==20080377
replace natregno="221219-0066" if pid==20080654
replace natregno="320402-7019" if pid==20080450
replace natregno="491113-0039" if pid==20081109
replace natregno="250906-0022" if pid==20080461
replace natregno="310705-0050" if pid==20080533
replace natregno="361011-0078" if pid==20080504
replace natregno="210130-0107" if pid==20080476
replace natregno="120821-8006" if pid==20080385
replace natregno="220708-9999" if pid==20080205
replace natregno="360722-7034" if pid==20080720


** Create cancer dataset with unmatched
preserve
drop if eid==. | match!=.
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
drop dlc slc duration* onset* cod1b cod1c cod1d cod2* certif* death_certif*
count //592
save "data\raw\datarequest_NAACCR-IACR_cancer_unmatched_alive_2008-2012.dta", replace
restore

** Create cancer dataset with match
preserve
drop if eid==. | match==.
count //53
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
drop dlc slc duration* onset* cod1b cod1c cod1d cod2* certif* death_certif*
save "data\raw\datarequest_NAACCR-IACR_cancer_matched_2008-2012.dta", replace
restore

** Create death dataset with match
preserve
drop if deathid==. | match==.
count //51
save "data\raw\datarequest_NAACCR-IACR_death_matched_2008-2012.dta", replace
restore

** Clear data and merge 2008 'alive' cancer dataset with matched death dataset
use "data\raw\datarequest_NAACCR-IACR_cancer_matched_2008-2012.dta", clear

merge m:1 lname fname match using "data\raw\datarequest_NAACCR-IACR_death_matched_2008-2012.dta"

/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                                53  (_merge==3)
    -----------------------------------------
*/

count //53
drop *_dd*
** Save merged dataset
save "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2008-2012.dta", replace

** Add other matched cases from above to this saved dataset
append using "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2008.dta"

count //162

save "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2008.dta", replace

*************************
**   2008 CANCER DATA  **
**   FINAL DATASETS    **
*************************

** Create alive cancer dataset wtih merged dataset and unmatched alive cases
use "data\raw\datarequest_NAACCR-IACR_cancer_death_matched_2008.dta", clear

count //162

append using "data\raw\datarequest_NAACCR-IACR_cancer_unmatched_alive_2008-2012.dta"

drop *_dd*
count //754

save "data\raw\datarequest_NAACCR-IACR_cancer_alive_un&matched_2008.dta", replace

** Create 2008 cancer dataset with alive and previously-matched dead cases
use "data\raw\2008_updated_cancer_dataset_site.dta", clear

** Some CR5 cases missing eid (DCOs) so check CR5 and assign
order eid2 lineno fname lname
replace eid2=20081133 if lineno=="X0000030F/2008"
replace eid2=20081132 if lineno=="X0000099C/2008"
replace eid2=20081130 if lineno=="X0000026E/2008"
replace eid2=20081129 if lineno=="X0000169B/2008"
replace eid2=20081128 if lineno=="X0000171B/2008"
replace eid2=20090037 if lineno=="X0000083C/2008"
replace eid2=20081131 if lineno=="X0000012B/2008"
replace eid2=20081135 if lineno=="X0001509A/2008"
replace eid2=20081134 if lineno=="X0000067B/2008"

count //1,204
drop if vstatus!=2 //754 deleted

count //450

append using "data\raw\datarequest_NAACCR-IACR_cancer_alive_un&matched_2008.dta"

count //1,204

count if pid==. & eid2!=. //450
replace pid=eid2 if pid==. & eid2!=. //450 changes
count if cod1a=="" & causeofdeath!="" //437
replace cod1a=causeofdeath if cod1a=="" & causeofdeath!="" //437 changes

drop name6

order pid deathid primarysite cod1a fname lname dod

** Updated cod field based on primarysite/hx vs cod1a
count if vstatus==2 & cod==. //110
list deathid pid fname lname if vstatus==2 & cod==.
export_excel pid deathid fname lname basis nrn natregno dod primarysite histology cod1a if vstatus==2 & cod==. ///
			 using "L:\BNR_data\DM\data_requests\2019\cancer\versions\NAACCR-IACR\data\raw\2019-02-07_2008_cod_JC.xlsx", sheet("List_cod_missing_2008") firstrow(variables) replace
replace cod=1 if vstatus==2 & cod==. & basis==0 //9 changes
replace cod=1 if pid==20080084|pid==20080070|pid==20080600|pid==20080411 ///
				|pid==20080071|pid==20080074|pid==20080077|pid==20080299 ///
				|pid==20080297|pid==20080107|pid==20080266|pid==20080072 ///
				|pid==20080081|pid==20080080|pid==20080087|pid==20080086 ///
				|pid==20080621|pid==20080091|pid==20080090|pid==20080083 ///
				|pid==20080463|pid==20080464|pid==20080516|pid==20080265 ///
				|pid==20080293|pid==20080515|pid==20080359|pid==20080355 ///
				|pid==20080354|pid==20080309|pid==20080078|pid==20080085 ///
				|pid==20080075|pid==20080082|pid==20080267|pid==20080073 ///
				|pid==20080586|pid==20080421|pid==20080011|pid==20080161 ///
				|pid==20080177|pid==20080269|pid==20080346|pid==20080535 ///
				|pid==20080616|pid==20080324|pid==20080597|pid==20080047 ///
				|pid==20080323|pid==20080321|pid==20080057|pid==20080504 ///
				|pid==20080286|pid==20080279|pid==20080328|pid==20080296 ///
				|pid==20080136|pid==20080205|pid==20080187|pid==20080278 ///
				|pid==20080469|pid==20080123|pid==20080479
replace cod=2 if pid==20080609|pid==20080089|pid==20080445|pid==20080465 ///
				|pid==20080478|pid==20080104|pid==20080098|pid==20080079 ///
				|pid==20080347|pid==20080344|pid==20080182|pid==20080301 ///
				|pid==20080377|pid==20080631|pid==20080654|pid==20080461 ///
				|pid==20080387|pid==20080533|pid==20080029|pid==20080042 ///
				|pid==20080608|pid==20080367|pid==20080545|pid==20080476 ///
				|pid==20080381|pid==20080385|pid==20080561|pid==20080581 ///
				|pid==20080720|pid==20080580|pid==20080203

replace cod1a="N SQUAMOUS CARCINOMA LUNG" if pid==20080463
replace cod1a="N PULMONARY OEDEMA CHRONIC LEUKEMIA SEVERE ANEMIA AND HEPATO SPLENOMEGALY" if pid==20080464
replace cod1a="N INTESTINAL OBSTRUCTION WITH SEPTICAEMIC SHOCK (NATURAL)" if pid==20080465

** Check for DCOs to ensure dot=dod
rename doc dot
count if basis==0 & dot!=dod //0
count if vstatus==2 & dod==. //0
count if patient==. //0
count if deceased==1 & dod==. //11 - checked and dead in main CR5db
list pid deathid fname lname vstatus basis if deceased==1 & dod==.
replace vstatus=2 if deceased==1 & dod==. //11 changes


count //1,204

** Save final 2008 cancer dataset to be used in cancer survival analysis
save "data\clean\datarequest_NAACCR-IACR_matched_2008.dta", replace
label data "2008 cancer and 2013-2017 deaths matched - NAACCR-IACR 2019 Submission"
