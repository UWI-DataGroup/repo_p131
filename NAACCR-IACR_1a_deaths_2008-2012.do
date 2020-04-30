** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name              1a_deaths_2008-2012.do
    //  project:                        BNR
    //  analysts:                       Jacqueline CAMPBELL
    //  date first created      07-FEB-2019
    //  date last modified      12-FEB-2019
    //  algorithm task              Preparing 2008-2012 death data for matching with 2008 cancer data
    //  status                  Completed

    ** General algorithm set-up
    version 15
    clear all
    macro drop _all
    set more off
    set linesize 80

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
    log using "`logpath'\2008-2012_deaths_prep.smcl", replace
** HEADER -----------------------------------------------------

**************************************
** DATA PREPARATION
**************************************
** LOAD the cleaned and prepped (for REDCap) national registry deaths 2008-2017 dataset
import excel using "`datapath'\version01\1-input\BNRDeathDataALL_DATA_2019-02-07_JC.xlsx" , firstrow case(lower) clear

count
** 11,890 records

** Format and drop necessary variables
rename record_id deathid
format dod %dD_m_CY
label var dod "Date of death"

format nrn %12.0g
//Note: nrn missing leading zeros as this dataset exported as .csv from REDCap db
tostring nrn, replace

*****************
**  Formatting **
**    Names    **
*****************

** Need to check for duplicate death registrations
** First split full name into first, middle and last names
** Also - code to split full name into 2 variables fname and lname - else can't merge!
split pname, parse(", "" ") gen(name)
order deathid pname name1 name2 name3 name4 name5 name6 name7

** First, sort cases that contain only a first name and a last name
count if name3=="" & name4=="" & name5=="" & name6=="" & name7=="" //8,857
replace name6=name2 if name6=="" & name5=="" & name3=="" & name4=="" //8,857
replace name2="" if name6=="" & name5=="" & name3=="" & name4=="" //0

** Second, sort case with name in name7 variable
count if name7!="" //1
list deathid *name* if name7!=""
replace name5="" if deathid==6894 //1 change
replace name6=name4 if deathid==6894 //1 change
replace name7="" if deathid==6894 //1 change
replace name1=name1+" "+name2+" "+name3 if deathid==6894 //1 change
replace name2="" if deathid==6894 //1 change
replace name3="" if deathid==6894 //1 change
replace name4="" if deathid==6894 //1 change
list deathid *name* if deathid==6894

** Third, sort cases with name 'baby' or 'b/o' in name1 variable
count if (regexm(name1,"BABY")|regexm(name1,"B/O")) & deathid!=6894 //72
gen tempvarn=1 if (regexm(name1,"BABY")|regexm(name1,"B/O")) & deathid!=6894
list deathid *name* if tempvarn==1
list deathid *name* if deathid==809|deathid==1444|deathid==4478|deathid==6734|deathid==11044
replace name6=name5 if deathid==809|deathid==1444|deathid==4478|deathid==6734
replace name6=name4+"."+name5 if deathid==11044
replace name1=name1+" "+name2+" "+name3 if deathid==809|deathid==1444|deathid==4478|deathid==6734|deathid==11044
replace name2=name4 if deathid==809|deathid==1444|deathid==4478|deathid==6734
replace name2="" if deathid==11044
replace name3="" if deathid==11044
replace name4="" if deathid==11044
replace name5="" if deathid==11044
replace name3="" if deathid==809|deathid==1444|deathid==4478|deathid==6734
replace name4="" if deathid==809|deathid==1444|deathid==4478|deathid==6734
replace name5="" if deathid==809|deathid==1444|deathid==4478|deathid==6734
replace tempvarn=. if deathid==809|deathid==1444|deathid==4478|deathid==6734|deathid==11044 //5 changes
count if tempvarn==1 //67
list deathid *name* if tempvarn==1
replace name6=name4 if tempvarn==1 //67 changes
replace name4="" if tempvarn==1 //67 changes
replace name1=name1+" "+name2+" "+name3 if tempvarn==1 //67 changes
replace name2="" if tempvarn==1 //67 changes
replace name3="" if tempvarn==1 //67 changes

