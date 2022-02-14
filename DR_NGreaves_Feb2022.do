** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          DR_NGreaves_Feb2022.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      10-FEB-2022
    // 	date last modified      10-FEB-2022
    //  algorithm task          Preparing 2008,2013-2015 dataset per data request form
    //  status                  Completed
    //  objective               To have one dataset with cleaned 2008,2013-2015 hepatic, gall bladder, pancreatic duodenal, stomach,  and colorectal data
    //  methods                 Format and save dataset using the 2015 annual report dataset

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
    log using "`logpath'\DR_NGreaves_Feb2022.smcl", replace
** HEADER -----------------------------------------------------

** Using the 2015 annual report dataset that was generated for IARC-Hub's use
use "`datapath'\version09\1-input\2008_2013_2014_2015_iarchub_nonsurvival_reportable"

count //3588

/* Remove all variables except:
		Record ID
		Age
		Sex
		Status at last contact
		Date of last contact
		Date of death, where applicable
		Year of death, where applicable
		Date of incidence
		Year of incidence
		Topography
		Morphology
		ICD-10 code
		Behaviour
		Basis of Diagnosis
		Site (IARC/ICD-10 site)
		Cause(s) of death
*/
keep pid cr5id age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath dxyr fname lname natregno dd_cod1a cr5cod mpseq mptot


** Remove all sites except hepatic, gall bladder, pancreatic duodenal, stomach,  and colorectal cancers
labelbook siteiarc_lab

keep if siteiarc==11|siteiarc==13|siteiarc==14|siteiarc==16|siteiarc==17|siteiarc==18|topography==170 //2752 deleted

count //836

** Check no missing in the above variables
tab pid ,m //none missing
tab age ,m //none missing
tab sex ,m //none missing
tab slc ,m //none missing
tab dlc ,m //none missing
tab dod ,m //187 missing - 187 alive
tab dodyear ,m //187 missing - 187 alive
tab dot ,m //none missing
tab dotyear ,m //none missing
tab dxyr ,m //none missing
tab topography ,m //none missing
tab morph ,m //none missing
tab icd10 ,m //none missing
tab beh ,m //none missing
tab basis ,m //none missing
tab siteiarc ,m //none missing
tab dd_coddeath ,m //212 missing
tab cr5cod ,m //116 missing

** Clean cause of death variable
count if slc==2 & dd_coddeath=="" //26
count if dd_coddeath=="" & dd_cod1a!="" //11
count if dd_coddeath=="" & cr5cod!="" & cr5cod!="99" //14
replace cr5cod = upper(rtrim(ltrim(itrim(cr5cod)))) //595 changes
count if slc!=2 & dd_cod1a!="" //1 - it's a full-stop
replace dd_cod1a="" if slc!=2 & dd_cod1a!="" //1 change
count if slc!=2 & cr5cod!="" & cr5cod!="99" //0

replace dd_coddeath=cr5cod if dd_coddeath==""  & cr5cod!="" & cr5cod!="99" //14 changes
replace dd_coddeath=dd_cod1a if dd_coddeath=="" & dd_cod1a!="" //8 changes

count if slc==2 & dd_coddeath=="" //4 - check these individually in REDCap death db - pids 20080611, 20130167, 20130690 cannot be found in death data
replace dd_coddeath="METASTATIC COLON CANCER" if pid=="20155029"
count if slc==2 & dd_coddeath=="" //3 - PIDs 20080611, 20130167, 20130690 cannot be found in death data

drop dxyr fname lname natregno dd_cod1a cr5cod

** Check if cancer is a MP
count if cr5id!="T1S1" //13
drop cr5id mpseq mptot

** Check labels of variables to ensure they are understandable
label var pid "Unique Patient ID"
//label var cr5id "Tumour + Source ID"
label var slc "Status at Last Contact"
label var dlc "Date of Last Contact"
label var dod "Date of Death"
label var morph "ICD-O-3 Morphology"
//label var mpseq "Tumour Sequence"
//label var mptot "Tumour Total"
label var sex "Sex"
label var beh "ICD-O-3 Behaviour"
label var basis "Most Valid Basis of Diagnosis"
label var dot "Date of Incidence"
label var topography "ICD-O-3 Topography"
label var icd10 "ICD-10"
label var siteiarc "IARC-ICD10 Site Classification"
label var dd_coddeath "Cause(s) of Death"
label var dotyear "Year of Incidence"
label var dodyear "Year of Death"

