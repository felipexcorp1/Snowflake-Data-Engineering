    CREATE TABLE tasty_bytes.raw_pos.truck_dev
        CLONE tasty_bytes.raw_pos.truck;
    SELECT * FROM tasty_bytes.raw_pos.truck_dev;
    SET saved_query_id = LAST_QUERY_ID();
    SET saved_timestamp = CURRENT_TIMESTAMP;
    UPDATE tasty_bytes.raw_pos.truck_dev t
        SET t.year = (YEAR(CURRENT_DATE()) -1000);

    SHOW VARIABLES;

select * from tasty_bytes.raw_pos.truck;


SELECT * FROM tasty_bytes.raw_pos.truck_dev
AT(TIMESTAMP => $saved_timestamp);


SELECT * FROM tasty_bytes.raw_pos.truck_dev
BEFORE(STATEMENT => $saved_query_id);

-- Transient tables

drop table tasty_bytes.raw_pos.truck_dev;

CREATE TRANSIENT TABLE tasty_bytes.raw_pos.truck_TRANSIENT
CLONE tasty_bytes.raw_pos.truck;

CREATE TEMPORARY TABLE tasty_bytes.raw_pos.truck_TEMPORARY
CLONE tasty_bytes.raw_pos.truck;


SHOW TABLES LIKE 'truck%';


ALTER TABLE tasty_bytes.raw_pos.truck           SET DATA_RETENTION_TIME_IN_DAYS = 90;
ALTER TABLE tasty_bytes.raw_pos.truck_TRANSIENT SET DATA_RETENTION_TIME_IN_DAYS = 90;
ALTER TABLE tasty_bytes.raw_pos.truck_TEMPORARY SET DATA_RETENTION_TIME_IN_DAYS = 90;

ALTER TABLE tasty_bytes.raw_pos.truck_TRANSIENT SET DATA_RETENTION_TIME_IN_DAYS = 0;
ALTER TABLE tasty_bytes.raw_pos.truck_TEMPORARY SET DATA_RETENTION_TIME_IN_DAYS = 0;


SELECT * FROM TASTY_BYTES.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE (TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK')
AND TABLE_CATALOG = 'TASTY_BYTES';


SHOW RESOURCE MONITORS;
SHOW FUNCTIONS;
SHOW FUNCTIONS LIKE 'MIN_MENU_PRICE';

CREATE FUNCTION MIN_MENU_PRICE()
RETURNS NUMBER(5,2)
AS
$$
	SELECT MIN(SALE_PRICE_USD) FROM TASTY_BYTES.RAW_POS.MENU
$$
;

SELECT MIN_MENU_PRICE();


CREATE FUNCTION menu_prices_below(price_ceiling NUMBER)
RETURNS TABLE ( ITEM VARCHAR,
                PRICE NUMBER)
AS
$$
	SELECT MENU_ITEM_NAME, SALE_PRICE_USD
    FROM TASTY_BYTES.RAW_POS.MENU
    WHERE SALE_PRICE_USD < price_ceiling
    ORDER BY 2 DESC
$$
;

SELECT * FROM TABLE(menu_prices_below(3));