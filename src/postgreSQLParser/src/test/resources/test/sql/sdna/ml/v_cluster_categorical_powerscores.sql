drop view if exists dna_ml.v_cluster_categorical_powerscores;
create or replace view dna_ml.v_cluster_categorical_powerscores as (
with _total_revenue as (
    select 
        cut_id, 
        variable, 
        category,  
        sum(value) as total_pipeline, 
        sum(value*dna_std_dc_end_result::int) as total_revenue, 
        sum(value*dna_std_dc_end_result::int)*1./nullif(sum(value),0) as mean_revenue
    from 
        dna_ml.v_cluster_categorical_stats
    where variable = 'sum'
    group by 1,2,3
),

_rev_share as (
    select 
        cut_id, 
        variable, 
        category,  
        sub_category,
        classification_label,
        sum(value) as total_pipeline, 
        sum(value*dna_std_dc_end_result::int) as total_revenue,
        sum(value*dna_std_dc_end_result::int)*1./t1.total_revenue as total_revenue_share,
        sum(value*dna_std_dc_end_result::int)*1./nullif(sum(value),0) as mean_revenue
    from 
        dna_ml.v_cluster_categorical_stats
    left join 
        _total_revenue t1
    using(cut_id, variable, category)
    where variable = 'sum'
    group by 1,2,3,4,5,t1.total_revenue

),

_ps_unnormalized as (
    select 
        cut_id, 
        category,  
        sub_category,
        classification_label,
        sum(value*dna_std_dc_end_result::int)*total_revenue_share/nullif(sum(value),0) as ps_unnormalized
    from 
        dna_ml.v_cluster_categorical_stats s1
    left join 
        _rev_share r1
    using(cut_id, category, sub_category, classification_label)
    where s1.variable = 'count'
    group by 1,2,3,4,total_revenue_share

),

_baseline as (
    select 
        cut_id, 
        variable,
        sum(value) as total_, 
        sum(value*dna_std_dc_end_result::int) as total_win, 
        sum(value*dna_std_dc_end_result::int)*1./nullif(sum(value),0) as mean
    from
        dna_ml.v_cluster_categorical_stats
    group by 1,2
            
)
select
    cut_id, 
    category,
    sub_category,
    classification_label,
    ps_unnormalized,
    ps_unnormalized / (b1.mean*b2.mean) as power_scores
from
    _ps_unnormalized
left join 
    _baseline b1
using(cut_id)
left join 
    _baseline b2
using(cut_id)
where 
    b1.variable = 'count'
    and b2.variable = 'sum')