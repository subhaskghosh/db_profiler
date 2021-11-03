create table if not exists dna_ml.classification_20210317 as 

select 
	null as cut_id,
	account_id, 
	opportunity_id,
	classification_label,
	true::boolean as in_training
from 
	dna_ml.rubrik_classification_20210317