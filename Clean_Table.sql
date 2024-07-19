CREATE TABLE books_clean AS
SELECT DISTINCT ON (title, author)
    id,
    title,
    author,
    rating,
	voters,
	price,
	currency,
	description,
	publisher,
	page_count,
	genres,
    "ISBN",
    language,
    published_date
FROM google_books
ORDER BY title, author, voters DESC;