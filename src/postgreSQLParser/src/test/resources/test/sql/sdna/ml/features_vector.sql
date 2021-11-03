drop table if exists dna_ml.features_vector CASCADE; 

create table dna_ml.features_vector as 

with _lead_source_org as (
    select column1 as dna_std_dc_lead_source_org, column2 as dna_std_dc_lead_source_arr from (VALUES
        ('Sales', ARRAY['ISR/Partner Outbound', 'Sales']),
        ('Marketing', ARRAY[ 'Email', 'Field Marketing', 'Lead Gen', 'List Purchase', 'Organic Search', 'Promotion', 'Referral', 'Trade Show', 'Web', 'Webinar']),
        ('Channel', ARRAY['Channel Marketing'])
        ) v

)
, 

_lead_source_mode as (
    select column1 as dna_std_dc_lead_source_mode, column2 as dna_std_dc_lead_source_arr from (VALUES
        ('Sales', ARRAY['ISR/Partner Outbound', 'Sales']),
        ('Digital', ARRAY['Email', 'Lead Gen', 'List Purchase', 'Organic Search', 'Promotion', 'Referral', 'Web', 'Webinar']),
        ('Field', ARRAY['Field Marketing', 'Trade Show']),
        ('Channel', ARRAY['Channel Marketing'])
        ) v
)
,

_lead_source_inbound as (
    select column1 as dna_std_dc_lead_source_inbound, column2 as dna_std_dc_lead_source_arr from (VALUES
        ('Inbound', ARRAY['Organic Search', 'Web']),
        ('Outbound', ARRAY[ 'Channel Marketing', 'Email', 'Field Marketing', 'ISR/Partner Outbound', 'Lead Gen', 'List Purchase', 'Promotion', 'Referral', 'Sales', 'Trade Show', 'Webinar'])
        ) v

)
,

_lead_source_channel as (
    select column1 as dna_std_dc_lead_source_channel, column2 as dna_std_dc_lead_source_arr from (VALUES
        ('Direct', ARRAY['Email', 'Field Marketing', 'ISR/Partner Outbound', 'Lead Gen', 'List Purchase', 'Organic Search', 'Promotion', 'Sales', 'Trade Show', 'Web', 'Webinar']),
        ('Indirect', ARRAY['Channel Marketing', 'Referral'])
        ) v
)
, 

_acc_opp_user as (
    SELECT
        acc.account_id,
        account_created_date,
        dna_std_ac_annual_revenue,
        dna_std_ac_number_of_employees,
        dna_std_ac_industry,
        dna_std_ac_industry_groups,
        dna_custom_ac_owner_theater,
        dna_std_dc_lead_source_org,
        dna_std_dc_lead_source_mode,
        dna_std_dc_lead_source_inbound,
        dna_std_dc_lead_source_channel,
        opp.*,
        opportunity_created_date::timestamp::date - account_created_date::timestamp::date as DNA_STD_DC_MKTG_NURTURE_TIME,
        coalesce(opportunity_closed_date::timestamp::date, CURRENT_DATE) - account_created_date::timestamp::date as DNA_STD_DC_TOTAL_ELAPSED_TIME,
        coalesce(opportunity_closed_date::timestamp::date, CURRENT_DATE) - opportunity_created_date::timestamp::date as DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME,
        dna_custom_ia_end_date_poc::timestamp::date - dna_custom_ia_start_date_poc::timestamp::date as DNA_CUSTOM_DC_DURATION_POC,
        usr.title as usr_title,
        usr.badge_text as usr_badge_text,
        usr.is_active as usr_is_active,
        usr.user_type as usr_user_type,
        usr.manager_id as usr_manager_id,
        usr.contact_id as usr_contact_id,
        usr.partner_type_c as usr_partner_type_c
        -- contact.title as contact_title, 
        -- contact.contact_status_c as contact_status_c,
        -- contact.is_partner_contact_c as contact_partner_contact_c,
        -- contact.lead_source as contact_lead_source,
        -- contact.lead_lifecycle_c as contact_lead_lifecycle_c,
        -- contact.lead_source_most_recent_c as contact_lead_source_most_recent_c
    FROM
        dna_rnf.RNF_ACCOUNT acc
    FULL JOIN 
        dna_rnf.RNF_OPPORTUNITY opp
    ON
        acc.account_id = opportunity_account_id
    LEFT JOIN 
        dna_rnf.RNF_USER usr
    ON    
        owner_id = user_id
    -- LEFT JOIN 
    --     dna_rnf.RNF_CONTACT contact
    -- ON    
    --     acc.account_id = contact.account_id
    --     AND usr.contact_id = contact.contact_id
    LEFT JOIN 
        _lead_source_org
    ON dna_std_dc_lead_source = ANY(_lead_source_org.dna_std_dc_lead_source_arr)
    LEFT JOIN 
        _lead_source_mode
    ON dna_std_dc_lead_source = ANY(_lead_source_mode.dna_std_dc_lead_source_arr)
    LEFT JOIN 
        _lead_source_inbound
    ON dna_std_dc_lead_source = ANY(_lead_source_inbound.dna_std_dc_lead_source_arr)
    LEFT JOIN 
        _lead_source_channel
    ON dna_std_dc_lead_source = ANY(_lead_source_channel.dna_std_dc_lead_source_arr)
    WHERE 
        opportunity_created_date::timestamp::date <= COALESCE(opportunity_closed_date, CURRENT_DATE)
        AND opportunity_created_date is not NULL
) -- select * from _acc_opp_user limit 10
, 

