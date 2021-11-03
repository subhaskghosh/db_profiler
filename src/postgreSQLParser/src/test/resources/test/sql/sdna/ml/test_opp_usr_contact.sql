create table dna_ml.test_opp_usr_contact as 
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
        usr.partner_type_c as usr_partner_type_c,
        contact.title as contact_title, 
        contact.contact_created_date as contact_created_date,
        contact.contact_status_c as contact_status_c,
        contact.is_partner_contact_c as contact_partner_contact_c,
        contact.lead_source as contact_lead_source,
        contact.lead_lifecycle_c as contact_lead_lifecycle_c,
        contact.lead_source_most_recent_c as contact_lead_source_most_recent_c
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
    LEFT JOIN 
        dna_rnf.RNF_CONTACT contact
    ON    
        acc.account_id = contact.account_id
        -- AND usr.contact_id = contact.contact_id
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
        AND opportunity_closed_date::timestamp::date <= contact_created_date::date
) -- select * from _acc_opp_user limit 10

select * from _acc_opp_user; 