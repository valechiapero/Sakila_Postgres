-- Drop Schema if exists
DROP SCHEMA IF EXISTS sakila CASCADE;
CREATE SCHEMA sakila;

-- Table: actor
CREATE TABLE sakila.actor (
    actor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: address
CREATE TABLE sakila.address (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id INT NOT NULL,
    postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    location VARCHAR(255), -- Use VARCHAR instead of POINT
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES sakila.city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table: category
CREATE TABLE sakila.category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: city
CREATE TABLE sakila.city (
    city_id SERIAL PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country_id INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES sakila.country(country_id)
);

-- Table: country
CREATE TABLE sakila.country (
    country_id SERIAL PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: customer
CREATE TABLE sakila.customer (
    customer_id SERIAL PRIMARY KEY,
    store_id INT NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    address_id INT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES sakila.store(store_id),
    FOREIGN KEY (address_id) REFERENCES sakila.address(address_id)
);

-- Table: film
CREATE TABLE sakila.film (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(128) NOT NULL,
    description TEXT,
    release_year INTEGER,
    language_id INT NOT NULL,
    original_language_id INT,
    rental_duration SMALLINT NOT NULL DEFAULT 3,
    rental_rate NUMERIC(4,2) NOT NULL DEFAULT 4.99,
    length SMALLINT,
    replacement_cost NUMERIC(5,2) NOT NULL DEFAULT 19.99,
    rating VARCHAR(5) DEFAULT 'G',
    special_features VARCHAR(255)[] DEFAULT '{}'::VARCHAR[], -- Use ::VARCHAR[] to cast to VARCHAR[]
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (language_id) REFERENCES sakila.language(language_id),
    FOREIGN KEY (original_language_id) REFERENCES sakila.language(language_id)
);

-- Table: film_actor
CREATE TABLE sakila.film_actor (
    actor_id INT NOT NULL,
    film_id INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id, film_id),
    FOREIGN KEY (actor_id) REFERENCES sakila.actor(actor_id),
    FOREIGN KEY (film_id) REFERENCES sakila.film(film_id)
);

-- Table: film_category
CREATE TABLE sakila.film_category (
    film_id INT NOT NULL,
    category_id INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (film_id, category_id),
    FOREIGN KEY (film_id) REFERENCES sakila.film(film_id),
    FOREIGN KEY (category_id) REFERENCES sakila.category(category_id)
);

-- Table: film_text
CREATE TABLE sakila.film_text (
    film_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT
);

-- Table: inventory
CREATE TABLE sakila.inventory (
    inventory_id SERIAL PRIMARY KEY,
    film_id INT NOT NULL,
    store_id INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (film_id) REFERENCES sakila.film(film_id),
    FOREIGN KEY (store_id) REFERENCES sakila.store(store_id)
);

-- Table: language
CREATE TABLE sakila.language (
    language_id SERIAL PRIMARY KEY,
    name CHAR(40) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: payment
CREATE TABLE sakila.payment (
    payment_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount NUMERIC(5,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES sakila.customer(customer_id),
    FOREIGN KEY (staff_id) REFERENCES sakila.staff(staff_id),
    FOREIGN KEY (rental_id) REFERENCES sakila.rental(rental_id)
);

-- Table: rental
CREATE TABLE sakila.rental (
    rental_id SERIAL PRIMARY KEY,
    rental_date TIMESTAMP NOT NULL,
    inventory_id INT NOT NULL,
    customer_id INT NOT NULL,
    return_date TIMESTAMP,
    staff_id INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: staff
CREATE TABLE sakila.staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    address_id INT NOT NULL,
    picture BYTEA,
    email VARCHAR(50),
    store_id INT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    username VARCHAR(16) NOT NULL,
    password VARCHAR(64), -- Se incrementa el tamaño para el hash SHA2
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (address_id) REFERENCES sakila.address(address_id)
);

-- Table: store
CREATE TABLE sakila.store (
    store_id SERIAL PRIMARY KEY,
    manager_staff_id INT NOT NULL,
    address_id INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_staff_id) REFERENCES sakila.staff(staff_id),
    FOREIGN KEY (address_id) REFERENCES sakila.address(address_id)
);
