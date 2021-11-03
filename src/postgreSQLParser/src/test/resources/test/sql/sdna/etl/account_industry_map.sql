drop table if exists DNA_RNF.account_industry_map;
create table DNA_RNF.account_industry_map as (
    select column1 as industry_category, column2 as industry_fine from (VALUES
        ('Tech', ARRAY['Communications', 'Electronics', 'Services', 'Technology','Telecommunications']),
        ('Healthcare', ARRAY['Biotechnology', 'Healthcare', 'Healthcare Providers']),
        ('Insurance', ARRAY['Insurance']),
        ('Financial Services', ARRAY['Banking', 'Finance', 'Financial']),
        ('Manufacturing', ARRAY['Engineering', 'Machinery', 'Manufacturing']),
        ('Utilities', ARRAY['Utilities']),
        ('Retail', ARRAY['Apparel', 'Retail']),
        ('Media & Entertainment', ARRAY['Communications & Media', 'Entertainment']),
        ('Education', ARRAY['Education', 'Education - Higher Ed', 'Education - K-12']),
        ('Public Sector', ARRAY['Federal Government', 'Government', 'Local Government', 'State Government']),
        ('Other', ARRAY['Agriculture', 'Commercial', 'Construction', 'Consulting','Energy',
                  'Hospitality', 'Natural Resources', 'Not For Profit', 'Other',
                  'Recreation', 'Special District', 'Transportation', 'Unclassified',
                  'Wholesale Trade'])) v);