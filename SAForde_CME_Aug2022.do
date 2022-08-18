
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
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p131"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p131

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'/SAForde_CME_Aug2022.smcl", replace
** HEADER -----------------------------------------------------
 
** LOAD 2008, 2013-2018 cleaned cancer incidence dataset from p117/version15/20d_final clean.do
use "`datapath'\version15\1-input\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

count //6682

preserve
				****************************
				*	   MS WORD REPORT      *
				*  BNR 2022 CME STATISTICS *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2008, 2013-2018 BNR 2022 CME Presentation: Stata Results"), bold
putdocx textblock begin
Date Prepared: 18-AUG-2022. 
putdocx textblock end
putdocx textblock begin
Prepared by: JC using Stata v17.0
putdocx textblock end
putdocx textblock begin
CanReg5 v5.43 (incidence) data release date: 21-May-2021.
putdocx textblock end
putdocx textblock begin
REDCap v12.3.3 (death) data release date: 06-May-2022.
putdocx textblock end
putdocx textblock begin
Generated using Dofile: SAForde_CME_Aug2022.do
putdocx textblock end
putdocx textblock begin
VS Code path: p131/version15/SAForde_CME_Aug2022 branch
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("CME Statistics for BNR-Cancer, 2018 (Population=286,640), 2016 (Population=285,798), 2017 (Population=286,229), 2015 (Population=285,327), 2014 (Population=284,825), 2013 (Population=284,294), 2008 (Population=279,946))"), bold font(Helvetica,10,"blue")
putdocx pagebreak
putdocx paragraph
putdocx text ("Standards"), bold
putdocx paragraph, halign(center)
putdocx image "`datapath'\version15\1-input\standards.png", width(6.64) height(6.8)
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version15\1-input\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end
putdocx textblock begin
(2) Population: WPP population for 2008, 2013, 2014, 2015, 2016, 2017 and 2018 (see p_117\2016-2018AnnualReport branch\0_population.do)
putdocx textblock end
putdocx textblock begin
(3) No.(patients): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs, First tumour (variable used: patient; dataset used: "`datapath'\version15\1-input\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end
putdocx textblock begin
(4) Site Order: These tables show where the order of 2015 top 10 sites in 2015,2014,2013, respectively; site order datasets used: "`datapath'\version04\2-working\siteorder_2015; siteorder_2014; siteorder_2013")
putdocx textblock end
putdocx textblock begin
(5) Population files (WPP): generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019; re-checked on 10-May-2022 (totals remain the same).
putdocx textblock end
putdocx textblock begin
(6) No.(DCOs): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs. (variable used: basis. dataset used: "`datapath'\version15\1-input\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end
putdocx textblock begin
(7) % of tumours: Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (variable used: basis; dataset used: "`datapath'\version15\1-input\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version15\3-output\Cancer_2008_2013-2018_CMEStats_`listdate'.docx", replace
putdocx clear
restore


** SF requested by email 12aug2022 % pts who died at home vs hospital in 2018; since death matching ds doesn't have this categorized but the mortality ds does I'll merge POD from that ds using deathid - merge performed in p117/version15/20d_final clean.do
tab pod dxyr ,m
tab slc dxyr ,m
tab pod dxyr if slc==2 & patient==1
/*
  Place of Death from |                                Diagnosis Year
    National Register |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
                  QEH |        21         59         59        163        341        260        244 |     1,147 
              At Home |        21         39         38        106        187        183        121 |       695 
   Geriatric Hospital |         2          1          5          0          7          9          9 |        33 
     Con/Nursing Home |         3          0          2         12         16         19         10 |        62 
    District Hospital |         0          0          1          0          2          1          1 |         5 
 Psychiatric Hospital |         0          1          0          2          0          2          0 |         5 
     Bayview Hospital |         0          0          2          4          8         13          6 |        33 
Sandy Crest/FMH/Sparm |         0          0          0          1          0          1          1 |         3 
          Other/Hotel |         1          1          2          8         14         19          9 |        54 
                   ND |         0          0          0          0          0          0          1 |         1 
----------------------+-----------------------------------------------------------------------------+----------
                Total |        48        101        109        296        575        507        402 |     2,038 
*/

count if pod!=. & slc!=2 //0

count if dxyr==2018 & pod!=. //402
count if dxyr==2018 & slc==2 //490

preserve
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Place Of Death, 2008, 2013-2018"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Place Of Death (Dofile: SAForde_CME_Aug2022.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("% Patients who died at home vs hospital"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below tables use the variables [pod] and [slc]+[patient] to display results for only patients (not tumours, i.e. MPs excluded) that have died. It does not include cases where [pod] is missing.")

putdocx paragraph, halign(center)
putdocx text ("2008"), bold font(Helvetica,10,"blue")
tab2docx pod if dxyr==2008 & slc==2 & patient==1
putdocx paragraph, halign(center)
putdocx text ("2013"), bold font(Helvetica,10,"blue")
tab2docx pod if dxyr==2013 & slc==2 & patient==1
putdocx paragraph, halign(center)
putdocx text ("2014"), bold font(Helvetica,10,"blue")
tab2docx pod if dxyr==2014 & slc==2 & patient==1
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("2015"), bold font(Helvetica,10,"blue")
tab2docx pod if dxyr==2015 & slc==2 & patient==1
putdocx paragraph, halign(center)
putdocx text ("2016"), bold font(Helvetica,10,"blue")
tab2docx pod if dxyr==2016 & slc==2 & patient==1
putdocx paragraph, halign(center)
putdocx text ("2017"), bold font(Helvetica,10,"blue")
tab2docx pod if dxyr==2017 & slc==2 & patient==1
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("2018"), bold font(Helvetica,10,"blue")
tab2docx pod if dxyr==2018 & slc==2 & patient==1

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version15\3-output\Cancer_2008_2013-2018_CMEStats_`listdate'.docx", append
putdocx clear
restore


** SF requested by email 16aug2022: length of time between Dx and Death for 2015 and 2018
//	Mean and median duration in months from date of incident diagnosis to date of abstraction
** First calculate the difference in months between these 2 dates 
// (need to add in qualifier to ignore missing dod dates)
gen doddotdiff = (dod - dot) / (365/12) if dod!=. & dot!=.
** Now calculate the overall mean & median
preserve
drop if doddotdiff==. //2470 deleted
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
save "`datapath'\version15\2-working\doddotdiff" ,replace
restore

** Now calculate mean & median per diagnosis year
// 2008
preserve
drop if dxyr!=2008 //5867 deleted
drop if doddotdiff==. //197 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%     .0328767              0       Obs                 618
25%     1.446575              0       Sum of wgt.         618

50%      14.9589                      Mean           34.18561
                        Largest       Std. dev.      42.56738
75%     56.35069       155.9014
90%     104.0877       156.5918       Variance       1811.982
95%     131.5397        158.926       Skewness       1.310217
99%     152.2521       165.9945       Kurtosis       3.620028
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
append using "`datapath'\version15\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version15\2-working\doddotdiff" ,replace
restore

// 2013
preserve
drop if dxyr!=2013 //5798 deleted
drop if doddotdiff==. //276 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 608
25%      1.29863              0       Sum of wgt.         608

50%     9.386302                      Mean           20.85838
                        Largest       Std. dev.      26.17669
75%     29.65479       97.05206
90%      67.3315       99.09041       Variance       685.2192
95%     81.66576       99.71507       Skewness       1.413478
99%     95.60548       105.1397       Kurtosis       3.921642
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
append using "`datapath'\version15\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version15\2-working\doddotdiff" ,replace
restore

// 2014
preserve
drop if dxyr!=2014 //5798 deleted
drop if doddotdiff==. //303 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 581
25%     .7561644              0       Sum of wgt.         581

50%     7.791781                      Mean           17.37599
                        Largest       Std. dev.      22.09671
75%     27.05754       87.12329
90%     49.84109       87.71507       Variance       488.2645
95%         67.2       87.87946       Skewness       1.485112
99%     86.59726       88.99726       Kurtosis        4.39957
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
gen year=4

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version15\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version15\2-working\doddotdiff" ,replace
restore

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
gen year=5

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version15\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version15\2-working\doddotdiff" ,replace
restore

// 2016
preserve
drop if dxyr!=2016 //5612 deleted
drop if doddotdiff==. //418 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 652
25%     .3780822              0       Sum of wgt.         652

50%     3.156164                      Mean           11.60644
                        Largest       Std. dev.      16.29346
75%     17.91781       63.58356
90%     38.63014        63.8137       Variance       265.4768
95%     51.18904       66.80548       Skewness       1.611021
99%     62.56438        67.7589       Kurtosis         4.6604
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
gen year=6

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version15\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version15\2-working\doddotdiff" ,replace
restore

// 2017
preserve
drop if dxyr!=2017 //5705 deleted
drop if doddotdiff==. //400 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 577
25%     .3616438              0       Sum of wgt.         577

50%     3.353425                      Mean           10.11606
                        Largest       Std. dev.      13.64302
75%     14.69589       53.85205
90%     33.27123       54.96986       Variance       186.1321
95%     42.54247       58.19178       Skewness       1.567533
99%     51.84658       62.13699       Kurtosis       4.624403
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
gen year=7

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version15\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version15\2-working\doddotdiff" ,replace
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
gen year=8

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version15\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff

label define year_lab 1 "2008,2013-2018" 2 "2008" 3 "2013" 4 "2014" 5 "2015" ///
					  6 "2016" 7 "2017" 8 "2018" , modify
label values year year_lab

save "`datapath'\version15\2-working\doddotdiff" ,replace
restore

preserve
use "`datapath'\version15\2-working\doddotdiff", clear
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Date Difference"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Date Difference (Dofile: SAForde_CME_Aug2022.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Length of Time Between Diagnosis and Death in MONTHS (Median, Range and Mean), 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below table uses the variables [dot] and [dod] to display results for patients by tumour (i.e. MPs not excluded) that have died. It does not include cases where [dod] is missing, i.e. Alive patients.")

