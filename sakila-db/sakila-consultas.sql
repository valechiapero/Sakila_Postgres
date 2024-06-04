--Obtener el nombre, idioma original de la película, fecha de alquiler y fecha de devolución de todos los alquileres
-- realizados por el cliente: Nombre: BARBARA Apellido: JONES (22 Filas)  
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       f.title AS film_title,
       ol.name AS original_language,
       r.rental_date,
       r.return_date
FROM sakila.rental r
JOIN sakila.customer c ON r.customer_id = c.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
LEFT JOIN sakila.language ol ON f.original_language_id = ol.language_id
WHERE c.first_name = 'BARBARA' AND c.last_name = 'JONES';

--Mostrar Apellido, Nombre de los actores que participan en todas las películas de la categoría Comedy con 
--y sin repetición (286 filas c/repetición) (147 filas s/repetición) [DISTINCT]

--ConRepeticion
SELECT a.last_name, a.first_name
FROM sakila.actor a
JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
JOIN sakila.film_category fc ON fa.film_id = fc.film_id
JOIN sakila.category c ON fc.category_id = c.category_id
WHERE c.name = 'Comedy';

--SinRepeticion
SELECT DISTINCT a.last_name, a.first_name
FROM sakila.actor a
JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
JOIN sakila.film_category fc ON fa.film_id = fc.film_id
JOIN sakila.category c ON fc.category_id = c.category_id
WHERE c.name = 'Comedy';

--Obtener todos los datos de película en las que participo el actor de nombre : RAY  (30 filas)
SELECT *
FROM sakila.film
WHERE film_id IN (
    SELECT film_id
    FROM sakila.film_actor fa
    JOIN sakila.actor a ON fa.actor_id = a.actor_id
    WHERE a.first_name = 'RAY'
);

--Obtener un listado de todas las películas cuya duración sea entre 61 y 99 minutos (ambos inclusive) y el lenguaje original sea French (9 rows)
SELECT f.*
FROM sakila.film f
JOIN sakila.language l ON f.language_id = l.language_id
WHERE f.length BETWEEN 61 AND 99
AND l.name = 'French';

-- Mostrar nombre ciudad y nombre de país (en MAYÚSCULAS) de todas las ciudades de los países
-- (Austria, Chile, France) ordenadas por país luego nombre localidad (10 filas) [UPPER]
SELECT UPPER(ci.name) AS city_name,
       UPPER(co.country) AS country_name
FROM sakila.city ci
JOIN sakila.country co ON ci.country_id = co.country_id
WHERE UPPER(co.country) IN ('AUSTRIA', 'CHILE', 'FRANCE')
ORDER BY UPPER(co.country), ci.name;

--Mostrar el apellido (minúsculas) concatenado al nombre (MAYÚSCULAS) cuyo apellido de los actores contenga SS. 
--(7 Filas) [LIKE, UPPER, LOWER]
SELECT LOWER(last_name) || ' ' || UPPER(first_name) AS actor_name
FROM sakila.actor
WHERE last_name LIKE '%SS%';

--Mostrar el nro de ejemplar y nombre película de todos los alquileres del día 26 (sin importar mes)
-- que sean del almacén de la ciudad Woodridge (99 filas) [Utilizando extract o date_part]

--extract
SELECT i.inventory_id, f.title
FROM sakila.rental r
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
JOIN sakila.store s ON i.store_id = s.store_id
JOIN sakila.address a ON s.address_id = a.address_id
JOIN sakila.city c ON a.city_id = c.city_id
WHERE EXTRACT(DAY FROM r.rental_date) = 26
AND c.name = 'Woodridge';

--date_part
SELECT i.inventory_id, f.title
FROM sakila.rental r
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
JOIN sakila.store s ON i.store_id = s.store_id
JOIN sakila.address a ON s.address_id = a.address_id
JOIN sakila.city c ON a.city_id = c.city_id
WHERE DATE_PART('day', r.rental_date) = 26
AND c.name = 'Woodridge';

