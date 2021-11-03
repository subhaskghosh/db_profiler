drop table if exists DNA_RNF.incumbent_map;
create table DNA_RNF.incumbent_map as (
    select column1 as incumbent_category, column2 as incumbent_name from (VALUES
        ('Modern',  ARRAY['Cohesity', 'Rubrik', 'Veeam']),
        ('Traditional',  ARRAY['CommVault','DellEMC Avamar','DellEMC DataDomain','DellEMC Networker',
                'IBM Spectrum Protect','Veritas BackupExec','Veritas NetBackup']),
        ('Other',  ARRAY['Actifio','Arcserve','DellEMC DPS (Data Protection Suite)',
          'DellEMC IDPA','DellEMC PowerProtect','Druva','Exagrid',
          'HPE Data Protector (MicroFocus)','IBM Spectrum Protect (TSM)',
          'Igneous','Microsoft DPM / Azure Backup','NetApp',
          'Other','Unitrends','Zerto']),
        ('No Incumbent',  ARRAY['Greenfield', 'No Incumbent', 'Not Sure'])) v);