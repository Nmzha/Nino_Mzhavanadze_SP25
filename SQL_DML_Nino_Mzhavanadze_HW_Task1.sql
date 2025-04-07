INSERT INTO film (
    title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update
)
SELECT nf.title,
       nf.description,
       nf.release_year,
       nf.language_id,
       nf.rental_duration,
       nf.rental_rate,
       nf.length,
       nf.replacement_cost,
       nf.rating::mpaa_rating,     -- ← EXPLICIT CAST HERE
       CURRENT_DATE
  FROM (
       SELECT 
         'The Imitation Game' AS title,
         'Biographical drama about Alan Turing' AS description,
         2014 AS release_year,
         (SELECT language_id FROM language WHERE name = 'English' LIMIT 1) AS language_id,
         1 AS rental_duration,
         4.99 AS rental_rate,
         114 AS length,
         19.99 AS replacement_cost,
         'PG-13' AS rating    -- This is text that needs casting
       UNION ALL
       SELECT
         '12 Angry Men',
         'A jury debates the guilt or innocence of a defendant',
         1957,
         (SELECT language_id FROM language WHERE name = 'English' LIMIT 1),
         2,
         9.99,
         96,
         19.99,
         'G'
       UNION ALL
       SELECT
         'Life Is Beautiful',
         'An Italian Jewish man employs his imagination to protect his son in a Nazi concentration camp',
         1997,
         (SELECT language_id FROM language WHERE name = 'English' LIMIT 1),
         3,
         19.99,
         116,
         19.99,
         'PG-13'
  ) nf
 WHERE NOT EXISTS (
       SELECT 1
         FROM film f
        WHERE f.title = nf.title
)
RETURNING film_id, title;


--  Insert  actors for my favorite movies.
--    add 7 real actors for:
--      - "The Imitation Game": Benedict Cumberbatch, Keira Knightley, Matthew Goode
--      - "12 Angry Men": Henry Fonda, Lee J. Cobb
--      - "Life Is Beautiful": Roberto Benigni, Nicoletta Braschi
------------------------------------------------------------------------------

WITH new_actors AS (
  INSERT INTO actor (first_name, last_name, last_update)
  SELECT first_name, last_name, current_date
    FROM (
         SELECT 'Benedict'   AS first_name, 'Cumberbatch' AS last_name
         UNION ALL
         SELECT 'Keira',      'Knightley'
         UNION ALL
         SELECT 'Matthew',    'Goode'
         UNION ALL
         SELECT 'Henry',      'Fonda'
         UNION ALL
         SELECT 'Lee',        'J. Cobb'
         UNION ALL
         SELECT 'Roberto',    'Benigni'
         UNION ALL
         SELECT 'Nicoletta',  'Braschi'
         ) AS actors
  WHERE NOT EXISTS (
    SELECT 1 
      FROM actor a
     WHERE a.first_name = actors.first_name
       AND a.last_name  = actors.last_name
  )
  RETURNING actor_id, first_name, last_name
)
SELECT 'Inserted actors' AS info, COUNT(*) AS number_of_actors
FROM new_actors;

-- Insert into "inventory" for store 1, for each of the 3 films.

WITH new_inventory AS (
  INSERT INTO inventory (film_id, store_id, last_update)
  SELECT f.film_id,
         1,               -- store_id = 1
         current_date
    FROM film f
   WHERE f.title IN ('The Imitation Game','12 Angry Men','Life Is Beautiful')
     AND NOT EXISTS (
       SELECT 1 
         FROM inventory i
        WHERE i.film_id = f.film_id
          AND i.store_id = 1
     )
  RETURNING inventory_id, film_id, store_id
)
SELECT * FROM new_inventory;

-- Update the first customer who meets the 43 rentals & 43 payments condition
-- and hasn't already been changed to "John Smith".

WITH find_customer AS (
  SELECT c.customer_id
    FROM customer c
   WHERE (SELECT COUNT(*) FROM rental  r WHERE r.customer_id = c.customer_id) >= 43
     AND (SELECT COUNT(*) FROM payment p WHERE p.customer_id = c.customer_id) >= 43
     AND c.first_name <> 'John'
   LIMIT 1
),
pick_address AS (
  -- Pick ANY existing address_id from the table.
  SELECT address_id
    FROM address
   LIMIT 1
),
upd AS (
  UPDATE customer c
     SET first_name  = 'John',
         last_name   = 'Smith',
         email       = 'john.smith@example.com',
         address_id  = (SELECT address_id FROM pick_address),
         last_update = current_date
    FROM find_customer fc
   WHERE c.customer_id = fc.customer_id
  RETURNING c.customer_id, c.first_name, c.last_name, c.email, c.address_id
)
SELECT * FROM upd;
