set search_path to mimiciii;

--temp lab table (inner_join with Temp Master table on hadm_id to get hospital admissions with certain lab cohort)
SELECT le.hadm_id, le.subject_id, le.itemid, lit.label, lit.loinc_code, lit.fluid, le.value, le.valueuom, le.flag
FROM labevents le
INNER JOIN d_labitems lit
ON le.itemid = lit.itemid

--temp prescription

	string_agg(dr.drug,',') AS drug_list, string_agg(dr.drug_name_generic,',') AS drug_name_generic_list, string_agg(dr.formulary_drug_cd,',') AS drug_formulary_list
FROM admissions a
LEFT JOIN prescriptions dr
ON a.hadm_id = dr.hadm_id

SELECT hadm_id, proc_icd9_shart_list
FROM master_table

-- temp Master table
SELECT
	a.hadm_id, a.subject_id, a.diagnosis, a.ethnicity, a.insurance, cast(a.dischtime as date) - cast(a.admittime as date)
          AS hadm_id_los, a.hospital_expire_flag, 
	p.gender, p.dob, MIN(ROUND((cast(a.admittime as date)- cast (p.dob as date))/365)) AS patient_age,
	i.icustay_id, i.first_careunit, i.los,
	string_agg(d.icd9_code,',') AS icd9_list, string_agg(di.short_title,',') AS icd9_short_list, string_agg(di.long_title,',') AS icd9_long_list,
	string_agg(pr.icd9_code,',') AS proc_icd9_list, string_agg(pi.short_title,',') AS proc_icd9_shart_list, string_agg(pi.long_title,',') AS proc_icd9_long_list
INTO master_table
FROM admissions a
LEFT JOIN patients p
ON a.subject_id = p.subject_id
LEFT JOIN icustays i
ON a.hadm_id = i.hadm_id
LEFT JOIN diagnoses_icd d
ON a.hadm_id = d.hadm_id
LEFT JOIN d_icd_diagnoses di
ON d.icd9_code = di.icd9_code
LEFT JOIN procedures_icd pr
ON a.hadm_id = pr.hadm_id
LEFT JOIN d_icd_procedures pi
ON pr.icd9_code = pi.icd9_code
GROUP BY a.hadm_id, a.subject_id, a.diagnosis, a.ethnicity, a.insurance, a.dischtime, a.admittime, a.hospital_expire_flag, p.gender, p.dob, 
i.icustay_id, i.first_careunit, i.los

--change death to binary values

--temp HADM_ID Diagnosis code and short&long descriptions						 
select d.hadm_id, string_agg(d.icd9_code, ',') as icd9_list, string_agg(di.short_title, ',') as icd9_short_list, string_agg(di.long_title, ',') as icd9_long_list
from  diagnoses_icd d
LEFT JOIN d_icd_diagnoses di
ON d.icd9_code = di.icd9_code
group by hadm_id