** Create Stata dictionaries for topography and morph based on CR5db data dictionary
label define topography_lab ///
000	"C00.0 External upper lip" ///
001	"C00.1 External lower lip" ///
002	"C00.2 External lip, NOS" ///
003	"C00.3 Mucosa of upper lip" ///
004	"C00.4 Mucosa of lower lip" ///
005	"C00.5 Mucosa of lip, NOS" ///
006	"C00.6 Commissure of lip" ///
008	"C00.8 Overl. lesion of lip" ///
009	"C00.9 Lip, NOS" ///
019	"C01.9 Base of tongue, NOS" ///
020	"C02.0 Dorsal surface of tongue, NOS" ///
021	"C02.1 Border of tongue" ///
022	"C02.2 Ventral surface of tongue, NOS" ///
023	"C02.3 Anterior 2/3 of tongue, NOS" ///
024	"C02.4 Lingual tonsil" ///
028	"C02.8 Overl. lesion of tongue" ///
029	"C02.9 Tongue, NOS" ///
030	"C03.0 Upper gum" ///
031	"C03.1 Lower gum" ///
039	"C03.9 Gum, NOS" ///
040	"C04.0 Anterior floor of mouth" ///
041	"C04.1 Lateral floor of mouth" ///
048	"C04.8 Overl. lesion of floor of mouth" ///
049	"C04.9 Floor of mouth, NOS" ///
050	"C05.0 Hard palate" ///
051	"C05.1 Soft palate, NOS" ///
052	"C05.2 Uvula" ///
058	"C05.8 Overl. lesion of palate" ///
059	"C05.9 Palate, NOS" ///
060	"C06.0 Cheek mucosa" ///
061	"C06.1 Vestibule of mouth" ///
062	"C06.2 Retromolar area" ///
068	"C06.8 Overl. lesion of other/unspec. parts of mouth" ///
069	"C06.9 Mouth, NOS" ///
079	"C07.9 Parotid gland" ///
080	"C08.0 Submandibular gland" ///
081	"C08.1 Sublingual gland" ///
088	"C08.8 Overl. lesion of major salivary gland" ///
089	"C08.9 Major salivary gland, NOS" ///
090	"C09.0 Tonsillar fossa" ///
091	"C09.1 Tonsillar pillar" ///
098	"C09.8 Overl. lesion of tonsil" ///
099	"C09.9 Tonsil, NOS" ///
100	"C10.0 Vallecula" ///
101	"C10.1 Anterior surface of epiglottis" ///
102	"C10.2 Lateral wall of oropharynx" ///
103	"C10.3 Posterior wall of oropharynx" ///
104	"C10.4 Branchial cleft" ///
108	"C10.8 Overl. lesion of oropharynx" ///
109	"C10.9 Oropharynx, NOS" ///
110	"C11.0 Superior wall of nasopharynx" ///
111	"C11.1 Posterior wall of nasopharynx" ///
112	"C11.2 Lateral wall of nasopharynx" ///
113	"C11.3 Anterior wall of nasopharynx" ///
118	"C11.8 Overl. lesion of nasopharynx" ///
119	"C11.9 Nasopharynx, NOS" ///
129	"C12.9 Pyriform sinus" ///
130	"C13.0 Postcricoid region" ///
131	"C13.1 Aryepiglottic fold" ///
132	"C13.2 Posterior wall of hypopharynx" ///
138	"C13.8 Overl. lesion of hypopharynx" ///
139	"C13.9 Laryngopharynx, Hypopharynx NOS" ///
140	"C14.0 Pharynx, NOS" ///
141	"C14.1 Laryngopharynx (OLD CODE, NOW C13.9)" ///
142	"C14.2 Waldeyer's ring, NOS" ///
148	"C14.8 Overl. lesion of lip, oral cavity, pharynx" ///
150	"C15.0 Cervical esophagus" ///
151	"C15.1 Thoracic esophagus" ///
152	"C15.2 Abdominal esophagus" ///
153	"C15.3 Upper third of esophagus" ///
154	"C15.4 Middle third of esophagus" ///
155	"C15.5 Lower third of esophagus" ///
158	"C15.8 Overl. lesion of esophagus" ///
159	"C15.9 Oesophagus, NOS" ///
160	"C16.0 Cardia, NOS" ///
161	"C16.1 Fundus of stomach" ///
162	"C16.2 Body of stomach" ///
163	"C16.3 Gastric antrum" ///
164	"C16.4 Pylorus" ///
165	"C16.5 Lesser curvature of stomach, NOS" ///
166	"C16.6 Greater curvature of stomach, NOS" ///
168	"C16.8 Overl. lesion of stomach" ///
169	"C16.9 Stomach, NOS" ///
170	"C17.0 Duodenum" ///
171	"C17.1 Jejunum" ///
172	"C17.2 Ileum" ///
173	"C17.3 Meckel's diverticulum" ///
178	"C17.8 Overl. lesion of small intestine" ///
179	"C17.9 Small intestine" ///
180	"C18.0 Cecum" ///
181	"C18.1 Appendix" ///
182	"C18.2 Ascending colon" ///
183	"C18.3 Hepatic flexure of colon" ///
184	"C18.4 Transverse colon" ///
185	"C18.5 Splenic flexure of colon" ///
186	"C18.6 Descending colon" ///
187	"C18.7 Sigmoid colon" ///
188	"C18.8 Overl. lesion of colon" ///
189	"C18.9 Colon, NOS" ///
199	"C19.9 Rectosigmoid junction" ///
209	"C20.9 Rectum, NOS" ///
210	"C21.0 Anus, NOS" ///
211	"C21.1 Anal canal" ///
212	"C21.2 Cloacogenic zone" ///
218	"C21.8 Overl. lesion rectum, anal canal" ///
220	"C22.0 Liver" ///
221	"C22.1 Intrahepatic bile duct" ///
239	"C23.9 Gallbladder" ///
240	"C24.0 Extrahepatic bile duct" ///
241	"C24.1 Ampulla of Vater" ///
248	"C24.8 Overl. lesion of biliary tract" ///
249	"C24.9 Biliary tract, NOS" ///
250	"C25.0 Head of pancreas" ///
251	"C25.1 Body of pancreas" ///
252	"C25.2 Tail of pancreas" ///
253	"C25.3 Pancreatic duct" ///
254	"C25.4 Islets of Langerhans" ///
257	"C25.7 Other specified parts of pancreas" ///
258	"C25.8 Overl. lesion of pancreas" ///
259	"C25.9 Pancreas, NOS" ///
260	"C26.0 Intestinal tract, NOS" ///
268	"C26.8 Overl. lesion of digestive system" ///
269	"C26.9 Gastrointestinal tract, NOS" ///
300	"C30.0 Nasal cavity" ///
301	"C30.1 Middle ear" ///
310	"C31.0 Maxillary sinus" ///
311	"C31.1 Ethmoid sinus" ///
312	"C31.2 Frontal sinus" ///
313	"C31.3 Sphenoid sinus" ///
318	"C31.8 Overl. lesion of accessory sinuses" ///
319	"C31.9 Accessory sinus, NOS" ///
320	"C32.0 Glottis" ///
321	"C32.1 Supraglottis" ///
322	"C32.2 Subglottis" ///
323	"C32.3 Laryngeal cartilage" ///
328	"C32.8 Overl. lesion of larynx" ///
329	"C32.9 Larynx, NOS" ///
339	"C33.9 Trachea" ///
340	"C34.0 Main bronchus" ///
341	"C34.1 Upper lobe, lung" ///
342	"C34.2 Middle lobe, lung" ///
343	"C34.3 Lower lobe, lung" ///
348	"C34.8 Overl. lesion of lung" ///
349	"C34.9 Lung, NOS" ///
379	"C37.9 Thymus" ///
380	"C38.0 Heart" ///
381	"C38.1 Anterior mediastinum" ///
382	"C38.2 Posterior mediastinum" ///
383	"C38.3 Mediastinum, NOS" ///
384	"C38.4 Pleura, NOS" ///
388	"C38.8 Overl. lesion of heart, mediastinum, pleura" ///
390	"C39.0 Upper respiratory tract" ///
398	"C39.8 Overl. lesion of respiratory system" ///
399	"C39.9 Ill-defined sites within respiratory system" ///
400	"C40.0 Long bones of upper limb, scapula" ///
401	"C40.1 Short bones of upper limb" ///
402	"C40.2 Long bones of lower limb" ///
403	"C40.3 Short bones of lower limb" ///
408	"C40.8 Overl. lesion of bones of limb" ///
409	"C40.9 Bone of limb, NOS" ///
410	"C41.0 Bones of skull and face" ///
411	"C41.1 Mandible" ///
412	"C41.2 Vertebral column" ///
413	"C41.3 Rib, Sternum, Clavicle" ///
414	"C41.4 Pelvic bones, Sacrum, Coccyx" ///
418	"C41.8 Overl. lesion of bones" ///
419	"C41.9 Bone, NOS" ///
420	"C42.0 Blood" ///
421	"C42.1 Bone marrow" ///
422	"C42.2 Spleen" ///
423	"C42.3 Reticuloendothelial system, NOS" ///
424	"C42.4 Hematopoietic system, NOS" ///
440	"C44.0 Skin of lip, NOS" ///
441	"C44.1 Eyelid" ///
442	"C44.2 External ear" ///
443	"C44.3 Skin, other & unspec parts of face" ///
444	"C44.4 Skin of scalp and neck" ///
445	"C44.5 Skin of trunk" ///
446	"C44.6 Skin of upper limb and shoulder" ///
447	"C44.7 Skin of lower limb and hip" ///
448	"C44.8 Overl. lesion of skin" ///
449	"C44.9 Skin, NOS" ///
470	"C47.0 Per. nerves & A.N.S. of head, face, neck" ///
471	"C47.1 Per. nerves & A.N.S. of upper limb, should" ///
472	"C47.2 Per. nerves & A.N.S. of lower limb, hip" ///
473	"C47.3 Per. nerves & A.N.S. of thorax" ///
474	"C47.4 Per. nerves & A.N.S. of abdomen" ///
475	"C47.5 Per. nerves & A.N.S. of pelvis" ///
476	"C47.6 Per. nerves & A.N.S. of trunk" ///
478	"C47.8 Overl. lesion of peripheral nerves & ANS" ///
479	"C47.9 Autonomic nervous system, NOS" ///
480	"C48.0 Retroperitoneum" ///
481	"C48.1 Specified parts of peritoneum" ///
482	"C48.2 Peritoneum, NOS" ///
488	"C48.8 Overl. lesion of retroperitoneum & peritoneum" ///
490	"C49.0 Soft tissues of head, face, & neck" ///
491	"C49.1 Soft tissues of upper limb, shoulder" ///
492	"C49.2 Soft tissues of lower limb and hip" ///
493	"C49.3 Soft tissues of thorax" ///
494	"C49.4 Soft tissues of abdomen" ///
495	"C49.5 Soft tissues of pelvis" ///
496	"C49.6 Soft tissues of trunk" ///
498	"C49.8 Overl. lesion of soft tissues" ///
499	"C49.9 Other soft tissues" ///
500	"C50.0 Nipple" ///
501	"C50.1 Central portion of breast" ///
502	"C50.2 Upper-inner quadrant of breast" ///
503	"C50.3 Lower-inner quadrant of breast" ///
504	"C50.4 Upper-outer quadrant of breast" ///
505	"C50.5 Lower-outer quadrant of breast" ///
506	"C50.6 Axillary tail of breast" ///
508	"C50.8 Overl. lesion of breast" ///
509	"C50.9 Breast, NOS" ///
510	"C51.0 Labium majus" ///
511	"C51.1 Labium minus" ///
512	"C51.2 Clitoris" ///
518	"C51.8 Overl. lesion of vulva" ///
519	"C51.9 Vulva, NOS" ///
529	"C52.9 Vagina, NOS" ///
530	"C53.0 Endocervix" ///
531	"C53.1 Exocervix" ///
538	"C53.8 Overl. lesion of cervix uteri" ///
539	"C53.9 Cervix uteri" ///
540	"C54.0 Isthmus uteri" ///
541	"C54.1 Endometrium" ///
542	"C54.2 Myometrium" ///
543	"C54.3 Fundus uteri" ///
548	"C54.8 Overl. lesion of corpus uteri" ///
549	"C54.9 Corpus uteri" ///
559	"C55.9 Uterus, NOS" ///
569	"C56.9 Ovary" ///
570	"C57.0 Fallopian tube" ///
571	"C57.1 Broad ligament" ///
572	"C57.2 Round ligament" ///
573	"C57.3 Parametrium" ///
574	"C57.4 Uterine adnexa" ///
577	"C57.7 Other parts of female genital organs" ///
578	"C57.8 Overl. lesion of female genital organs" ///
579	"C57.9 Female genital tract, NOS" ///
589	"C58.9 Placenta" ///
600	"C60.0 Prepuce" ///
601	"C60.1 Glans penis" ///
602	"C60.2 Body of penis" ///
608	"C60.8 Overl. lesion of penis" ///
609	"C60.9 Penis, NOS" ///
619	"C61.9 Prostate gland" ///
620	"C62.0 Undescended testis" ///
621	"C62.1 Descended testis" ///
629	"C62.9 Testis, NOS" ///
630	"C63.0 Epididymis" ///
631	"C63.1 Spermatic cord" ///
632	"C63.2 Scrotum, NOS" ///
637	"C63.7 Other parts of male genital organs" ///
638	"C63.8 Overl. lesion of male genital organs" ///
639	"C63.9 Male genital organs, NOS" ///
649	"C64.9 Kidney, NOS" ///
659	"C65.9 Renal pelvis" ///
669	"C66.9 Ureter" ///
670	"C67.0 Trigone of urinary bladder" ///
671	"C67.1 Dome of urinary bladder" ///
672	"C67.2 Lateral wall of urinary bladder" ///
673	"C67.3 Anterior wall of urinary bladder" ///
674	"C67.4 Posterior wall of urinary bladder" ///
675	"C67.5 Bladder neck" ///
676	"C67.6 Ureteric orifice" ///
677	"C67.7 Urachus" ///
678	"C67.8 Overl. lesion of bladder" ///
679	"C67.9 Urinary bladder, NOS" ///
680	"C68.0 Urethra" ///
681	"C68.1 Paraurethral gland" ///
688	"C68.8 Overl. lesion of urinary organs" ///
689	"C68.9 Urinary system, NOS" ///
690	"C69.0 Conjunctiva" ///
691	"C69.1 Cornea, NOS" ///
692	"C69.2 Retina" ///
693	"C69.3 Choroid" ///
694	"C69.4 Ciliary body" ///
695	"C69.5 Lacrimal gland, NOS" ///
696	"C69.6 Orbit, NOS" ///
698	"C69.8 Overl. lesion of eye, adnexa" ///
699	"C69.9 Eye, NOS" ///
700	"C70.0 Cerebral meninges" ///
701	"C70.1 Spinal meninges" ///
709	"C70.9 Meninges, NOS" ///
710	"C71.0 Cerebrum" ///
711	"C71.1 Frontal lobe" ///
712	"C71.2 Temporal lobe" ///
713	"C71.3 Parietal lobe" ///
714	"C71.4 Occipital lobe" ///
715	"C71.5 Ventricle, NOS" ///
716	"C71.6 Cerebellum, NOS" ///
717	"C71.7 Brain stem" ///
718	"C71.8 Overl. lesion of brain" ///
719	"C71.9 Brain, NOS" ///
720	"C72.0 Spinal cord" ///
721	"C72.1 Cauda equina" ///
722	"C72.2 Olfactory nerve" ///
723	"C72.3 Optic nerve" ///
724	"C72.4 Acoustic nerve" ///
725	"C72.5 Cranial nerve" ///
728	"C72.8 Overl. lesion of brain and CNS" ///
729	"C72.9 Nervous system, NOS" ///
739	"C73.9 Thyroid gland" ///
740	"C74.0 Cortex of adrenal gland" ///
741	"C74.1 Medulla of adrenal gland" ///
749	"C74.9 Adrenal gland, NOS" ///
750	"C75.0 Parathyroid gland" ///
751	"C75.1 Pituitary gland" ///
752	"C75.2 Craniopharyngeal duct" ///
753	"C75.3 Pineal gland" ///
754	"C75.4 Carotid body" ///
755	"C75.5 Aortic body and other paraganglia" ///
758	"C75.8 Overl. lesion of endocrine glands" ///
759	"C75.9 Endocrine gland, NOS" ///
760	"C76.0 Head, face or neck, NOS" ///
761	"C76.1 Thorax, NOS" ///
762	"C76.2 Abdomen, NOS" ///
763	"C76.3 Pelvis, NOS" ///
764	"C76.4 Upper limb, NOS" ///
765	"C76.5 Lower limb, NOS" ///
767	"C76.7 Other ill-defined sites" ///
768	"C76.8 Overl. lesion of ill-defined sites" ///
770	"C77.0 Lymph nodes of head, face and neck" ///
771	"C77.1 Intrathoracic lymph nodes" ///
772	"C77.2 Intra-abdominal lymph nodes" ///
773	"C77.3 Lymph nodes of axilla or arm" ///
774	"C77.4 Lymph nodes, inguinal region or leg" ///
775	"C77.5 Pelvic lymph nodes" ///
778	"C77.8 Lymph nodes of multiple regions" ///
779	"C77.9 Lymph node, NOS" ///
809	"C80.9 Unknown primary site" , modify
label values topography topography_lab

