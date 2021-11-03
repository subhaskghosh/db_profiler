DROP TABLE IF EXISTS sandbox_sv.cluster_classification;

CREATE TABLE sandbox_sv.cluster_classification(
	id SERIAL,
	cut_id INT,
	account_id TEXT,
	opportunity_id TEXT, 
	classification_label INT,
	in_training BOOLEAN
);