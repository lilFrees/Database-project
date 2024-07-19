CREATE SCHEMA denormalized;

SET search_path TO denormalized, public;

CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

CREATE TABLE dim_publisher (
    publisher_key SERIAL PRIMARY KEY,
    publisher_id INT NOT NULL,
    name VARCHAR(300) NOT NULL
);

CREATE TABLE dim_language (
    language_key SERIAL PRIMARY KEY,
    language_code VARCHAR(50) NOT NULL,
    description VARCHAR(300) NOT NULL
);

CREATE TABLE dim_author (
    author_key SERIAL PRIMARY KEY,
    author_id INT NOT NULL,
    name VARCHAR(300) NOT NULL
);

CREATE TABLE dim_genre (
    genre_key SERIAL PRIMARY KEY,
    genre_id INT NOT NULL,
    name VARCHAR(300) NOT NULL
);

CREATE TABLE fact_books (
    book_key SERIAL PRIMARY KEY,
    isbn VARCHAR(50) NOT NULL,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL,
    currency_code VARCHAR(50) NOT NULL,
    page_count INT NOT NULL,
    published_date_key INT REFERENCES dim_date(date_key),
    publisher_key INT REFERENCES dim_publisher(publisher_key),
    language_key INT REFERENCES dim_language(language_key),
    average_rating NUMERIC,
    total_ratings INT
);

CREATE TABLE fact_book_authors (
    book_key INT REFERENCES fact_books(book_key),
    author_key INT REFERENCES dim_author(author_key),
    PRIMARY KEY (book_key, author_key)
);

CREATE TABLE fact_book_genres (
    book_key INT REFERENCES fact_books(book_key),
    genre_key INT REFERENCES dim_genre(genre_key),
    PRIMARY KEY (book_key, genre_key)
);