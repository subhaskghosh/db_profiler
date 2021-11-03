DROP TABLE IF EXISTS dna_ml.cluster_name;

CREATE TABLE dna_ml.cluster_name(
	cut_id INT,
	classification_label INT,
	label_name TEXT,
	insert_date TIMESTAMP WITHOUT TIME ZONE
)