--Mostrar la segunda pagina (cada una tiene 10 películas) del listado nombre de la película ,
-- lenguaje original y valor de reposición de la películas ordenadas por su valor de reposición del mas caro al mas barato 
--(10 filas) [LIMIT, OFFSET y ORDER]
SELECT f.title AS movie_title, l.name AS original_language, f.replacement_cost
FROM sakila.film f
JOIN sakila.language l ON f.original_language_id = l.language_id
ORDER BY f.replacement_cost DESC
LIMIT 10 OFFSET 10;

--Mostrar el nombre de la película, el nombre del cliente, nro de ejemplar, fecha de alquiler, 
--fecha de devolución de los ejemplares que demoraron mas de 7 días en ser devueltos (3557 filas) [AGE]
SELECT f.title AS movie_title,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       i.inventory_id,
       r.rental_date,
       r.return_date
FROM sakila.rental r
JOIN sakila.customer c ON r.customer_id = c.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
WHERE AGE(r.return_date, r.rental_date) > INTERVAL '7 days';

--CONSULTAS INTERMEDIAS

--Mostrar todas las películas que están alquiladas y que todavía no fueron devueltas. 
--Mostrando el nombre de la película, el número de ejemplar, quien la alquilo y la fecha. 
--Mostrar el nombre del cliente de la manera Apellido, Nombre y renombre el campo como 'nombre_cliente' 
SELECT f.title AS movie_title,
       i.inventory_id,
       CONCAT(c.last_name, ', ', c.first_name) AS nombre_cliente,
       r.rental_date
FROM sakila.rental r
JOIN sakila.customer c ON r.customer_id = c.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
WHERE r.return_date IS NULL;

--Mostrar cuales fueron las 10 películas mas alquiladas
SELECT f.title AS movie_title, COUNT(*) AS rental_count
FROM sakila.rental r
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 10;

--Realizar un listado de las películas que fueron alquiladas por el cliente "OWENS, CARMEN"
SELECT f.title AS movie_title
FROM sakila.rental r
JOIN sakila.customer c ON r.customer_id = c.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
WHERE CONCAT(c.last_name, ', ', c.first_name) = 'OWENS, CARMEN';

--Buscar los pagos que no han sido asignados a ningún alquiler
SELECT *
FROM sakila.payment
WHERE rental_id IS NULL;

--Seleccionar todas las películas que son en "Mandarin" y listar las por orden alfabético. 
--Mostrando el titulo de la película y el idioma ingresando el idioma en minúsculas.
SELECT title AS movie_title, LOWER(name) AS language
FROM sakila.film
JOIN sakila.language ON film.language_id = language.language_id
WHERE LOWER(name) = 'mandarin'
ORDER BY title;

--Mostrar los clientes que hayan alquilado mas de 1 vez la misma película
SELECT CONCAT(c.last_name, ', ', c.first_name) AS customer_name
FROM sakila.customer c
JOIN sakila.rental r ON c.customer_id = r.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
GROUP BY c.customer_id, f.film_id
HAVING COUNT(*) > 1;

--Mostrar los totales de alquileres por mes del año 2005
SELECT DATE_TRUNC('month', r.rental_date) AS month,
       COUNT(*) AS total_rentals
FROM sakila.rental r
WHERE EXTRACT(YEAR FROM r.rental_date) = 2005
GROUP BY DATE_TRUNC('month', r.rental_date)
ORDER BY month;

--Mostrar los totales históricos de alquileres discriminados por categoría. 
--Ordene los resultados por el campo monto en orden descendente al campo calculado llamarlo monto. 
SELECT c.name AS category_name,
       COUNT(r.rental_id) AS rental_count,
       SUM(p.amount) AS total_amount,
       SUM(p.amount) / COUNT(r.rental_id) AS monto
FROM sakila.rental r
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film_category fc ON i.film_id = fc.film_id
JOIN sakila.category c ON fc.category_id = c.category_id
JOIN sakila.payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY monto DESC;

--Listar todos los actores de las películas alquiladas en el periodo 7 del año 2005. 
--Ordenados alfabéticamente representados "APELLIDO, nombre" renombrar el campo como Actor
SELECT DISTINCT CONCAT(a.last_name, ', ', a.first_name) AS Actor
FROM sakila.actor a
JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
JOIN sakila.inventory i ON fa.film_id = i.film_id
JOIN sakila.rental r ON i.inventory_id = r.inventory_id
WHERE EXTRACT(MONTH FROM r.rental_date) = 7
AND EXTRACT(YEAR FROM r.rental_date) = 2005
ORDER BY Actor;

