USE ROLE accountadmin;
CREATE DATABASE course_repo;
USE SCHEMA public;

-- Create credentials
CREATE OR REPLACE SECRET course_repo.public.github_pat
  TYPE = password
  USERNAME = 'felipexcorp1'
  PASSWORD = '';

-- Create the API integration
CREATE OR REPLACE API INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('') -- URL to your GitHub profile
  ALLOWED_AUTHENTICATION_SECRETS = ()
  ENABLED = TRUE;

-- Create the git repository object
CREATE OR REPLACE GIT REPOSITORY course_repo.public.advanced_data_engineering_snowflake
  API_INTEGRATION =  -- Name of the API integration defined above
  ORIGIN = '' -- Insert URL of forked repo
  GIT_CREDENTIALS = ;

-- List the git repositories
SHOW GIT REPOSITORIES;
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