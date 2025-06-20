-- Created Database as Library_Management_system
-- Create Tables

-- Create Branch Table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch 
	(
		branch_id VARCHAR(10) PRIMARY KEY,
		manager_id VARCHAR(10),
		branch_address VARCHAR(20),
		contact_no VARCHAR(15)
	);
	
-- Create Employee Table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(
		emp_id VARCHAR(10) PRIMARY KEY,
		emp_name VARCHAR(25),
		position VARCHAR(15),
		salary INT,
		branch_id VARCHAR(20)  -- FK
	);

-- Create Employee Table
DROP TABLE IF EXISTS books;
CREATE TABLE books
	(
		isbn VARCHAR(20) PRIMARY KEY,
		book_title VARCHAR(75),
		category VARCHAR(25),
		rental_price FLOAT, 
		status VARCHAR(10),
		author VARCHAR(35),
		publisher VARCHAR(55)
	);

-- Create members Table
DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
		member_id VARCHAR(20) PRIMARY KEY,
		member_name VARCHAR(30),
		member_address VARCHAR(75),
		reg_date DATE
	);

-- Create issued_status Table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(
		issued_id VARCHAR(20) PRIMARY KEY,
		issued_member_id VARCHAR(10),  -- FK
		issued_book_name VARCHAR(75),
		issued_date DATE,
		issued_book_isbn VARCHAR(25),  -- FK
		issued_emp_id VARCHAR(10)      -- FK
	);

-- Create Table return_status
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(
		return_id VARCHAR(10) PRIMARY KEY,
		issued_id VARCHAR(10),  -- FK
		return_book_name VARCHAR(25),
		return_date DATE,
		return_book_isbn VARCHAR(25)
	);


-- FOREIGN KEY
-- Add Foriegn Key for Issued status from members
ALTER TABLE issued_status
ADD CONSTRAINT fk_status
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

-- Add Foreifn key for Issued status from books
ALTER TABLE issued_status
ADD CONSTRAINT fw_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

-- Add Foreign Key for Issued status from employees
ALTER TABLE issued_status
ADD CONSTRAINT fw_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

-- Add Foreign Key for Employees from Branch
ALTER TABLE employees
ADD CONSTRAINT fw_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- Add Foreign Key for return_status id from issued_status
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);






