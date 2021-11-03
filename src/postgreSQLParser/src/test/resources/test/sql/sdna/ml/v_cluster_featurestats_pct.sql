drop view if exists dna_ml.v_cluster_featurestats_pct;

create view dna_ml.v_cluster_featurestats_pct as ( 
    with _temp as (
        select * from (
            select 
                cut_id, 
                variable, 
                classification_label, 
                dna_std_dc_end_result, 
                sum(value) as sum
            from 
                dna_ml.v_cluster_featurestats
            where 
                (variable = 'count' 
                or variable like 'sum%')
            group by grouping sets((variable, cut_id), 
                                   (variable, cut_id, classification_label), 
                                   (variable, cut_id, dna_std_dc_end_result),
                                   (variable, cut_id, classification_label, dna_std_dc_end_result))
            ) a 
        where 
            variable is not null 
            and cut_id is not null 
            and (classification_label is null 
                OR dna_std_dc_end_result is null)
        )

    select 
        a.cut_id, 
        a.variable, 
        a.classification_label, 
        a.dna_std_dc_end_result, 
        value, value*100./nullif(t1.sum,0) as percent_by_result, 
        value*100./nullif(t2.sum,0) as percent_by_label,
        value*100./nullif(t3.sum,0) as percent_by_global
    from 
        dna_ml.v_cluster_featurestats a
    left join 
        _temp t1
    on
        a.cut_id = t1.cut_id
        and a.variable = t1.variable
        and a.classification_label = t1.classification_label
    left join 
        _temp t2
    on
        a.cut_id = t2.cut_id
        and a.variable = t2.variable
        and a.dna_std_dc_end_result = t2.dna_std_dc_end_result
    left join 
        _temp t3
    on
        a.cut_id = t3.cut_id
        and a.variable = t3.variable
    where 
        t2.variable is not null
        and t1.variable is not null
        and t3.variable is not null
        and t3.classification_label is null 
        and t3.dna_std_dc_end_result is null
    order by 
        cut_id, 
        variable, 
        classification_label,
        dna_std_dc_end_result)

