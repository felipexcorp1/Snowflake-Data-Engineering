


            SELECT 
                DATE,
                PRIMARY_CITY,
                SUM(ORDER_TOTAL) AS  SUM_ORDERS
            FROM 
                TASTY_BYTES.ANALYTICS.ORDERS_V
            WHERE 
                PRIMARY_CITY IN ('Cairo')
                AND YEAR(DATE) BETWEEN 2021  AND 2022
            GROUP BY 
                DATE,
                PRIMARY_CITY
            ORDER BY
                DATE DESC