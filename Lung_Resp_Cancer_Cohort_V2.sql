set search_path to mimiciii;
SELECT d.subject_id, string_agg(d.icd9_code,',') AS icd9_list, 
		lab.loinc_code, lab.min_value, lab.max_value, 
		m.patient_age, m.gender, m.ethnicity, m.insurance, m.hadm_id_los
		, CASE
			WHEN m.proc_icd9_long_list LIKE '%chemotherapeutic%' THEN '1'
			ELSE '0'
			END AS has_chemo
		, CASE
			WHEN m.proc_icd9_long_list LIKE '%radiotherapeutic%' THEN '1'
			ELSE '0'
			END AS has_radio
		, CASE
			WHEN m.icd9_list LIKE '%1620%' 
			OR m.icd9_list LIKE '%1622%' 
			OR m.icd9_list LIKE '%1623%'
			OR m.icd9_list LIKE '%1624%'
			OR m.icd9_list LIKE '%1625%'
			OR m.icd9_list LIKE '%1628%'
			OR m.icd9_list LIKE '%1629%'
			OR m.icd9_list LIKE '%1970%'
			OR m.icd9_list LIKE '%2312%'
			OR m.icd9_list LIKE '%2357%'
			OR m.icd9_list LIKE '%2391%'
			THEN '1' 
			ELSE '0'
			END AS has_cancer
		, m.hospital_expire_flag 
FROM diagnoses_icd AS d
	INNER JOIN 
	(SELECT le.subject_id, le.itemid, li.loinc_code, MIN(value) AS min_value, MAX(value) AS max_value
		FROM labevents AS le, d_labitems AS li
		WHERE le.itemid = li.itemid
		AND le.itemid IN ('50817','50820','50882','51265','51279','51301')
		GROUP BY 1,2,3) AS lab
		ON d.subject_id = lab.subject_id
	INNER JOIN master_table m
		ON d.subject_id = m.subject_id
		AND d.hadm_id = m.hadm_id
		AND (m.icd9_list LIKE '%1620%' 
			OR m.icd9_list LIKE '%1622%'
			OR m.icd9_list LIKE '%1623%'
			OR m.icd9_list LIKE '%1624%'
			OR m.icd9_list LIKE '%1625%'
			OR m.icd9_list LIKE '%1628%'
			OR m.icd9_list LIKE '%1629%'
			OR m.icd9_list LIKE '%1970%'
			OR m.icd9_list LIKE '%2312%'
			OR m.icd9_list LIKE '%2357%'
			OR m.icd9_list LIKE '%2391%') 
			AND (m.icd9_list NOT LIKE '%25541%'
				 OR m.icd9_list NOT LIKE '%2459%'
				 OR m.icd9_list NOT LIKE '%042%')
		GROUP BY 1,3,4,5,6,7,8,9,10,11,12,13,14
		