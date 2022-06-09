** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          SimonAnderson_Jun2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      08-JUN-2022
    // 	date last modified      09-JUN-2022
    //  algorithm task          Analysing renal impairment in risk factors for stroke and heart
    //  status                  Completed
    //  objective               To have tables with renal related terms and renal impairment for SimonAnderson
    //  methods                 Using analysis datasets from 2020 CVD annual report process

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
    log using "`logpath'\SimonAnderson_Jun2022.smcl", replace
** HEADER -----------------------------------------------------

** HEART
** Load the dataset  
use "`datapath'\version13\1-input\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022)"

count
**4794 seen 27-Jan-2022

** JC 17feb2022: Sex updated for 2018 pid that has sex=99 using MedData
replace sex=1 if anon_pid==596 & record_id=="20181197" //1 change

** Limit dataset to the variables needed for this request

***********************************************************************************************************************************************
** Data request for Simon Anderson 08jun2022
list ovrf1 ovrf2 ovrf3 ovrf4 year if (regexm(ovrf1,"RENAL")|regexm(ovrf2,"RENAL")|regexm(ovrf3,"RENAL")|regexm(ovrf4,"RENAL") ///	
											|regexm(ovrf1, "KIDNEY")|regexm(ovrf2, "KIDNEY")|regexm(ovrf3, "KIDNEY")|regexm(ovrf4, "KIDNEY"))

tab year if (regexm(ovrf1,"RENAL")|regexm(ovrf2,"RENAL")|regexm(ovrf3,"RENAL")|regexm(ovrf4,"RENAL") ///	
											|regexm(ovrf1, "KIDNEY")|regexm(ovrf2, "KIDNEY")|regexm(ovrf3, "KIDNEY")|regexm(ovrf4, "KIDNEY"))

											
tab year if regexm(ovrf1,"RENAL IMPAIRMENT")|regexm(ovrf2,"RENAL IMPAIRMENT")|regexm(ovrf3,"RENAL IMPAIRMENT")|regexm(ovrf4,"RENAL IMPAIRMENT")
*************************************************************************************************************************************************

clear

** STROKE
** Load the dataset  
use "`datapath'\version13\1-input\stroke_2009-2020_v9_names_Stata_v16_clean" ,clear

count
** 7649 as of 24-Feb-2022

** JC 09jun2022: copied the preserve/restore code from p116/version02/1.2_stroke_cvd_analysis.do as the table totals were different from yesterday's run
preserve
drop if abstracted!=1

sort ovrf1 ovrf2 ovrf3 ovrf4
replace ovrf1 = upper(rtrim(ltrim(itrim(ovrf1))))
replace ovrf2 = upper(rtrim(ltrim(itrim(ovrf2))))
replace ovrf3 = upper(rtrim(ltrim(itrim(ovrf3))))
replace ovrf4 = upper(rtrim(ltrim(itrim(ovrf4))))
list ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  abstracted!=2 & (ovrf1!="" | ovrf2!="" | ovrf3!="" | ovrf4 !="")



replace obese=1 if year==2020 & ((regexm(ovrf1, "OBESE")) | (regexm(ovrf1, "OBESITY")) | (regexm(ovrf1, "OBGSE")) | (regexm(ovrf1, "NBESE")))
replace obese=1 if year==2020 & ((regexm(ovrf2, "OBESE")) | (regexm(ovrf2, "OBESITY")) | (regexm(ovrf2, "OBGSE")) | (regexm(ovrf2, "NBESE")))
replace obese=1 if year==2020 & ((regexm(ovrf3, "OBESE")) | (regexm(ovrf3, "OBESITY")) | (regexm(ovrf3, "OBGSE")) | (regexm(ovrf3, "NBESE")))
replace obese=1 if year==2020 & ((regexm(ovrf4, "OBESE")) | (regexm(ovrf4, "OBESITY")) | (regexm(ovrf4, "OBGSE")) | (regexm(ovrf4, "NBESE")))
label values obese risk_lab
label var obese "Whether patient is obese"
count if obese==1
codebook obese
tab obese
**

** Also may need to recode/update "prior MI" as there may be some in the "other" section as well
list pami ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  ((regexm(ovrf1, "ACUTE MI")) | ///
	 (regexm(ovrf2, "ACUTE MI")) | (regexm(ovrf3, "ACUTE MI")) | (regexm(ovrf4, "ACUTE MI")))
** No need for re-coding

