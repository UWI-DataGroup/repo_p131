** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    bnr_survival_2008.do
    //  project:				        BNR
    //  analysts:				       	Ian HAMBLETON, Jacqueline CAMPBELL
    //  date first created      12-FEB-2019
    // 	date last modified	    14-FEB-2019
    //  algorithm task			    Reading the FAO population dataset
    //  objectve                To create graphs for NAACCR-IACR 2019 abstract

    ** DO FILE BASED ON
    * AMC Rose code from on 02-jun-2015
    * Code for BNR Cancer 2008 annual report (??)

    ** General algorithm set-up
    version 15
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p131"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p131

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\bnr_survival_2008", replace
** HEADER -----------------------------------------------------


* ************************************************************************
* SURVIVAL ANALYSIS
* Survival analysis to 5 years
**************************************************************************

** Load the dataset
use "`datapath'\version01\3-output\datarequest_NAACCR-IACR_matched_2008", clear

count //1,204

** first we have to restrict dataset to patients not tumours
drop if patient!=1
count //1,117

** note: to standardize case definitions in 2008, 2013, 2014 datasets remove non-reportable skin cancers and tumours with behaviour!=in-situ or malignant
drop if icd10=="C44" //0 deleted - AR dropped all skin cancers in original dataset using ICD-O-3 code C44: included reportable skin cancers
drop if beh!=2 & beh!=3 //17 deleted

** now ensure everyone has a unique id
count if pid==. //0

** IRH (12feb2019) tab id ,m
** IRH (12feb2019) summ

** failure is defined as deceased==1
** IRH (12feb2019) codebook deceased
recode deceased 2=0 //511 changes
** IRH (12feb2019) tab deceased ,m
** IRH (12feb2019) tab deathdate ,m //dod, not deathdate, used in 2013, 2014 datasets
** JC (14feb2019) tab dod ,m
** JC (14feb2019) tab dlc ,m //dlc used in 2013,2014 datasets for date last contact
** JC (14feb2019) count if dod!=.
** IRH (12feb2019) count if deathdate!=.

** check for all patients who are deceased but missing dod
count if deceased==1 & dod==. //5
list pid fname lname deceased vstatus slc dlc if deceased==1 & dod==.
replace dod=dlc if deceased==1 & dod==. //5 changes
** JC (14feb2019) tab dod ,m

version 14.1

** check all patients have a dot (incidence date)
** IRH (12feb2019) tab dot ,m

** set study end date variable as 5 years from dx date IF PT HAS NOT DIED
gen end_date=(dot+(365.25*5)) if dot!=. // note 2008 was a leap year so pt dx on 01 jan 2008
                              //  actually has an end date on 31dec2012!

format end_date %dD_m_CY

** check all patients have an end_date
** IRH (12feb2019) tab end_date ,m

** check that all who died have a dod
** IRH (12feb2019) tab dod if deceased==1 ,m
// 4 have dod in 2014 but we saw above
// that all end_dates are in 2013

** those 4 with dod in 2014 need to be reset to "alive". In fact,
** and any with dod >5 years from dx even if dod still in 2013,
** needs to be reset as alive
replace deceased=0 if dod!=. & dod>dot+(365.25*5) //94 changes

** set to missing those who have dod>5 years from incidence date - but
** first create new variable for time to death/date last seen, called "time"

** (1) use dod to define time to death if died within 5 yrs
gen time=dod-dot if (dod!=. & deceased==1 & dod<dot+(365.25*5))

** (2) next use 5 yrs as time, if died >5 yrs from incidence
replace time=end_date-dot if (end_date<dod & dod!=. & deceased==1) //0 changes

** (2) next use dlc as end date, if alive and have date last seen (dlc)
replace time=dlc-dot if (dlc<end_date & deceased==0) //507 changes

** IRH (12feb2019) tab time ,m
** IRH (12feb2019) count if time!=. // at this point we are missing 9 for time... why?
** JC (14feb2019) count if time!=. //98 missing time - why?

** IRH (12feb2019) list time dot dlc end_date dod deceased if time==.
** these have date last seen > end_date - so here make dlc the end_date
replace time=end_date-dot if (end_date<dlc & deceased==0) & time==. & dlc!=. //98 changes

