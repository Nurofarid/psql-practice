-- Lab 08: Foreign Keys and Relationships
-- Run with: bash run.sh   (creates a fresh fk_practice database)
-- Contains 7 EXPECTED errors (marked below).

-- 1. Creating foreign keys
-- Method 1: inline constraint during table creation
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id)
);

-- Method 2: table-level constraint during creation
DROP TABLE employees;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Method 3: adding a constraint to an existing table
DROP TABLE employees;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER
);
ALTER TABLE employees
ADD CONSTRAINT fk_employee_department
FOREIGN KEY (dept_id) REFERENCES departments(dept_id);

-- Method 4: named constraint during table creation
DROP TABLE employees;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
\d employees

-- 2. Referential integrity
INSERT INTO departments (dept_name, location) VALUES
    ('Engineering', 'Building A'),
    ('Marketing', 'Building B'),
    ('HR', 'Building C');
INSERT INTO employees (first_name, last_name, dept_id) VALUES ('John', 'Smith', 1);
-- EXPECTED ERROR: department 99 does not exist
INSERT INTO employees (first_name, last_name, dept_id) VALUES ('Jane', 'Doe', 99);
-- EXPECTED ERROR: department 1 is still referenced by John
DELETE FROM departments WHERE dept_id = 1;

-- 3. ON DELETE CASCADE: child rows are deleted with the parent
DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY;   -- reset the parent table for this test
INSERT INTO departments (dept_name, location) VALUES
    ('Engineering', 'Building A'), ('Marketing', 'Building B'), ('HR', 'Building C');
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id) ON DELETE CASCADE
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
    ('John', 'Smith', 1), ('Aida', 'Asanova', 1), ('Timur', 'Bekov', 2);
DELETE FROM departments WHERE dept_id = 1;
SELECT * FROM employees;

-- 4. ON DELETE SET NULL: child rows stay, their dept_id becomes NULL
DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY;   -- reset the parent table for this test
INSERT INTO departments (dept_name, location) VALUES
    ('Engineering', 'Building A'), ('Marketing', 'Building B'), ('HR', 'Building C');
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id) ON DELETE SET NULL
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
    ('John', 'Smith', 1), ('Aida', 'Asanova', 1), ('Timur', 'Bekov', 2);
DELETE FROM departments WHERE dept_id = 1;
SELECT * FROM employees;

-- 5. ON DELETE SET DEFAULT: child rows get the default value (0)
DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY;   -- reset the parent table for this test
INSERT INTO departments (dept_name, location) VALUES
    ('Engineering', 'Building A'), ('Marketing', 'Building B'), ('HR', 'Building C');
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER DEFAULT 0 REFERENCES departments(dept_id) ON DELETE SET DEFAULT
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
    ('John', 'Smith', 1), ('Aida', 'Asanova', 1), ('Timur', 'Bekov', 2);
-- EXPECTED ERROR: department 0 (the default) does not exist yet
DELETE FROM departments WHERE dept_id = 1;

-- Fix: the default value must exist in the parent table
INSERT INTO departments (dept_id, dept_name) VALUES (0, 'Unassigned');
DELETE FROM departments WHERE dept_id = 1;
SELECT * FROM employees;

-- 6. ON DELETE RESTRICT: the parent cannot be deleted while children exist
DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY;   -- reset the parent table for this test
INSERT INTO departments (dept_name, location) VALUES
    ('Engineering', 'Building A'), ('Marketing', 'Building B'), ('HR', 'Building C');
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id) ON DELETE RESTRICT
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
    ('John', 'Smith', 1), ('Aida', 'Asanova', 1), ('Timur', 'Bekov', 2);
-- EXPECTED ERROR: department 1 still has employees
DELETE FROM departments WHERE dept_id = 1;
-- Works: department 3 (HR) has no employees
DELETE FROM departments WHERE dept_id = 3;

-- 7. ON UPDATE CASCADE (combined with ON DELETE CASCADE)
DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY;   -- reset the parent table for this test
INSERT INTO departments (dept_name, location) VALUES
    ('Engineering', 'Building A'), ('Marketing', 'Building B'), ('HR', 'Building C');
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
    ('John', 'Smith', 1), ('Aida', 'Asanova', 1), ('Timur', 'Bekov', 2);
UPDATE departments SET dept_id = 100 WHERE dept_id = 1;
SELECT * FROM employees;

-- 8. One-to-one: users <-> user_profiles (FOREIGN KEY + UNIQUE)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE user_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    bio TEXT,
    profile_picture_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
INSERT INTO users (username, email) VALUES ('johndoe', 'john@example.com');
INSERT INTO user_profiles (user_id, first_name, last_name, bio) VALUES
    (1, 'John', 'Doe', 'Software developer passionate about databases');
-- EXPECTED ERROR: user 1 already has a profile
INSERT INTO user_profiles (user_id, first_name, last_name) VALUES (1, 'Jane', 'Smith');

