** This version03 prepared by AMC Rose on 02-jun-2015 
** (first version for this analysis of survival as per Bristol)
** version03 prepared by AMC Rose on 02-jun-2015: TO DO SURVIVAL PROPERLY!

** Stata version control
version 13

** Initialising the STATA log and allow automatic page scrolling
capture {
        program drop _all
	drop _all
	log close
	}

** Direct Stata to your do file folder using the -cd- command
cd "C:\BNR_data\DM\data_analysis\2008\cancer\versions\version03\"

** Automatic page scrolling of output
set more off

** Begin a Stata logfile
log using "logfiles\8_section6.smcl", replace


 *************************************************************************
 *     C D R C         A N A L Y S I S         C O D E
 *                                                              
 *     DO FILE: 8_section6.do
 * 
 *  	AUTHOR : Angie Rose
 *
 *		LAST UPDATE: 02-jun-2015
 *
 *    	ANALYSIS: BNR CANCER: 2008 Annual Report 
 *
 *     PRODUCT: STATA SE version 13
 *
 *        DATA: Datasets provided by Angie Rose
 *
 *     SUPPORT: Ian R Hambleton        
 *     DETAILS: Section 4: Treatment & outcomes
 *			   
 *************************************************************************


* ************************************************************************
* ANALYSIS: SECTION 6 - SURVIVAL ANALYSIS
* Covering
* 6.1 Survival analysis to 5 years
**************************************************************************

** Load the dataset
use "data\2008_updated_cancer_dataset_site_cod2.dta", clear

** first we have to restrict dataset to patients not tumours
drop if patient!=1
count

** now ensure everyone has a unique id
count if eid==.

gen id=eid-2008000000
list id lineno if eid==.
** These are the 9 DCOs - no eid as not abstracted by BNR-C team
** so we give them fake eids
replace id=999901 if lineno=="X0000026E/2008"
replace id=999902 if lineno=="X0000169B/2008"
replace id=999903 if lineno=="X0000099C/2008"
replace id=999904 if lineno=="X0000083C/2008"
replace id=999905 if lineno=="X0001509A/2008"
replace id=999906 if lineno=="X0000171B/2008"
replace id=999907 if lineno=="X0000067B/2008"
replace id=999908 if lineno=="X0000030F/2008"
replace id=999909 if lineno=="X0000012B/2008"
tab id ,m

summ

** failure is defined as deceased==1
codebook deceased
recode deceased 2=0
tab deceased ,m
tab deathdate ,m
count if deathdate!=.

** check all patients have a doc (incidence date)
tab doc ,m

** set study end date variable as 5 years from dx date IF PT HAS NOT DIED
gen end_date=(doc+(365.25*5)) if doc!=. // note 2008 was a leap year so pt dx on 01 jan 2008
                              //  actually has an end date on 31dec2012!						  
							  
format end_date %dD_m_CY

** check all patients have an end_date
tab end_date ,m

** check that all who died have a deathdate
tab deathdate if deceased==1 ,m // 4 have deathdates in 2014 but we saw above
								// that all end_dates are in 2013

** those 4 with deathdates in 2014 need to be reset to "alive". In fact,
** and any with deathdates >5 years from dx even if deathdate still in 2013,
** needs to be reset as alive
replace deceased=0 if deathdate!=. & deathdate>doc+(365.25*5)
		
** set to missing those who have deathdate>5 years from incidence date - but
** first create new variable for time to death/date last seen, called "time"

** (1) use deathdate to define time to death if died within 5 yrs
gen time=deathdate-doc if (deathdate!=. & deceased==1 & deathdate<doc+(365.25*5)) 

** (2) next use 5 yrs as time, if died >5 yrs from incidence
replace time=end_date-doc if (end_date<deathdate & deathdate!=. & deceased==1)

** (2) next use dod as end date, if alive and have date last seen (dod)
replace time=dod-doc if (dod<end_date & deceased==0)

tab time ,m
count if time!=. // at this point we are missing 9 for time... why?

list time doc dod end_date deathdate deceased if time==.
** these have date last seen > end_date - so here make dod the end_date
replace time=end_date-doc if (end_date<dod & deceased==0) & time==. & dod!=.

** what to do with the 3 missing values for dod??
list if dod==.

** for eid 2008017901 - comments state that pt contacted by doctor's office on
** 26aug2009 and then that they died in the USA in 2011 - will use 15jun2011 as
** deathdate
replace deathdate=d(15jun2011) if eid==2008017901
replace deceased=1  if eid==2008017901
replace time=deathdate-doc if (deathdate!=. & deceased==1 & deathdate<doc+(365.25*5)) 
													
** for eid 2009006101 - comments state that procedure done/report issued 23mar2009
** so will use this as proxy for dod (date last seen)
replace dod=d(23mar2009) if eid==2009006101 & dod==.
replace time=dod-doc if (dod<end_date & deceased==0)
								
** for eid 2008066401 - comments state that procedure done 08dec2008
** so will use this as proxy for dod (date last seen)
replace dod=d(08dec2008) if eid==2008066401 & dod==.
replace time=dod-doc if (dod<end_date & deceased==0)
									
list doc end_date deathdate deceased if end_date<deathdate & deathdate!=.
** these are the 11 from above - change deathdate to missing (deceased already
** set to 0 above) as they did not die within 5 years
replace deathdate=. if end_date<deathdate & deathdate!=.

tab deceased ,m // now 492 (used to be 502 but 11 died >5 years + 1 extra just discovered)
sort end_date   // death from comments so changed from alive to dead
tab end_date ,m

