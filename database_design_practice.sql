-- Database Design Basics practice
-- Run with: psql -d design_practice -f database_design_practice.sql

DROP TABLE IF EXISTS loans, members, book_authors, books, authors,
  enrollments, courses, professors, student_phones, students, departments CASCADE;

-- PART A: University (ER model: Student, Course, Professor)
--   Students ENROLL in Courses (many-to-many -> enrollments)
--   Professors TEACH Courses   (one-to-many  -> courses.professor_id)

-- 1NF: atomic values. BAD: phone_numbers TEXT = '0555-111-222, 0700-333-444'
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE student_phones (
    student_id INT,
    phone_number VARCHAR(15),
    phone_type VARCHAR(20),
    PRIMARY KEY (student_id, phone_number),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
INSERT INTO students VALUES (1, 'Alymbek'), (2, 'Timur');
INSERT INTO student_phones VALUES
    (1, '0555-111-222', 'mobile'),
    (1, '0700-333-444', 'home'),
    (2, '0777-555-666', 'mobile');

-- 2NF: no partial dependencies. BAD: course_name inside enrollments
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT
);
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    grade CHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO courses VALUES (101, 'Database Systems', 6), (102, 'Statistics', 4);
INSERT INTO enrollments VALUES (1, 101, 'A'), (2, 101, 'B+'), (1, 102, 'A-');

-- 3NF: no transitive dependencies. BAD: department_name inside students
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    department_head VARCHAR(100)
);
INSERT INTO departments VALUES
    (10, 'Software Engineering', 'Dr. Asanov'),
    (20, 'Business Administration', 'Dr. Bekova');
ALTER TABLE students ADD COLUMN department_id INT REFERENCES departments(department_id);
UPDATE students SET department_id = 10;

-- Professors TEACH Courses (one-to-many)
CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT REFERENCES departments(department_id)
);
INSERT INTO professors (first_name, last_name, email, department_id) VALUES
    ('Aibek', 'Toktogulov', 'aibek@university.kg', 10),
    ('Gulnara', 'Isaeva', 'gulnara@university.kg', 20);
ALTER TABLE courses ADD COLUMN professor_id INT REFERENCES professors(professor_id);
UPDATE courses SET professor_id = 1 WHERE course_id = 101;
UPDATE courses SET professor_id = 2 WHERE course_id = 102;

SELECT s.name, c.course_name, e.grade,
       p.first_name || ' ' || p.last_name AS professor, d.department_name
FROM enrollments e
JOIN students s    ON e.student_id = s.student_id
JOIN courses c     ON e.course_id = c.course_id
JOIN professors p  ON c.professor_id = p.professor_id
JOIN departments d ON s.department_id = d.department_id;

-- Derived attribute: age from date of birth
SELECT AGE(DATE '2003-05-14') AS age_today;

-- PART B: Library Management System
--   Author WRITES Book (many-to-many -> book_authors)
--   Member BORROWS Book through Loan (one-to-many)
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE
);
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(13) UNIQUE,
    publication_year INTEGER,
    available_copies INTEGER DEFAULT 1
);
CREATE TABLE book_authors (
    book_id INTEGER,
    author_id INTEGER,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);
CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    membership_date DATE DEFAULT CURRENT_DATE
);
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    loan_date DATE DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE,
    late_fee DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
INSERT INTO authors (first_name, last_name) VALUES
    ('Chingiz', 'Aitmatov'), ('Abraham', 'Silberschatz'), ('Henry', 'Korth');
INSERT INTO books (title, isbn, publication_year, available_copies) VALUES
    ('Jamilia', '9780863564048', 1958, 3),
    ('Database System Concepts', '9780078022159', 2019, 2);
INSERT INTO book_authors VALUES (1, 1), (2, 2), (2, 3);
INSERT INTO members (first_name, last_name, email) VALUES
    ('Aida', 'Karimova', 'aida@example.com'),
    ('Timur', 'Bekov', 'timur@example.com');
INSERT INTO loans (member_id, book_id, loan_date, due_date, return_date) VALUES
    (1, 1, '2026-09-01', '2026-09-15', '2026-09-14'),
    (2, 2, '2026-09-20', '2026-10-04', NULL),
    (1, 2, '2026-10-10', '2026-10-24', NULL);

SELECT b.title, a.first_name || ' ' || a.last_name AS author
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
ORDER BY b.title;

SELECT m.first_name, b.title, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE;
