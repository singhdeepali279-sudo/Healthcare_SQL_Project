-- Database Setup 
create database Dib_hos_Data;
use dib_hos_data;
select* from diabetic_data;
rename table `discharge description` to discharge_description;
select*from  discharge_description;
select* from outpatient_admission_description;
select * from inpatient_admission_description;

-- Data Validation 
Show tables;
-- Describe Data type
describe diabetic_data;
describe discharge_description;
describe outpatient_admission_description;
describe inpatient_admission_description;

-- Count Details
select count(*) from diabetic_data;
select count(*) from discharge_description;
select count(*) from outpatient_admission_description;
select count(*) from inpatient_admission_description;

-- Data Quality check- Duplicate/NULL/Missing values/Update Value/Patients Visits Count records
select count(*) as Total_rows
from diabetic_data;

select count(distinct Encounter_id) as unique_encounters 
from diabetic_data;

select encounter_id,count(*) as duplicate_count 
from diabetic_data
group by encounter_id
having count(*)>1;

-- patient Visit records 
select patient_nbr, count(*) as Visits
from diabetic_data
group by patient_nbr
having	count(*)>1
order by visits desc;

-- Null value 
select	
count(*) as Total_Rows,
sum(weight is null)as weight_null,
sum(race is null) as race_null,
sum(payer_code is null) as payer_code_null,
sum(medical_specialty)as medical_specialty_null,
sum(diag_1 is null)as diag_1_null,
sum(diag_2 is null) as diag_2_null,
sum(diag_3 is  null)as diag_3_null
from diabetic_data;

select distinct weight from diabetic_data;

select count(*) as missing_weight
from diabetic_data
where weight='?';

select distinct race from diabetic_data;
select count(*) as missing_race from diabetic_data where race ='?';

select distinct payer_code from diabetic_data;
select count(*) as missing_payer_code from diabetic_data where payer_code='?';

select distinct medical_specialty from diabetic_data;
select count(*) as missing_medical_specialty from diabetic_data where medical_specialty = '?';

-- update Missing Value 
set sql_safe_updates=0;
update diabetic_data 
set race ='Unknown'
where race ='?';
select * from diabetic_data;

update diabetic_data
set payer_code ='Unknown'
where payer_code='?';

update diabetic_data 
set medical_specialty='Unknown'
where medical_specialty ='?';

update diabetic_data
set weight ='Unknown'
where weight ='?';

-- Data Profiling
select distinct gender from diabetic_data;

select distinct age from diabetic_data
order by age;

select distinct readmitted 
from diabetic_data;

select distinct diabetesMed
from diabetic_data;

select distinct A1Cresult
from diabetic_data;

select distinct max_glu_serum
from diabetic_data;

-- EDA (Exploratory Data Analysis)
-- Total Number of patients 
select count(*) as Total_Patients
from diabetic_data;

-- Number of Patients by gender 
select gender, count(*) as Total_Patients
from diabetic_data 
group by gender;

-- Number of Patients by Race
select race,count(*) as Total_Patients
from diabetic_data
group by race order by Total_Patients desc;

-- Average Hospital Stay
select avg(time_in_hospital) as avg_hospital_stay
from diabetic_data;

-- Readmission Distribution 
select readmitted ,count(*) as Total_Patients
from diabetic_data
group by readmitted;

-- Which age Group has the highest number of patients?
select age, count(*) as Num_age
from diabetic_data
group by age order by Num_age desc;

-- Which medical specialty treated the most patients?
select medical_specialty, count(*) as Total_Patients
from diabetic_data 
group by medical_specialty 
order by Total_Patients
limit 10;

-- Average Hospital Stay by Gender
select gender, count(*) as Total_Patients
from diabetic_data
group by gender
order by Total_Patients desc limit 10;

-- Which race has the highest average hospital stay?
select race,avg(time_in_hospital) as Avg_hospital_stay
from diabetic_data
group by race order by Avg_hospital_stay desc;

-- How many patients have diabetes medication?
select diabetesMed,count(*) as Total_Patients
from diabetic_data group by diabetesMed;

-- Lookup Table JOINs
-- Admission Type
select
d.patient_nbr,
d.admission_type_id,
a.description as admission_type
from diabetic_data d 
left join inpatient_admission_description a
on d.admission_type_id = a.admission_type_id;

describe inpatient_admission_description;
show create table
inpatient_admission_description;

drop table inpatient_admission_description;
create table inpatient_admission_description
(admission_type_id INT,
description Text);

