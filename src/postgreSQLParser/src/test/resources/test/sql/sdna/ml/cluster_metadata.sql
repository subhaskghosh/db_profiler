DROP TABLE IF EXISTS dna_ml.cluster_metadata;

CREATE TABLE dna_ml.cluster_metadata(
	cut_id SERIAL,
	name TEXT,
	run_date TIMESTAMP WITHOUT TIME ZONE,
	cluster_size INT,
	features TEXT,
	hyperparameters TEXT,
	results TEXT,
	notes TEXT,
	insert_date TIMESTAMP WITHOUT TIME ZONE
)