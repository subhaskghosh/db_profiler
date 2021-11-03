with _timeline as (
	select 
		activity_date::date as activity_date
	from generate_series('2015-01-01', current_date, '1 day') as activity_date
)
,

_opportunity_open as (
	select
		opportunity_account_id as account_id,
		opportunity_id,
		opportunity_created_date::date as activity_date,
		1 as opp_open,
		NULL::int as opp_close
	from
		opportunities
	right join 
		_timeline 
	on
		opportunity_created_date::date = activity_date
)
,

_opportunity_close as (
	select
		opportunity_account_id as account_id,
		opportunity_id,
		opportunity_closed_date::date as activity_date,
		NULL::int as opp_open,
		1 as opp_close
	from
		opportunities
	right join 
		_timeline 
	on
		opportunity_closed_date::date = activity_date
)
,

_opp_acc_vector as (
	select
		*
	from
		_opportunity_open
	union
	select 
		*
	from
		_opportunity_close
)

select * from _opp_acc_vector order by 1,2,3 limit 100