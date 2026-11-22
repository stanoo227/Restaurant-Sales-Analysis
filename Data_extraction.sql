SELECT COUNT(*) AS total_rows
FROM restaurant_project_mysql;

SELECT mesiac, COUNT(*) AS total_rows
FROM restaurant_project_mysql
GROUP BY mesiac;

DESCRIBE restaurant_project_mysql;

SELECT
    menu_group,
    COUNT(*) AS row_count
FROM restaurant_project_mysql
GROUP BY menu_group
ORDER BY row_count DESC;

SELECT *
FROM restaurant_project_mysql
WHERE item IS NULL
   OR menu_group LIKE '(%)'
   OR item = 'Grand Total';
   
   
   SELECT
    mesiac,
    SUM(
        CASE
            WHEN item IS NOT NULL
             AND menu_group NOT LIKE '(%)'
             AND menu_group <> 'Grand Total'
            THEN quantity_sold
            ELSE 0
        END
    ) AS product_quantity,
    SUM(
        CASE
            WHEN item IS NOT NULL
             AND menu_group NOT LIKE '(%)'
             AND menu_group <> 'Grand Total'
            THEN net_sales
            ELSE 0
        END
    ) AS product_net_sales,
    MAX(
        CASE
            WHEN menu_group = 'Grand Total'
            THEN quantity_sold
        END
    ) AS reported_quantity,
    MAX(
        CASE
            WHEN menu_group = 'Grand Total'
            THEN net_sales
        END
    ) AS reported_net_sales
FROM restaurant_project_mysql
GROUP BY mesiac;



SELECT
    mesiac,
    menu_group,
    item,
    quantity_sold,
    refunds,
    net_sales,
    avg_price,
    discount
FROM restaurant_project_mysql
WHERE item IS NULL
ORDER BY mesiac, id;


SELECT *
FROM restaurant_project_mysql
WHERE mesiac = 'jun'
ORDER BY net_sales DESC
LIMIT 10;


SELECT *
FROM restaurant_project_mysql
WHERE mesiac = 'jul'
ORDER BY net_sales DESC
LIMIT 10;


SELECT *
FROM restaurant_project_mysql
WHERE menu_group = 'Grand Total'
   OR item IS NULL
ORDER BY id;


CREATE TABLE restaurant_sales_clean AS
SELECT *
FROM restaurant_project_mysql
WHERE item IS NOT NULL;

SELECT
    mesiac,
    COUNT(*) AS total_products,
    SUM(quantity_sold) AS total_quantity,
    ROUND(SUM(net_sales), 2) AS total_net_sales
FROM restaurant_sales_clean
GROUP BY mesiac;


SELECT
    COUNT(*) AS total_rows,
    SUM(item IS NULL) AS missing_items,
    SUM(quantity_sold IS NULL) AS missing_quantity,
    SUM(net_sales IS NULL) AS missing_net_sales,
    SUM(avg_price IS NULL) AS missing_avg_price,
    SUM(discount IS NULL) AS missing_discount
FROM restaurant_sales_clean;


SELECT
    id,
    COUNT(*) AS duplicate_count
FROM restaurant_sales_clean
GROUP BY id
HAVING COUNT(*) > 1;

SELECT *
FROM restaurant_sales_clean
WHERE quantity_sold < 0
   OR refunds < 0
   OR net_sales < 0
   OR avg_price < 0
   OR discount < 0
   OR (quantity_sold > 0 AND avg_price = 0);
   
   
   SELECT
    mesiac,
    COUNT(*) AS total_products,
    SUM(quantity_sold) AS total_quantity,
    SUM(refunds) AS total_refunds,
    ROUND(SUM(net_sales), 2) AS total_net_sales,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(AVG(avg_price), 2) AS avg_product_price
FROM restaurant_sales_clean
GROUP BY mesiac
ORDER BY
    CASE
        WHEN mesiac = 'jun' THEN 1
        WHEN mesiac = 'jul' THEN 2
    END;
    
    
    
    
    SELECT
    mesiac,
    menu_group,
    COUNT(*) AS product_count,
    SUM(quantity_sold) AS total_quantity,
    ROUND(SUM(net_sales), 2) AS total_net_sales,
    ROUND(SUM(discount), 2) AS total_discount,
    SUM(refunds) AS total_refunds
FROM restaurant_sales_clean
GROUP BY
    mesiac,
    menu_group
ORDER BY
    mesiac,
    total_net_sales DESC;
    
    
    
    SELECT
    mesiac,
    menu_group,
    COUNT(*) AS product_count,
    SUM(quantity_sold) AS total_quantity,
    ROUND(SUM(net_sales), 2) AS total_net_sales,
    ROUND(SUM(discount), 2) AS total_discount,
    SUM(refunds) AS total_refunds