** Fourth, sort cases so that name1, name2, name6 will all contain values
list deathid pname if name2=="" & name3!="" & name4!="" & name5!="" //0

list deathid pname *name* if name2=="" & name3!="" & name4!="" & name5!="" //0

list deathid pname *name* if name6=="" & name2!="" & name3!="" & name4!="" & name5!="" //5
replace name6=name3+" "+name4+" "+name5 if deathid==1650|deathid==3258
replace name2=name2+" "+name3+" "+name4 if deathid==10637|deathid==10485
replace name6=name5 if deathid==10637|deathid==10485|deathid==3619|deathid==6370|deathid==9628
replace name2=name2+" "+name3+"."+name4 if deathid==3619
replace name2=name2+"."+name3+" "+name4 if deathid==6370
replace name2=name2+" "+name3+name4 if deathid==9628
list deathid pname *name* if deathid==9628
replace name3="" if deathid==9628
replace name4="" if deathid==9628
replace name5="" if deathid==9628
list deathid pname *name* if deathid==1650|deathid==3258
replace name3="" if deathid==1650|deathid==3258
replace name4="" if deathid==1650|deathid==3258
replace name5="" if deathid==1650|deathid==3258

** Names containing 'ST' are being interpreted as 'ST'=name1/fname so correct
count if name1=="ST" | name1=="ST." //31
replace tempvarn=2 if name1=="ST" | name1=="ST."
list deathid pname *name* if tempvarn==2
list deathid pname *name* if tempvarn==2 & regexm(name1, "ST.")
replace name1=name1+""+name2 if tempvarn==2 & regexm(name1, "ST.") //6 changes
list deathid pname *name* if tempvarn==2 & name1=="ST"
replace name1=name1+"."+""+name2 if tempvarn==2 & name1=="ST" //25 changes
list deathid pname name1 name2 name3 name4 name5 name6 if tempvarn==2
replace name6=name3+name4 if deathid==4319
replace name3="" if deathid==4319
replace name4="" if deathid==4319
replace name2="" if tempvarn==2 //31 changes
replace name2=name3 if tempvarn==2 & name4!="" //5 changes
replace name3="" if tempvarn==2 & name4!="" //5 changes
replace name6=name4 if tempvarn==2 & name4!="" //5 changes
replace name6=name3 if tempvarn==2 & name6=="" //25 changes
replace name3="" if tempvarn==2 //25 changes
replace name4="" if tempvarn==2 //5 changes

count if name2=="ST" //38
list deathid pname name1 name2 name3 name4 name5 name6 if tempvarn==3
replace tempvarn=3 if name2=="ST"
replace name2=name2+"."+name3 if tempvarn==3 //38 changes
replace name6=name2 if tempvarn==3 & name4=="" //12 changes
replace name6=name4 if tempvarn==3 & name6=="" //26 changes
replace name2="" if tempvarn==3 & name4=="" //12 changes
replace name3="" if tempvarn==3 //38 changes
replace name4="" if tempvarn==3 //26 changes

count if name3=="ST" //7
replace tempvarn=4 if name3=="ST"
list deathid pname name1 name2 name3 name4 name5 name6 if tempvarn==4
replace name6=name3+"."+name4 if tempvarn==4 & name6=="" //7 changes
replace name3="" if tempvarn==4 //7 changes
replace name4="" if tempvarn==4 //7 changes
replace name5="" if tempvarn==4 //1 change

