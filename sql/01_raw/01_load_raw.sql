-- Raw layer: load the SEC Financial Statement Data Sets as delivered.
-- Everything is kept as text here, type casting happens in staging.
-- Source: https://www.sec.gov/data/financial-statement-data-sets

CREATE SCHEMA IF NOT EXISTS raw;

CREATE OR REPLACE TABLE raw.sub AS
SELECT *
FROM read_csv(
    'data/raw/*/sub.txt',
    delim = '\t',
    header = true,
    quote = '"',  -- values containing tabs or quotes are wrapped in double quotes
    all_varchar = true,
    union_by_name = true,
    filename = true
);

CREATE OR REPLACE TABLE raw.num AS
SELECT *
FROM read_csv(
    'data/raw/*/num.txt',
    delim = '\t',
    header = true,
    quote = '"',
    all_varchar = true,
    union_by_name = true,
    filename = true
);