INSERT INTO dim_date (full_date, year, quarter, month, day, day_of_week, is_weekend)
SELECT 
    d::date AS full_date,
    EXTRACT(YEAR FROM d) AS year,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(MONTH FROM d) AS month,
    EXTRACT(DAY FROM d) AS day,
    EXTRACT(DOW FROM d) AS day_of_week,
    CASE WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM generate_series(
    (SELECT MIN(published_date) FROM book_inventory.books),
    (SELECT MAX(published_date) FROM book_inventory.books),
    '1 day'::interval
) d;

INSERT INTO dim_publisher (publisher_id, name)
SELECT publisher_id, name
FROM book_inventory.publishers;

INSERT INTO dim_language (language_code, description)
SELECT language_code, description
FROM book_inventory.languages;

INSERT INTO dim_author (author_id, name)
SELECT author_id, name
FROM book_inventory.authors;

INSERT INTO dim_genre (genre_id, name)
SELECT genre_id, name
FROM book_inventory.genres;

INSERT INTO fact_books (
    isbn, title, description, price, currency_code, page_count, 
    published_date_key, publisher_key, language_key, average_rating, total_ratings
)
SELECT 
    i.isbn,
    b.title,
    b.description,
    b.price,
    b.currency_code,
    b.page_count,
    dd.date_key,
    dp.publisher_key,
    dl.language_key,
    r.rating_value,
    r.voters_count
FROM 
    book_inventory.books b
    JOIN book_inventory.isbns i ON b.book_id = i.book_id
    JOIN denormalized.dim_date dd ON b.published_date = dd.full_date
    JOIN denormalized.dim_publisher dp ON b.publisher_id = dp.publisher_id
    JOIN denormalized.dim_language dl ON b.language = dl.language_code
    LEFT JOIN book_inventory.ratings r ON b.book_id = r.book_id;
	
INSERT INTO fact_book_genres (book_key, genre_key)
SELECT 
    fb.book_key,
    dg.genre_key
FROM 
    public.book_genres bg
    JOIN fact_books fb ON fb.isbn = (SELECT isbn FROM public.isbns WHERE book_id = bg.book_id LIMIT 1)
    JOIN dim_genre dg ON bg.genre_id = dg.genre_id;
	
INSERT INTO denormalized.fact_book_authors (book_key, author_key)
SELECT DISTINCT
    fb.book_key,
    da.author_key
FROM 
    book_authors ba
    JOIN denormalized.fact_books fb ON fb.isbn = (SELECT isbn FROM isbns WHERE book_id = ba.book_id LIMIT 1)
    JOIN denormalized.dim_author da ON ba.author_id = da.author_id;