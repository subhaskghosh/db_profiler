
!define output_dir=file://c:\Salesdna\workspace\data\2020-09-16;
!set variable_substitution=true;


use warehouse DNA_WH;
use database RBK_DB;
use schema OUTBOUND_SALESDNA;

-- 1. Open Opportunities - 2020-6-11 (updated to get region as instructed by Ankur)
COPY INTO @~/salesdna/result/sfdc_opportunity.csv.gz FROM 
(
SELECT o.*, u.TLEVEL_1_C, u.TLEVEL_2_C, u.TLEVEL_3_C, u.TLEVEL_4_C, l.LATTICE_SCORE_C
 FROM pv_sfdc_opportunity o 
  LEFT JOIN PV_SFDC_USER u ON o.OWNER_ID = u.ID 
  LEFT JOIN PV_SFDC_LEAD l ON o.ID = l.CONVERTED_OPPORTUNITY_ID  
 WHERE o.is_deleted=0
)
file_format = (TYPE=CSV compression='gzip' null_if=('') TRIM_SPACE=TRUE 
FIELD_OPTIONALLY_ENCLOSED_BY='"') header=true single=true max_file_size=4900000000 overwrite=true;

-- 2. Accounts for Opportunities
COPY INTO @~/salesdna/result/sfdc_account.csv.gz FROM 
(
select distinct a.* from pv_sfdc_account a
where a.is_deleted=0
)
file_format = (TYPE=CSV compression='gzip' null_if=('') TRIM_SPACE=TRUE 
FIELD_OPTIONALLY_ENCLOSED_BY='"') header=true single=true max_file_size=4900000000 overwrite=true;

-- 3. Tasks for Opportunities ---

COPY INTO @~/salesdna/result/sfdc_task.csv.gz FROM 
(
select o.id as opportunity_id, t.* 
from pv_sfdc_task t, pv_sfdc_opportunity o
where t.is_deleted=0 and o.is_deleted=0 
and t.account_id = o.account_id
and t.what_id = o.id
)
file_format = (TYPE=CSV compression='gzip' null_if=('') TRIM_SPACE=TRUE 
FIELD_OPTIONALLY_ENCLOSED_BY='"') header=true single=true max_file_size=4900000000 overwrite=true;


-- 4. Tasks for accounts associated with opportunities
COPY INTO @~/salesdna/result/sfdc_task_acclevel.csv.gz FROM 
(
select t.* from pv_sfdc_task t, pv_sfdc_account a
where a.is_deleted=0 and t.is_deleted=0 and
t.account_id = a.id and a.id in (
select account_id from pv_sfdc_opportunity where is_deleted = 0
)
)
file_format = (TYPE=CSV compression='gzip' null_if=('') TRIM_SPACE=TRUE 
FIELD_OPTIONALLY_ENCLOSED_BY='"') header=true single=true max_file_size=4900000000 overwrite=true;

-- 5. Interesting moments for accounts associated with opportunities - 2020-04-12 (updated to get contact_id's as well)

COPY INTO @~/salesdna/result/sfdc_moments_acclevel.csv.gz FROM 
(
select a.id as account_id, im.*, ml.SFDC_CONTACT_ID as CONTACT_ID
from 
pv_mkto_activity_interesting_moment im, pv_mkto_lead ml, pv_sfdc_account a
where a.is_deleted=0
and im.lead_id = ml.id and ml.sfdc_account_id = a.id and a.id in (
select account_id from pv_sfdc_opportunity where is_deleted = 0
)
)
file_format = (TYPE=CSV compression='gzip' null_if=('') TRIM_SPACE=TRUE 
FIELD_OPTIONALLY_ENCLOSED_BY='"') header=true single=true max_file_size=4900000000 overwrite=true;


-- 6. Events - 2020-04-30

COPY INTO @~/salesdna/result/sfdc_events.csv.gz FROM 
(
select *
from PV_SFDC_EVENT event
)
file_format = (TYPE=CSV compression='gzip' null_if=('') TRIM_SPACE=TRUE 
FIELD_OPTIONALLY_ENCLOSED_BY='"') header=true single=true max_file_size=4900000000 overwrite=true;


-- 7. Users - 2020-09-23

COPY INTO @~/salesdna/result/sfdc_users.csv.gz FROM 
(
select *
from PV_SFDC_USER user
)
file_format = (TYPE=CSV compression='gzip' null_if=('') TRIM_SPACE=TRUE 
FIELD_OPTIONALLY_ENCLOSED_BY='"') header=true single=true max_file_size=4900000000 overwrite=true;


-- Download the files to local disk from Snowflake staging area

GET @~/salesdna/result/sfdc_opportunity.csv.gz '&output_dir';
GET @~/salesdna/result/sfdc_account.csv.gz '&output_dir';
GET @~/salesdna/result/sfdc_task.csv.gz '&output_dir';

GET @~/salesdna/result/sfdc_task_acclevel.csv.gz '&output_dir';
GET @~/salesdna/result/sfdc_moments_acclevel.csv.gz '&output_dir';

GET @~/salesdna/result/sfdc_events.csv.gz '&output_dir';
GET @~/salesdna/result/sfdc_users.csv.gz '&output_dir';


-- Remove staged data
LIST @~/salesdna;

REMOVE @~/salesdna/result/sfdc_opportunity.csv.gz;
REMOVE @~/salesdna/result/sfdc_account.csv.gz;
REMOVE @~/salesdna/result/sfdc_task.csv.gz;

REMOVE @~/salesdna/result/sfdc_task_acclevel.csv.gz;
REMOVE @~/salesdna/result/sfdc_moments_acclevel.csv.gz;

REMOVE @~/salesdna/result/sfdc_events.csv.gz;
REMOVE @~/salesdna/result/sfdc_users.csv.gz;