label define morph_lab ///
8000	"Neoplasm, malignant" ///
8001	"Tumor cells, malignant" ///
8002	"Malignant tumor, small cell type" ///
8003	"Malignant tumor, giant cell type" ///
8004	"Malignant tumor, spindle cell type" ///
8005	"Malignant tumor, clear cell type" ///
8010	"Carcinoma, NOS" ///
8011	"Epithelioma, malignant" ///
8012	"Large cell carcinoma, NOS" ///
8013	"Large cell neuroendocrine carcinoma" ///
8014	"Large cell carcinoma with rhabdoid phenotype" ///
8015	"Glassy cell carcinoma" ///
8020	"Carcinoma, undifferentiated, NOS" ///
8021	"Carcinoma, anaplastic, NOS" ///
8022	"Pleomorphic carcinoma" ///
8030	"Giant cell and spindle cell carcinoma" ///
8031	"Giant cell carcinoma" ///
8032	"Spindle cell carcinoma, NOS" ///
8033	"Pseudosarcomatous carcinoma" ///
8034	"Polygonal cell carcinoma" ///
8035	"Carcinoma with osteoclast-like giant cells" ///
8041	"Small cell carcinoma, NOS" ///
8042	"Oat cell carcinoma" ///
8043	"Small cell carcinoma, fusiform cell" ///
8044	"Small cell carcinoma, intermediate cell" ///
8045	"Combined small cell carcinoma" ///
8046	"Non-small cell carcinoma" ///
8050	"Papillary carcinoma, NOS" ///
8051	"Verrucous carcinoma, NOS" ///
8052	"Papillary squamous cell carcinoma" ///
8070	"Squamous cell carcinoma, NOS" ///
8071	"Squamous cell carcinoma, keratinizing, NOS" ///
8072	"Squamous cell carcinoma, large cell, nonkeratinizing" ///
8073	"Squamous cell carcinoma, small cell, nonkeratinizing" ///
8074	"Squamous cell carcinoma, spindle cell" ///
8075	"Squamous cell carcinoma, adenoid" ///
8076	"Squamous cell carcinoma, microinvasive" ///
8077	"squamous intraepithelial neoplasia, grade III" ///
8078	"Squamous cell carcinoma with horn formation" ///
8082	"Lymphoepithelial carcinoma" ///
8083	"Basaloid squamous cell carcinoma" ///
8084	"Squamous cell carcinoma, clear cell type" ///
8090	"Basal cell carcinoma, NOS" ///
8091	"Multifocal superficial basal cell carcinoma" ///
8092	"Infiltrating basal cell carcinoma, NOS" ///
8093	"Basal cell carcinoma, fibroepithelial" ///
8094	"Basosquamous carcinoma" ///
8095	"Metatypical carcinoma" ///
8097	"Basal cell carcinoma, nodular" ///
8098	"Adenoid basal carcinoma" ///
8102	"Trichilemmocarcinoma" ///
8110	"Pilomatrix carcinoma" ///
8120	"Transitional cell carcinoma, NOS" ///
8121	"Schneiderian carcinoma" ///
8122	"Transitional cell carcinoma, spindle cell" ///
8123	"Basaloid carcinoma" ///
8124	"Cloacogenic carcinoma" ///
8130	"Papillary transitional cell carcinoma" ///
8131	"Transitional cell carcinoma, micropapillary" ///
8140	"Adenocarcinoma, NOS" ///
8141	"Scirrhous adenocarcinoma" ///
8142	"Linitis plastica" ///
8143	"Superficial spreading adenocarcinoma" ///
8144	"Adenocarcinoma, intestinal type" ///
8145	"Carcinoma, diffuse type" ///
8147	"Basal cell adenocarcinoma" ///
8150	"Islet cell carcinoma" ///
8151	"Insulinoma, malignant" ///
8152	"Glucagonoma, malignant" ///
8153	"Gastrinoma, malignant" ///
8154	"Mixed islet cell and exocrine adenocarcinoma" ///
8155	"Vipoma, malignant" ///
8156	"Somatostatinoma, malignant" ///
8157	"Enteroglucagonoma, malignant" ///
8160	"Cholangiocarcinoma" ///
8161	"Bile duct cystadenocarcinoma" ///
8162	"Klatskin tumor" ///
8170	"Hepatocellular carcinoma, NOS" ///
8171	"Hepatocellular carcinoma, fibrolamellar" ///
8172	"Hepatocellular carcinoma, scirrhous" ///
8173	"Hepatocellular carcinoma, spindle cell" ///
8174	"Hepatocellular carcinoma, clear cell type" ///
8175	"Hepatocellular carcinoma, pleomorphic type" ///
8180	"Combined hepatocellular carcinoma and cholangiocarcinoma" ///
8190	"Trabecular adenocarcinoma" ///
8200	"Adenoid cystic carcinoma" ///
8201	"Cribriform carcinoma, NOS" ///
8210	"Adenocarcinoma in adenomatous polyp" ///
8211	"Tubular adenocarcinoma" ///
8214	"Parietal cell carcinoma" ///
8215	"Adenocarcinoma of anal glands" ///
8220	"Adenocarcinoma in adenomatous polyposis" ///
8221	"Adenocarcinoma in multiple adenomatous" ///
8230	"Solid carcinoma, NOS" ///
8231	"Carcinoma simplex" ///
8240	"Carcinoid tumor, NOS" ///
8241	"Enterochromaffin cell carcinoid" ///
8242	"Enterochromaffin-like cell tumor, malignant" ///
8243	"Goblet cell carcinoid" ///
8244	"Composite carcinoid" ///
8245	"Adenocarcinoid tumor" ///
8246	"Neuroendocrine carcinoma, NOS" ///
8247	"Merkel cell carcinoma" ///
8249	"A typical carcinoid tumor" ///
8250	"Bronchiolo-alveolar adenocarcinoma, NOS" ///
8251	"Alveolar adenocarcinoma" ///
8252	"Bronchiolo-alveolar carcinoma, non-mucinous" ///
8253	"Bronchiolo-alveolar carcinoma, mucinous" ///
8254	"Bronchiolo-alveolar carcinoma, mixed mucinous and non-mucinous" ///
8255	"Adenocarcinoma with mixed subtypes" ///
8260	"Papillary adenocarcinoma, NOS" ///
8261	"Adenocarcinoma in villous adenoma" ///
8262	"Villous adenocarcinoma" ///
8263	"Adenocarcinoma in tubulovillous adenoma" ///
8270	"Chromophobe carcinoma" ///
8272	"Pituitary carcinoma, NOS" ///
8280	"Acidophil carcinoma" ///
8281	"Mixed acidophil-basophil carcinoma" ///
8290	"Oxyphilic adenocarcinoma" ///
8300	"Basophil carcinoma" ///
8310	"Clear cell adenocarcinoma, NOS" ///
8312	"Renal cell carcinoma, NOS" ///
8313	"Clear cell adenocarcinofibroma" ///
8314	"Lipid-rich carcinoma" ///
8315	"Glycogen-rich carcinoma" ///
8316	"Cyst-associated renal cell carcinoma" ///
8317	"Renal cell carcinoma, chromophobe type" ///
8318	"Renal cell carcinoma, sarcomatoid" ///
8319	"Collecting duct carcinoma" ///
8320	"Granular cell carcinoma" ///
8322	"Water-clear cell adenocarcinoma" ///
8323	"Mixed cell adenocarcinoma" ///
8330	"Follicular adenocarcinoma, NOS" ///
8331	"Follicular adenocarcinoma, well differentiated" ///
8332	"Follicular adenocarcinoma, trabecular" ///
8333	"Fetal adenocarcinoma" ///
8335	"Follicular carcinoma, minimally invasive" ///
8337	"Insular carcinoma" ///
8340	"Papillary carcinoma, follicular variant" ///
8341	"Papillary microcarcinoma" ///
8342	"Papillary carcinoma, oxyphilic cell" ///
8343	"Papillary carcinoma, encapsulated" ///
8344	"Papillary carcinoma, columnar cell" ///
8345	"Medullary carcinoma with amyloid stroma" ///
8346	"Mixed medullary-follicular carcinoma" ///
8347	"Mixed medullary-papillary carcinoma" ///
8350	"Nonencapsulated sclerosing carcinoma" ///
8370	"Adrenal cortical carcinoma" ///
8380	"Endometrioid adenocarcinoma, NOS" ///
8381	"Endometrioid adenofibroma, malignant" ///
8382	"Endometrioid adenocarcinoma, secretory variant" ///
8383	"Endometrioid adenocarcinoma, ciliated cell variant" ///
8384	"Adenocarcinoma, endocervical type" ///
8390	"Skin appendage carcinoma" ///
8400	"Sweat gland adenocarcinoma" ///
8401	"Apocrine adenocarcinoma" ///
8402	"Nodular hidradenoma, malignant" ///
8403	"Malignant eccrine spiradenoma" ///
8407	"Sclerosing sweat duct carcinoma" ///
8408	"Eccrine papillary adenocarcinoma" ///
8409	"Eccrine poroma, malignant" ///
8410	"Sebaceous adenocarcinoma" ///
8413	"Eccrine adenocarcinoma" ///
8420	"Ceruminous adenocarcinoma" ///
8430	"Mucoepidermoid carcinoma" ///
8440	"Cystadenocarcinoma, NOS" ///
8441	"Serous cystadenocarcinoma, NOS" ///
8450	"Papillary cystadenocarcinoma, NOS" ///
8452	"Solid pseudopapillary carcinoma" ///
8453	"Intraductal papillary-mucinous carcinoma, invasive" ///
8460	"Papillary serous cystadenocarcinoma" ///
8461	"Serous surface papillary carcinoma" ///
8470	"Mucinous cystadenocarcinoma, NOS" ///
8471	"Papillary mucinous cystadenocarcinoma" ///
8480	"Mucinous adenocarcinoma" ///
8481	"Mucin-producing adenocarcinoma" ///
8482	"Mucinous adenocarcinoma, endocervical type" ///
8490	"Signet ring cell carcinoma" ///
8500	"Infiltrating duct carcinoma, NOS" ///
8501	"Comedocarcinoma, NOS" ///
8502	"Secretory carcinoma of breast" ///
8503	"Intraductal papillary adenocarcinoma with invasion" ///
8504	"Intracystic carcinoma, NOS" ///
8508	"Cystic hypersecretory carcinoma" ///
8510	"Medullary carcinoma, NOS" ///
8512	"Medullary carcinoma with lymphoid stroma" ///
8513	"Atypical medullary carcinoma" ///
8514	"Duct carcinoma, desmoplastic type" ///
8520	"Lobular carcinoma, NOS" ///
8521	"Infiltrating ductular carcinoma" ///
8522	"Infiltrating duct and lobular carcinoma" ///
8523	"Infiltrating duct mixed with other types of carcinoma" ///
8524	"Infiltrating lobular mixed with other types of carcinoma" ///
8525	"Polymorphous low grade adenocarcinoma" ///
8530	"Inflammatory carcinoma" ///
8540	"Paget disease, mammary" ///
8541	"Paget disease and infiltrating duct carcinoma of breast" ///
8542	"Paget disease, extramammary (except Paget disease of bone)" ///
8543	"Paget disease and intraductal carcinoma of breast" ///
8550	"Acinar cell carcinoma" ///
8551	"Acinar cell cystadenocarcinoma" ///
8560	"Adenosquamous carcinoma" ///
8562	"Epithelial-myoepithelial carcinoma" ///
8570	"Adenocarcinoma with squamous metaplasia" ///
8571	"Adenocarcinoma with cartilaginous and osseous metaplasia" ///
8572	"Adenocarcinoma with spindle cell metaplasia" ///
8573	"Adenocarcinoma with apocrine metaplasia" ///
8574	"Adenocarcinoma with neuroendocrine differentiation" ///
8575	"Metaplastic carcinoma, NOS" ///
8576	"Hepatoid adenocarcinoma" ///
8580	"Thymoma, malignant, NOS" ///
8581	"Thymoma, type A, malignant" ///
8582	"Thymoma, type AB, malignant" ///
8583	"Thymoma, type B1, malignant" ///
8584	"Thymoma, type B2, malignant" ///
8585	"Thymoma, type B3, malignant" ///
8586	"Thymic carcinoma, NOS" ///
8588	"Spindle epithelial tumor with thymus-like elements" ///
8589	"Carcinoma showing thymus-like elements" ///
8600	"Thecoma, malignant" ///
8620	"Granulosa cell tumor, malignant" ///
8630	"Androblastoma, malignant" ///
8631	"Sertoli-Leydig cell tumor, poorly differentiated" ///
8634	"Sertoli-Leydig cell, poorly diffn, with heterologous elements" ///
8640	"Sertoli cell carcinoma" ///
8650	"Leydig cell tumor, malignant" ///
8670	"Steroid cell tumor, malignant" ///
8680	"Paraganglioma, malignant" ///
8693	"Extra-adrenal paraganglioma, malignant" ///
8700	"Pheochromocytoma, malignant" ///
8710	"Glomangiosarcoma" ///
8711	"Glomus tumor, malignant" ///
8720	"Malignant melanoma, NOS (except juvenile melanoma)" ///
8721	"Nodular melanoma" ///
8722	"Balloon cell melanoma" ///
8723	"Malignant melanoma, regressing" ///
8728	"Meningeal melanomatosis" ///
8730	"Amelanotic melanoma" ///
8740	"Malignant melanoma in junctional nevus" ///
8741	"Malignant melanoma in precancerous" ///
8742	"Lentigo maligna melanoma" ///
8743	"Superficial spreading melanoma" ///
8744	"Acral lentiginous melanoma, malignant" ///
8745	"Desmoplastic melanoma, malignant" ///
8746	"Mucosal lentiginous melanoma" ///
8761	"Malignant melanoma in giant pigmented nevus" ///
8770	"Mixed epithelioid and spindle cell melanoma" ///
8771	"Epithelioid cell melanoma" ///
8772	"Spindle cell melanoma, NOS" ///
8773	"Spindle cell melanoma, type A" ///
8774	"Spindle cell melanoma, type B" ///
8780	"Blue nevus, malignant" ///
8800	"Sarcoma, NOS" ///
8801	"Spindle cell sarcoma" ///
8802	"Giant cell sarcoma (except of bone)" ///
8803	"Small cell sarcoma" ///
8804	"Epithelioid sarcoma" ///
8805	"Undifferentiated sarcoma" ///
8806	"Desmoplastic small round cell tumor" ///
8810	"Fibrosarcoma, NOS" ///
8811	"Fibromyxosarcoma" ///
8812	"Periosteal fibrosarcoma" ///
8813	"Fascial fibrosarcoma" ///
8814	"Infantile fibrosarcoma" ///
8815	"Solitary fibrous tumor, malignant" ///
8830	"Malignant fibrous histiocytoma" ///
8832	"Dermatofibrosarcoma, NOS" ///
8833	"Pigmented dermatofibrosarcoma protuberans" ///
8840	"Myxosarcoma" ///
8850	"Liposarcoma, NOS" ///
8851	"Liposarcoma, well differentiated" ///
8852	"Myxoid liposarcoma" ///
8853	"Round cell liposarcoma" ///
8854	"Pleomorphic liposarcoma" ///
8855	"Mixed liposarcoma" ///
8857	"Fibroblastic liposarcoma" ///
8858	"Dedifferentiated liposarcoma" ///
8890	"Leiomyosarcoma, NOS" ///
8891	"Epithelioid leiomyosarcoma" ///
8894	"Angiomyosarcoma" ///
8895	"Myosarcoma" ///
8896	"Myxoid leiomyosarcoma" ///
8900	"Rhabdomyosarcoma, NOS" ///
8901	"Pleomorphic rhabdomyosarcoma, adult type" ///
8902	"Mixed type rhabdomyosarcoma" ///
8910	"Embryonal rhabdomyosarcoma, NOS" ///
8912	"Spindle cell rhabdomyosarcoma" ///
8920	"Alveolar rhabdomyosarcoma" ///
8921	"Rhabdomyosarcoma with ganglionic differentiation" ///
8930	"Endometrial stromal sarcoma, NOS" ///
8931	"Endometrial stromal sarcoma, low grade" ///
8933	"Adenosarcoma" ///
8934	"Carcinofibroma" ///
8935	"Stromal sarcoma, NOS" ///
8936	"Gastrointestinal stromal sarcoma" ///
8940	"Mixed tumor, malignant, NOS" ///
8941	"Carcinoma in pleomorphic adenoma" ///
8950	"Mullerian mixed tumor" ///
8951	"Mesodermal mixed tumor" ///
8959	"Malignant cystic nephroma" ///
8960	"Nephroblastoma, NOS" ///
8963	"Malignant rhabdoid tumor" ///
8964	"Clear cell sarcoma of kidney" ///
8970	"Hepatoblastoma" ///
8971	"Pancreatoblastoma" ///
8972	"Pulmonary blastoma" ///
8973	"Pleuropulmonary blastoma" ///
8980	"Carcinosarcoma, NOS" ///
8981	"Carcinosarcoma, embryonal" ///
8982	"Malignant myoepithelioma" ///
8990	"Mesenchymoma, malignant" ///
8991	"Embryonal sarcoma" ///
9000	"Brenner tumor, malignant" ///
9014	"Serous adenocarcinofibroma" ///
9015	"Mucinous adenocarcinofibroma" ///
9020	"Phyllodes tumor, malignant" ///
9040	"Synovial sarcoma, NOS" ///
9041	"Synovial sarcoma, spindle cell" ///
9042	"Synovial sarcoma, epithelioid cell" ///
9043	"Synovial sarcoma, biphasic" ///
9044	"Clear cell sarcoma, NOS (except of kidney)" ///
9050	"Mesothelioma, malignant" ///
9051	"Fibrous mesothelioma, malignant" ///
9052	"Epithelioid mesothelioma, malignant" ///
9053	"Mesothelioma, biphasic, malignant" ///
9060	"Dysgerminoma" ///
9061	"Seminoma, NOS" ///
9062	"Seminoma, anaplastic" ///
9063	"Spermatocytic seminoma" ///
9064	"Germinoma" ///
9065	"Germ cell tumor, nonseminomatous" ///
9070	"Embryonal carcinoma, NOS" ///
9071	"Yolk sac tumor" ///
9072	"Polyembryoma" ///
9080	"Teratoma, malignant, NOS" ///
9081	"Teratocarcinoma" ///
9082	"Malignant teratoma, undifferentiated" ///
9083	"Malignant teratoma, intermediate" ///
9084	"Teratoma with malignant transformation" ///
9085	"Mixed germ cell tumor" ///
9090	"Struma ovarii, malignant" ///
9100	"Choriocarcinoma, NOS" ///
9101	"Choriocarcinoma combined with other germ cell elements" ///
9102	"Malignant teratoma, trophoblastic" ///
9105	"Trophoblastic tumor, epithelioid" ///
9110	"Mesonephroma, malignant" ///
9120	"Hemangiosarcoma" ///
9124	"Kupffer cell sarcoma" ///
9130	"Hemangioendothelioma, malignant" ///
9133	"Epithelioid hemangioendothelioma, malignant" ///
9140	"Kaposi sarcoma" ///
9150	"Hemangiopericytoma, malignant" ///
9170	"Lymphangiosarcoma" ///
9180	"Osteosarcoma, NOS" ///
9181	"Chondroblastic osteosarcoma" ///
9182	"Fibroblastic osteosarcoma" ///
9183	"Telangiectatic osteosarcoma" ///
9184	"Osteosarcoma in Paget disease of bone" ///
9185	"Small cell osteosarcoma" ///
9186	"Central osteosarcoma" ///
9187	"Intraosseous well differentiated osteosarcoma" ///
9192	"Parosteal osteosarcoma" ///
9193	"Periosteal osteosarcoma" ///
9194	"High grade surface osteosarcoma" ///
9195	"Intracortical osteosarcoma" ///
9220	"Chondrosarcoma, NOS" ///
9221	"Juxtacortical chondrosarcoma" ///
9230	"Chondroblastoma, malignant" ///
9231	"Myxoid chondrosarcoma" ///
9240	"Mesenchymal chondrosarcoma" ///
9242	"Clear cell chondrosarcoma" ///
9243	"Dedifferentiated chondrosarcoma" ///
9250	"Giant cell tumor of bone, malignant" ///
9251	"Malignant giant cell tumor of soft parts" ///
9252	"Malignant tenosynovial giant cell tumor" ///
9260	"Ewing sarcoma" ///
9261	"Adamantinoma of long bones" ///
9270	"Odontogenic tumor, malignant" ///
9290	"Ameloblastic odontosarcoma" ///
9310	"Ameloblastoma, malignant" ///
9330	"Ameloblastic fibrosarcoma" ///
9342	"Odontogenic carcinosarcoma" ///
9362	"Pineoblastoma" ///
9364	"Peripheral neuroectodermal tumor" ///
9365	"Askin tumor" ///
9370	"Chordoma, NOS" ///
9371	"Chondroid chordoma" ///
9372	"Dedifferentiated chordoma" ///
9380	"Glioma, malignant" ///
9381	"Gliomatosis cerebri" ///
9382	"Mixed glioma" ///
9390	"Choroid plexus carcinoma" ///
9391	"Ependymoma, NOS" ///
9392	"Ependymoma, anaplastic" ///
9393	"Papillary ependymoma" ///
9400	"Astrocytoma, NOS" ///
9401	"Astrocytoma, anaplastic" ///
9410	"Protoplasmic astrocytoma" ///
9411	"Gemistocytic astrocytoma" ///
9420	"Fibrillary astrocytoma" ///
9423	"Polar spongioblastoma" ///
9424	"Pleomorphic xanthoastrocytoma" ///
9430	"Astroblastoma" ///
9440	"Glioblastoma, NOS" ///
9441	"Giant cell glioblastoma" ///
9442	"Gliosarcoma" ///
9450	"Oligodendroglioma, NOS" ///
9451	"Oligodendroglioma, anaplastic" ///
9460	"Oligodendroblastoma" ///
9470	"Medulloblastoma, NOS" ///
9471	"Desmoplastic nodular medulloblastoma" ///
9472	"Medullomyoblastoma" ///
9473	"Primitive neuroectodermal tumor, NOS" ///
9474	"Large cell medulloblastoma" ///
9480	"Cerebellar sarcoma, NOS" ///
9490	"Ganglioneuroblastoma" ///
9500	"Neuroblastoma, NOS" ///
9501	"Medulloepithelioma, NOS" ///
9502	"Teratoid medulloepithelioma" ///
9503	"Neuroepithelioma, NOS" ///
9504	"Spongioneuroblastoma" ///
9505	"Ganglioglioma, anaplastic" ///
9508	"Atypical teratoid/rhabdoid tumor" ///
9510	"Retinoblastoma, NOS" ///
9511	"Retinoblastoma, differentiated" ///
9512	"Retinoblastoma, undifferentiated" ///
9513	"Retinoblastoma, diffuse" ///
9520	"Olfactory neurogenic tumor" ///
9521	"Olfactory neurocytoma" ///
9522	"Olfactory neuroblastoma" ///
9523	"Olfactory neuroepithelioma" ///
9530	"Meningioma, malignant" ///
9538	"Papillary meningioma" ///
9539	"Meningeal sarcomatosis" ///
9540	"Malignant peripheral nerve sheath tumor" ///
9560	"Neurilemoma, malignant" ///
9561	"Malig. peripheral nerve sheath tumor, rhabdomyoblastic differentiation" ///
9571	"Perineurioma, malignant" ///
9580	"Granular cell tumor, malignant" ///
9581	"Alveolar soft part sarcoma" ///
9590	"Malignant lymphoma, NOS" ///
9591	"Malignant lymphoma, non-Hodgkin, NOS" ///
9596	"Composite Hodgkin and non-Hodgkin lymphoma" ///
9650	"Hodgkin lymphoma, NOS" ///
9651	"Hodgkin lymphoma, lymphocyte-rich" ///
9652	"Hodgkin lymphoma, mixed cellularity, NOS" ///
9653	"Hodgkin lymphoma, lymphocyte depletion, NOS" ///
9654	"Hodgkin lymphoma, lymphocyte depletion, diffuse" ///
9655	"Hodgkin lymphoma, lymphocyte depletion, reticular" ///
9659	"Hodgkin lymphoma, nodular lymphocyte predominantly" ///
9661	"Hodgkin granuloma" ///
9662	"Hodgkin sarcoma" ///
9663	"Hodgkin lymphoma, nodular sclerosis, NOS" ///
9664	"Hodgkin lymphoma, nodular sclerosis, cellular phase" ///
9665	"Hodgkin lymphoma, nodular sclerosis, grade 1" ///
9667	"Hodgkin lymphoma, nodular sclerosis, grade 2" ///
9670	"Malignant lymphoma, small B lymphocytic, NOS" ///
9671	"Malignant lymphoma, lymphoplasmacytic" ///
9673	"Mantle cell lymphoma" ///
9675	"Malignant lymphoma, mixed small and large cell, diffuse" ///
9678	"Primary effusion lymphoma" ///
9679	"Mediastinal large B-cell lymphoma" ///
9680	"Malignant lymphoma, large B-cell, diffuse, NOS" ///
9684	"Malignant lymphoma, large B-cell, diffuse, immunoblastic NOS" ///
9687	"Burkitt lymphoma, NOS" ///
9689	"Splenic marginal zone B-cell lymphoma" ///
9690	"Follicular lymphoma, NOS" ///
9691	"Follicular lymphoma, grade 2" ///
9695	"Follicular lymphoma, grade 1" ///
9698	"Follicular lymphoma, grade 3" ///
9699	"Marginal zone B-cell lymphoma, NOS" ///
9700	"Mycosis fungoides" ///
9701	"Sezary syndrome" ///
9702	"Mature T-cell lymphoma, NOS" ///
9705	"Angioimmunoblastic T-cell lymphoma" ///
9708	"Subcutaneous panniculitis-like T-cell lymphoma" ///
9709	"Cutaneous T-cell lymphoma, NOS" ///
9714	"Anaplastic large cell lymphoma, T cell and Null cell type" ///
9716	"Hepatosplenic (gamma-delta) cell" ///
9717	"Intestinal T-cell lymphoma" ///
9718	"Primary cutaneous CD30+ T-cell lymphoproliferative" ///
9719	"NK/T-cell lymphoma, nasal and nasal-type" ///
9727	"Precursor cell lymphoblastic lymphoma, NOS" ///
9728	"Precursor B-cell lymphoblastic lymphoma" ///
9729	"Precursor T-cell lymphoblastic lymphoma" ///
9731	"Plasmacytoma, NOS" ///
9732	"Multiple myeloma" ///
9733	"Plasma cell leukemia" ///
9734	"Plasmacytoma, extramedullary (not occurring in bone)" ///
9740	"Mast cell sarcoma" ///
9741	"Malignant mastocytosis" ///
9742	"Mast cell leukemia" ///
9750	"Malignant histiocytosis" ///
9754	"Langerhans cell histiocytosis, disseminated" ///
9755	"Histiocytic sarcoma" ///
9756	"Langerhans cell sarcoma" ///
9757	"Interdigitating dendritic cell sarcoma" ///
9758	"Follicular dendritic cell sarcoma" ///
9760	"Immunoproliferative disease, NOS" ///
9761	"Waldenstrom macroglobulinemia" ///
9762	"Heavy chain disease, NOS" ///
9764	"Immunoproliferative small intestinal disease" ///
9800	"Leukemia, NOS" ///
9801	"Acute leukemia, NOS" ///
9805	"Acute biphenotypic leukemia" ///
9811	"B-lymphoblastic leukemia/lymphoma, NOS/Acute lymphoblastic leukemia" ///
9820	"Lymphoid leukemia, NOS" ///
9823	"B-cell chronic lymphocytic leukemia/small lymph" ///
9826	"Burkitt cell leukemia" ///
9827	"Adult T-cell leukemia/lymphoma (HTLV-1 positive)" ///
9832	"Prolymphocytic leukemia, NOS" ///
9833	"Prolymphocytic leukemia, B-cell type" ///
9834	"Prolymphocytic leukemia, T-cell type" ///
9835	"Precursor cell lymphoblastic leukemia, NOS" ///
9836	"Precursor B-cell lymphoblastic leukemia" ///
9837	"Precursor T-cell lymphoblastic leukemia" ///
9840	"Acute myeloid leukemia, M6 type" ///
9860	"Myeloid leukemia, NOS" ///
9861	"Acute myeloid leukemia, NOS" ///
9863	"Chronic myeloid leukemia, NOS" ///
9866	"Acute promyelocytic leukemia, t(15;17)(q22;q11-12)" ///
9867	"Acute myelomonocytic leukemia" ///
9870	"Acute basophilic leukemia" ///
9871	"Acute myeloid leukemia with abnormal marrow eosinophils" ///
9872	"Acute myeloid leukemia, minimal differentiation" ///
9873	"Acute myeloid leukemia without maturation" ///
9874	"Acute myeloid leukemia with maturation" ///
9875	"Chronic myelogenous leukemia, BCR/ABL" ///
9876	"Atypical chronic myeloid leukemia" ///
9891	"Acute monocytic leukemia" ///
9895	"Acute myeloid leukemia with multilineage dysplasia" ///
9896	"Acute myeloid leukemia, t(8;21)(q22;q22)" ///
9897	"Acute myeloid leukemia, 11q23 abnormalities" ///
9898	"Myeloid leukemia associated with Down syndrome" ///
9910	"Acute megakaryoblastic leukemia" ///
9920	"Therapy-related acute myeloid leukemia, NOS" ///
9930	"Myeloid sarcoma" ///
9931	"Acute panmyelosis with myelofibrosis" ///
9940	"Hairy cell leukemia" ///
9945	"Chronic myelomonocytic leukemia, NOS" ///
9946	"Juvenile myelomonocytic leukemia" ///
9948	"Aggressive NK-cell leukemia" ///
9950	"Polycythemia vera" ///
9960	"Chronic myeloproliferative disease, NOS (2001-2009 dx)" ///
9961	"Myelosclerosis with myeloid metaplasia" ///
9962	"Essential thrombocythemia" ///
9963	"Chronic neutrophilic leukemia" ///
9964	"Hypereosinophilic syndrome" ///
9975	"(Chronic) Myeloproliferative disease, NOS (2010 onwards dx)" ///
9980	"Refractory anemia" ///
9982	"Refractory anemia with sideroblasts" ///
9983	"Refractory anemia with excess blasts" ///
9984	"Refractory anemia with excess blasts in transformation" ///
9985	"Refractory cytopenia with multilineage dysplasia" ///
9986	"Myelodysplastic syndrome with 5q- syndrome" ///
9987	"Therapy-related myelodysplastic syndrome, NOS" ///
9989	"Myelodysplastic syndrome, NOS" , modify
label values morph morph_lab

