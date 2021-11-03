DROP TABLE IF EXISTS dna_rnf.rnf_opportunity_history; 
CREATE TABLE dna_rnf.rnf_opportunity_history AS (
    SELECT 
        opportunity_id, 
        stage_name, 
        created_date as current_stage_start_date, 
        lead(created_date) over (partition by opportunity_id ORDER BY created_date) AS next_stage_start_date,
        lead(stage_name) over (partition by opportunity_id ORDER BY created_date) AS next_stage_name 
    FROM (
        SELECT 
            opportunity_id, 
            stage_name, 
            created_date, 
            row_number() over (partition by opportunity_id, stage_name ORDER BY created_date) AS rn 
        FROM dna_etl.sfdc_opportunity_history 
        ) a
    WHERE rn = 1)