FROM restaurant_sales_clean
GROUP BY mesiac, menu_group
ORDER BY mesiac, total_net_sales DESC;



WITH category_monthly AS (
    SELECT
        menu_group,
        mesiac,
        SUM(quantity_sold) AS total_quantity,
        ROUND(SUM(net_sales), 2) AS total_net_sales,
        ROUND(SUM(discount), 2) AS total_discount
    FROM restaurant_sales_clean
    GROUP BY menu_group, mesiac
)

SELECT
    menu_group,
    ROUND(SUM(CASE
        WHEN mesiac = 'jun' THEN total_net_sales
        ELSE 0
    END), 2) AS june_sales,
    ROUND(SUM(CASE
        WHEN mesiac = 'jul' THEN total_net_sales
        ELSE 0
    END), 2) AS july_sales,
    ROUND(
        SUM(CASE WHEN mesiac = 'jul' THEN total_net_sales ELSE 0 END)
        -
        SUM(CASE WHEN mesiac = 'jun' THEN total_net_sales ELSE 0 END),
    2) AS sales_difference,
    ROUND(
        (
            SUM(CASE WHEN mesiac = 'jul' THEN total_net_sales ELSE 0 END)
            -
            SUM(CASE WHEN mesiac = 'jun' THEN total_net_sales ELSE 0 END)
        )
        / NULLIF(SUM(CASE WHEN mesiac = 'jun' THEN total_net_sales ELSE 0 END), 0)
        * 100,
    2) AS growth_percentage
FROM category_monthly
GROUP BY menu_group
ORDER BY growth_percentage DESC;



SELECT
    menu_group,

    SUM(CASE
        WHEN mesiac = 'jun' THEN quantity_sold
        ELSE 0
    END) AS june_quantity,

    SUM(CASE
        WHEN mesiac = 'jul' THEN quantity_sold
        ELSE 0
    END) AS july_quantity,

    SUM(CASE
        WHEN mesiac = 'jul' THEN quantity_sold
        ELSE 0
    END)
    -
    SUM(CASE
        WHEN mesiac = 'jun' THEN quantity_sold
        ELSE 0
    END) AS quantity_difference

FROM restaurant_sales_clean
GROUP BY menu_group
ORDER BY quantity_difference DESC;



SELECT
    menu_group,

    SUM(CASE WHEN mesiac = 'jun'
        THEN quantity_sold ELSE 0 END) AS june_quantity,

    SUM(CASE WHEN mesiac = 'jul'
        THEN quantity_sold ELSE 0 END) AS july_quantity,

    SUM(CASE WHEN mesiac = 'jul'
        THEN quantity_sold ELSE 0 END)
    -
    SUM(CASE WHEN mesiac = 'jun'
        THEN quantity_sold ELSE 0 END) AS quantity_difference,

    ROUND(
        (
            SUM(CASE WHEN mesiac = 'jul'
                THEN quantity_sold ELSE 0 END)
            -
            SUM(CASE WHEN mesiac = 'jun'
                THEN quantity_sold ELSE 0 END)
        )
        / NULLIF(
            SUM(CASE WHEN mesiac = 'jun'
                THEN quantity_sold ELSE 0 END), 0
        ) * 100,
    2) AS quantity_growth_percentage

FROM restaurant_sales_clean
GROUP BY menu_group
ORDER BY quantity_growth_percentage DESC;


SELECT * FROM restaurant_project_mysql;


SELECT MAX(net_sales) FROM restaurant_sales;
SELECT MAX(net_sales) FROM restaurant_sales_clean;

SELECT id, item, quantity_sold, avg_price, net_sales, mesiac
FROM restaurant_sales
WHERE item LIKE 'RAVU%';

SELECT COUNT(*) FROM restaurant_project_mysql;


SELECT COUNT(*), MAX(net_sales) FROM restaurant_sales;
SELECT COUNT(*), MAX(net_sales) FROM restaurant_sales_clean;

ALTER TABLE restaurant_sales_clean
ADD COLUMN net_sales_fixed DECIMAL(10,2);


UPDATE restaurant_sales_clean
SET net_sales_fixed = CASE
    WHEN quantity_sold * avg_price >= 1000
        THEN ROUND(quantity_sold * avg_price, 2)
    ELSE net_sales
END
WHERE id > 0;


SELECT MAX(net_sales_fixed) FROM restaurant_sales_clean;   -- cca 9 250


