WITH monetary AS (
    SELECT 
        olist_orders_dataset.customer_id, 
        SUM(CAST(olist_order_payments_dataset.payment_value AS decimal(10,2))) AS total_spent
    FROM olist_orders_dataset
    INNER JOIN olist_order_payments_dataset
        ON olist_orders_dataset.order_id = olist_order_payments_dataset.order_id
    GROUP BY olist_orders_dataset.customer_id
),
frequency AS (
    SELECT 
        customer_id, 
        COUNT(*) AS order_count
    FROM olist_orders_dataset
    GROUP BY customer_id
),
recency AS (
    SELECT 
        customer_id, 
        DATEDIFF(DAY, MAX(order_purchase_timestamp), '2018-10-18') AS recency
    FROM olist_orders_dataset
    GROUP BY customer_id
),
scores AS (
    SELECT 
        NTILE(4) OVER (ORDER BY total_spent DESC) AS m_score,
        NTILE(4) OVER (ORDER BY order_count DESC) AS f_score,
        NTILE(4) OVER (ORDER BY recency ASC) AS r_score,
        monetary.customer_id,
        total_spent,
        order_count,
        recency
    FROM monetary
    INNER JOIN frequency ON monetary.customer_id = frequency.customer_id
    INNER JOIN recency ON monetary.customer_id = recency.customer_id
)

SELECT 
    customer_id, 
    total_spent, 
    order_count, 
    recency, 
    CAST(m_score AS nvarchar) + CAST(f_score AS nvarchar) + CAST(r_score AS nvarchar) AS rfm_segment
FROM scores