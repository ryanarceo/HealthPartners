-- Description: Create external tables for bronze dataset in BigQuery

CREATE EXTERNAL TABLE IF NOT EXISTS `gcp-health-partners-473103.bronze_dataset.claims` 
OPTIONS (
  format = 'JSON',
  uris = ['gs://db-health-partners/inputdata/claims/*.json']
);

CREATE EXTERNAL TABLE IF NOT EXISTS `gcp-health-partners-473103.bronze_dataset.elig` 
OPTIONS (
  format = 'JSON',
  uris = ['gs://db-health-partners/inputdata/claims/*.json']
);

CREATE EXTERNAL TABLE IF NOT EXISTS `gcp-health-partners-473103.bronze_dataset.acctstruct` 
OPTIONS (
  format = 'JSON',
  uris = ['gs://db-health-partners/inputdata/claims/*.json']
);