putdocx paragraph, halign(center)

putdocx table tbl1 = data(year median_doddotdiff range_lower range_upper mean_doddotdiff), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version15\3-output\Cancer_2008_2013-2018_CMEStats_`listdate'.docx", append
putdocx clear
restore


** SF requested by email 12aug2022: "Would you be able to provide me DCO numbers/percentages for the top 10 cancers in 2018? Or if you already have all the information to provide the graph that is Figure 8 of the 2015 cancer annual report, I would appreciate it (the numbers and I can create the graph if needed."

** Load the dataset from p117/v09/2-working
use "`datapath'\version15\1-input\2013-2018_cancer_numbers", clear

****************************************************************************** 2018 ****************************************************************************************

drop if dxyr!=2018 //4907 deleted
count //960

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //0 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     female |        484       50.42       50.42
       male |        476       49.58      100.00
------------+-----------------------------------
      Total |        960      100.00
*/

** Determine sequential order of 2018 sites from 2018 top 10
tab siteiarc ,m

preserve
drop if siteiarc>60 //| siteiarc==25 //41 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5                       Multiple myeloma (C90) |
     |-------------------------------------------------------|
  6. |        6                               Pancreas (C25) |
  7. |        7                              Rectum (C19-20) |
  8. |        8   Lung (incl. trachea and bronchus) (C33-34) |
  9. |        9            Non-Hodgkin lymphoma (C82-86,C96) |
 10. |       10                                Stomach (C16) |
     |-------------------------------------------------------|
 11. |       11                                 Kidney (C64) |
 12. |       12                                Bladder (C67) |
 13. |       13                           Cervix uteri (C53) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                 Larynx (C32) |
     |-------------------------------------------------------|
 16. |       16                                  Ovary (C56) |
 17. |       17                   Myeloid leukaemia (C92-94) |
 18. |       18                                  Liver (C22) |
 19. |       19                             Oesophagus (C15) |
 20. |       20           Myeloproliferative disorders (MPD) |
     |-------------------------------------------------------|
 21. |       21                    Gallbladder etc. (C23-24) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23                        Small intestine (C17) |
 24. |       24         Connective and soft tissue (C47+C49) |
 25. |       25                       Melanoma of skin (C43) |
     |-------------------------------------------------------|
 26. |       26               Brain, nervous system (C70-72) |
 27. |       27                       Other oropharynx (C10) |
 28. |       28                                  Vulva (C51) |
 29. |       29                           Renal pelvis (C65) |
 30. |       30                               Mouth (C03-06) |
     |-------------------------------------------------------|
 31. |       31                                  Penis (C60) |
 32. |       32                              Tongue (C01-02) |
 33. |       33                                 Vagina (C52) |
 34. |       34                            Nasopharynx (C11) |
 35. |       35                                Bone (C40-41) |
     |-------------------------------------------------------|
 36. |       36                             Other skin (C44) |
 37. |       37                                   Anus (C21) |
 38. |       38                           Mesothelioma (C45) |
 39. |       39                  Nose, sinuses etc. (C30-31) |
 40. |       40                                 Tonsil (C09) |
     |-------------------------------------------------------|
 41. |       41                  Leukaemia unspecified (C95) |
 42. |       42                      Salivary gland (C07-08) |
 43. |       43                     Uterus unspecified (C55) |
 44. |       44            Other female genital organs (C57) |
 45. |       45                                    Eye (C69) |
     |-------------------------------------------------------|
 46. |       46                          Adrenal gland (C74) |
 47. |       47                       Hodgkin lymphoma (C81) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //27 deleted
