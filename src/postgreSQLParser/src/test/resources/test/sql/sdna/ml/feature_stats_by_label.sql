select 
	DNA_CUSTOM_DC_OPPORTUNITY_CLASS_S,
    AVG(DNA_CUSTOM_DC_CONTACTS_ACTIVE) AS DNA_CUSTOM_DC_CONTACTS_ACTIVE,
    AVG(DNA_STD_AC_ANNUAL_REVENUE) AS DNA_STD_AC_ANNUAL_REVENUE,
	AVG(DNA_STD_AC_ANNUAL_REVENUE_KNNImput) AS DNA_STD_AC_ANNUAL_REVENUE_KNNImput,
	AVG(DNA_STD_AC_NUMBER_OF_EMPLOYEES) AS DNA_STD_AC_NUMBER_OF_EMPLOYEES,
    AVG(DNA_STD_AC_NUMBER_OF_EMPLOYEES_KNNImput) AS DNA_STD_AC_NUMBER_OF_EMPLOYEES_KNNImput,
    AVG(DNA_STD_DC_AMOUNT) AS DNA_STD_DC_AMOUNT,
    AVG(DNA_STD_DC_EVENTS_TOTAL_IA_COUNT) AS DNA_STD_DC_EVENTS_TOTAL_IA_COUNT,
    AVG(DNA_STD_DC_MKTG_NURTURE_TIME) AS DNA_STD_DC_MKTG_NURTURE_TIME,
    AVG(DNA_STD_DC_MKTG_TOTAL_IA_COUNT) AS DNA_STD_DC_MKTG_TOTAL_IA_COUNT,
    AVG(DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME) AS DNA_STD_DC_OPPORTUNITY_ELAPSED_TIME,
    AVG(DNA_STD_DC_TASKS_TOTAL_IA_COUNT) AS DNA_STD_DC_TASKS_TOTAL_IA_COUNT,
    AVG(DNA_STD_DC_TOTAL_ELAPSED_TIME) AS DNA_STD_DC_TOTAL_ELAPSED_TIME,
    AVG(PARTNER_LEVEL_OF_INVOLVEMENT_CALC_C) AS PARTNER_LEVEL_OF_INVOLVEMENT_CALC_C,
    AVG(DNA_STD_DC_TASKS_TOTAL_IA_COUNT) AS DNA_STD_DC_TASKS_TOTAL_IA_COUNT,
    AVG(DNA_STD_DC_TOTAL_ELAPSED_TIME) AS DNA_STD_DC_TOTAL_ELAPSED_TIME,
    AVG(PARTNER_LEVEL_OF_INVOLVEMENT_CALC_C) AS PARTNER_LEVEL_OF_INVOLVEMENT_CALC_C
from 
	dna_etl.features_vector_20210112
where
	DNA_STD_AC_ANNUAL_REVENUE between 10000 AND 1000000000000
	AND DNA_STD_AC_NUMBER_OF_EMPLOYEES > 1
	AND DNA_CUSTOM_DC_OPPORTUNITY_CLASS_S != 'error_opp_closed_before_start'
group by 1 
order by 1