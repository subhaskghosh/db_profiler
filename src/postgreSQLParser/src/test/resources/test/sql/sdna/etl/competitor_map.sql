drop table if exists DNA_RNF.competitor_map;
create table DNA_RNF.competitor_map as (
    select column1 as competitor_category, column2 as competitor_name from (VALUES
        ('Modern', ARRAY['Cohesity', 'Veeam']),
        ('Traditional', ARRAY['Avamar', 'CommVault', 'DataDomain']),
        ('Other', ARRAY['Actifio','Arcserve','BackupExec','DellEMC DPS (Data Protection Suite)',
          'Druva','ExaGrid','HPE Data Protector \\ MicroFocus Data Protector',
          'IBM Spectrum Protect','IDPA','Microsoft DPM','NetApp(Alta Vault)',
          'NetBackup','Networker','Other','TSM','Unitrends','Zerto']),
        ('No Competitor', ARRAY['Do Nothing', 'No Competitor', 'Not Sure'])) v);