--Listar el monto gastado por el customer last_name=SHAW; first_name=CLARA; 
SELECT c.last_name || ', ' || c.first_name AS customer_name,
       SUM(p.amount) AS total_amount_spent
FROM sakila.customer c
JOIN sakila.payment p ON c.customer_id = p.customer_id
WHERE c.last_name = 'SHAW' AND c.first_name = 'CLARA';

--Listar el valor mas alto de los alquileres registrados en el año 2005. 
--Mostrar además quien fue el cliente que abono ese alquiler.
SELECT p.amount AS highest_rental_amount,
       CONCAT(c.last_name, ', ', c.first_name) AS customer_name
FROM sakila.payment p
JOIN sakila.rental r ON p.rental_id = r.rental_id
JOIN sakila.customer c ON p.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM r.rental_date) = 2005
ORDER BY p.amount DESC
LIMIT 1;

--Listar el monto gastado por los customer que hayan gastado mas de 40 en el mes 6 de 2005
SELECT CONCAT(c.last_name, ', ', c.first_name) AS customer_name,
       SUM(p.amount) AS total_amount_spent
FROM sakila.customer c
JOIN sakila.payment p ON c.customer_id = p.customer_id
JOIN sakila.rental r ON p.rental_id = r.rental_id
WHERE EXTRACT(MONTH FROM r.rental_date) = 6
AND EXTRACT(YEAR FROM r.rental_date) = 2005
GROUP BY c.customer_id
HAVING SUM(p.amount) > 40;

--Mostrar la cantidad del clientes hay por ciudad
SELECT ci.name AS city_name, COUNT(c.customer_id) AS customer_count
FROM sakila.customer c
JOIN sakila.address a ON c.address_id = a.address_id
JOIN sakila.city ci ON a.city_id = ci.city_id
GROUP BY ci.name
ORDER BY customer_count DESC;

--Mostrar las 5 películas con mayor cantidad de actores
SELECT f.title AS movie_title, COUNT(fa.actor_id) AS actor_count
FROM sakila.film f
JOIN sakila.film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id, f.title
ORDER BY actor_count DESC
LIMIT 5;

--Mostrar los días donde se hayan alquilado mas de 10 de películas de "Drama"
SELECT DATE(rental_date) AS rental_day, COUNT(*) AS total_rentals
FROM sakila.rental r
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
JOIN sakila.film_category fc ON f.film_id = fc.film_id
JOIN sakila.category c ON fc.category_id = c.category_id
WHERE c.name = 'Drama'
GROUP BY rental_day
HAVING COUNT(*) > 10;

--Mostrar los actores que no están en ninguna película
SELECT actor_id, first_name, last_name
FROM sakila.actor
WHERE actor_id NOT IN (SELECT actor_id FROM sakila.film_actor);

--CONSULTAS AVANZADAS
--Mostrar los clientes que hayan alquilado la película mas alquilada conjuntamente con los clientes
-- que hayan alquilado la menos alquilada con repeticiones, ordenados alfabéticamente 
-- Subconsulta para encontrar la película más alquilada

WITH most_rented_film AS (
    SELECT i.film_id, COUNT(*) AS rental_count
    FROM sakila.rental r
    JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
    ORDER BY rental_count DESC
    LIMIT 1
),
-- Subconsulta para encontrar la película menos alquilada
least_rented_film AS (
    SELECT i.film_id, COUNT(*) AS rental_count
    FROM sakila.rental r
    JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
    ORDER BY rental_count ASC
    LIMIT 1
)
-- Consulta principal para encontrar los clientes que alquilaron estas películas
SELECT DISTINCT CONCAT(c.last_name, ', ', c.first_name) AS customer_name
FROM sakila.customer c
JOIN sakila.rental r ON c.customer_id = r.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
WHERE i.film_id = (SELECT film_id FROM most_rented_film)
   OR i.film_id = (SELECT film_id FROM least_rented_film)
ORDER BY customer_name;

--Mostrar los clientes que hayan alquilado la película mas alquilada conjuntamente con los clientes 
--que hayan alquilado la menos alquilada sin repeticiones, ordenados alfabéticamente