** what to do with the 3 missing values for dlc??
** IRH (12feb2019) list if dlc==.
** JC (14feb2019) count if dlc==. //0

** for pid 20080179 - comments state that pt contacted by doctor's office on
** 26aug2009 and then that they died in the USA in 2011 - will use 15jun2011 as
** dod
replace dod=d(15jun2011) if pid==20080179 //1 change
** JC (14feb2019) replace deceased=1  if pid==20080179 //changed already in 1b_cancer_deaths_2008.do
replace time=dod-dot if (dod!=. & deceased==1 & dod<dot+(365.25*5)) //1 change

** for eid 2009006101 - comments state that procedure done/report issued 23mar2009
** so will use this as proxy for dlc (date last seen)
** JC (14feb2019) list dlc dod deceased if pid==20090061
** JC (14feb2019) replace dlc=d(23mar2009) if eid==2009006101 & dlc==. //changed already in 1b_cancer_deaths_2008.do
replace time=dlc-dot if (dlc<end_date & deceased==0) //0 changes

** for eid 2008066401 - comments state that procedure done 08dec2008
** so will use this as proxy for dlc (date last seen)
** JC (14feb2019) list dlc dod deceased if pid==20080664
** JC (14feb2019) replace dlc=d(23mar2009) if eid==2008066401 & dlc==. //changed already in 1b_cancer_deaths_2008.do
** JC (14feb2019) replace dlc=d(08dec2008) if eid==2008066401 & dlc==.
** JC (14feb2019) replace time=dlc-dot if (dlc<end_date & deceased==0)

** IRH (12feb2019) list dot end_date dod deceased if end_date<dod & dod!=.
** these are the 11 from above - change dod to missing (deceased already
** set to 0 above) as they did not die within 5 years
** JC (14feb2019) list dot end_date dod deceased if end_date<dod & dod!=.
** these are the 94 from 98 above - change dod to missing (deceased already
** set to 0 above) as they did not die within 5 years
replace dod=. if end_date<dod & dod!=. //94 changes

** IRH (12feb2019) tab deceased ,m // now 492 (used to be 502 but 11 died >5 years + 1 extra just discovered)
** JC (14feb2019) tab deceased ,m // now 495 (used to be 589 but 94 died >5 years)
sort end_date   // death from comments so changed from alive to dead
** IRH (12feb2019) tab end_date ,m

** Now to set up dataset for survival analysis, we need each patient's date of
** entry to study (incidence date, or dot), and exit date from study which is end_date
** UNLESS they died before end_date or were last seen before end_date in which case
** they should be censored... so now we create a NEW end_date as a combination of
** the above
sort dot
sort pid
**sort eid2

** IRH (12feb2019) list eid2 dot deceased dod dlc end_date
** JC (14feb2019) list pid dot deceased dod dlc end_date

gen newend_date=dod if (end_date>dod & dod!=. & deceased==1)
replace newend_date=dlc if (dlc<end_date) & dod==. & deceased==0 //507 changes
** IRH (12feb2019) count if newend_date==.
** IRH (12feb2019) list dot deceased dod dlc end_date if newend_date==.
** JC (14feb2019) count if newend_date==. //98
** JC (14feb2019) list dot deceased dod dlc end_date if newend_date==.
replace newend_date=end_date if newend_date==. //98 changes
format newend_date %dD_m_CY

** IRH (12feb2019) describe dot  newend_date
sort dot
** IRH (12feb2019) list id dot dod dlc end_date newend_date

** IRH (12feb2019) tab time ,m
** IRH (12feb2019) list deceased dot dod dlc end_date newend_date time if time==0
** there are 121 records with time=0 (ie either DCO or defaulted as not seen after dx date)
** honestly those who did not die (ie no death certificate) should have at least a
** value of 1 day... while those DCOs are understandably at time=0
** JC (14feb2019) list deceased dot dod dlc end_date newend_date time if time==0
** there are 112 records with time=0 (ie either DCO or defaulted as not seen after dx date)
** honestly those who did not die (ie no death certificate) should have at least a
** value of 1 day... while those DCOs are understandably at time=0
replace newend_date=newend_date+1 if (time==0 & deceased==0) //55 changes
replace time=1 if (time==0 & deceased==0) //55 changes