save "`datapath'\version15\2-working\siteorder_2018" ,replace
restore

** Output for above Site Order tables
preserve
use "`datapath'\version15\2-working\siteorder_2018", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2015    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
putdocx table tbl1(11,.), bold shading("yellow")
//putdocx table tbl1(12,.), bold shading("yellow")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version15\3-output\Cancer_2008_2013-2018_CMEStats_`listdate'.docx" ,append
putdocx clear
restore


*****************************
**   Data Quality Indices  **
*****************************
** Added on 04-June-2019 by JC as requested by NS for 2014 cancer annual report

*****************************
** Identifying & Reporting **
** 	 Data Quality Index	   **
** MV,DCO,O+U,UnkAge,CLIN  **
*****************************

tab basis ,m
tab siteicd10 basis ,m 
tab sex ,m //0 missing
tab age ,m //0 missing=999
tab sex age if age==.|age==999 //0 - used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sex if sitecr5db==20 //site=O&U; used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)


tab basis ,m
gen boddqi=1 if basis>4 & basis <9 //800 changes; 
replace boddqi=2 if basis==0 //55 changes
replace boddqi=3 if basis>0 & basis<5 //103 changes
replace boddqi=4 if basis==9 //2 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

gen siteagedqi=1 if siteiarc==61 //39 changes
replace siteagedqi=2 if age==.|age==999 //0 changes
replace siteagedqi=3 if dob==. & siteagedqi!=2 //6 changes
replace siteagedqi=4 if siteiarc==61 & siteagedqi!=1 //2 changes
replace siteagedqi=5 if sex==.|sex==99 //0 changes
label define siteagedqi_lab 1 "O&U SITE" 2 "UNK.AGE" 3 "UNK.DOB" 4 "O&U+UNK.AGE/DOB" 5 "UNK.SEX", modify
label var siteagedqi "site/age DQI"
label values siteagedqi siteagedqi_lab

