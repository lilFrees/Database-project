CREATE TABLE currencies (
    currency_code VARCHAR(50) PRIMARY KEY,
    description VARCHAR(300)
);
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(300) UNIQUE
);
CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(300) UNIQUE NOT NULL
);
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(300) UNIQUE NOT NULL
);
CREATE TABLE languages (
    language_code VARCHAR(50) PRIMARY KEY,
    description VARCHAR(300) NOT NULL
);
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    page_count INT NOT NULL,
    price NUMERIC NOT NULL,
    currency_code VARCHAR(50) REFERENCES currencies(currency_code),
    publisher_id INT REFERENCES publishers(publisher_id),
    language VARCHAR(50) REFERENCES languages(language_code),
    published_date DATE NOT NULL
);
CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    book_id INT REFERENCES books(book_id),
    rating_value NUMERIC NOT NULL,
    voters_count INT NOT NULL
);
CREATE TABLE isbns (
    isbn VARCHAR(50) PRIMARY KEY,
    book_id INT REFERENCES books(book_id)
);
CREATE TABLE book_genres (
    book_id INT REFERENCES books(book_id),
    genre_id INT REFERENCES genres(genre_id),
    PRIMARY KEY (book_id, genre_id)
);
CREATE TABLE book_authors (
    book_id INT REFERENCES books(book_id),
    author_id INT REFERENCES authors(author_id),
    PRIMARY KEY (book_id, author_id)
);