** Combining caardiac RFs: CVD + IHD + PVD
list ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  ((regexm(ovrf1, "IHD")) | (regexm(ovrf1, "CVD")) | (regexm(ovrf1, "PVD")) | (regexm(ovrf1, "CARDIOVASC"))  | (regexm(ovrf1, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf2, "IHD")) | (regexm(ovrf2, "CVD")) | (regexm(ovrf2, "PVD")) | (regexm(ovrf2, "CARDIOVASC"))  | (regexm(ovrf2, "PERIPHERAL VASC")) | /// 
	 (regexm(ovrf3, "IHD")) | (regexm(ovrf3, "CVD")) | (regexm(ovrf3, "PVD")) | (regexm(ovrf3, "CARDIOVASC"))  | (regexm(ovrf3, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf4, "IHD")) | (regexm(ovrf4, "CVD")) | (regexm(ovrf4, "PVD")) | (regexm(ovrf4, "CARDIOVASC"))  | (regexm(ovrf4, "PERIPHERAL VASC")))
**

gen car_all=1 if year==2020 &  ((regexm(ovrf1, "IHD")) | (regexm(ovrf1, "CVD")) | (regexm(ovrf1, "PVD")) | (regexm(ovrf1, "CARDIOVASC")) | (regexm(ovrf1, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf2, "IHD")) | (regexm(ovrf2, "CVD")) | (regexm(ovrf2, "PVD"))  | (regexm(ovrf2, "CARDIOVASC")) | (regexm(ovrf2, "PERIPHERAL VASC")) | /// 
	 (regexm(ovrf3, "IHD")) | (regexm(ovrf3, "CVD")) | (regexm(ovrf3, "PVD"))  | (regexm(ovrf3, "CARDIOVASC")) | (regexm(ovrf3, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf4, "IHD")) | (regexm(ovrf4, "CVD")) | (regexm(ovrf4, "PVD"))  | (regexm(ovrf4, "CARDIOVASC")) | (regexm(ovrf4, "PERIPHERAL VASC")))
label values car_all risk_lab
label var car_all "Whether patient had prior or current IHD, CVD or PVD"
**  do a tab to be sure it worked...
tab car_all ,m //12

** For alcohol use
list ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  ( (regexm(ovrf1, "ALCOHOL")) | (regexm(ovrf1, "DRINKER")) | (regexm(ovrf1, "ETOH")) | ///
	 (regexm(ovrf2, "ALCOHOL")) | (regexm(ovrf2, "DRINKER")) | (regexm(ovrf2, "ETOH")) | /// 
	 (regexm(ovrf3, "ALCOHOL")) | (regexm(ovrf3, "DRINKER")) | (regexm(ovrf3, "ETOH")) | ///
	 (regexm(ovrf4, "ALCOHOL")) | (regexm(ovrf4, "DRINKER")) | (regexm(ovrf4, "ETOH")))

replace alco=1 if year==2020 &  ( (regexm(ovrf1, "ALCOHOL")) | (regexm(ovrf1, "DRINKER")) | (regexm(ovrf1, "ETOH")) | ///
	 (regexm(ovrf2, "ALCOHOL")) | (regexm(ovrf2, "DRINKER")) | (regexm(ovrf2, "ETOH")) | /// 
	 (regexm(ovrf3, "ALCOHOL")) | (regexm(ovrf3, "DRINKER")) | (regexm(ovrf3, "ETOH")) | ///
	 (regexm(ovrf4, "ALCOHOL")) | (regexm(ovrf4, "DRINKER")) | (regexm(ovrf4, "ETOH")))
label values alco risk_lab
label var alco "Whether patient used alcohol"

tab pami if abstracted==1 & year==2020 ,m 
tab car_all if abstracted==1 & year==2020 ,m
tab alco if abstracted==1 & year==2020 ,m

** for denominator
count if (ovrf1!="" | ovrf2!="" | ovrf3!="" | ovrf4!="") & year==2020  & abstracted==1


*************************************************
** NO PRIOR STROKE
** To avoid double-counting of prior stroke:
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CVA") | regexm(ovrf2, "CVA") | regexm(ovrf3, "CVA") | /// 
											 regexm(ovrf4, "CVA"))
**  No changes required
**replace np=0 if ovrf1=="CVA" & np==2

list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "STROKE") | regexm(ovrf2, "STROKE") | regexm(ovrf3, "STROKE") | /// 
											 regexm(ovrf4, "STROKE"))

** No changes required
** replace np=0 if vrf_11=="STROKE" & np==2
											 							 
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CEREBRO") | regexm(ovrf2, "CEREBRO") | regexm(ovrf3, "CEREBRO") | /// 
											 regexm(ovrf4, "CEREBRO"))
** No changes required											 
											 
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CEREBRAL") | regexm(ovrf2, "CEREBRAL") | regexm(ovrf3, "CEREBRAL") | /// 
											 regexm(ovrf4, "CEREBRAL"))
** No changes required												 
											 
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CRANIAL") | regexm(ovrf2, "CRANIAL") | regexm(ovrf3, "CRANIAL") | /// 
											 regexm(ovrf4, "CRANIAL"))
** No changes required											 