SELECT mesiac, ROUND(SUM(net_sales_fixed)) AS tržby, SUM(quantity_sold) AS kusy
FROM restaurant_sales_clean
GROUP BY mesiac;

SELECT id, menu_group, item, mesiac FROM restaurant_sales_clean WHERE id IN (1,2,3);

SELECT * FROM restaurant_sales_clean WHERE item IS NULL;


-- Top 10 položiek podľa tržieb
SELECT item, ROUND(SUM(net_sales_fixed)) AS trzby, SUM(quantity_sold) AS kusy
FROM restaurant_sales_clean
GROUP BY item
ORDER BY trzby DESC
LIMIT 10;


-- Podiel kategórií na tržbách
SELECT menu_group,
       ROUND(SUM(net_sales_fixed)) AS trzby,
       ROUND(100 * SUM(net_sales_fixed) / SUM(SUM(net_sales_fixed)) OVER (), 1) AS podiel_pct
FROM restaurant_sales_clean
GROUP BY menu_group
ORDER BY trzby DESC;

DELETE FROM restaurant_sales_clean WHERE id IN (1,2,3);

-- kontrola: jún 18971 kusov, tržby ≈ 249 857
SELECT mesiac, SUM(quantity_sold) AS kusy, ROUND(SUM(net_sales_fixed)) AS trzby
FROM restaurant_sales_clean GROUP BY mesiac;


SELECT item_clean, ROUND(SUM(net_sales_fixed)) AS trzby, SUM(quantity_sold) AS kusy
FROM restaurant_sales_clean
GROUP BY item_clean
ORDER BY trzby DESC
LIMIT 10;

-- zmena tržieb po kategóriách
SELECT menu_group,
  ROUND(SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END)) AS jun,
  ROUND(SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)) AS jul,
  ROUND(100 * (SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)
        / NULLIF(SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END), 0) - 1), 1) AS zmena_pct
FROM restaurant_sales_clean
GROUP BY menu_group
ORDER BY zmena_pct DESC;


-- položky, ktoré boli len v jednom mesiaci
SELECT item_clean, MIN(mesiac) AS mesiac, ROUND(SUM(net_sales_fixed)) AS trzby
FROM restaurant_sales_clean
GROUP BY item_clean
HAVING COUNT(DISTINCT mesiac) = 1
ORDER BY trzby DESC;


-- 1. pridaj nové stĺpce
ALTER TABLE restaurant_sales_clean
  ADD COLUMN item_clean VARCHAR(150),
  ADD COLUMN is_checkmate TINYINT(1) DEFAULT 0;
  
  UPDATE restaurant_sales_clean
SET is_checkmate = IF(item LIKE 'z:checkmate-%', 1, 0),
    item_clean   = TRIM(REPLACE(REPLACE(item, 'z:checkmate-', ''), ' ,', ','))
WHERE id > 0;


-- 3. oprav názvy skupín
UPDATE restaurant_sales_clean
SET menu_group = 'Senso Creations - Hot Food'
WHERE menu_group = 'Senso Creations - Hot Foo';

UPDATE restaurant_sales_clean
SET menu_group = 'Senso Creations - Sushi'
WHERE menu_group = 'Sushi - Senso Creations';

SELECT item, item_clean, is_checkmate
FROM restaurant_sales_clean
WHERE item LIKE 'z:checkmate-%' LIMIT 5;


SELECT DISTINCT item_clean FROM restaurant_sales_clean
WHERE is_checkmate = 1
  AND item_clean NOT IN (SELECT item FROM restaurant_sales_clean WHERE is_checkmate = 0);



SELECT item_clean, ROUND(SUM(net_sales_fixed)) AS trzby, SUM(quantity_sold) AS kusy
FROM restaurant_sales_clean
GROUP BY item_clean
ORDER BY trzby DESC
LIMIT 10;


SELECT item_clean, MIN(mesiac) AS mesiac, ROUND(SUM(net_sales_fixed)) AS trzby
FROM restaurant_sales_clean
GROUP BY item_clean
HAVING COUNT(DISTINCT mesiac) = 1
ORDER BY trzby DESC;


SELECT DISTINCT item_clean
FROM restaurant_sales_clean
WHERE is_checkmate = 1
  AND item_clean NOT IN (SELECT item FROM restaurant_sales_clean WHERE is_checkmate = 0);
  
  
  SELECT is_checkmate, COUNT(*) AS riadky, ROUND(SUM(net_sales_fixed)) AS trzby
FROM restaurant_sales_clean
GROUP BY is_checkmate;


