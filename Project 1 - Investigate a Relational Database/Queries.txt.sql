/*
Question 1:  How many times were family movies rented out by category?
(With family movies= Animation or Children or Classics or Comedy or Family or music.
*/

WITH count_rental AS (
    SELECT f.title film_title, c.name category_name, COUNT(rental_id) count_rental
    FROM film f
    JOIN film_category fc
    ON f.film_id=fc.film_id
    JOIN category c
    ON c.category_id=fc.category_id
    JOIN inventory i
    ON i.film_id=f.film_id
    JOIN rental r
    ON i.inventory_id=r.inventory_id
    GROUP BY f.title, c.name
    HAVING c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
)
SELECT category_name, SUM(count_rental) tot_rental_count
FROM count_rental
GROUP BY category_name
ORDER BY tot_rental_count DESC;

/*
Question 2: What is the amount of rental orders for each store per year?
*/
SELECT Date_TRUNC('year', r.rental_date) rental_year, i.store_id store_id, COUNT(*) count_rentals
FROM rental r
JOIN inventory i
ON i.inventory_id=r.inventory_id
GROUP BY rental_year, store_id
ORDER BY count_rentals DESC;

/*Question 3 - Who are the top 10 paying customers ? How much did each paid in total ?
*/
WITH table1 AS(
    SELECT CONCAT(c.first_name,' ', c.last_name) AS full_name,
    SUM(p.amount) total_amount
    FROM customer c
    JOIN payment p
    ON p.customer_id=c.customer_id
    GROUP BY full_name
    ORDER BY total_amount DESC
    LIMIT 10
)

SELECT full_name,total_amount
FROM table1;

/*Question 4 - For the top 10 paying customers,
what is the difference across their monthly payments during 2007 for the top 10 paying customers?
*/

WITH amount_paid AS (
  SELECT DATE_TRUNC('month', p.payment_date) AS monthly_pay,
         CONCAT(c.first_name, ' ', c.last_name) AS full_name,
         p.customer_id AS customer_id,
         COUNT(*) AS pay_count_per_month,
         SUM(p.amount) AS pay_amount
  FROM customer c
  JOIN payment p
    ON c.customer_id = p.customer_id
  GROUP BY 2, 3, 1
  ORDER BY 2, 1
),

top_10_customers AS (
  SELECT customer_id,
         SUM(amount) payment_amount
    FROM payment
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 10
),

amount_paid_top_10 AS (
  SELECT a.monthly_pay,
         a.full_name,
         a.pay_count_per_month,
         a.pay_amount
    FROM amount_paid a
    JOIN top_10_customers t
      ON a.customer_id = t.customer_id
  ORDER BY 2, 1
)

SELECT monthly_pay,
       full_name,
       pay_count_per_month,
       pay_amount,
       LAG(pay_amount) OVER(ORDER BY full_name, monthly_pay) AS lag,
       pay_amount - LAG(pay_amount) OVER(ORDER BY full_name, monthly_pay) AS lag_difference
FROM amount_paid_top_10