-- Alternative one-to-one: sharing the same primary key
DROP TABLE user_profiles;
CREATE TABLE user_profiles (
    user_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    bio TEXT,
    profile_picture_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
INSERT INTO user_profiles (user_id, first_name, last_name, bio) VALUES
    (1, 'John', 'Doe', 'Software developer passionate about databases');
-- EXPECTED ERROR: user 1 already has a profile
INSERT INTO user_profiles (user_id, first_name, last_name) VALUES (1, 'Jane', 'Smith');
-- Deleting the user also deletes the profile (ON DELETE CASCADE)
DELETE FROM users WHERE user_id = 1;
SELECT * FROM user_profiles;

-- 9. One-to-many: departments -> employees
DROP TABLE employees;
DROP TABLE departments;
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    manager_name VARCHAR(100),
    budget DECIMAL(10,2)
);
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100),
    salary DECIMAL(10,2),
    hire_date DATE DEFAULT CURRENT_DATE,
    dept_id INTEGER NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE RESTRICT
);
INSERT INTO departments (dept_name, manager_name, budget) VALUES
    ('Engineering', 'Alice Johnson', 500000.00),
    ('Marketing', 'Bob Wilson', 200000.00);
INSERT INTO employees (first_name, last_name, position, salary, dept_id) VALUES
    ('John', 'Smith', 'Software Engineer', 75000.00, 1),
    ('Jane', 'Doe', 'Senior Developer', 85000.00, 1),
    ('Mike', 'Brown', 'DevOps Engineer', 80000.00, 1),
    ('Sarah', 'Davis', 'Marketing Specialist', 55000.00, 2);
SELECT d.dept_name, e.first_name, e.last_name, e.position
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
ORDER BY d.dept_name, e.last_name;

-- 10. One-to-many: blog_posts -> comments
CREATE TABLE blog_posts (
    post_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author VARCHAR(100),
    published_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE comments (
    comment_id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL,
    commenter_name VARCHAR(100),
    comment_text TEXT NOT NULL,
    comment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES blog_posts(post_id) ON DELETE CASCADE
);
INSERT INTO blog_posts (title, author) VALUES ('My first post', 'Nuri'), ('Learning SQL', 'Nuri');
INSERT INTO comments (post_id, commenter_name, comment_text) VALUES
    (1, 'Aida', 'Great post!'), (1, 'Timur', 'Thanks for sharing'), (2, 'Beka', 'Very useful');
-- Deleting a post deletes its comments (ON DELETE CASCADE)
DELETE FROM blog_posts WHERE post_id = 1;
SELECT comment_id, post_id, commenter_name, comment_text FROM comments;

-- 11. Many-to-many: students <-> courses via the junction table student_enrollments
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    enrollment_date DATE DEFAULT CURRENT_DATE
);
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits INTEGER NOT NULL,
    instructor VARCHAR(100)
);
CREATE TABLE student_enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE (student_id, course_id)
);
INSERT INTO students (first_name, last_name, email) VALUES
    ('Alice', 'Johnson', 'alice@university.edu'),
    ('Bob', 'Smith', 'bob@university.edu'),
    ('Carol', 'Wilson', 'carol@university.edu');
INSERT INTO courses (course_code, course_name, credits, instructor) VALUES
    ('CS101', 'Introduction to Programming', 3, 'Dr. Brown'),
    ('CS201', 'Data Structures', 4, 'Dr. Davis'),
    ('MATH101', 'Calculus I', 4, 'Dr. Wilson');
INSERT INTO student_enrollments (student_id, course_id, grade) VALUES
    (1, 1, 'A'), (1, 2, 'B+'), (2, 1, 'A-'), (2, 3, 'B'), (3, 2, 'A'), (3, 3, 'A-');
-- All enrollments
SELECT s.first_name || ' ' || s.last_name AS student_name,
       c.course_code, c.course_name, se.grade, se.enrollment_date
FROM students s
JOIN student_enrollments se ON s.student_id = se.student_id
JOIN courses c ON se.course_id = c.course_id
ORDER BY s.last_name, c.course_code;
-- All students in a specific course
SELECT s.first_name, s.last_name, se.grade
FROM students s
JOIN student_enrollments se ON s.student_id = se.student_id
JOIN courses c ON se.course_id = c.course_id
WHERE c.course_code = 'CS101';
-- All courses for a specific student
SELECT c.course_code, c.course_name, c.credits, se.grade
FROM courses c
JOIN student_enrollments se ON c.course_id = se.course_id
JOIN students s ON se.student_id = s.student_id
WHERE s.email = 'alice@university.edu';
-- EXPECTED ERROR: Alice is already enrolled in CS101 (UNIQUE)
INSERT INTO student_enrollments (student_id, course_id, grade) VALUES (1, 1, 'C');