tab boddqi ,m
generate rectot=_N //960
tab boddqi rectot,m

tab siteagedqi ,m
tab siteagedqi rectot,m


** Create variables for table by basis (DCO% + MV%) in Data Quality section of annual report
** This was done manually in excel for 2014 annual report so the above code has now been updated to be automated in Stata
tab sitecr5db boddqi if boddqi!=. & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        13          0          0          0 |        13 
        Stomach (C16) |        14          2          5          0 |        21 
Colon, rectum, anus ( |       140          2          7          0 |       149 
       Pancreas (C25) |         8          7         16          0 |        31 
Lung, trachea, bronch |        17          3          8          0 |        28 
         Breast (C50) |       171          5          0          1 |       177 
         Cervix (C53) |        13          0          0          0 |        13 
Corpus & Uterus NOS ( |        50          1          3          0 |        54 
       Prostate (C61) |       198          7         15          1 |       221 
Lymphoma (C81-85,88,9 |        38          3         14          0 |        55 
   Leukaemia (C91-95) |        15          2          0          0 |        17 
----------------------+--------------------------------------------+----------
                Total |       677         32         68          2 |       779

                      |                  basis DQI
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        23          0          0          0 |        23 
        Stomach (C16) |        23          7          6          0 |        36 
Colon, rectum, anus ( |       143         12          9          2 |       166 
       Pancreas (C25) |         7          7         11          1 |        26 
Lung, trachea, bronch |        13          6         11          0 |        30 
         Breast (C50) |       179         11          5          3 |       198 
         Cervix (C53) |        14          2          0          0 |        16 
Corpus & Uterus NOS ( |        43          2          6          0 |        51 
       Prostate (C61) |       169         25         16          6 |       216 
Lymphoma (C81-85,88,9 |        44          6          5          5 |        60 
   Leukaemia (C91-95) |        11          2          1          2 |        16 
----------------------+--------------------------------------------+----------
                Total |       669         80         70         19 |       838
*/
** All BOD options
preserve
drop if boddqi==. | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
40	1	677	0
40	2	 32	0
40	3	 68 0
40	4	  2 0
end

label define sitecr5db_lab ///
1 "Mouth & pharynx" ///
2 "Oesophagus" ///
3 "Stomach" ///
4 "Colon, rectum, anus" ///
5 "Liver" ///
6 "Pancreas" ///
7 "Larynx" ///
8 "Lung, trachea, bronchus" ///
9 "Melanoma of skin" ///
10 "Breast" ///
11 "Cervix" ///
12 "Corpus & Uterus NOS" ///
13 "Ovary & adnexa" ///
14 "Prostate" ///
15 "Testis" ///
16 "Kidney & urinary NOS" ///
17 "Bladder" ///
18 "Brain, nervous system" ///
19 "Thyroid" ///
20 "O&U" ///
21 "Lymphoma" ///
22 "Leukaemia" ///
23 "Other digestive" ///
24 "Nose, sinuses" ///
25 "Bone, cartilage, etc" ///
26 "Other skin" ///
27 "Other female organs" ///
28 "Other male organs" ///
29 "Other endocrine" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc" ///
40 "All sites (in this table)" , modify
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab
drop percentage
gen percentage=(count/13)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/13)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/13)*100 if sitecr5db==1 & boddqi==3
replace percentage=(count/13)*100 if sitecr5db==1 & boddqi==4
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==3
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==4
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==3
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==4
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==3
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==4
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==3
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==4
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==3
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==4
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==3
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==4
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==3
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==4
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==3
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==4
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==3
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==4
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==3
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==4
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==1
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==2
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==3
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==4
format percentage %04.1f

gen icd10dqi="C00-14" if sitecr5db==1
replace icd10dqi="C16" if sitecr5db==3
replace icd10dqi="C18-21" if sitecr5db==4
replace icd10dqi="C25" if sitecr5db==6
replace icd10dqi="C33-34" if sitecr5db==8
replace icd10dqi="C50" if sitecr5db==10
replace icd10dqi="C53" if sitecr5db==11
replace icd10dqi="C54-55" if sitecr5db==12
replace icd10dqi="C61" if sitecr5db==14
replace icd10dqi="C81-85,88,90,96" if sitecr5db==21
replace icd10dqi="C91-95" if sitecr5db==22
replace icd10dqi="All" if sitecr5db==40

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Title)
putdocx text ("CANCER 2016-2018 Annual Report: DQI"), bold
putdocx textblock begin
Date Prepared: 18-AUG-2022. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofiles: 20a_clean current years cancer.do and 25b_analysis sites.do
putdocx textblock end
putdocx paragraph, style(Heading1)
putdocx text ("Basis - MV%, DCO%, CLIN%, UNK%: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=960): 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version15\3-output\Cancer_2008_2013-2018_CMEStats_`listdate'.docx" ,append
putdocx clear
restore


preserve
** % tumours - site,age
tab siteagedqi
contract siteagedqi, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=960): 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version15\3-output\Cancer_2008_2013-2018_CMEStats_`listdate'.docx" ,append
putdocx clear
restore


** SF requested via Zoom meeting on 18aug2022: table with dxyr and basis
** For ease, I copied and pasted the below results into the Word doc:

** LOAD 2008, 2013-2018 cleaned cancer incidence dataset from p117/version15/20d_final clean.do
use "`datapath'\version15\1-input\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

count //6682

tab basis dxyr
/*
                      |                                Diagnosis Year
   Basis Of Diagnosis |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
                  DCO |        52         59         41        101         82         79         55 |       469 
        Clinical only |        16         21         38         67        101         83         43 |       369 
Clinical Invest./Ult  |        45         60         36         62         55         58         43 |       359 
Lab test (biochem/imm |         7          5         10         14         31         13         17 |        97 
        Cytology/Haem |        31         31         45         28         23         19         27 |       204 
Hx of mets/Autopsy wi |        24         16         13         19         13         24         21 |       130 
Hx of primary/Autopsy |       635        646        638        754        729        683        752 |     4,837 
              Unknown |         5         46         63         47         36         18          2 |       217 
----------------------+-----------------------------------------------------------------------------+----------
                Total |       815        884        884      1,092      1,070        977        960 |     6,682
*/
table basis dxyr
/*
-------------------------------------------------------------------------------------------------------------------------------
                                                                    |                       Diagnosis Year                     
                                                                    |  2008   2013   2014    2015    2016   2017   2018   Total
--------------------------------------------------------------------+----------------------------------------------------------
Basis Of Diagnosis                                                  |                                                          
  DCO                                                               |    52     59     41     101      82     79     55     469
  Clinical only                                                     |    16     21     38      67     101     83     43     369
  Clinical Invest./Ult Sound/Exploratory Surgery/Autopsy without hx |    45     60     36      62      55     58     43     359
  Lab test (biochem/immuno.)                                        |     7      5     10      14      31     13     17      97
  Cytology/Haem                                                     |    31     31     45      28      23     19     27     204
  Hx of mets/Autopsy with Hx of mets                                |    24     16     13      19      13     24     21     130
  Hx of primary/Autopsy with Hx of primary                          |   635    646    638     754     729    683    752   4,837
  Unknown                                                           |     5     46     63      47      36     18      2     217
  Total                                                             |   815    884    884   1,092   1,070    977    960   6,682
-------------------------------------------------------------------------------------------------------------------------------
*/

contract basis dxyr
rename _freq number
