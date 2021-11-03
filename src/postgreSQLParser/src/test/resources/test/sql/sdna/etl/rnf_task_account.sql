DROP TABLE IF EXISTS DNA_RNF.RNF_TASK_ACCOUNT;

CREATE TABLE DNA_RNF.RNF_TASK_ACCOUNT AS
SELECT DISTINCT ID::TEXT AS TASK_ID,
    ACCOUNT_ID::TEXT AS ACCOUNT_ID,
    NULL::TEXT AS OPPORTUNITY_ID,
    ACTIVITY_TYPE_C::TEXT AS ACTIVITY_TYPE_C,
    ACTIVITY_DATE::TIMESTAMP WITHOUT TIME ZONE AS ACTIVITY_DATE,
    STATUS::TEXT AS STATUS, 
    TASK_SUBTYPE::TEXT AS TASK_SUBTYPE,
    CREATED_BY_ROLE_NAME_C::TEXT AS CREATED_BY_ROLE_NAME_C,
    WHO_ID::TEXT as WHO_ID
FROM (
select t.* from dna_etl.SFDC_TASK t, dna_etl.SFDC_ACCOUNT a
where not a.is_deleted::boolean and not t.is_deleted::boolean and
t.account_id = a.id and a.id in (
select account_id from dna_etl.SFDC_OPPORTUNITY where not is_deleted::boolean
)) T;