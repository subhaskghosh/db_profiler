DROP TABLE IF EXISTS sandbox_sv.cluster_featurestats;

CREATE TABLE sandbox_sv.cluster_featurestats(
	cut_id INT,
	dna_std_dc_end_result BOOLEAN,
	classification_label INT,
	variable TEXT,
	value DOUBLE PRECISION
);