_acc_opp_user_agg as (
    select 
        account_id,
        opportunity_id,
        count(distinct prev_opp_id) as dna_custom_dc_prev_opps_count,
        count(distinct 
                CASE 
                    WHEN prev_opp_result = True 
                    AND prev_closed_date::timestamp::date  < opportunity_created_date::timestamp::date
                THEN prev_opp_id ELSE NULL END) as dna_custom_dc_prev_opps_won_count,
        count(distinct 
                CASE 
                    WHEN prev_opp_result = False 
                    AND prev_closed_date::timestamp::date  < opportunity_created_date::timestamp::date
                THEN prev_opp_id ELSE NULL END) as dna_custom_dc_prev_opps_lost_count
    FROM(
        select 
            a.account_id,
            a.opportunity_id,
            a.opportunity_created_date,
            a.opportunity_closed_date,
            a.dna_std_dc_end_result,
            b.opportunity_id as prev_opp_id,
            b.opportunity_created_date as prev_created_date,
            b.opportunity_closed_date as prev_closed_date,
            b.dna_std_dc_end_result as prev_opp_result
        FROM
            _acc_opp_user a
        CROSS JOIN  
            _acc_opp_user b
        WHERE
            a.account_id = b.account_id
            and a.opportunity_created_date::timestamp::date > b.opportunity_created_date::timestamp::date) _temp
    GROUP BY 
        1,2
)
,

_events as (
    select 
        o.account_id, 
        opportunity_id,
        event_id,
        event_who_id::text as event_who_id,
        event_type,
        usr_title,
        usr_badge_text,
        usr_is_active,
        usr_partner_type_c,
        account_created_date,
        opportunity_created_date,
        opportunity_closed_date,
        activity_date_time::date as event_date,
        DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME,
        DNA_STD_DC_MKTG_NURTURE_TIME,
        c.title as contact_title, 
        c.contact_status_c as contact_status_c,
        c.is_partner_contact_c as contact_partner_contact_c,
        c.lead_source as contact_lead_source,
        c.lead_lifecycle_c as contact_lead_lifecycle_c,
        c.lead_source_most_recent_c as contact_lead_source_most_recent_c
    from
        _acc_opp_user o
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

) -- select * from _events limit 100; 
, 