** Put variables in order they are to appear
sort siteiarc pid	  
order pid age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath
//order pid cr5id mpseq mptot age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath

count //836

** Export the data into an excel workbook
** Sheet 1 - variable labels
** Sheet 2 - variable values (no labels)
/*
local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid cr5id mpseq mptot age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Labels") firstrow(varlabels) replace

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid cr5id mpseq mptot age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Values") firstrow(variables) nolabel
*/

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Labels") firstrow(varlabels)

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel pid age sex slc dlc dod dodyear dot dotyear topography morph icd10 beh basis siteiarc dd_coddeath using "`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Values") firstrow(variables) nolabel


** Save coded labels and above notes into a Word document
preserve
cls
describe
translate @Results "`datapath'\version09\2-working\describe.txt" ,replace
restore

preserve
cls
label list sex_lab
translate @Results "`datapath'\version09\2-working\sex.txt" ,replace
restore

preserve
cls
label list slc_lab 
translate @Results "`datapath'\version09\2-working\slc.txt" ,replace
restore

preserve
cls
label list beh_lab
translate @Results "`datapath'\version09\2-working\beh.txt" ,replace
restore

preserve
cls
label list basis_lab 
translate @Results "`datapath'\version09\2-working\basis.txt" ,replace
restore

preserve
cls
label list siteiarc_lab
translate @Results "`datapath'\version09\2-working\siteiarc.txt" ,replace
restore

