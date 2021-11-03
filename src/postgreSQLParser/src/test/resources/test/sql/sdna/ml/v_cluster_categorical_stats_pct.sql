drop view if exists dna_ml.v_cluster_categorical_stats_pct;

create view dna_ml.v_cluster_categorical_stats_pct as ( 
    with _temp as (
        select * from (
            select cut_id, 
                   category,
                   sub_category,
                   variable, 
                   classification_label, 
                   dna_std_dc_end_result, 
                   sum(value) as sum
            from 
                dna_ml.v_cluster_categorical_stats
            group by grouping sets((category, cut_id, variable),
                                   (category, sub_category, cut_id, variable), 
                                   (category, sub_category, cut_id, variable, classification_label), 
                                   (category, sub_category, cut_id, variable, dna_std_dc_end_result),
                                   (category, sub_category, cut_id, variable, classification_label, dna_std_dc_end_result))
            ) a 
        where 
            variable is not null
            and category is not null 
            and cut_id is not null 
            and (classification_label is null 
                OR dna_std_dc_end_result is null)
        )

    select 
        a.cut_id, 
        a.category,
        a.sub_category,  
        a.variable,
        a.classification_label, 
        a.dna_std_dc_end_result, 
        value, value*100./nullif(t1.sum,0) as percent_by_result, 
        value*100./nullif(t2.sum,0) as percent_by_label,
        value*100./nullif(t3.sum,0) as percent_by_subcategory
        -- value*100./nullif(t4.sum,0) as percent_by_category
    from 
        dna_ml.v_cluster_categorical_stats a
    left join 
        _temp t1
    on
        a.cut_id = t1.cut_id
        and a.category = t1.category
        and a.sub_category = t1.sub_category
        and a.variable = t1.variable
        and a.classification_label = t1.classification_label
    left join 
        _temp t2
    on
        a.cut_id = t2.cut_id
        and a.category = t2.category
        and a.sub_category = t2.sub_category
        and a.variable = t2.variable
        and a.dna_std_dc_end_result = t2.dna_std_dc_end_result
    left join 
        _temp t3
    on
        a.cut_id = t3.cut_id
        and a.category = t3.category
        and a.sub_category = t3.sub_category
        and a.variable = t3.variable
    -- left join 
    --     _temp t4
    -- on
    --     a.cut_id = t4.cut_id
    --     and a.category = t4.category
    where 
        t1.category is not null
        and t2.category is not null
        and t3.category is not null
        and t1.variable is not null
        and t2.variable is not null
        and t3.variable is not null
        -- and t4.category is not null
        and t3.classification_label is null 
        and t3.dna_std_dc_end_result is null
    order by 
        cut_id, 
        category, 
        sub_category,
        variable,
        classification_label,
        dna_std_dc_end_result)