***********************************************************************************************************************************************
** Data request for Simon Anderson 08jun2022										 
list ovrf1 ovrf2 ovrf3 ovrf4 np year if (regexm(ovrf1,"RENAL")|regexm(ovrf2,"RENAL")|regexm(ovrf3,"RENAL")|regexm(ovrf4,"RENAL") ///	
											|regexm(ovrf1, "KIDNEY")|regexm(ovrf2, "KIDNEY")|regexm(ovrf3, "KIDNEY")|regexm(ovrf4, "KIDNEY"))

tab year if (regexm(ovrf1,"RENAL")|regexm(ovrf2,"RENAL")|regexm(ovrf3,"RENAL")|regexm(ovrf4,"RENAL") ///	
											|regexm(ovrf1, "KIDNEY")|regexm(ovrf2, "KIDNEY")|regexm(ovrf3, "KIDNEY")|regexm(ovrf4, "KIDNEY"))

tab year if regexm(ovrf1,"RENAL IMPAIRMENT")|regexm(ovrf2,"RENAL IMPAIRMENT")|regexm(ovrf3,"RENAL IMPAIRMENT")|regexm(ovrf4,"RENAL IMPAIRMENT")
*************************************************************************************************************************************************
restore

/*
From: CAMPBELL, Jacqueline <jacqueline.campbell@cavehill.uwi.edu>
Date: Thursday, June 9, 2022 at 2:45 PM
To: FORDE, Shelly-Ann <shelly-ann.forde@cavehill.uwi.edu>, ANDERSON, Simon <simon.anderson@cavehill.uwi.edu>, SOBERS, Natasha <natasha.sobers@cavehill.uwi.edu>
Subject: DR: RE: Data

Hi Simon,
 
Apologies for the delay.
We don't have rates on renal impairment as Shelly mentioned.
 
The DAs at times record the below terms in the other risk factors fields: 
•         renal impairment
•         renal failure
•         kidney disease
•         renal calculi
•         polycystic kidney disease
•         kidney problems
•         renal insufficiency
 
This data is not likely to be representative of hospital admissions as documentation of this may vary but I can provide absolute numbers on the year and times the above terms were recorded in the other risk factor fields.  
 
Would you like to have these in proportions using (1) number of cases abstracted per year or (2) number of cases with risk factor data or (3) number of cases that had risk factor data in this other risk factor field?:
 
Stroke registry (2009-2020 dataset)
 
       year |      Freq.     
------------+------------
       2010 |          3       
       2011 |          3       
       2012 |          3       
       2013 |          6       
       2014 |          3       
       2015 |          2       
       2016 |          3       
       2017 |          3       
       2018 |          1       
       2019 |          3       
       2020 |          6       
------------+--------------
      Total |         36      
 
 
Heart (AMI) registry (2009-2020 dataset)
 
       year |      Freq.     
------------+------------
       2016 |          3       
       2017 |          2       
       2018 |          2      
       2019 |          3       
------------+-------------
      Total |         10      
 
 
If I restrict the code to show numbers for the term `renal impairment' only then these are the numbers:
 
Stroke registry (2009-2020 dataset)
 
       year |      Freq.     
------------+------------
       2011 |          2     
       2012 |          2     
       2013 |          1     
       2015 |          1     
       2017 |          1     
------------+------------
      Total |          7      
 
Heart (AMI) registry (2009-2020 dataset)
 
       year |      Freq.     
------------+------------
       2017 |          1     
       2019 |          1     
------------+------------
      Total |          2     
 
Kind regards,
Jacqui
 
From: FORDE, Shelly-Ann <shelly-ann.forde@cavehill.uwi.edu> 
Sent: Wednesday, 8 June 2022 13:26
To: ANDERSON, Simon <simon.anderson@cavehill.uwi.edu>; SOBERS, Natasha <natasha.sobers@cavehill.uwi.edu>
Cc: CAMPBELL, Jacqueline <jacqueline.campbell@cavehill.uwi.edu>
Subject: Re: Data
 
Good afternoon Simon,
 
Currently the BNR does not routinely collect these statistics. The DAs may indicate CKD under other risk factors if recorded. 
 
Jacqui, is this documented with enough frequency or in a large enough percentage of cases to provide any data for Simon's request?
 
Kind regards,
Shelly
 
 
________________________________________
From: ANDERSON, Simon <simon.anderson@cavehill.uwi.edu>
Sent: 08 June 2022 3:39 AM
To: SOBERS, Natasha <natasha.sobers@cavehill.uwi.edu>; FORDE, Shelly-Ann <shelly-ann.forde@cavehill.uwi.edu>
Subject: Data 
 
Morning Natasha and Shelly-Ann
 
Good morning.
 
This is definitely last minute but I am part of a roundtable at QEH on renal impairment (including failure), I was invited a few days ago.
 
Do we have any data on rates of renal impairment in those from the stroke and cardiovascular registry?
 
Just simple statistics?
 
Simon
 
 
 
Professor Simon Anderson
