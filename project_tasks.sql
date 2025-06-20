SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Project Tasks
-- ### 2. CRUD Operations
-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT *FROM books;

-- Task 2: Update an Existing Member's Address

SELECT * FROM members;
UPDATE members
SET member_address = '125 Hyderabad St'
WHERE member_id = 'C101';


-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.


DELETE FROM issued_status
WHERE issued_id = 'IS104';
SELECT * FROM issued_status;  -- IS104 Is Deleted

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM employees
WHERE emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT * FROM issued_status;
SELECT 
	issued_emp_id,
	COUNT(issued_emp_id) AS tot_books_issued
FROM issued_status
GROUP BY 1
HAVING COUNT(issued_emp_id) > 1;

-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

CREATE TABLE book_cnts
AS

SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS issue_id
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

-- New TABLE Is created as 
SELECT * FROM book_cnts;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9. **List Members Who Registered in the Last 180 Days**:

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES 
('C131',	'alex', '819 dsj', '2025-03-11'),
('C132',	'alex', '819 dsj', '2025-04-23');

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS manager_name
FROM employees AS e1
JOIN branch AS b
ON b.branch_id = e1.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USE
CREATE TABLE books_price_greater_than_seven
AS
SELECT * FROM books
WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_seven;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
	DISTINCT(ist.issued_book_name)
FROM issued_status AS ist
LEFT JOIN
return_status AS rs
ON rs.return_id = ist.issued_id
WHERE rs.return_id IS NULL;


-- Before Doing Advanced SQL We add some Records to our Tables

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

SELECT * FROM issued_status;

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

SELECT * FROM return_status;

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
	
SELECT * FROM return_status;


/*
### Advanced SQL Operations

Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

-- Logic
-- To JOIN --> issued_status == Members == Books == return_status
-- Filter books which is return
-- Overdue > 30 days
*/

SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date  AS overDue
FROM issued_status AS ist
	JOIN members AS m
ON m.member_id = ist.issued_member_id
	JOIN books AS b
ON ist.issued_book_isbn = b.isbn
	LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL 
	AND CURRENT_DATE - ist.issued_date > 30
ORDER BY 1;


/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "yes" when they are returned (based on entries in the return_status table).
*/

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-330-25864-8';
-- IS140
SELECT * FROM Books
WHERE isbn = '978-0-330-25864-8';

SELECT * FROM return_status
WHERE issued_id = 'IS140';

SELECT * FROM return_status;

INSERT INTO return_status (return_id, issued_id, return_date, book_quality) 
VALUES 
('RS125', 'IS140', CURRENT_DATE, 'Good');

SELECT * FROM return_status
WHERE issued_id = 'IS140';

--  I want to do Dynamically, we have concept called Stored Procedures

CREATE OR REPLACE PROCEDURE return_record(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$
DECLARE
	v_isbn VARCHAR(20);
	v_book_name VARCHAR(75);
	BEGIN
		-- Insert query Based on the data
		INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
		VALUES 
		(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
		-- Select the data
		SELECT
			issued_book_isbn,
			issued_book_name
			INTO
			v_isbn,
			v_book_name
		FROM issued_status
		WHERE issued_id = p_issued_id;

		-- Update the status to yes
		UPDATE books
		SET status = 'yes'
		WHERE isbn = v_isbn;
		RAISE NOTICE 'Thank you for returning the book : %', v_book_name;
	END;
$$

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';


-- Call the Procedure
CALL return_record('RS138', 'IS140', 'Good');
SELECT * FROM return_status
WHERE issued_id = 'IS140';


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

CREATE TABLE branch_reports
AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS number_book_isbn,
	COUNT(rs.return_id) AS number_return_id,
	SUM(bk.rental_price) as Total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.
*/
DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE 
	member_id IN (
				 	SELECT DISTINCT member_id
					FROM issued_status 
					WHERE 
						issued_date > CURRENT_DATE - INTERVAL '6 month'
				 );

SELECT * FROM active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/

SELECT
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) AS no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON ist.issued_emp_id = e.emp_id
JOIN
branch as b
ON b.branch_id = e.branch_id
GROUP BY 1, 2;

/*
Task 18: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;
	IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;

    
END;
$$

SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;


CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