** Now to set up dataset for survival analysis, we need each patient's date of
** entry to study (incidence date, or doc), and exit date from study which is end_date
** UNLESS they died before end_date or were last seen before end_date in which case
** they should be censored... so now we create a NEW end_date as a combination of
** the above
sort doc 
sort eid2

list eid2 doc deceased deathdate dod end_date

gen newend_date=deathdate if (end_date>deathdate & deathdate!=. & deceased==1)
replace newend_date=dod if (dod<end_date) & deathdate==. & deceased==0
count if newend_date==.
list doc deceased deathdate dod end_date if newend_date==.
replace newend_date=end_date if newend_date==.
format newend_date %dD_m_CY

describe doc  newend_date
sort doc
list id doc deathdate dod end_date newend_date

tab time ,m
list deceased doc deathdate dod end_date newend_date time if time==0
** there are 121 records with time=0 (ie either DCO or defaulted as not seen after dx date)
** honestly those who did not die (ie no death certificate) should have at least a
** value of 1 day... while those DCOs are understandably at time=0
replace newend_date=newend_date+1 if (time==0 & deceased==0)
replace time=1 if (time==0 & deceased==0)

** AR: after meeting RH 26-aug-2016: CHANGE THOSE WITH DOC>DEATHDATE SO DOC=DEATHDATE

** Now survival time set the dataset using newend_date as the time variable and deceased
** as the failure variable
stset newend_date , failure(deceased) origin(doc) scale(365.25)
tab _st // 1049 observations contribute to analysis
stdes
sts graph
sts graph , by(sex) 
gen newtime=int(time/365.25) 
tab newtime deceased ,m

** now see by site - for blood cancers for BNR-C seminar in Oct 2016 (see earlier dofile)
preserve
keep if site==10
count
** put it into 3 age-groups 0-44, 45-74, 75 & over
gen age_new=1 if age>0 & age<45
replace age_new=2 if age>44 & age<75
replace age_new=3 if age>74 & age!=.

rename age_new agegroup

label define agegroup_lab 1 "0-44" 2 "45-74" 3 "75 & over"
label values agegroup agegroup_lab

tab agegroup ,m
list doc deathdate top morph cause if agegroup==3

sts graph  //, by(agegroup) 
restore

** now see by broad age-groups
preserve
gen age_3="0-54 years" if age_10<6
replace age_3="55-74 years" if age_10>5 & age_10<8
replace age_3="75 years & over" if age_10>7 & age_10!=.
sts graph , by(age_3) 
restore

** check that variables make sense
tab _d deceased // yes
list id doc deceased newend_date time _t0 _t in 1/10
list id doc deceased newend_date time _t0 _t if time==1

** now we can compute rates of disease
strate
strate , per(1000) // per 1000 py
strate sex, per(1000) // per 1000 py by sex
list id doc newend_date _t0 _t in 1/10

** merge with population dataset for MRs
merge m:m sex age_10 using "C:\BNR_data\DM\data_analysis\2012\stroke\weeks01-52\versions\version02\data\population\bb2010_10-2.dta"
 
** use stmh command for rate ratios with 95%CI
stmh sex // no difference
stmh age // significant difference
stmh age_10 // significant difference

** now we can compute rates of death
strate
strate , per(1000) // per 1000 py
strate sex, per(1000) // per 1000 py by sex NS
strate age_10, per(1000) // per 1000 py by age-group SS!

** how do rates change with age?
tab age_10 _d
recode age_10 1=2
gen age_group=24 if age_10==2
replace age_group=34 if age_10==3
replace age_group=44 if age_10==4
replace age_group=54 if age_10==5
replace age_group=64 if age_10==6
replace age_group=74 if age_10==7
replace age_group=84 if age_10==8
replace age_group=94 if age_10==9

strate age_group , per(1000) graph yscale(log)

** however note that this is ALL DEATHS - need to change to deaths FROM CANCER
** and the other deaths will count as COMPETING RISKS
** first create new variable called event
gen event=1 if cod==1 // cancer death
replace event=2 if cod==2 // non-cancer death
replace event=3 if cod==. & deceased==0 // survived
label define event 1 "died from cancer" 2 "non-cancer death" 3 "survived"

** first stset data with cancer death as event of interest
stset time , failure(event=1) scale(365.25)
sts graph ,f
sts list ,f // shows us that 73.1% appear to have died from cancer by end of follow-up

** next stset data with non-cancer death as event of interest
stset time , failure(event=2) scale(365.25)
sts graph ,f
sts list ,f // shows us that 19.5% appear to have died from non-cancer causes by end of follow-up

** next stset data with unknown cod as event of interest
stset time , failure(event=3) scale(365.25)
sts graph ,f
sts list ,f // shows us that 97.3% appear to have survived by end of follow-up

** obviously the 3 things above are not possible all together!

** So now do cumulative incidence function but specify your competing risk by telling
** it that event #2 is the competing one
// quietly: do stcomp.do
stset time , failure(event==1) scale(365.25)

** generate the CIP for event 1 (cancer death), taking into account competing event 2 
** (non-cancer death)
stcompet cif=ci , compet(2)
gen cif1=cif if event==1
label var cif1 "CIF for cancer deaths"

** generate the CIP for event 2 (non-cancer death), taking into account competing event 1 
** (cancer death)
gen cif2=cif if event==2
label var cif2 "CIF for non-cancer deaths"

** graph the 2 CIFs together
sort _t
graph twoway line cif1 cif2 _t , ///
      title(Cumulative incidence of cancer deaths in cancer patients) ///
	  xtitle(years from diagnosis) ytitle(% patients)



