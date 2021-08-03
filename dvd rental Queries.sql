/* Query 1: set 1 question 1 */
SELECT f.title, c.name, count(rental_id) rental_count
FROM rental r
JOIN inventory i
ON r.inventory_id = i.inventory_id
JOIN film f
ON f.film_id = i.film_id
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON c.category_id = fc.category_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1,2
ORDER BY 2,1;
/* Query 2: set 1 question 2 */
SELECT f.title, c.name category_name, f.rental_duration,
NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
FROM film f
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON c.category_id = fc.category_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');
/* Query 3: set 1 question 3 */
WITH t1 AS (SELECT f.title, c.name category_name, f.rental_duration,
NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
FROM film f
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON c.category_id = fc.category_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))

SELECT category_name, standard_quartile,count(*)
FROM t1
GROUP BY 1,2
ORDER BY 1,2;
/* Query 4: set 2 question 1 */
SELECT date_part('month',r.rental_date) rental_month, date_part('year',r.rental_date) rental_year,
s.store_id, COUNT(*) rentals_count
FROM store s
JOIN staff
ON s.store_id = staff.store_id
JOIN rental r
ON r.staff_id = staff.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;
/* Query 5: set 2 question 2 */
SELECT DATE_TRUNC('month',p.payment_date) as payment_month, CONCAT(c.first_name,' ',c.last_name) AS full_name,
SUM(amount) pay_per_month, count(*)
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
where (p.payment_date BETWEEN '2006-12-31' AND '2008-1-1')
AND CONCAT(c.first_name,' ',c.last_name) IN 
	(SELECT CONCAT(c.first_name,' ',c.last_name) AS full_name FROM customer c 
		JOIN payment p ON c.customer_id = p.customer_id 
		GROUP BY 1 ORDER BY SUM(p.amount) desc LIMIT 10)
GROUP BY 1,2
ORDER BY 2;
/* Query 6: set 2 question 3 */
SELECT DATE_TRUNC('month',p.payment_date) as payment_month, CONCAT(c.first_name,' ',c.last_name) AS full_name,
SUM(amount) pay_per_month, count(*),(LAG(SUM(amount)) OVER (PARTITION BY CONCAT(c.first_name,' ',c.last_name) ORDER BY DATE_TRUNC('month',p.payment_date),CONCAT(c.first_name,' ',c.last_name)))
,COALESCE(SUM(amount)-(LAG(SUM(amount)) OVER (PARTITION BY CONCAT(c.first_name,' ',c.last_name) ORDER BY DATE_TRUNC('month',p.payment_date),CONCAT(c.first_name,' ',c.last_name)))) AS difference
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
where (p.payment_date BETWEEN '2006-12-31' AND '2008-1-1')
AND CONCAT(c.first_name,' ',c.last_name) IN 
	(SELECT CONCAT(c.first_name,' ',c.last_name) AS full_name FROM customer c 
		JOIN payment p ON c.customer_id = p.customer_id 
		GROUP BY 1 ORDER BY SUM(p.amount) desc LIMIT 10)
GROUP BY 1,2
ORDER BY 6 DESC;