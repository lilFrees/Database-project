CREATE OR REPLACE VIEW recent_quarter_book_analytics AS
WITH recent_quarter AS (
    SELECT DATE_TRUNC('quarter', MAX(published_date)) AS quarter_start
    FROM books
)
SELECT 
    b.title,
    STRING_AGG(DISTINCT a.name, ', ') AS authors,
    STRING_AGG(DISTINCT g.name, ', ') AS genres,
    b.published_date,
    b.page_count,
    b.price,
    c.currency_code,
    p.name AS publisher,
    l.description AS language,
    r.rating_value,
    r.voters_count,
    STRING_AGG(DISTINCT i.isbn, ', ') AS isbns
FROM 
    books b
    JOIN recent_quarter rq ON DATE_TRUNC('quarter', b.published_date) = rq.quarter_start
    LEFT JOIN book_authors ba ON b.book_id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.author_id
    LEFT JOIN book_genres bg ON b.book_id = bg.book_id
    LEFT JOIN genres g ON bg.genre_id = g.genre_id
    LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
    LEFT JOIN languages l ON b.language = l.language_code
    LEFT JOIN currencies c ON b.currency_code = c.currency_code
    LEFT JOIN ratings r ON b.book_id = r.book_id
    LEFT JOIN isbns i ON b.book_id = i.book_id
GROUP BY 
    b.book_id, b.title, b.published_date, b.page_count, b.price, 
    c.currency_code, p.name, l.description, r.rating_value, r.voters_count
ORDER BY 
    b.published_date DESC, b.title;

