drop table dna_ml.power_score_test;
create table dna_ml.power_score_test(
      cut_id VARCHAR,
      classification_label INT,
      category VARCHAR,
      subcategory VARCHAR,
      score double precision);
        
insert into dna_ml.power_score_test (cut_id, classification_label, category,
      subcategory,
      score)
values
(NULL,0,'Induatry','Education - Higher Ed',0.756715),
(NULL,0,'Induatry','Financial',0.401337),
(NULL,0,'Induatry','Healthcare Providers',0.295602),
(NULL,0,'Induatry','Manufacturing',0.936593),
(NULL,0,'Induatry','Services',4.722398),
(NULL,0,'Induatry','Wholesale Trade',0.000000),
(NULL,1,'Induatry','Education - Higher Ed',0.111503),
(NULL,1,'Induatry','Financial',0.371684),
(NULL,1,'Induatry','Healthcare Providers',0.000000),
(NULL,1,'Induatry','Manufacturing',0.046840),
(NULL,1,'Induatry','Services',0.375208),
(NULL,1,'Induatry','Wholesale Trade',0.043728),
(NULL,2,'Induatry','Education - Higher Ed',0.000000),
(NULL,2,'Induatry','Financial',4.809938),
(NULL,2,'Induatry','Healthcare Providers',5.420250),
(NULL,2,'Induatry','Manufacturing',1.906014),
(NULL,2,'Induatry','Services',12.100550),
(NULL,2,'Induatry','Wholesale Trade',2.102171)