_events_agg as (
    select 
        account_id,
        opportunity_id,
        string_agg(CASE WHEN event_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_title ELSE NULL END, '|;|') as usr_titles_events,
        string_agg(CASE WHEN event_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_badge_text ELSE NULL END, '|;|') as usr_badges_events,
        string_agg(CASE WHEN event_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_is_active::text ELSE NULL END, '|;|') as usr_active_events,
        string_agg(CASE WHEN event_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_partner_type_c ELSE NULL END, '|;|') as usr_partner_events,
        string_agg(CASE WHEN event_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN contact_title ELSE NULL END, '|;|') as contact_titles_events,
        string_agg(event_type, '|;|') as agg_event_type_total,
        string_agg(CASE WHEN event_date::timestamp::date < opportunity_created_date::timestamp::date 
              THEN event_type ELSE NULL END, '|;|') as agg_event_type_before_oppty,
        string_agg(CASE WHEN event_date::timestamp::date >= opportunity_created_date
              AND event_date::timestamp::date <= opportunity_closed_date 
              THEN event_type ELSE NULL END, '|,|') as agg_event_type_after_oppty,
        count(distinct event_id) as DNA_STD_DC_EVENTS_TOTAL_IA_COUNT, 
        count(distinct 
              CASE WHEN event_date::timestamp::date < opportunity_created_date::timestamp::date 
              THEN event_id ELSE NULL END) as DNA_STD_DC_EVENTS_IA_BEFORE_OPPTY_COUNT,
        count(distinct 
              CASE WHEN event_date::timestamp::date >= opportunity_created_date
              AND event_date::timestamp::date <= opportunity_closed_date 
              THEN event_id ELSE NULL END) as DNA_STD_DC_EVENTS_IA_AFTER_OPPTY_COUNT,
        count(distinct event_id) / (DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME + DNA_STD_DC_MKTG_NURTURE_TIME)::double precision as DNA_STD_DC_EVENTS_TOTAL_IA_FREQ, 
        (count(distinct 
              CASE WHEN event_date::timestamp::date < opportunity_created_date::timestamp::date
              THEN event_id ELSE NULL END) / (DNA_STD_DC_MKTG_NURTURE_TIME))::double precision as DNA_STD_DC_EVENTS_IA_BEFORE_OPPTY_FREQ,
        (count(distinct 
              CASE WHEN event_date::timestamp::date >= opportunity_created_date
              AND event_date::timestamp::date <= opportunity_closed_date 
              THEN event_id ELSE NULL END) / DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME)::double precision as DNA_STD_DC_EVENTS_IA_AFTER_OPPTY_FREQ
    FROM
        _events
    WHERE
        DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME > 0
        AND DNA_STD_DC_MKTG_NURTURE_TIME > 0
    GROUP BY 1,2, DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME, DNA_STD_DC_MKTG_NURTURE_TIME
)
,

_moments as (
    select 
        account_id, 
        opportunity_id,
        moment_id,
        moment_who_id::text as moment_who_id,
        moment_description_keywords,
        account_created_date,
        opportunity_created_date,
        opportunity_closed_date,
        activity_date as moment_date,
        DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME,
        DNA_STD_DC_MKTG_NURTURE_TIME
    from
        _acc_opp_user
    left join 
        dna_rnf.rnf_moments
    using(account_id)
    WHERE
        activity_date >= opportunity_created_date - interval '1 YEAR'
) -- select * from _moments limit 100; 
, 