** AR: after meeting RH 26-aug-2016: CHANGE THOSE WITH DOT>DOD SO DOT=DOD



*************************************************************
** IRH (12feb2019)
** SURVIVAL WORK FROM HERE
*************************************************************

** Now survival time set the dataset using newend_date as the time variable and deceased
** as the failure variable
stset newend_date , failure(deceased) origin(dot) scale(365.25)
** IRH (12feb2019) tab _st // 1049 observations contribute to analysis
stdes

** GRAPH 1
** K-M unstratified
#delimit ;
sts graph
        ,
        plotregion(c(gs16) lw(vthin) ic(gs16) ilw(vthin) )
        graphregion(color(gs16) ic(gs16) ilw(vthin) lw(vthin))
        ysize(10) xsize(7.5)

	    xtitle(Years since Diagnosis, margin(t=4) size(3))
        ytitle(% Participants, margin(r=4) size(3))
        ylab( 0(0.2)1, labs(3)  nogrid angle(0) format(%9.1f))
        ymtick(0(0.1)1)
        xlab(0(1)5, labs(3)  nogrid angle(0) format(%9.1f))
        xmtick(0(0.5)5)

        title("")
        plotopts(lp("l") lc(gs0))
        legend(size(3) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1) order(1 2)
        region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
        lab(1 "Male")
        lab(2 "Female")
        )
        name(figure1)
        ;
#delimit cr


** GRAPH 2
** K-M stratified by sex
** IRH - example of a publication-quality formatted graphic...
#delimit ;
sts graph
        ,
        by(sex)
        plotregion(c(gs16) lw(vthin) ic(gs16) ilw(vthin) )
        graphregion(color(gs16) ic(gs16) ilw(vthin) lw(vthin))
        ysize(10) xsize(7.5)

	    xtitle(Years since Diagnosis, margin(t=4) size(3))
        ytitle(% Participants, margin(r=4) size(3))
        ylab( 0(0.2)1, labs(3)  nogrid angle(0) format(%9.1f))
        ymtick(0(0.1)1)
        xlab(0(1)5, labs(3)  nogrid angle(0) format(%9.1f))
        xmtick(0(0.5)5)

        title("")
        plot1opts(lp("l") lc(gs0))
        plot2opts(lp("l") lc(gs10))

        legend(size(3) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1) order(1 2)
        region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
        lab(1 "Male")
        lab(2 "Female")
        )
        name(figure2)
        ;
#delimit cr



gen newtime=int(time/365.25)
** IRH (12feb2019) tab newtime deceased ,m



** BY THREE broad age groups
** Unstratified K-M
preserve
    gen age_3="0-54 years" if age_10<6
    replace age_3="55-74 years" if age_10>5 & age_10<8
    replace age_3="75 years & over" if age_10>7 & age_10!=.

    #delimit ;
    sts graph
            ,
            by(age_3)
            plotregion(c(gs16) lw(vthin) ic(gs16) ilw(vthin) )
            graphregion(color(gs16) ic(gs16) ilw(vthin) lw(vthin))
            ysize(10) xsize(7.5)

    	    xtitle(Years since Diagnosis, margin(t=4) size(3))
            ytitle(% Participants, margin(r=4) size(3))
            ylab( 0(0.2)1, labs(3)  nogrid angle(0) format(%9.1f))
            ymtick(0(0.1)1)
            xlab(0(1)5, labs(3)  nogrid angle(0) format(%9.1f))
            xmtick(0(0.5)5)

            title("")
            plot1opts(lp("l") lc(gs0))
            plot2opts(lp("l") lc(gs5))
            plot3opts(lp("l") lc(gs10))

            legend(size(3) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1) order(1 2 3)
            region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
            lab(1 "0-54 yrs")
            lab(2 "55-74 yrs")
            lab(3 "75+ yrs")
            )
            name(figure3)
            ;
    #delimit cr
restore


** MERGE WITH 2010 BARBADOS POPULATION
drop _merge
merge m:m sex age_10 using "`datapath'\version01\1-input\bb2010_10-2.dta"

