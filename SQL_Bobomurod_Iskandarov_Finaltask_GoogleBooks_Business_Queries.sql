WITH author_sales AS (
    SELECT 
        da.name AS author_name,
        EXTRACT(YEAR FROM dd.full_date) AS year,
        SUM(fb.price) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM dd.full_date) ORDER BY SUM(fb.price) DESC) AS rank
    FROM fact_books fb
    JOIN fact_book_authors fba ON fb.book_key = fba.book_key
    JOIN dim_author da ON fba.author_key = da.author_key
    JOIN dim_date dd ON fb.published_date_key = dd.date_key
    WHERE EXTRACT(YEAR FROM dd.full_date) IN (EXTRACT(YEAR FROM CURRENT_DATE) - 1, EXTRACT(YEAR FROM CURRENT_DATE))
    GROUP BY da.name, EXTRACT(YEAR FROM dd.full_date)
)
SELECT 
    year,
    author_name,
    total_sales,
    LAG(author_name) OVER (PARTITION BY rank ORDER BY year) AS prev_year_author,
    LAG(total_sales) OVER (PARTITION BY rank ORDER BY year) AS prev_year_sales
FROM author_sales
WHERE rank <= 3
ORDER BY year DESC, rank;

SELECT 
    dg.name AS genre,
    dd.year,
    dd.quarter,
    SUM(fb.price) AS quarterly_sales,
    SUM(SUM(fb.price)) OVER (PARTITION BY dg.name ORDER BY dd.year, dd.quarter) AS cumulative_sales
FROM fact_books fb
JOIN fact_book_genres fbg ON fb.book_key = fbg.book_key
JOIN dim_genre dg ON fbg.genre_key = dg.genre_key
JOIN dim_date dd ON fb.published_date_key = dd.date_key
GROUP BY dg.name, dd.year, dd.quarter
ORDER BY dg.name, dd.year, dd.quarter;

SELECT 
    dd.year,
    dd.month,
    AVG(fb.price) AS avg_price,
    AVG(AVG(fb.price)) OVER (ORDER BY dd.year, dd.month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_price
FROM fact_books fb
JOIN dim_date dd ON fb.published_date_key = dd.date_key
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;

SELECT 
    fb.title,
    fb.average_rating,
    dp.name AS publisher,
    AVG(fb.average_rating) OVER (PARTITION BY fb.publisher_key) AS publisher_avg_rating,
    fb.average_rating - AVG(fb.average_rating) OVER (PARTITION BY fb.publisher_key) AS rating_difference
FROM fact_books fb
JOIN dim_publisher dp ON fb.publisher_key = dp.publisher_key
ORDER BY rating_difference DESC;

SELECT 
    da.name AS author_name,
    fb.title,
    dd.full_date AS publish_date,
    fb.price,
    LAG(fb.title) OVER (PARTITION BY da.author_key ORDER BY dd.full_date) AS prev_book,
    LAG(fb.price) OVER (PARTITION BY da.author_key ORDER BY dd.full_date) AS prev_price,
    fb.price - LAG(fb.price) OVER (PARTITION BY da.author_key ORDER BY dd.full_date) AS price_change
FROM fact_books fb
JOIN fact_book_authors fba ON fb.book_key = fba.book_key
JOIN dim_author da ON fba.author_key = da.author_key
JOIN dim_date dd ON fb.published_date_key = dd.date_key
ORDER BY da.name, dd.full_date;