-- Part 1

-- Task 1: All animation movies released between 2017 and 2019 with rate > 1, ordered alphabetically
-- Using LEFT JOINs to preserve all films even if category info is missing 
SELECT 
    f.title AS animation_title
FROM film f
LEFT JOIN film_category fc ON fc.film_id = f.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE f.release_year BETWEEN 2017 AND 2019 
  AND f.rental_rate > 1
  AND c.name = 'Animation'
ORDER BY f.title;

-- Task 2: Revenue earned by each store after March 2017 (address + address2, revenue)
-- Using COALESCE for NULL-safe concatenation
SELECT 
    a.address || ' ' || COALESCE(a.address2, '') AS full_address,
    SUM(p.amount) AS revenue
FROM payment p
LEFT JOIN staff s ON p.staff_id = s.staff_id
LEFT JOIN store st ON s.store_id = st.store_id
LEFT JOIN address a ON st.address_id = a.address_id
WHERE p.payment_date > '2017-03-31'
GROUP BY a.address, a.address2;

-- Task 3: Top-5 actors by number of movies (released after 2015)
SELECT 
    a.first_name,
    a.last_name,
    COUNT(*) AS number_of_movies
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
LEFT JOIN film f ON f.film_id = fa.film_id
WHERE f.release_year > 2015
GROUP BY a.first_name, a.last_name
ORDER BY number_of_movies DESC
LIMIT 5;

-- Task 4: Number of Drama, Travel, Documentary per year
SELECT 
    f.release_year,
    COUNT(CASE WHEN c.name = 'Drama' THEN 1 END) AS number_of_drama_movies,
    COUNT(CASE WHEN c.name = 'Travel' THEN 1 END) AS number_of_travel_movies,
    COUNT(CASE WHEN c.name = 'Documentary' THEN 1 END) AS number_of_documentary_movies
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE c.name IN ('Drama', 'Travel', 'Documentary')
GROUP BY f.release_year
ORDER BY f.release_year DESC;

-- Part 2

-- Task 1: Top 3 employees by revenue in 2017 (with last store)
WITH staff_revenue AS (
    SELECT 
        p.staff_id,
        SUM(p.amount) AS revenue
    FROM payment p
    WHERE p.payment_date BETWEEN '2017-01-01' AND '2017-12-31'
    GROUP BY p.staff_id
),
last_store AS (
    SELECT 
        s.staff_id,
        s.store_id
    FROM staff s
)
SELECT 
    s.first_name,
    s.last_name,
    ls.store_id AS last_store,
    sr.revenue
FROM staff_revenue sr
LEFT JOIN staff s ON s.staff_id = sr.staff_id
LEFT JOIN last_store ls ON sr.staff_id = ls.staff_id
ORDER BY sr.revenue DESC
LIMIT 3;

-- Task 2: Top 5 most rented movies and their expected age group
WITH rental_counts AS (
    SELECT 
        f.film_id,
        f.title,
        f.rating,
        COUNT(r.rental_id) AS rental_count
    FROM rental r
    LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
    LEFT JOIN film f ON i.film_id = f.film_id
    GROUP BY f.film_id, f.title, f.rating
)
SELECT 
    title,
    rating,
    rental_count,
    CASE rating
        WHEN 'G' THEN '0+'
        WHEN 'PG' THEN '10+'
        WHEN 'PG-13' THEN '13+'
        WHEN 'R' THEN '17+'
        WHEN 'NC-17' THEN '18+'
        ELSE 'Unknown'
    END AS expected_age
FROM rental_counts
ORDER BY rental_count DESC
LIMIT 5;

-- Part 3

-- V1: Gap between current year (2025) and last release year per actor
SELECT 
    a.first_name,
    a.last_name,
    MAX(f.release_year) AS last_movie_year,
    2025 - MAX(f.release_year) AS years_since_last_movie
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN film f ON fa.film_id = f.film_id
GROUP BY a.first_name, a.last_name
ORDER BY years_since_last_movie DESC;

-- V2: Max gap between sequential films per actor
SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    MAX(f2.release_year - f1.release_year) AS max_gap
FROM actor a
LEFT JOIN film_actor fa1 ON a.actor_id = fa1.actor_id
LEFT JOIN film f1 ON fa1.film_id = f1.film_id
LEFT JOIN film_actor fa2 ON a.actor_id = fa2.actor_id
LEFT JOIN film f2 ON fa2.film_id = f2.film_id
WHERE f2.release_year > f1.release_year
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY max_gap DESC;