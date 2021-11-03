DROP TABLE IF EXISTS sandbox_sv.cluster_powerscore;

CREATE TABLE sandbox_sv.cluster_powerscore(
      cut_id INT,
      classification_label INT,
      category VARCHAR,
      subcategory VARCHAR,
      score double precision);