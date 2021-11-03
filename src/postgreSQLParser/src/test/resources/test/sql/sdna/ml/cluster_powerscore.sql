DROP TABLE IF EXISTS sandbox_sv.powerscore;

CREATE TABLE sandbox_sv.powerscore(
      cut_id INT,
      classification_label INT,
      category VARCHAR,
      subcategory VARCHAR,
      score double precision);