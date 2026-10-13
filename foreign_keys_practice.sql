-- Foreign Keys and Relationships practice
-- Run with: psql -d fk_practice -f foreign_keys_practice.sql

DROP TABLE IF EXISTS student_enrollments, students, courses, comments, blog_posts,
  user_profiles, users, employees, departments CASCADE;

-- 1. Creating foreign keys (4 methods)
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);
-- Method 1: dept_id INTEGER REFERENCES departments(dept_id)
-- Method 2: FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
-- Method 3: ALTER TABLE employees ADD CONSTRAINT fk_employee_department
--           FOREIGN KEY (dept_id) REFERENCES departments(dept_id);
-- Method 4 (named constraint):
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INTEGER,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- 2. Referential integrity
INSERT INTO departments (dept_name, location) VALUES
    ('Engineering', 'Building A'), ('Marketing', 'Building B'), ('HR', 'Building C');
INSERT INTO employees (first_name, last_name, dept_id) VALUES ('John', 'Smith', 1);
-- dept_id = 99                               -> ERROR: violates foreign key constraint
-- DELETE FROM departments WHERE dept_id = 1; -> ERROR: still referenced

-- 3. CASCADE options
-- ON DELETE CASCADE     -> children deleted with the parent
-- ON DELETE SET NULL    -> child key becomes NULL
-- ON DELETE SET DEFAULT -> child key becomes its DEFAULT (that value must exist in the parent!)
-- ON DELETE RESTRICT    -> parent cannot be deleted while children exist
-- ON UPDATE CASCADE     -> changing the parent key updates the children

-- 4. One-to-one
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
-- second profile for user 1 -> ERROR: duplicate key (UNIQUE)

-- 5. One-to-many
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
    ('Engineering', 'Alice Johnson', 500000.00), ('Marketing', 'Bob Wilson', 200000.00);
INSERT INTO employees (first_name, last_name, position, salary, dept_id) VALUES
    ('John', 'Smith', 'Software Engineer', 75000.00, 1),
    ('Jane', 'Doe', 'Senior Developer', 85000.00, 1),
    ('Mike', 'Brown', 'DevOps Engineer', 80000.00, 1),
    ('Sarah', 'Davis', 'Marketing Specialist', 55000.00, 2);
SELECT d.dept_name, e.first_name, e.last_name, e.position
FROM departments d JOIN employees e ON d.dept_id = e.dept_id
ORDER BY d.dept_name, e.last_name;

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

-- 6. Many-to-many
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

SELECT s.first_name || ' ' || s.last_name AS student_name,
       c.course_code, c.course_name, se.grade, se.enrollment_date
FROM students s
JOIN student_enrollments se ON s.student_id = se.student_id
JOIN courses c ON se.course_id = c.course_id
ORDER BY s.last_name, c.course_code;
