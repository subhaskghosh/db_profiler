DROP TABLE IF EXISTS DNA_RNF.RNF_MOMENTS;

CREATE TABLE DNA_RNF.RNF_MOMENTS AS
WITH _actions as (
  SELECT action from 
      UNNEST(ARRAY['register', 'visit', 'rsvp', 'attend', 'fill', 'download', 'respond', 
             'refer', 'schedule', 'member', 'invite', 'convert', 'synd', 'click', 
             'open', 'lead gen', 'access']) action
),

_categories as (
    SELECT category from 
    UNNEST(ARRAY['conference', 'booth', 'tradeshow', 'webinar', 'poc', 'trial', 'wp', 
              'white paper', 'content', 'ebook', 'contact sales', 'field', 'event', 'promo', 
              'social', 'channel', 'program', 'asset', 'product interest']) category
)

SELECT
  ROW_NUMBER() OVER (ORDER BY ACTIVITY_DATE, ACCOUNT_ID) as MOMENT_ID,
  -- ROW_NUMBER() OVER (PARTITION BY ACCOUNT_ID, ACTIVITY_DATE, DESCRIPTION) as SAME_MOMENT_ID,
  *
FROM (
  SELECT DISTINCT 
      ACCOUNT_ID::TEXT AS ACCOUNT_ID,
      ACTIVITY_DATE::TIMESTAMP WITHOUT TIME ZONE AS ACTIVITY_DATE,
      CONCAT(action, '__', category) AS MOMENT_DESCRIPTION_KEYWORDS,
      DESCRIPTION,
      LEAD_ID::TEXT as MOMENT_WHO_ID,
      COALESCE(ACTION,NULL) AS ACTION,
      COALESCE(CATEGORY,NULL) AS CATEGORY
  FROM (
    select a.id as account_id, im.*, ml.SFDC_CONTACT_ID as CONTACT_ID
    from 
    dna_etl.mkto_activity_interesting_moment im, dna_etl.mkto_lead ml, dna_etl.sfdc_account a
    where not a.is_deleted::boolean
    and im.lead_id = ml.id and ml.sfdc_account_id = a.id and a.id in (
    select account_id from dna_etl.sfdc_opportunity where not is_deleted::boolean
    )
  ) T
  LEFT JOIN _actions
  ON 
      description ILIKE '%'||action||'%' 
  LEFT JOIN _categories
  ON 
      description ILIKE '%'||category||'%'
) _temp;