_moments_agg as (
    select 
        account_id,
        opportunity_id,
        string_agg(moment_description_keywords, '|;|') as agg_moments_total,
        string_agg(CASE WHEN moment_date::timestamp::date < opportunity_created_date::timestamp::date 
              THEN moment_description_keywords ELSE NULL END, '|;|') as agg_moments_before_oppty,
        string_agg(CASE WHEN moment_date::timestamp::date >= opportunity_created_date
              AND moment_date::timestamp::date <= opportunity_closed_date 
              THEN moment_description_keywords ELSE NULL END, '|,|') as agg_moments_after_oppty,
        count(distinct moment_id) as DNA_STD_DC_MKTG_TOTAL_IA_COUNT, 
        count(distinct 
              CASE WHEN moment_date < opportunity_created_date 
              THEN moment_id ELSE NULL END) as DNA_STD_DC_MKTG_IA_BEFORE_OPPTY_COUNT,
        count(distinct 
              CASE WHEN moment_date::timestamp::date >= opportunity_created_date
              AND moment_date::timestamp::date <= opportunity_closed_date 
              THEN moment_id ELSE NULL END) as DNA_STD_DC_MKTG_IA_AFTER_OPPTY_COUNT,
        (count(distinct moment_id) / (DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME + DNA_STD_DC_MKTG_NURTURE_TIME))::double precision as DNA_STD_DC_MKTG_TOTAL_IA_FREQ, 
        (count(distinct 
              CASE WHEN moment_date < opportunity_created_date 
              THEN moment_id ELSE NULL END) / DNA_STD_DC_MKTG_NURTURE_TIME)::double precision as DNA_STD_DC_MKTG_IA_BEFORE_OPPTY_FREQ,
        (count(distinct 
              CASE WHEN moment_date::timestamp::date >= opportunity_created_date
              AND moment_date::timestamp::date <= opportunity_closed_date 
              THEN moment_id ELSE NULL END) / DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME)::double precision as DNA_STD_DC_MKTG_IA_AFTER_OPPTY_FREQ
    FROM
        _moments
    WHERE
        DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME > 0
        AND DNA_STD_DC_MKTG_NURTURE_TIME > 0
    GROUP BY 1,2, DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME, DNA_STD_DC_MKTG_NURTURE_TIME
)
,

_tasks as (
    select 
        a.account_id, 
        a.opportunity_id,
        task_id,
        who_id::text as task_who_id,
        task_subtype,
        activity_type_c,
        usr_title,
        usr_badge_text,
        usr_is_active,
        usr_partner_type_c,
        account_created_date,
        opportunity_created_date,
        opportunity_closed_date,
        activity_date as task_date,
        DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME,
        DNA_STD_DC_MKTG_NURTURE_TIME,
        c.title as contact_title, 
        c.contact_status_c as contact_status_c,
        c.is_partner_contact_c as contact_partner_contact_c,
        c.lead_source as contact_lead_source,
        c.lead_lifecycle_c as contact_lead_lifecycle_c,
        c.lead_source_most_recent_c as contact_lead_source_most_recent_c
    from
        _acc_opp_user a
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

    UNION ALL 

    select 
        o.account_id, 
        opportunity_id,
        task_id,
        who_id::text as task_who_id,
        task_subtype,
        activity_type_c,
        usr_title,
        usr_badge_text,
        usr_is_active,
        usr_partner_type_c,
        account_created_date,
        opportunity_created_date,
        opportunity_closed_date,
        activity_date as task_date,
        DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME,
        DNA_STD_DC_MKTG_NURTURE_TIME,
        c.title as contact_title, 
        c.contact_status_c as contact_status_c,
        c.is_partner_contact_c as contact_partner_contact_c,
        c.lead_source as contact_lead_source,
        c.lead_lifecycle_c as contact_lead_lifecycle_c,
        c.lead_source_most_recent_c as contact_lead_source_most_recent_c
    from
        _acc_opp_user o 
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

) -- select * from _moments limit 100; 
, 

