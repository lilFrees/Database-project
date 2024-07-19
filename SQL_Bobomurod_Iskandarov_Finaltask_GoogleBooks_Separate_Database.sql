CREATE DATABASE book_store_db;
CREATE SCHEMA book_inventory;

CREATE TABLE book_inventory.currencies (
    currency_code VARCHAR(50) PRIMARY KEY,
    description VARCHAR(300)
);
CREATE TABLE book_inventory.authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(300) UNIQUE
);
CREATE TABLE book_inventory.publishers (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(300) UNIQUE NOT NULL
);
CREATE TABLE book_inventory.genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(300) UNIQUE NOT NULL
);
CREATE TABLE book_inventory.languages (
    language_code VARCHAR(50) PRIMARY KEY,
    description VARCHAR(300) NOT NULL
);
CREATE TABLE book_inventory.books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    page_count INT NOT NULL,
    price NUMERIC NOT NULL,
    currency_code VARCHAR(50) REFERENCES book_inventory.currencies(currency_code),
    publisher_id INT REFERENCES book_inventory.publishers(publisher_id),
    language VARCHAR(50) REFERENCES book_inventory.languages(language_code),
    published_date DATE NOT NULL
);
CREATE TABLE book_inventory.ratings (
    rating_id SERIAL PRIMARY KEY,
    book_id INT REFERENCES book_inventory.books(book_id),
    rating_value NUMERIC NOT NULL,
    voters_count INT NOT NULL
);
CREATE TABLE book_inventory.isbns (
    isbn VARCHAR(50) PRIMARY KEY,
    book_id INT REFERENCES book_inventory.books(book_id)
);
CREATE TABLE book_inventory.book_genres (
    book_id INT REFERENCES book_inventory.books(book_id),
    genre_id INT REFERENCES book_inventory.genres(genre_id),
    PRIMARY KEY (book_id, genre_id)
);
CREATE TABLE book_inventory.book_authors (
    book_id INT REFERENCES book_inventory.books(book_id),
    author_id INT REFERENCES book_inventory.authors(author_id),
    PRIMARY KEY (book_id, author_id)
);

ALTER TABLE book_inventory.books
ADD CONSTRAINT check_positive_page_count CHECK (page_count > 0),
ADD CONSTRAINT check_positive_price CHECK (price >= 0);

ALTER TABLE book_inventory.ratings
ADD CONSTRAINT check_rating_range CHECK (rating_value BETWEEN 0 AND 5),
ADD CONSTRAINT check_positive_voters CHECK (voters_count >= 0);

ALTER TABLE book_inventory.languages
ADD CONSTRAINT check_language_code_length CHECK (LENGTH(language_code) < 20);

ALTER TABLE book_inventory.isbns
ADD CONSTRAINT check_isbn_format CHECK (isbn ~ '^[0-9]{10}([0-9]{3})?$');

ALTER TABLE book_inventory.currencies
ADD CONSTRAINT check_currency_code_length CHECK (LENGTH(currency_code) < 20);

ALTER TABLE book_inventory.books
ADD COLUMN exchange_rate NUMERIC DEFAULT 1.0;

ALTER TABLE book_inventory.books
ADD COLUMN price_usd NUMERIC GENERATED ALWAYS AS (price * exchange_rate) STORED;

CREATE OR REPLACE VIEW book_inventory.books_with_authors AS
SELECT 
    b.book_id,
    b.title,
    b.description,
    b.page_count,
    b.price,
    b.currency_code,
    b.publisher_id,
    b.language,
    b.published_date,
    b.exchange_rate,
    b.price_usd,
    b.title || ' by ' || COALESCE(STRING_AGG(a.name, ', '), 'Unknown Author') AS full_title
FROM 
    book_inventory.books b
LEFT JOIN 
    book_inventory.book_authors ba ON b.book_id = ba.book_id
LEFT JOIN 
    book_inventory.authors a ON ba.author_id = a.author_id
GROUP BY 
    b.book_id;