SELECT menu_group, COUNT(*) FROM restaurant_sales_clean
WHERE menu_group LIKE 'Senso%' OR menu_group LIKE 'Sushi%'
GROUP BY menu_group;


ALTER TABLE restaurant_sales_clean ADD COLUMN item_key VARCHAR(150);

UPDATE restaurant_sales_clean
SET item_key = LOWER(TRIM(REGEXP_REPLACE(
                 REGEXP_REPLACE(item_clean, '\\([VGF, ]+\\)', ''),
               '[*.]', '')))
WHERE id > 0;


SELECT item_clean, MIN(mesiac) AS mesiac, ROUND(SUM(net_sales_fixed)) AS trzby
FROM restaurant_sales_clean
WHERE menu_group NOT LIKE '%Wine'
GROUP BY item_clean
HAVING COUNT(DISTINCT mesiac) = 1
ORDER BY trzby DESC;


SELECT item_key,
  ROUND(SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END)) AS jun,
  ROUND(SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)) AS jul,
  ROUND(SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)
      - SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END)) AS rozdiel
FROM restaurant_sales_clean
GROUP BY item_key
HAVING COUNT(DISTINCT mesiac) = 2
ORDER BY rozdiel ASC
LIMIT 15;



SELECT is_checkmate,
       COUNT(*) AS riadky,
       SUM(quantity_sold) AS kusy,
       ROUND(SUM(net_sales_fixed)) AS trzby
FROM restaurant_sales_clean
GROUP BY is_checkmate;


-- to isté po mesiacoch
SELECT mesiac, is_checkmate,
       COUNT(*) AS riadky,
       ROUND(SUM(net_sales_fixed)) AS trzby
FROM restaurant_sales_clean
GROUP BY mesiac, is_checkmate
ORDER BY mesiac, is_checkmate;


-- Mt. Fuji je zapísaný pod dvoma kľúčmi
UPDATE restaurant_sales_clean
SET item_key = 'mt fuji'
WHERE item_key = 'mt fuji roll' AND id > 0;


SELECT item_key, COUNT(*) FROM restaurant_sales_clean
WHERE item_key LIKE 'mt fuji%' GROUP BY item_key;



SELECT item_key,
  ROUND(SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END)) AS jun,
  ROUND(SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)) AS jul,
  ROUND(SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)
      - SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END)) AS rozdiel
FROM restaurant_sales_clean
WHERE menu_group NOT LIKE '%Wine'
GROUP BY item_key
HAVING COUNT(DISTINCT mesiac) = 2
ORDER BY rozdiel DESC
LIMIT 15;



UPDATE restaurant_sales_clean
SET item_key = LOWER(TRIM(REGEXP_REPLACE(
                 REGEXP_REPLACE(item_clean, '\\([VGF, ]+\\)', ''),
               '[*.]', '')))
WHERE id > 0;



UPDATE restaurant_sales_clean
SET item_key = 'mt fuji'
WHERE item_key = 'mt fuji roll' AND id > 0;



SELECT COUNT(DISTINCT item_key) FROM restaurant_sales_clean;
SELECT item_key, COUNT(*) FROM restaurant_sales_clean
WHERE item_key LIKE 'mt fuji%' GROUP BY item_key;



SELECT item_key,
  ROUND(SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END)) AS jun,
  ROUND(SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)) AS jul,
  ROUND(SUM(CASE WHEN mesiac='jul' THEN net_sales_fixed END)
      - SUM(CASE WHEN mesiac='jun' THEN net_sales_fixed END)) AS rozdiel
FROM restaurant_sales_clean
WHERE menu_group NOT LIKE '%Wine'
GROUP BY item_key
HAVING COUNT(DISTINCT mesiac) = 2
ORDER BY rozdiel ASC
LIMIT 15;


SELECT mesiac,
       SUM(quantity_sold) AS kusy,
       ROUND(SUM(net_sales_fixed)) AS trzby,
       ROUND(SUM(net_sales_fixed) / SUM(quantity_sold), 2) AS priemerna_cena,
       ROUND(SUM(discount)) AS zlavy
FROM restaurant_sales_clean
WHERE item_key = 'spicy wifey'
GROUP BY mesiac;



CREATE OR REPLACE VIEW v_sales_clean AS
SELECT id,
       mesiac AS month_label,
       CASE mesiac WHEN 'jun' THEN 6 WHEN 'jul' THEN 7 END AS month_num,
       menu_group,
       item_clean AS item,
       item_key,
       is_checkmate,
       quantity_sold,
       refunds,
       avg_price,
       discount,
       net_sales_fixed AS net_sales
FROM restaurant_sales_clean;

SELECT * FROM v_sales_clean;

