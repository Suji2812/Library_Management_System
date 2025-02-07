-- creating a database LibraryDB
CREATE DATABASE LibraryDB;

-- using database LibraryDB 
USE LibraryDB;

-- creating tables in database LibraryDB

-- Books Table
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    publication_year INT,
    copies_available INT DEFAULT 1
);

-- Members Table
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

-- Borrowing Table
CREATE TABLE Borrowing (
    borrow_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    borrow_date DATE DEFAULT CURDATE(),
    return_date DATE,
    status ENUM('Borrowed', 'Returned') DEFAULT 'Borrowed',
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- Librarians Table
CREATE TABLE Librarians (
    librarian_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Reservations Table
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    reservation_date DATE DEFAULT CURDATE(),
    status ENUM('Reserved', 'Cancelled', 'Completed') DEFAULT 'Reserved',
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);




-- Inserting values into the tables




-- Inserting into Books

INSERT INTO Books (title, author, genre, publication_year, copies_available) VALUES
('The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937, 3),
('1984', 'George Orwell', 'Dystopian', 1949, 2),
('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 1951, 4);

-- Inserting into Members


INSERT INTO Members (name, email, phone) VALUES
('Alice Green', 'alice@mail.com', '1234567890'),
('Bob White', 'bob@mail.com', '0987654321');

-- Inserting into Borrowing Records


INSERT INTO Borrowing (member_id, book_id, borrow_date, return_date, status) VALUES
(1, 1, '2024-02-01', NULL, 'Borrowed'),
(2, 2, '2024-02-03', '2024-02-10', 'Returned');

-- Inserting into Librarians


INSERT INTO Librarians (name, email) VALUES
('David Smith', 'david@mail.com'),
('Emma Brown', 'emma@mail.com');

-- Inserting into Reservations
INSERT INTO Reservations (member_id, book_id, reservation_date, status) VALUES
(1, 2, '2024-02-05', 'Reserved'),
(2, 3, '2024-02-06', 'Completed');




-- querying tables 




-- viewing all available tables


SELECT * FROM Books WHERE copies_available > 0;



-- listing all books with their availability 


SELECT book_id, title, author, genre, publication_year, 
       copies_available, 
       CASE 
           WHEN copies_available > 0 THEN 'Available' 
           ELSE 'Out of Stock' 
       END AS availability_status
FROM Books;



-- finding most borrowed books


SELECT b.title, COUNT(br.borrow_id) AS times_borrowed
FROM Borrowing br
JOIN Books b ON br.book_id = b.book_id
GROUP BY b.title
ORDER BY times_borrowed DESC
LIMIT 5;


-- showing member borrowing history 


SELECT m.name AS member_name, b.title AS book_title, br.borrow_date, br.return_date, br.status
FROM Borrowing br
JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id
WHERE m.member_id = 1; -- Change the member ID as needed



-- counting books borrowed by each member 


SELECT m.name, COUNT(br.borrow_id) AS total_books_borrowed
FROM Members m
LEFT JOIN Borrowing br ON m.member_id = br.member_id
GROUP BY m.name
ORDER BY total_books_borrowed DESC;



-- listings all reservations and their status



SELECT r.reservation_id, m.name AS member_name, b.title AS book_title, r.reservation_date, r.status
FROM Reservations r
JOIN Members m ON r.member_id = m.member_id
JOIN Books b ON r.book_id = b.book_id
ORDER BY r.reservation_date DESC;


-- finding active reservations for a specific book


SELECT m.name AS member_name, b.title, r.reservation_date, r.status
FROM Reservations r
JOIN Members m ON r.member_id = m.member_id
JOIN Books b ON r.book_id = b.book_id
WHERE b.book_id = 2 AND r.status = 'Reserved';


-- listing all librarians

 
SELECT librarian_id, name, email FROM Librarians;


-- finding overdue books and calculate late fees


SELECT br.borrow_id, m.name AS member_name, b.title, br.borrow_date, 
       DATEDIFF(CURDATE(), br.borrow_date) AS overdue_days,
       (DATEDIFF(CURDATE(), br.borrow_date) * 2) AS estimated_fine -- Assuming $2 per day
FROM Borrowing br
JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id
WHERE br.return_date IS NULL AND DATEDIFF(CURDATE(), br.borrow_date) > 14; -- Assuming 14-day limit


-- getting a list of that have been returned 


SELECT b.title, m.name AS borrowed_by, br.borrow_date, br.return_date
FROM Borrowing br
JOIN Books b ON br.book_id = b.book_id
JOIN Members m ON br.member_id = m.member_id
WHERE br.status = 'Returned'
ORDER BY br.return_date DESC;


-- updating book return status and increase available copies


UPDATE Borrowing 
SET return_date = CURDATE(), status = 'Returned' 
WHERE borrow_id = 1; -- Change borrow_id as needed

UPDATE Books 
SET copies_available = copies_available + 1 
WHERE book_id = (SELECT book_id FROM Borrowing WHERE borrow_id = 1);


-- total books in library by genre


SELECT genre, COUNT(*) AS total_books
FROM Books
GROUP BY genre;


-- monthly borrowing trend


SELECT DATE_FORMAT(borrow_date, '%Y-%m') AS month, COUNT(*) AS books_borrowed
FROM Borrowing
GROUP BY month
ORDER BY month DESC;


-- members who have borrowed the most books


SELECT m.name, COUNT(br.borrow_id) AS total_borrowed
FROM Members m
JOIN Borrowing br ON m.member_id = br.member_id
GROUP BY m.name
ORDER BY total_borrowed DESC
LIMIT 5;


-- removing old reservations


DELETE FROM Reservations WHERE reservation_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);


-- finding duplicate member accounts based on e-mail 


SELECT email, COUNT(*) AS duplicate_count
FROM Members
GROUP BY email
HAVING duplicate_count > 1;


-- identifying the books with no borrowing history 


SELECT b.book_id, b.title
FROM Books b
LEFT JOIN Borrowing br ON b.book_id = br.book_id
WHERE br.book_id IS NULL;




-- END --