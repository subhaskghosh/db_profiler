drop table if exists sandbox_sv.opportunity_timeline; 

create table sandbox_sv.opportunity_timeline as (

with _step_size as (
    select 
        interval '1 Month' as time_interval_days
),

_acc_opps as (
    select
        account_id, 
        opportunity_id, 
        account_created_date,
        opportunity_created_date,
        opportunity_closed_date,
        dna_std_dc_end_result,
        dna_std_dc_oppty_stage_name
    from
        dna_ml.features_vector
),

_timeline as (
    select 
        d::date as start_date, 
        (d + _step_size.time_interval_days)::date as end_date
    from
        generate_series((select date_trunc('month', min(account_created_date)) from _acc_opps)::date, current_date, (select time_interval_days from _step_size))d
    cross join 
        _step_size
),

_opps_timeline as (
    select
        start_date,
        end_date,
        account_id,
        opportunity_id,
        opportunity_created_date
    from
        _timeline 
    cross join 
        _acc_opps
    where
        (start_date, end_date) OVERLAPS 
            (opportunity_created_date, coalesce(opportunity_closed_date, current_date))
),

_opps_phase as (
    select 
        start_date,
        end_date,
        account_id,
        opportunity_id,
        stage_name,
        row_number() over (partition by start_date, end_date, account_id, opportunity_id order by stage_name desc) as phase_rank
    from
        _opps_timeline
    left join
        dna_rnf.rnf_opportunity_history
    using(opportunity_id)
    where
        (start_date, end_date) overlaps 
            (current_stage_start_date::date, 
             coalesce(next_stage_start_date::date, 
                      (current_stage_start_date::date - (select time_interval_days from _step_size))::date))
),

_events as (
    select 
        o.account_id, 
        opportunity_id,
        start_date,
        end_date,
        event_id,
        event_who_id::text as event_who_id,
        activity_date_time::date as event_date,
        c.title as contact_title, 
        c.contact_status_c as contact_status_c,
        c.is_partner_contact_c as contact_partner_contact_c,
        c.lead_source as contact_lead_source,
        c.lead_lifecycle_c as contact_lead_lifecycle_c,
        c.lead_source_most_recent_c as contact_lead_source_most_recent_c
    from
        _opps_timeline o
    left join 
        dna_rnf.rnf_event e
    using(account_id)
    left join 
        dna_rnf.rnf_contact c
    ON
        o.account_id = c.account_id
        and e.event_who_id = c.contact_id
    WHERE
        activity_date_time >= opportunity_created_date - interval '1 YEAR'
        AND activity_date_time <= end_date

) -- select * from _events limit 100; 
, 

_events_agg as (
    select 
        account_id,
        opportunity_id,
        start_date,
        end_date,
        string_agg(contact_title, '|;|') as events_titles,
        count(distinct event_id) as events_count
    FROM
        _events
    GROUP BY 1,2,3,4
)
,

_moments as (
    select 
        account_id, 
        opportunity_id,
        start_date,
        end_date,
        moment_id,
        moment_who_id::text as moment_who_id,
        activity_date as moment_date
    from
        _opps_timeline
    left join 
        dna_rnf.rnf_moments
    using(account_id)
    WHERE
        activity_date >= opportunity_created_date - interval '1 YEAR'
        AND activity_date <= end_date
) -- select * from _moments limit 100; 
, 

_moments_agg as (
    select 
        account_id,
        opportunity_id,
        start_date,
        end_date,
        count(distinct moment_id) as moments_count
    FROM
        _moments
    GROUP BY 1,2,3,4
)
,

_tasks as (
    select 
        a.account_id, 
        a.opportunity_id,
        start_date,
        end_date,
        task_id,
        who_id::text as task_who_id,
        activity_date as task_date,
        c.title as contact_title, 
        c.contact_status_c as contact_status_c,
        c.is_partner_contact_c as contact_partner_contact_c,
        c.lead_source as contact_lead_source,
        c.lead_lifecycle_c as contact_lead_lifecycle_c,
        c.lead_source_most_recent_c as contact_lead_source_most_recent_c
    from
        _opps_timeline a
    left join 
        dna_rnf.rnf_task_account e
    using(account_id)
    left join 
        dna_rnf.rnf_contact c
    ON
        a.account_id = c.account_id
        and e.who_id = c.contact_id
    WHERE
        activity_date >= opportunity_created_date - interval '1 YEAR'
        AND activity_date <= end_date

    UNION ALL 

    select 
        o.account_id, 
        opportunity_id,
        start_date,
        end_date,
        task_id,
        who_id::text as task_who_id,
        activity_date as task_date,
        c.title as contact_title, 
        c.contact_status_c as contact_status_c,
        c.is_partner_contact_c as contact_partner_contact_c,
        c.lead_source as contact_lead_source,
        c.lead_lifecycle_c as contact_lead_lifecycle_c,
        c.lead_source_most_recent_c as contact_lead_source_most_recent_c
    from
        _opps_timeline o 
    left join 
        dna_rnf.rnf_task_opportunity e 
    using(account_id, opportunity_id)
    left join 
        dna_rnf.rnf_contact c
    ON
        o.account_id = c.account_id
        and e.who_id = c.contact_id
    WHERE
        activity_date >= opportunity_created_date - interval '1 YEAR'
        AND activity_date <= end_date

) -- select * from _moments limit 100; 
, 

_tasks_agg as (
    select 
        account_id,
        opportunity_id,
        start_date,
        end_date,
        string_agg(contact_title, '|;|') as tasks_titles,
        count(distinct task_id) as tasks_count
    FROM
        _tasks
    GROUP BY 1,2,3,4
)
,

_active_contacts_all as (
    select 
        account_id,
        opportunity_id,
        start_date,
        end_date,
        event_who_id as who_id
    from
        _events

    UNION ALL 

    select 
        account_id,
        opportunity_id,
        start_date,
        end_date,
        moment_who_id as who_id
    from
        _moments

    UNION ALL 

    select 
        account_id,
        opportunity_id,
        start_date,
        end_date,
        task_who_id as who_id
    from
        _tasks
)
,

_active_contacts_distinct as (
    select 
        account_id,
        opportunity_id,
        start_date,
        end_date,
        count(distinct who_id) as active_contacts
    from
        _active_contacts_all
    group by 
        1,2,3,4
)

select 
    a.*,
    f1.account_created_date,
    f1.opportunity_closed_date,
    f1.dna_std_dc_end_result,
    f1.dna_std_dc_oppty_stage_name,
    f2.stage_name,
    coalesce(f3.events_count, 0) as events_count,
    f3.events_titles,
    coalesce(f4.moments_count, 0) as moments_count,
    coalesce(f5.tasks_count, 0) as tasks_count,
    f5.tasks_titles,
    coalesce(f6.active_contacts, 0) as active_contacts
from
    _opps_timeline a
left join 
    _acc_opps f1
using(account_id,
      opportunity_id)
left join   
    _opps_phase f2
using(start_date,
      end_date,
      account_id,
      opportunity_id)
left join 
    _events_agg f3
using(start_date,
      end_date,
      account_id,
      opportunity_id)
left join 
    _moments_agg f4
using(start_date,
      end_date,
      account_id,
      opportunity_id)
left join 
    _tasks_agg f5
using(start_date,
      end_date,
      account_id,
      opportunity_id)
left join 
    _active_contacts_distinct f6
using(start_date,
      end_date,
      account_id,
      opportunity_id)
where
    phase_rank = 1 )