-- Subconsulta para encontrar la película más alquilada
WITH most_rented_film AS (
    SELECT i.film_id
    FROM sakila.rental r
    JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
),
-- Subconsulta para encontrar la película menos alquilada
least_rented_film AS (
    SELECT i.film_id
    FROM sakila.rental r
    JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
    ORDER BY COUNT(*) ASC
    LIMIT 1
)
-- Consulta principal para encontrar los clientes que alquilaron estas películas
SELECT DISTINCT CONCAT(c.last_name, ', ', c.first_name) AS customer_name
FROM sakila.customer c
JOIN sakila.rental r ON c.customer_id = r.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
WHERE i.film_id = (SELECT film_id FROM most_rented_film)
   OR i.film_id = (SELECT film_id FROM least_rented_film)
ORDER BY customer_name;


--Mostrar el/los clientes que hayan alquilo la película mas alquilada y la menos alquilada.

-- Subconsulta para encontrar la película más alquilada
WITH most_rented_film AS (
    SELECT i.film_id
    FROM sakila.rental r
    JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
),
-- Subconsulta para encontrar la película menos alquilada
least_rented_film AS (
    SELECT i.film_id
    FROM sakila.rental r
    JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
    ORDER BY COUNT(*) ASC
    LIMIT 1
)
-- Subconsulta para encontrar los clientes que alquilaron la película más alquilada
SELECT DISTINCT c.customer_id, CONCAT(c.last_name, ', ', c.first_name) AS customer_name
FROM sakila.customer c
JOIN sakila.rental r ON c.customer_id = r.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
WHERE i.film_id = (SELECT film_id FROM most_rented_film)
AND c.customer_id IN (
    SELECT DISTINCT c2.customer_id
    FROM sakila.customer c2
    JOIN sakila.rental r2 ON c2.customer_id = r2.customer_id
    JOIN sakila.inventory i2 ON r2.inventory_id = i2.inventory_id
    WHERE i2.film_id = (SELECT film_id FROM least_rented_film)
);


--Mostrar los clientes que alquilaron películas de la categoría 'New' los días en que se hayan alquilado más de 40 ejemplares de dicha categoría
-- Subconsulta para encontrar los días en los que se alquilaron más de 40 ejemplares de la categoría 'New'
WITH days_with_high_rentals AS (
    SELECT DATE(r.rental_date) AS rental_day
    FROM sakila.rental r
    JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
    JOIN sakila.film_category fc ON i.film_id = fc.film_id
    JOIN sakila.category c ON fc.category_id = c.category_id
    WHERE c.name = 'New'
    GROUP BY rental_day
    HAVING COUNT(*) > 40
)
-- Consulta principal para encontrar los clientes que alquilaron películas de la categoría 'New' en esos días
SELECT DISTINCT CONCAT(c.last_name, ', ', c.first_name) AS customer_name
FROM sakila.customer c
JOIN sakila.rental r ON c.customer_id = r.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film_category fc ON i.film_id = fc.film_id
JOIN sakila.category ca ON fc.category_id = ca.category_id
WHERE ca.name = 'New' AND DATE(r.rental_date) IN (SELECT rental_day FROM days_with_high_rentals)
ORDER BY customer_name;

--Mostrar los días que se hayan alquilado películas (cantidad) por encima de la media de alquileres diaria ordenado por la cantidad de alquileres.

-- Subconsulta para calcular la cantidad promedio de alquileres diarios
WITH average_daily_rentals AS (
    SELECT AVG(daily_rentals) AS avg_rentals
    FROM (
        SELECT DATE(rental_date) AS rental_day, COUNT(*) AS daily_rentals
        FROM sakila.rental
        GROUP BY rental_day
    ) daily_rentals_count
),
-- Subconsulta para encontrar los días con alquileres por encima del promedio
above_average_rentals AS (
    SELECT DATE(rental_date) AS rental_day, COUNT(*) AS rental_count
    FROM sakila.rental
    GROUP BY rental_day
    HAVING COUNT(*) > (SELECT avg_rentals FROM average_daily_rentals)
)
-- Consulta principal para ordenar los días por la cantidad de alquileres
SELECT rental_day, rental_count
FROM above_average_rentals
ORDER BY rental_count DESC;