_tasks_agg as (
    select 
        account_id,
        opportunity_id,
        string_agg(CASE WHEN task_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_title ELSE NULL END, '|;|') as usr_titles_tasks,
        string_agg(CASE WHEN task_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_badge_text ELSE NULL END, '|;|') as usr_badges_tasks,
        string_agg(CASE WHEN task_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_is_active::text ELSE NULL END, '|;|') as usr_active_tasks,
        string_agg(CASE WHEN task_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN usr_partner_type_c ELSE NULL END, '|;|') as usr_partner_tasks,
        string_agg(CASE WHEN task_date::timestamp::date between opportunity_created_date 
            AND opportunity_closed_date THEN contact_title ELSE NULL END, '|;|') as contact_titles_tasks,
        string_agg(task_subtype, '|;|') as agg_task_subtype_total,
        string_agg(CASE WHEN task_date::timestamp::date < opportunity_created_date::timestamp::date 
              THEN task_subtype ELSE NULL END, '|;|') as agg_task_subtype_before_oppty,
        string_agg(CASE WHEN task_date::timestamp::date >= opportunity_created_date
              AND task_date::timestamp::date <= opportunity_closed_date 
              THEN task_subtype ELSE NULL END, '|,|') as agg_task_subtype_after_oppty,
        string_agg(activity_type_c, '|;|') as agg_activity_type_c_total,
        string_agg(CASE WHEN task_date::timestamp::date < opportunity_created_date::timestamp::date 
              THEN activity_type_c ELSE NULL END, '|;|') as agg_activity_type_c_before_oppty,
        string_agg(CASE WHEN task_date::timestamp::date >= opportunity_created_date
              AND task_date::timestamp::date <= opportunity_closed_date 
              THEN activity_type_c ELSE NULL END, '|,|') as agg_activity_type_c_after_oppty,
        count(distinct task_id) as DNA_STD_DC_TASKS_TOTAL_IA_COUNT, 
        count(distinct 
              CASE WHEN task_date::timestamp::date < opportunity_created_date::timestamp::date 
              THEN task_id ELSE NULL END) as DNA_STD_DC_TASKS_IA_BEFORE_OPPTY_COUNT,
        count(distinct 
              CASE WHEN task_date::timestamp::date >= opportunity_created_date
              AND task_date::timestamp::date <= opportunity_closed_date 
              THEN task_id ELSE NULL END) as DNA_STD_DC_TASKS_IA_AFTER_OPPTY_COUNT,
        (count(distinct task_id) / (DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME + DNA_STD_DC_MKTG_NURTURE_TIME))::double precision as DNA_STD_DC_TASKS_TOTAL_IA_FREQ, 
        (count(distinct 
              CASE WHEN task_date::timestamp::date < opportunity_created_date::timestamp::date 
              THEN task_id ELSE NULL END) / DNA_STD_DC_MKTG_NURTURE_TIME)::double precision as DNA_STD_DC_TASKS_IA_BEFORE_OPPTY_FREQ,
        (count(distinct 
              CASE WHEN task_date::timestamp::date >= opportunity_created_date
              AND task_date::timestamp::date <= opportunity_closed_date 
              THEN task_id ELSE NULL END) / DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME)::double precision as DNA_STD_DC_TASKS_IA_AFTER_OPPTY_FREQ
    FROM
        _tasks
    WHERE
        DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME > 0
        AND DNA_STD_DC_MKTG_NURTURE_TIME > 0
    GROUP BY 1,2, DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME, DNA_STD_DC_MKTG_NURTURE_TIME
)
,

_active_contacts_all as (
    select 
        account_id,
        opportunity_id,
        event_who_id as who_id
    from
        _events
    WHERE
        event_date >= opportunity_created_date - interval '1 YEAR'

    UNION ALL 

    select 
        account_id,
        opportunity_id,
        moment_who_id as who_id
    from
        _moments
    WHERE
        moment_date >= opportunity_created_date - interval '1 YEAR'

    UNION ALL 

    select 
        account_id,
        opportunity_id,
        task_who_id as who_id
    from
        _tasks
    WHERE
        task_date >= opportunity_created_date - interval '1 YEAR'
)
,

_active_contacs_distinct as (
    select 
        account_id,
        opportunity_id,
        count(distinct who_id) as dna_custom_dc_contacts_active
    from
        _active_contacts_all
    group by 
        1,2
)

select * from _acc_opp_user
left join _acc_opp_user_agg
using(account_id, opportunity_id)
left join _events_agg
using(account_id, opportunity_id)
left join _moments_agg
using(account_id, opportunity_id)
left join _tasks_agg
using(account_id, opportunity_id)
left join _active_contacs_distinct
using(account_id, opportunity_id)

-- limit 100 