preserve
cls
label list topography_lab
translate @Results "`datapath'\version09\2-working\topography.txt" ,replace
restore

preserve
cls
label list morph_lab
translate @Results "`datapath'\version09\2-working\morph.txt" ,replace
restore

				**********************
				*   MS WORD REPORT   *
				* NOTES + DATA CODES *
				**********************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("BNR-Cancer: Notes + Data Codes"), bold
putdocx paragraph
putdocx text ("Time Period: 2008, 2013-2015") 
putdocx paragraph
putdocx text ("Date Prepared: 14-FEB-2022") 
putdocx paragraph
putdocx text ("Prepared by: Jacqueline Campbell using Stata data release date: 13-Feb-2020")
putdocx paragraph, halign(center)
putdocx text ("Notes"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Exclusions: ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable Multiple Primaries
putdocx textblock end
putdocx textblock begin
(2) Inclusions: Hepatic, gall bladder, pancreatic duodenal, stomach, and colorectal cancers for 2008, 2013-2015 diagnoses ONLY
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Data Dictionary"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Description of Dataset:") ,bold
putdocx textfile "`datapath'\version09\2-working\describe.txt"
putdocx paragraph, halign(center)
putdocx text ("Data Codes"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Sex codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\sex.txt"
putdocx paragraph
putdocx text ("Status at Last Contact codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\slc.txt"
putdocx paragraph
putdocx text ("Basis of Diagnosis codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\basis.txt"
putdocx paragraph
putdocx text ("Behaviour codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\beh.txt"
putdocx pagebreak
putdocx paragraph
putdocx text ("IARC-ICD10 Site codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\siteiarc.txt"
putdocx pagebreak
putdocx paragraph
putdocx text ("CanReg5 Topography codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\topography.txt"
putdocx pagebreak
putdocx paragraph
putdocx text ("CanReg5 Morphology codes:") ,bold
putdocx textfile "`datapath'\version09\2-working\morph.txt"

putdocx save "`datapath'\version09\3-output\2022-02-14_notes + codes.docx", replace
putdocx clear


** For 2015 onwards using internationally reportable standards, as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
** Save this corrected dataset with reportable cases
save "`datapath'\version09\3-output\2008_2013-2015_dr_ngreaves", replace
label data "2008,2013-2015 BNR-Cancer analysed data - Limited Non-survival Data Request Dataset"
note: TS This dataset was used for 2022 data request for Natalie Greaves
note: TS Excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

/*
  mkdir c:/results

  cd c:/results

local listdate = string( d(`c(current_date)'), "%dCYND" )
asdoc labelbook, save(c:/NGreaves_`listdate'.xlsx, sheet("Labelbook")) replace

local listdate = string( d(`c(current_date)'), "%dCYND" )
asdocx codebook, save("`datapath'\version09\3-output\2008_2013-2015_NGreaves_`listdate'.xlsx", sheet("Codebook")) replace
*/
/*
save "`datapath'\version09\3-output\2008_2013-2015_dr_ngreaves", replace

preserve

uselabel
describe
list

drop trunc
rename value labelvalue
label var labelvalue "Label's Coded Value"
rename label labelvalname
label var labelvalname "Label's Named Value"
rename lname labelname
label var labelname "Name of Label"

keep if labelname=="basis_lab"|labelname=="beh_lab"|labelname=="sex_lab"|labelname=="siteiarc_lab"|labelname=="slc_lab"

				**********************
				*   MS WORD REPORT   *
				* NOTES + DATA CODES *
				**********************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("BNR-Cancer: Notes + Data Codes"), bold
putdocx paragraph
putdocx text ("Time Period: 2008, 2013-2015") 
putdocx paragraph
putdocx text ("Date Prepared: 10-FEB-2022") 
putdocx paragraph
putdocx text ("Prepared by: Jacqueline Campbell using Stata data release date: 13-Feb-2020")
putdocx paragraph, halign(center)
putdocx text ("Notes"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Exclusions: ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
putdocx textblock end
putdocx textblock begin
(2) Inclusions: Hepatic, gall bladder, pancreatic duodenal, stomach, and colorectal cancers for 2008, 2013-2015 diagnoses ONLY
putdocx textblock end
putdocx paragraph, halign(center)
rename labelname Name_of_Label
rename labelvalue Coded_Value_of_Label
rename labelvalname Named_Value_of_Label
putdocx table tbl1 = data("Name_of_Label Coded_Value_of_Label Named_Value_of_Label"), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

putdocx save "`datapath'\version09\3-output\2022-02-10_notes + codes.docx", replace
putdocx clear

restore
stop
** For 2015 onwards using internationally reportable standards, as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
** Save this corrected dataset with reportable cases
save "`datapath'\version09\3-output\2008_2013-2015_dr_ngreaves", replace
label data "2008,2013-2015 BNR-Cancer analysed data - Limited Non-survival Data Request Dataset"
note: TS This dataset was used for 2022 data request for Natalie Greaves
note: TS Excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
*/