** MORTALITY RATE RATES
** Comparing gender
stmh sex
** Comparing Age (to nearest year)
stmh age
** Comparing Age (10-year bands?)
stmh age_10

** MORTALITY RATES (per  1000 person years)
strate
strate , per(1000) // per 1000 py
strate sex, per(1000) // per 1000 py by sex NS
strate age_10, per(1000) // per 1000 py by age-group SS!

** INFORMALLY (VISUALLY) ...
** How do rates change with age?
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

** GRAPHIC OF RATES
#delimit ;
    strate age_group , per(1000) graph yscale(log)
        mc(gs0)
        plotregion(c(gs16) lw(vthin) ic(gs16) ilw(vthin) )
        graphregion(color(gs16) ic(gs16) ilw(vthin) lw(vthin))
        ysize(7.5) xsize(7.5)

        title("")
        xtitle(Age, margin(t=4) size(3))
        ytitle(Mortality rate (per 1000 py), margin(r=4) size(3))
        ylab(50 100 200 400 600 800, labs(3)  nogrid angle(0) format(%9.1f))
        ymtick(150 250 350 450 550 650 750)
        xlab(24 "0-24" 34 "25-34"  44 "35-44" 54 "45-54" 64 "55-64" 74 "65-74" 84 "75-84" 94 "85+", labs(3)  nogrid angle(0) format(%9.1f))
        xmtick(24(10)94)

        legend(size(3) position(6) bm(t=0 b=5 l=0 r=0) colf cols(1) order(1 2)
        region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
        lab(1 "XX")
        lab(2 "YY")
        )
        name(figure4)
        ;
#delimit cr

** TO THIS POINT - WE HAVE USED ALL DEATHS
** CAN ALSO LOOK AT deaths ONLY FROM CANCER
** and the other deaths will count as COMPETING RISKS
** first create new variable called event
gen event=1 if cod==1 // cancer death
replace event=2 if cod==2 // non-cancer death
replace event=3 if cod==. & deceased==0 // survived
label define event 1 "cancer death" 2 "non-cancer death" 3 "survived"

** first stset data with cancer death as event of interest
stset time , failure(event=1) scale(365.25)
** IRH (12feb2019) sts graph ,f
** IRH (12feb2019) sts list ,f // shows us that 73.1% appear to have died from cancer by end of follow-up

** next stset data with non-cancer death as event of interest
stset time , failure(event=2) scale(365.25)
** IRH (12feb2019) sts graph ,f
** IRH (12feb2019) sts list ,f // shows us that 19.5% appear to have died from non-cancer causes by end of follow-up



** Cumulative incidence function (CIF)
** Event #2  (non-cancer deaths) is the competing event
stset time , failure(event==1) scale(365.25)

** generate the CIF for event 1 (cancer death), taking into account competing event 2 (non-cancer death)
stcompet cif = ci , compet(2)
gen cif1 = cif if event==1
label var cif1 "CIF for cancer deaths"

** generate the CIP for event 2 (non-cancer death), taking into account competing event 1 (cancer death)
gen cif2=cif if event==2
label var cif2 "CIF for non-cancer deaths"

** graph the 2 CIFs together
sort _t
#delimit ;
    graph twoway line cif1 cif2 _t, lp("l" "l") lc(gs0 gs10)
        ,
        plotregion(c(gs16) lw(vthin) ic(gs16) ilw(vthin) )
        graphregion(color(gs16) ic(gs16) ilw(vthin) lw(vthin))
        ysize(7.5) xsize(7.5)

        title("")
        xtitle(Years since Diagnosis, margin(t=4) size(3))
        ytitle(% Participants, margin(r=4) size(3))
        ylab( 0(0.2)1, labs(3)  nogrid angle(0) format(%9.1f))
        ymtick(0(0.1)1)
        xlab(0(1)5, labs(3)  nogrid angle(0) format(%9.1f))
        xmtick(0(0.5)5)

        legend(size(3) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1) order(1 2)
        region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
        lab(1 "Cancer deaths")
        lab(2 "Non-cancer deaths")
        )
        name(figure5)
        ;
#delimit cr
