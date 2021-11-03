drop table if exists dna_ml.centroid_features_vector_20210112;
create table if not exists dna_ml.centroid_features_vector_20210112 as 
with
_aggregates as (
    select 
        NULL as cut_id,
        classification_label, 
        dna_std_dc_end_result,
        count(*) as opportunity_count,
        min(dna_std_ac_annual_revenue) as min_dna_std_ac_annual_revenue,
        max(dna_std_ac_annual_revenue) as max_dna_std_ac_annual_revenue,
        avg(dna_std_ac_annual_revenue) as mean_dna_std_ac_annual_revenue,
        sum(dna_std_ac_annual_revenue) as sum_dna_std_ac_annual_revenue,
        min(dna_std_dc_amount) as min_dna_std_dc_amount,
        max(dna_std_dc_amount) as max_dna_std_dc_amount,
        avg(dna_std_dc_amount) as mean_dna_std_dc_amount,
        sum(dna_std_dc_amount) as sum_dna_std_dc_amount,
--      min(dna_custom_dc_sdr_led) as min_dna_custom_dc_sdr_led,
--      max(dna_custom_dc_sdr_led) as max_dna_custom_dc_sdr_led,
--      avg(dna_custom_dc_sdr_led) as mean_dna_custom_dc_sdr_led,
--      sum(dna_custom_dc_sdr_led) as sum_dna_custom_dc_sdr_led,
        min(dna_std_dc_total_elapsed_time) as min_dna_std_dc_total_elapsed_time,
        max(dna_std_dc_total_elapsed_time) as max_dna_std_dc_total_elapsed_time,
        avg(dna_std_dc_total_elapsed_time) as mean_dna_std_dc_total_elapsed_time,
        sum(dna_std_dc_total_elapsed_time) as sum_dna_std_dc_total_elapsed_time,
        min(dna_std_dc_opportunity_elapsed_time) as min_dna_std_dc_opportunity_elapsed_time,
        max(dna_std_dc_opportunity_elapsed_time) as max_dna_std_dc_opportunity_elapsed_time,
        avg(dna_std_dc_opportunity_elapsed_time) as mean_dna_std_dc_opportunity_elapsed_time,
        sum(dna_std_dc_opportunity_elapsed_time) as sum_dna_std_dc_opportunity_elapsed_time,
        min(dna_std_dc_mktg_nurture_time) as min_dna_std_dc_mktg_nurture_time,
        max(dna_std_dc_mktg_nurture_time) as max_dna_std_dc_mktg_nurture_time,
        avg(dna_std_dc_mktg_nurture_time) as mean_dna_std_dc_mktg_nurture_time,
        sum(dna_std_dc_mktg_nurture_time) as sum_dna_std_dc_mktg_nurture_time,
        min(dna_custom_dc_contacts_active) as min_dna_custom_dc_contacts_active,
        max(dna_custom_dc_contacts_active) as max_dna_custom_dc_contacts_active,
        avg(dna_custom_dc_contacts_active) as mean_dna_custom_dc_contacts_active,
        sum(dna_custom_dc_contacts_active) as sum_dna_custom_dc_contacts_active,
        min(dna_std_dc_mktg_ia_before_oppty_count) as min_dna_std_dc_mktg_ia_before_oppty_count,
        max(dna_std_dc_mktg_ia_before_oppty_count) as max_dna_std_dc_mktg_ia_before_oppty_count,
        avg(dna_std_dc_mktg_ia_before_oppty_count) as mean_dna_std_dc_mktg_ia_before_oppty_count,
        sum(dna_std_dc_mktg_ia_before_oppty_count) as sum_dna_std_dc_mktg_ia_before_oppty_count,
        min(dna_std_dc_mktg_ia_after_oppty_count) as min_dna_std_dc_mktg_ia_after_oppty_count,
        max(dna_std_dc_mktg_ia_after_oppty_count) as max_dna_std_dc_mktg_ia_after_oppty_count,
        avg(dna_std_dc_mktg_ia_after_oppty_count) as mean_dna_std_dc_mktg_ia_after_oppty_count,
        sum(dna_std_dc_mktg_ia_after_oppty_count) as sum_dna_std_dc_mktg_ia_after_oppty_count,
        min(dna_std_dc_mktg_total_ia_count) as min_dna_std_dc_mktg_total_ia_count,
        max(dna_std_dc_mktg_total_ia_count) as max_dna_std_dc_mktg_total_ia_count,
        avg(dna_std_dc_mktg_total_ia_count) as mean_dna_std_dc_mktg_total_ia_count,
        sum(dna_std_dc_mktg_total_ia_count) as sum_dna_std_dc_mktg_total_ia_count,
        min(dna_std_dc_tasks_ia_before_oppty_count) as min_dna_std_dc_tasks_ia_before_oppty_count,
        max(dna_std_dc_tasks_ia_before_oppty_count) as max_dna_std_dc_tasks_ia_before_oppty_count,
        avg(dna_std_dc_tasks_ia_before_oppty_count) as mean_dna_std_dc_tasks_ia_before_oppty_count,
        sum(dna_std_dc_tasks_ia_before_oppty_count) as sum_dna_std_dc_tasks_ia_before_oppty_count,
        min(dna_std_dc_tasks_ia_after_oppty_count) as min_dna_std_dc_tasks_ia_after_oppty_count,
        max(dna_std_dc_tasks_ia_after_oppty_count) as max_dna_std_dc_tasks_ia_after_oppty_count,
        avg(dna_std_dc_tasks_ia_after_oppty_count) as mean_dna_std_dc_tasks_ia_after_oppty_count,
        sum(dna_std_dc_tasks_ia_after_oppty_count) as sum_dna_std_dc_tasks_ia_after_oppty_count,
        min(dna_std_dc_tasks_total_ia_count) as min_dna_std_dc_tasks_total_ia_count,
        max(dna_std_dc_tasks_total_ia_count) as max_dna_std_dc_tasks_total_ia_count,
        avg(dna_std_dc_tasks_total_ia_count) as mean_dna_std_dc_tasks_total_ia_count,
        sum(dna_std_dc_tasks_total_ia_count) as sum_dna_std_dc_tasks_total_ia_count,
        min(dna_std_dc_events_ia_before_oppty_count) as min_dna_std_dc_events_ia_before_oppty_count,
        max(dna_std_dc_events_ia_before_oppty_count) as max_dna_std_dc_events_ia_before_oppty_count,
        avg(dna_std_dc_events_ia_before_oppty_count) as mean_dna_std_dc_events_ia_before_oppty_count,
        sum(dna_std_dc_events_ia_before_oppty_count) as sum_dna_std_dc_events_ia_before_oppty_count,
        min(dna_std_dc_events_ia_after_oppty_count) as min_dna_std_dc_events_ia_after_oppty_count,
        max(dna_std_dc_events_ia_after_oppty_count) as max_dna_std_dc_events_ia_after_oppty_count,
        avg(dna_std_dc_events_ia_after_oppty_count) as mean_dna_std_dc_events_ia_after_oppty_count,
        sum(dna_std_dc_events_ia_after_oppty_count) as sum_dna_std_dc_events_ia_after_oppty_count,
        min(dna_std_dc_events_total_ia_count) as min_dna_std_dc_events_total_ia_count,
        max(dna_std_dc_events_total_ia_count) as max_dna_std_dc_events_total_ia_count,
        avg(dna_std_dc_events_total_ia_count) as mean_dna_std_dc_events_total_ia_count,
        sum(dna_std_dc_events_total_ia_count) as sum_dna_std_dc_events_total_ia_count,
        min(dna_custom_dc_duration_poc) as min_dna_custom_dc_duration_poc,
        max(dna_custom_dc_duration_poc) as max_dna_custom_dc_duration_poc,
        avg(dna_custom_dc_duration_poc) as mean_dna_custom_dc_duration_poc,
        sum(dna_custom_dc_duration_poc) as sum_dna_custom_dc_duration_poc,
        percentile_disc(0.5) within group (order by dna_std_ac_annual_revenue) as median_dna_std_ac_annual_revenue,
        percentile_disc(0.5) within group (order by dna_std_dc_amount) as median_dna_std_dc_amount,
--      percentile_disc(0.5) within group (order by dna_custom_dc_sdr_led) as median_dna_custom_dc_sdr_led,
        percentile_disc(0.5) within group (order by dna_std_dc_total_elapsed_time) as median_dna_std_dc_total_elapsed_time,
        percentile_disc(0.5) within group (order by dna_std_dc_opportunity_elapsed_time) as median_dna_std_dc_opportunity_elapsed_time,
        percentile_disc(0.5) within group (order by dna_std_dc_mktg_nurture_time) as median_dna_std_dc_mktg_nurture_time,
        percentile_disc(0.5) within group (order by dna_custom_dc_contacts_active) as median_dna_custom_dc_contacts_active,
        percentile_disc(0.5) within group (order by dna_std_dc_mktg_ia_before_oppty_count) as median_dna_std_dc_mktg_ia_before_oppty_count,
        percentile_disc(0.5) within group (order by dna_std_dc_mktg_ia_after_oppty_count) as median_dna_std_dc_mktg_ia_after_oppty_count,
        percentile_disc(0.5) within group (order by dna_std_dc_mktg_total_ia_count) as median_dna_std_dc_mktg_total_ia_count,
        percentile_disc(0.5) within group (order by dna_std_dc_tasks_ia_before_oppty_count) as median_dna_std_dc_tasks_ia_before_oppty_count,
        percentile_disc(0.5) within group (order by dna_std_dc_tasks_ia_after_oppty_count) as median_dna_std_dc_tasks_ia_after_oppty_count,
        percentile_disc(0.5) within group (order by dna_std_dc_tasks_total_ia_count) as median_dna_std_dc_tasks_total_ia_count,
        percentile_disc(0.5) within group (order by dna_std_dc_events_ia_before_oppty_count) as median_dna_std_dc_events_ia_before_oppty_count,
        percentile_disc(0.5) within group (order by dna_std_dc_events_ia_after_oppty_count) as median_dna_std_dc_events_ia_after_oppty_count,
        percentile_disc(0.5) within group (order by dna_std_dc_events_total_ia_count) as median_dna_std_dc_events_total_ia_count,
        percentile_disc(0.5) within group (order by dna_custom_dc_duration_poc) as median_dna_custom_dc_duration_poc

    from
        dna_ml.features_vector_20210112
    inner join 
        dna_ml.rubrik_classification_20210112
    using(account_id, opportunity_id)
        
    group by 1,2,3
    order by 1,2,3
)
select * from _aggregates;