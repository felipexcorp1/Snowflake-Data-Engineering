CREATE OR REPLACE VIEW truck_franchise AS(
SELECT
    t.*,
    f.first_name AS franchisee_first_name,
    f.last_name AS franchisee_last_name
FROM tasty_bytes.raw_pos.truck t
JOIN tasty_bytes.raw_pos.franchise f
    ON t.franchise_id = f.franchise_id
    );


SELECT * FROM truck_franchise WHERE FRANCHISEE_FIRST_NAME = 'Sara';

describe view tasty_bytes.raw_pos.truck;

drop view truck_franchise;

CREATE OR REPLACE DYNAMIC TABLE tasty_bytes.raw_pos.truck_franchise_dynamic
  TARGET_LAG = '1 minute'
  WAREHOUSE = COMPUTE_WH
  AS
SELECT
    t.*,
    f.first_name AS franchisee_first_name,
    f.last_name AS franchisee_last_name
FROM tasty_bytes.raw_pos.truck t
JOIN tasty_bytes.raw_pos.franchise f
    ON t.franchise_id = f.franchise_id

    ;

CREATE OR REPLACE DYNAMIC TABLE test_database.test_schema.nissan 
TARGET_LAG = '5 minutes' 
WAREHOUSE = compute_wh 
AS SELECT t.* 
FROM tasty_bytes.raw_pos.truck t 
WHERE t.make = 'Nissan';

select * from test_database.test_schema.nissan;

drop dynamic table test_database.test_schema.nissan;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ
FROM TASTY_BYTES.RAW_POS.MENU;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ:menu_item_health_metrics
FROM TASTY_BYTES.RAW_POS.MENU;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ:menu_item_health_metrics:ingredients
FROM TASTY_BYTES.RAW_POS.MENU;


SELECT MENU_ITEM_HEALTH_METRICS_OBJ:menu_item_id
FROM TASTY_BYTES.RAW_POS.MENU;


SELECT MENU_ITEM_HEALTH_METRICS_OBJ:ingredients
FROM TASTY_BYTES.RAW_POS.MENU;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ
FROM TASTY_BYTES.RAW_POS.MENU



;

descriBE table TASTY_BYTES.RAW_POS.MENU;

SELECT TYPEOF(MENU_ITEM_HEALTH_METRICS_OBJ) FROM TASTY_BYTES.RAW_POS.MENU;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients'][0]
FROM tasty_bytes.raw_pos.menu
WHERE MENU_ITEM_NAME = 'Mango Sticky Rice';


SHOW SECRETS;

DROP SECRET GITHUB_PAT_SECRET;
DROP SECRET GITHUB_SECRET;
DROP SECRET github_pat_secret_2;
DROP SECRET github_pat_secret_3;
DROP SECRET github_secret;

SHOW API INTEGRATIONS;
DROP API INTEGRATION "Snowflake-Data-Engineering";
SHOW GIT REPOSITORIES;