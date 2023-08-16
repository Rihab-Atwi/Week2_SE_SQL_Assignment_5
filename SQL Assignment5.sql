-- Create a CTE named top_customers that lists the top 10 customers based on the total number of distinct films they've rented.
WITH top_customers AS (
	SELECT
	      se_c.customer_id,
	      se_c.first_name,
	      se_c.last_name,
	      COUNT(DISTINCT se_r.inventory_id) AS total_rentals
	
	FROM 
	    customer AS se_c
	INNER JOIN
	    rental AS se_r ON se_r.customer_id = se_c.customer_id
	GROUP BY
	      se_c.customer_id,
	      se_c.first_name,
	      se_c.last_name
	ORDER BY 
	      total_rentals DESC
	LIMIT 10
)

SELECT * FROM top_customers;
------------------------------------------------------------------------------------------------------------------
--For each customer from top_customers, retrieve their average payment amount and the count of rentals they've made.
WITH top_customers AS (
	SELECT
	      se_c.customer_id,
	      se_c.first_name,
	      se_c.last_name,
	      COUNT(DISTINCT se_r.inventory_id) AS total_rentals
	
	FROM 
	    customer AS se_c
	INNER JOIN
	    rental AS se_r ON se_r.customer_id = se_c.customer_id
	GROUP BY
	      se_c.customer_id,
	      se_c.first_name,
	      se_c.last_name
	ORDER BY 
	      total_rentals DESC
	LIMIT 10
)

SELECT
    se_top_customers.customer_id,
    se_top_customers.first_name,
    se_top_customers.last_name,
    COUNT(se_r.rental_id) AS rental_count,
    AVG(se_p.amount) AS average_payment_amount
FROM
    top_customers as se_top_customers
JOIN
    rental as se_r ON se_top_customers.customer_id = se_r.customer_id
LEFT JOIN
    payment as se_p ON se_r.rental_id = se_p.rental_id
GROUP BY
    se_top_customers.customer_id, se_top_customers.first_name, se_top_customers.last_name
ORDER BY
    rental_count DESC;
------------------------------------------------------------------------------------------------------------------
--Create a Temporary Table named film_inventory that stores film titles and their corresponding available inventory count.
DROP TABLE IF EXISTS film_inventory;
CREATE TEMPORARY TABLE film_inventory AS(
SELECT
    se_f.film_id,
    se_f.title,
    COUNT(se_i.inventory_id) AS available_inventory
FROM
    film AS se_f
INNER JOIN
    inventory AS se_i ON se_f.film_id = se_i.film_id
LEFT OUTER JOIN
    rental AS se_r ON se_i.inventory_id = se_r.inventory_id AND se_r.return_date IS NULL
GROUP BY
    se_f.film_id, se_f.title
	);
SELECT * FROM film_inventory
------------------------------------------------------------------------------------------------------------------
--Retrieve the film title with the lowest available inventory count from the film_inventory table.
SELECT title
FROM film_inventory
ORDER BY available_inventory
LIMIT 1
------------------------------------------------------------------------------------------------------------------
--Create a Temporary Table named store_performance that stores store IDs, revenue, and the average payment amount per rental.

DROP TABLE IF EXISTS store_performance;
CREATE TEMPORARY TABLE store_performance AS(
SELECT
    se_s.store_id,
    SUM(se_p.amount) AS revenue,
    AVG(se_p.amount) AS avg_payment
FROM
    store AS se_s
LEFT OUTER JOIN
    staff AS se_st ON se_s.manager_staff_id = se_st.staff_id
LEFT OUTER JOIN
    payment se_p ON se_st.staff_id  = se_p.staff_id
GROUP BY
    se_s.store_id);
SELECT * FROM store_performance
------------------------------------------------------------------------------------------------------------------

