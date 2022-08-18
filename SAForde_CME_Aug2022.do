
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          SAForde_CME_Aug2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      18-AUG-2022
    // 	date last modified      18-AUG-2022
    //  algorithm task          Providing death-related statistics to Shelly-Ann Forde for the BNR CME seminar
    //  status                  Completed
    //  objective               To have one document with cleaned and grouped 2008,2013-2018 data for inclusion in CME presentation.
    //  methods                 Taken from 25_analysis cancer.do + 30_report cancer.do in 2016-2018AnnualReport branch.

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
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'/SAForde_CME_Aug2022.smcl", replace
** HEADER -----------------------------------------------------


***************************************************************************
* SECTION 1: NUMBERS 
*        (1.1) total number & number of multiple events
*        (1.2) DCOs
*    	 (1.3) tumours by age-group: 
*				NOTE: missing/unknown age (code 999) are 
*				to be included in the age group that has a median total if 
*			  	total number of unk age is small, i.e. 5 cases with unk age; 
*			  	if larger then they would be distributed amongst more than
*			  	one age groups with median totals (NS update on 14-Oct-2020)
****************************************************************************
 
** LOAD cancer incidence dataset INCLUDING DCOs
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear


** SF requested by email 16aug2022: length of time between Dx and Death for 2015 and 2018
//	Mean and median duration in months from date of incident diagnosis to date of abstraction
** First calculate the difference in months between these 2 dates 
// (need to add in qualifier to ignore missing dod dates)
gen doddotdiff = (dod - dot) / (365/12) if dod!=. & dot!=.
** Now calculate the overall mean & median
preserve
drop if doddotdiff==. //209 deleted
summ doddotdiff //displays mean
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  doddotdiff |      4,212    17.06014    25.28071          0   165.9945
*/
summ doddotdiff, detail //displays mean + median (median is the percentile next to 50%)
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs               4,212
25%     .6246575              0       Sum of wgt.       4,212

50%      5.70411                      Mean           17.06014
                        Largest       Std. dev.      25.28071
75%     24.01644       155.9014
90%     49.70959       156.5918       Variance       639.1141
95%     71.17809        158.926       Skewness       2.329444
99%     121.1836       165.9945       Kurtosis        9.41532
*/
gen k=1
drop if k!=1

table k, stat(q2 doddotdiff) stat(min doddotdiff) stat(max doddotdiff) stat(mean doddotdiff)
** Now save the p50, min, max and mean for  SF's data request
sum doddotdiff
sum doddotdiff ,detail
gen median_doddotdiff=r(p50)
gen mean_doddotdiff=r(mean)
gen range_lower=r(min)
gen range_upper=r(max)
gen year=1

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version09\2-working\doddotdiff" ,replace
restore

** Now calculate mean & median per diagnosis year
// 2015
preserve
drop if dxyr!=2015 //5590 deleted
drop if doddotdiff==. //406 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 686
25%     .4273973              0       Sum of wgt.         686

50%          4.8                      Mean           14.38797
                        Largest       Std. dev.      19.12978
75%     22.48767       77.72055
90%     44.77808       80.51507       Variance       365.9486
95%     58.22466       81.13972       Skewness       1.503493
99%     74.10411       81.20548       Kurtosis       4.437584
*/
gen k=1
drop if k!=1

table k, stat(q2 doddotdiff) stat(min doddotdiff) stat(max doddotdiff) stat(mean doddotdiff)
** Now save the p50, min, max and mean for  SF's data request
sum doddotdiff
sum doddotdiff ,detail
gen median_doddotdiff=r(p50)
gen mean_doddotdiff=r(mean)
gen range_lower=r(min)
gen range_upper=r(max)
gen year=2

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version09\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version09\2-working\doddotdiff" ,replace
restore

// 2018
preserve
drop if dxyr!=2018 //5722 deleted
drop if doddotdiff==. //470 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 490
25%     .3287671              0       Sum of wgt.         490

50%     3.090411                      Mean           9.548471
                        Largest       Std. dev.      12.27191
75%     15.35343       43.79178
90%     31.47945       43.85753       Variance       150.5998
95%     36.59178       43.92329       Skewness       1.268874
99%     43.52877       44.97534       Kurtosis       3.358156
*/
gen k=1
drop if k!=1

table k, stat(q2 doddotdiff) stat(min doddotdiff) stat(max doddotdiff) stat(mean doddotdiff)
** Now save the p50, min, max and mean for  SF's data request
sum doddotdiff
sum doddotdiff ,detail
gen median_doddotdiff=r(p50)
gen mean_doddotdiff=r(mean)
gen range_lower=r(min)
gen range_upper=r(max)
gen year=3

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version09\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff

label define year_lab 1 "2008,2013-2018" 2 "2008" 3 "2013" 4 "2014" 5 "2015" ///
					  6 "2016" 7 "2017" 8 "2018" , modify
label values year year_lab

save "`datapath'\version09\2-working\doddotdiff" ,replace
restore