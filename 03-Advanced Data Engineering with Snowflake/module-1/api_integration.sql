USE ROLE accountadmin;
CREATE or replace DATABASE course_repo;
USE SCHEMA public;

-- Create credentials
CREATE OR REPLACE SECRET course_repo.public.github_pat
  TYPE = password
  USERNAME = 'felipexcorp1'
  PASSWORD = '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';

-- Create the API integration
CREATE OR REPLACE API INTEGRATION GIT_API_INTEGRATION_COURSE_3
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/felipexcorp1') -- URL to your GitHub profile
  ALLOWED_AUTHENTICATION_SECRETS = (github_pat)
  ENABLED = TRUE;

-- Create the git repository object
CREATE OR REPLACE GIT REPOSITORY course_repo.public.advanced_data_engineering_snowflake
  API_INTEGRATION =  GIT_API_INTEGRATION_COURSE_3-- Name of the API integration defined above
  ORIGIN = 'https://github.com/felipexcorp1/advanced-data-engineering-snowflake.git' -- Insert URL of forked repo
  GIT_CREDENTIALS = course_repo.public.github_pat;
SHOW GIT REPOSITORIES;

SELECT
    repository_catalog AS DATABASE_NAME,
    repository_schema  AS SCHEMA_NAME,
    repository_name,
    origin,
    created,
    last_altered,
    owner
FROM SNOWFLAKE.ACCOUNT_USAGE.GIT_REPOSITORIES
ORDER BY
    repository_catalog,
    repository_schema,
    repository_name;




SHOW API INTEGRATIONS;

DESCRIBE API INTEGRATION "github_snowflake_integration";


SHOW STAGES IN ACCOUNT;

SHOW GIT REPOSITORIES;