describe inpatient_admission_description;

-- Discharge Disposition 
select d.patient_nbr,
d.discharge_disposition_id,
dd.description as discharge_disposition
from diabetic_data d
left join discharge_description dd 
on d.discharge_disposition_id =
dd.discharge_disposition_id;

describe discharge_description;
show create table discharge_description;

ALTER TABLE discharge_description
RENAME COLUMN `ï»¿discharge_disposition_id` TO discharge_disposition_id;
show columns from discharge_description;

select* from discharge_description limit 10;
describe outpatient_admission_description;
show create table outpatient_admission_description;

ALTER TABLE outpatient_admission_description
RENAME COLUMN `ï»¿admission_source_id`
TO admission_source_id;

-- Admission Source Lookup JOIN
select 
d.patient_nbr,
d.admission_source_id,
s.description as admission_source
from diabetic_data d
left join outpatient_admission_description s
on d.admission_source_id = s.admission_source_id;

-- Final Lookup Join
select
d.patient_nbr,
d.admission_type_id,
at.description as admission_type,
d.discharge_disposition_id,
dd.description as discharge_disposition,
d.admission_source_id,
ads.description as admission_source 
from diabetic_data d

left join inpatient_admission_description at 
on d.admission_type_id = at.admission_type_id

left join discharge_description dd
on d.discharge_disposition_id =
dd.discharge_disposition_id

left join outpatient_admission_description ads 
on d.admission_source_id = ads.admission_source_id;

select *from diabetic_data;
select * from discharge_description;
select * from inpatient_admission_description;

-- Business Questions?
-- Which admission type has the highest readmission rate?
select at.description as admission_type,
d.readmitted,
count(*) as total_patients from diabetic_data d

left join inpatient_admission_description at 
on d.admission_type_id = at.admission_type_id

group by at.description, d.readmitted
order by at.description,total_patients desc;

-- Which discharge disposition has the highest readmission 
select dd.description as discharge_disposition,
d.readmitted,
count(*) as total_patients
from diabetic_data d

left join discharge_description dd
on d.discharge_disposition_id=dd.discharge_disposition_id

group by dd.description, d.readmitted
order by total_patients desc;

-- Which age group has the highest readmission distribution ?
select age,readmitted,count(*) as total_patients
from diabetic_data
group by age,readmitted 
order by age,total_patients desc;

-- Which medical specialty has the highest readmission?
select 
medical_specialty,readmitted,
count(*) as total_patients
from diabetic_data 
group by medical_specialty,readmitted
order by total_patients desc;

-- Within 30 Days under readmission 
select medical_specialty,
count(*) as Total_readmissions
from diabetic_data
where readmitted='<30'
group by medical_specialty order by total_readmissions desc;

-- Which discharge disposition has the highest readmission?
select 
dd.description as discharge_disposition,
d.readmitted, count(*) as total_patients
from diabetic_data d
left join discharge_description dd
on d.discharge_disposition_id=dd.discharge_disposition_id
group by dd.description, d.readmitted
order by dd.description,total_patients desc;

-- Which diagnosis has thew highest readmission ?
select 
diag_1,
readmitted , count(*) as total_patients
from diabetic_data 
group by diag_1,readmitted 
order by total_patients desc;

desc discharge_description;
select *from discharge_description limit 5; 

-- Time in Hospital Analysis 
select 
time_in_hospital,
readmitted,
count(*) as total_patients 
from diabetic_data
group by time_in_hospital,readmitted
order by time_in_hospital;

-- Readmission analyze by gender
select gender,readmitted,count(*) as total_patients
from diabetic_data
group by gender,readmitted
order by total_patients desc;

-- Readmission analysis by race/Highest rate
select race,readmitted, count(*) as total_patients
from diabetic_data
group by race,readmitted 
order by total_patients desc;

-- Average Hospital Stay by Admission Type
select admission_type_id,avg(time_in_hospital) as avg_stay
from diabetic_data
group by admission_type_id;

-- Average Hospital Stay by Medical Specialty
select medical_specialty,avg(time_in_hospital) as avg_stay
from diabetic_data
group by medical_specialty
order by avg_stay desc;

-- Top 10 Most Common Primary Dx
Select diag_1,count(*) as total_patients
from diabetic_data
group by diag_1
order by total_patients desc limit 10;

-- Top 10 Medical Specialkties by Patient count
select medical_specialty,count(*) as total_patients 
from diabetic_data
group by medical_specialty
order by total_patients desc limit 10;











