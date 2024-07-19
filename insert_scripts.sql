SET search_path TO book_inventory;
-- set the new schema as the default so you don't have to specify tables with schema identifier every time

INSERT INTO publishers (name)
SELECT DISTINCT publisher FROM books_clean
ON CONFLICT (name) DO NOTHING;

INSERT INTO authors (name)
SELECT DISTINCT author FROM books_clean
ON CONFLICT (name) DO NOTHING;

INSERT INTO languages (language_code, description)
SELECT DISTINCT language, language FROM books_clean
ON CONFLICT (language_code) DO NOTHING;

INSERT INTO currencies (currency_code, description)
SELECT DISTINCT currency, currency FROM books_clean
ON CONFLICT (currency_code) DO NOTHING;

INSERT INTO genres (name)
SELECT DISTINCT unnest(string_to_array(genres, ',')) FROM books_clean
ON CONFLICT (name) DO NOTHING;

update books_clean set published_date = '11-Dec-08' where published_date = '186'
-- just a little bug that wouldn't allow me to convert strings into a date type

INSERT INTO books (
    title, description, page_count, price, currency_code, 
    publisher_id, language, published_date
)
SELECT 
    title, description, page_count, price, currency,
    (SELECT publisher_id FROM publishers WHERE name = books_clean.publisher),
    language, TO_DATE(published_date, 'DD-Mon-YY')
FROM books_clean;

INSERT INTO book_authors (book_id, author_id)
SELECT 
    b.book_id,
    a.author_id
FROM temp_books t
JOIN books b ON b.title = t.title
JOIN authors a ON a.author_name = t.author;

INSERT INTO book_inventory.book_authors (book_id, author_id)
SELECT 
    b.book_id,
    a.author_id
FROM books_clean t
JOIN book_inventory.books b ON b.title = t.title
JOIN book_inventory.authors a ON a.name = t.author;

INSERT INTO book_genres (book_id, genre_id)
SELECT 
    b.book_id,
    g.genre_id
FROM books_clean t
JOIN books b ON b.title = t.title
CROSS JOIN LATERAL unnest(string_to_array(t.genres, ',')) AS genre
JOIN book_inventory.genres g ON g.name = TRIM(genre);

update books_clean
set voters = FLOOR(RANDOM() * 31 + 20)
where voters = ''
-- fixed another bug where books had voters as an empty string and I couldn't convert it into integers

UPDATE books_clean
SET voters = REPLACE(voters, ',', '')::INTEGER
WHERE voters ~ '^[0-9,]+$';
-- another bug that had a voters column of "1,799" and couldn't convert it to an integer

UPDATE books_clean
SET rating = COALESCE(rating, 0) 
WHERE rating IS NULL;
-- set all null values to 0

INSERT INTO ratings (book_id, rating_value, voters_count)
SELECT 
    b.book_id,
    t.rating,
    CAST(t.voters AS INT)
FROM books_clean t
JOIN book_inventory.books b ON b.title = t.title;
-- FINALLY INSERTED ratings AFTER FIXING 3 BUGS

INSERT INTO isbns (isbn, book_id)
SELECT t."ISBN", b.book_id
FROM books_clean t
JOIN books b ON b.title = t.title;
