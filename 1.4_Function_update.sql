CREATE OR REPLACE FUNCTION update_book(
    p_book_id INT,
    p_column_name VARCHAR(50),
    p_new_value TEXT
)
RETURNS VOID AS $$
DECLARE
    sql_query TEXT;
BEGIN
    IF p_column_name NOT IN ('title', 'description', 'page_count', 'price', 'currency_code', 'publisher_id', 'language', 'published_date') THEN
        RAISE EXCEPTION 'Invalid column name: %', p_column_name;
    END IF;

    sql_query := format('UPDATE books SET %I = $1 WHERE book_id = $2', p_column_name);

    EXECUTE sql_query USING p_new_value, p_book_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No book found with ID: %', p_book_id;
    END IF;
END;
$$ LANGUAGE plpgsql;