count if name2=="" & (name3!=""|name4!=""|name5!="") //0
count if name6=="" & (name2!=""|name3!=""|name4!=""|name5!="") //2,884
count if name6=="" & name5!="" //0
count if name6=="" & name4!="" //206
replace tempvarn=5 if name6=="" & name4!="" //206 changes
list deathid pname name1 name2 name3 name4 if tempvarn==5
list deathid pname name1 name2 name3 name4 name5 name6 if name3=="DE"
replace name6=name3+" "+name4 if name3=="DE" //4 changes
replace name4="" if name3=="DE" //4 changes
replace name3="" if name3=="DE" //4 changes
list deathid pname name1 name2 name3 name4 name5 name6 if name2=="ST." //17
replace name6=name2+name3 if name2=="ST." & name4=="" //5 changes
replace name6=name4 if name2=="ST." & name6=="" //12 changes
replace name2=name2+name3 if name2=="ST." & name4!="" //12 changes
replace name3="" if name2=="ST." & name3!="" //5 changes
replace name2="" if name2=="ST." & name2!="" //5 changes
list deathid name1 name2 name3 name4 if tempvarn==5 & name6=="" //190
list deathid pname name1 name2 name3 name4 name5 name6 if name4=="NEAL" //2
replace name6=name3+name4 if name4=="NEAL"
replace name3="" if name4=="NEAL"
replace name4="" if name4=="NEAL"
list deathid pname name1 name2 name3 name4 name5 name6 if name4=="JR"|name4=="JR." //2
replace name6=name3+" "+name4 if name4=="JR"|name4=="JR."
replace name3="" if name4=="JR"|name4=="JR."
replace name4="" if name4=="JR"|name4=="JR."
list deathid pname name1 name2 name3 name4 name5 name6 if name4=="SNR." //1
replace name6=name3+" "+name4 if name4=="SNR."
replace name3="" if name4=="SNR."
replace name4="" if name4=="SNR."
list deathid pname name1 name2 name3 name4 name5 name6 if name3=="ST." //2
replace name6=name3+name4 if name3=="ST."
replace name4="" if name3=="ST."
replace name3="" if name3=="ST."
list deathid name1 name2 name3 name4 if tempvarn==5 & name6=="" //183
replace name6=name4 if tempvarn==5 & name6=="" //183 changes
list deathid pname name1 name2 name6 if tempvarn==5 //183
replace name3="" if tempvarn==5 & (name3=="CLAIR"|name3=="C.") & deathid!=2945 //8 changes
replace name2=name2+" "+name3 if tempvarn==5 & name3!="" & length(name3)>4 //140 changes
replace name1=name2 if deathid==2945
replace name2=name3 if deathid==2945
replace name3="" if deathid==2945
replace name2=name2+" "+name3 if tempvarn==5 & name3!="" & length(name3)<5 & name3!="MC" //43 changes
replace name4=name3+name4 if tempvarn==5 & name3=="MC" //3 changes
replace name4="" if tempvarn==5 //195 changes
replace name3="" if tempvarn==5 //186 changes

count if name6=="" & name3!="" //2,667
list deathid pname name1 name2 name3 if name6=="" & name3!=""
replace name6=name3 if name6=="" & name3!="" //2,667 changes
count if name6=="" & name2!="" //0
count if name6=="" & name1!="" //0

count if length(name1)<2 //2
list deathid *name* if length(name1)<2
replace name3="" if length(name1)<2
replace name1=name1+name2 if length(name1)<2
replace name2="" if deathid==1105|deathid==3226
count if length(name6)<2 //1
list deathid *name* if length(name6)<2
replace name6=name1 if deathid==704
replace name1="99" if deathid==704

** Now rename, check and remove unnecessary variables
rename name1 fname
rename name2 mname
rename name6 lname
count if fname=="" //0
count if lname=="" //0
drop name3 name4 name5 name7 tempvarn

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace mname = lower(rtrim(ltrim(itrim(mname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))

order deathid pname fname mname lname namematch

count //11,890

save "`datapath'\version01\2-working\datarequest_NAACCR-IACR_death_prep_2008-2012.dta", replace
