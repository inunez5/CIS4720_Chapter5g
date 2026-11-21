/* ==========================================================================
   lab5g_starter.sql
   CIS 4720 Database Management and SQL
   In Class Lab 5g, Procedures That Make Decisions

   WHAT THIS FILE IS
   Lab 5f finished, plus a numbered heading for every step of Lab 5g waiting
   to be filled in.

   WHAT IT ALREADY BUILDS
     1. Everything Lab 5f started from: the tables, the view, the function,
        attendance and the two triggers
     2. The three procedures from Lab 5f: list_students (highest gpa
        first), student_report and scores_for_test

   HOW TO RUN IT
   One statement at a time. Put the cursor on it and press Ctrl + E twice.
   Anything that runs from CREATE down to END (a function, a trigger or a
   procedure) is ONE statement, however many semicolons are inside it.
   Select the whole block and run the selection. No DELIMITER lines.

   LABELING AND COMMENTING IS REQUIRED
   Above every statement you write, put a short comment in your own words
   saying what it does. The comments are graded.
   ========================================================================== */


-- =================================================================
-- SETUP. Run these three first, one at a time, while you are still
-- connected to information_schema.
-- =================================================================

-- every schema on this server. cis_students_db may or may not be listed.
show databases;

-- make yours. IF NOT EXISTS means it is safe to run twice.
create database if not exists cis_students_db;

-- switch into it, so everything below lands in the right place.
use cis_students_db;


-- ==================================================================
-- FROM LAB 5D. students. student_id is a surrogate key the server fills in.
-- ==================================================================
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name  VARCHAR(40) NOT NULL,
    gpa        FLOAT(4,2)
);
INSERT INTO students VALUES (NULL,'Jenna','Wilson',NULL);
INSERT INTO students VALUES (NULL,'Robert','Reese',NULL);
INSERT INTO students VALUES (NULL,'Maria Elena','Jimenez',NULL);
INSERT INTO students VALUES (NULL,'Inder','Singh',NULL);
INSERT INTO students (first_name,last_name) VALUES ('Rita','Nunez');
INSERT INTO students (first_name,last_name) VALUES ('James','Toor');

-- ==================================================================
-- James was student 6. Deleting him is why the counter says 7.
-- ==================================================================
DELETE FROM students WHERE first_name = 'James' AND last_name = 'Toor';

-- ==================================================================
-- FROM LAB 5D. test_scores, linked to students by a foreign key.
-- ==================================================================
CREATE TABLE test_scores (
    test_score_id INT AUTO_INCREMENT PRIMARY KEY,
    test_name     VARCHAR(20) NOT NULL,
    student_id    INT NOT NULL,
    score         FLOAT,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
INSERT INTO test_scores VALUES (NULL,'quiz1',1,90),(NULL,'quiz1',2,85),(NULL,'quiz1',3,95),
 (NULL,'quiz2',1,80),(NULL,'quiz2',2,72),(NULL,'quiz2',3,88),(NULL,'quiz2',4,91),
 (NULL,'quiz3',2,95),(NULL,'quiz3',3,94),(NULL,'quiz3',4,74);

-- ==================================================================
-- FROM LAB 5D. The student_scores view.
-- ==================================================================
CREATE VIEW student_scores AS
SELECT s.student_id,
       CONCAT(s.first_name, ' ', s.last_name) AS student_name,
       t.test_name,
       t.score
FROM students s
LEFT OUTER JOIN test_scores t ON s.student_id = t.student_id;

-- ==================================================================
-- FROM LAB 5D. The calculate_gpa function. Select the whole block from
-- CREATE FUNCTION down to END and run the selection.
-- ==================================================================
CREATE FUNCTION calculate_gpa(p_student_id INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_gpa DECIMAL(4,2);

    SELECT ROUND(AVG(score), 2)
    INTO v_gpa
    FROM test_scores
    WHERE student_id = p_student_id
      AND score IS NOT NULL;

    RETURN IFNULL(v_gpa, 0.00);
END;

-- ==================================================================
-- Fill in every gpa using the function.
-- ==================================================================
UPDATE students SET gpa = calculate_gpa(student_id);

-- ==================================================================
-- FROM LAB 5E. attendance, with its surrogate key starting at 500.
-- ==================================================================
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id    INT NOT NULL,
    attended_on   DATE,
    status        VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
) AUTO_INCREMENT = 500;
INSERT INTO attendance (student_id, attended_on, status) VALUES (1,'2026-10-05','present');
INSERT INTO attendance (student_id, attended_on, status) VALUES (2,'2026-10-05','absent');
INSERT INTO attendance (student_id, attended_on, status) VALUES (3,'2026-10-06','present');

-- ==================================================================
-- FROM LAB 5E. The BEFORE INSERT trigger. Select the whole block and run the selection.
-- ==================================================================
CREATE TRIGGER trg_attendance_before_insert
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
    IF NEW.attended_on IS NULL THEN
        SET NEW.attended_on = CURDATE();
    END IF;
    SET NEW.status = UPPER(NEW.status);
END;

-- ==================================================================
-- FROM LAB 5E. The AFTER DELETE trigger. Select the whole block and run the selection.
-- ==================================================================
CREATE TRIGGER trg_scores_after_delete
AFTER DELETE ON test_scores
FOR EACH ROW
BEGIN
    UPDATE students
    SET gpa = calculate_gpa(OLD.student_id)
    WHERE student_id = OLD.student_id;
END;

-- ==================================================================
-- FROM LAB 5E Step 9. The row the BEFORE trigger filled in. It becomes 503.
-- ==================================================================
INSERT INTO attendance (student_id, status) VALUES (4,'present');


-- ======================================================================
-- FROM LAB 5F. The three procedures.
-- Each procedure is one statement. Select the whole block and run it.
-- ======================================================================

-- ==================================================================
-- FROM LAB 5F Step 6. list_students, highest gpa first.
-- ==================================================================
CREATE PROCEDURE list_students()
BEGIN
    SELECT student_id, first_name, last_name, gpa
    FROM students
    ORDER BY gpa DESC;
END;

-- ==================================================================
-- FROM LAB 5F Step 4. student_report.
-- ==================================================================
CREATE PROCEDURE student_report(IN p_student_id INT)
BEGIN
    SELECT student_name, test_name, score
    FROM student_scores
    WHERE student_id = p_student_id;
END;

-- ==================================================================
-- FROM LAB 5F Step 7. scores_for_test.
-- ==================================================================
CREATE PROCEDURE scores_for_test(IN p_test_name VARCHAR(20))
BEGIN
    SELECT student_name, score
    FROM student_scores
    WHERE test_name = p_test_name
    ORDER BY score DESC;
END;


-- ======================================================================
-- CHECKS. Highest gpa first: 92.33, 85.00, 84.00, 82.50, 0.00.
-- ======================================================================

CALL list_students();


-- ######################################################################
-- YOUR LAB 5G WORK STARTS BELOW THIS LINE
--
-- LABELING AND COMMENTING IS REQUIRED. It is worth a full point.
--
-- You write Steps 4, 6, 8, 9 and 10 yourself. Steps 3 and 7 are
-- skeletons with one statement for you to write. Step 5 is mostly yours.
-- ######################################################################


-- =================================================================
-- STEP 3. Create add_score
--
-- Copy the skeleton from the handout and write the INSERT.
-- =================================================================

-- makes a procedure that adds a test score and then fixes that student's gpa right after
CREATE PROCEDURE add_score(IN p_test_name VARCHAR(20),
                           IN p_student_id INT,
                           IN p_score FLOAT)
BEGIN
    -- puts the new score into test_scores (no quotes so it uses the actual values)
    INSERT INTO test_scores (test_name, student_id, score)
    VALUES (p_test_name, p_student_id, p_score);

    -- recalculates the gpa for just that student so it counts the new score
    UPDATE students
    SET gpa = calculate_gpa(p_student_id)
    WHERE student_id = p_student_id;
END


-- =================================================================
-- STEP 4. Use add_score, and watch the gpa change
-- =================================================================

-- adds an 88 on quiz4 for Rita (student 5), her first score
CALL add_score('quiz4', 5, 88);

-- adds a 100 on quiz4 for Jenna (student 1)
CALL add_score('quiz4', 1, 100);

-- lists everyone by gpa, Jenna should be 90 now and Rita 88
CALL list_students();


-- =================================================================
-- STEP 5. Write record_attendance
--
-- Most of this one is yours. The handout walks you through it.
-- =================================================================

-- makes a procedure that records attendance with just the student and status,
-- the trigger from 5e fills in the date and makes the status all caps
CREATE PROCEDURE record_attendance(IN p_student_id INT,
                                   IN p_status VARCHAR(10))
BEGIN
    -- only inserts student_id and status, leaves the id and date for the db to handle
    INSERT INTO attendance (student_id, status)
    VALUES (p_student_id, p_status);
END


-- =================================================================
-- STEP 6. Test record_attendance
-- =================================================================

-- marks student 2 absent, typed lowercase on purpose to see the trigger fix it
CALL record_attendance(2, 'absent');

-- checks the attendance table, new row should be 504 with today's date and ABSENT
SELECT * FROM attendance;


-- =================================================================
-- STEP 7. Create remove_score
--
-- Copy the skeleton and write the DELETE.
-- =================================================================

-- makes a procedure that deletes one test score for one student
CREATE PROCEDURE remove_score(IN p_student_id INT,
                              IN p_test_name VARCHAR(20))
BEGIN
    -- only deletes the row where BOTH the student and test name match
    DELETE FROM test_scores
    WHERE student_id = p_student_id
      AND test_name = p_test_name;
END


-- =================================================================
-- STEP 8. Test remove_score
-- =================================================================

-- removes Jenna's quiz4 score (student 1)
CALL remove_score(1, 'quiz4');

-- checks Jenna's gpa went back to 85, the after delete trigger fixed it not the procedure
SELECT first_name, last_name, gpa FROM students WHERE student_id = 1;


-- =================================================================
-- STEP 9. Two problems, left open on purpose
--
-- Under each call, a comment on what happened and what should have.
-- =================================================================

-- problem 1: adds a score of -20 on quiz5 for Inder (student 4)
CALL add_score('quiz5', 4, -20);

-- shows the gpas after the bad score
CALL list_students();
-- what happened: it took the -20 with no problem and Inder's gpa dropped from 82.50 to 48.33
-- what should have happened: a negative score shouldn't be allowed in at all, the procedure
-- should check the score first and reject it

-- problem 2: removes the bad quiz5 score for Inder
CALL remove_score(4, 'quiz5');

-- shows the gpas again after cleaning it up
CALL list_students();
-- what happened: the -20 got deleted and Inder is back to 82.50
-- what should have happened: this part worked, but it's only a cleanup. we had to fix it after
-- the fact because nothing stopped it from going in the first place

-- problem 3: tries to record attendance for student 9, who doesn't exist
CALL record_attendance(9, 'present');
-- what happened: ERROR 1452, cannot add or update a child row, foreign key constraint fails
-- what should have happened: the foreign key kept bad data out which is good, but the error is
-- confusing for a normal user. the procedure should check if the student exists and give a
-- clear message like "student 9 does not exist"


-- =================================================================
-- STEP 10. List every routine in your schema
-- =================================================================

-- lists every function and procedure in cis_students_db in alphabetical order
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'cis_students_db'
ORDER BY routine_name;


-- =================================================================
-- STEP 11 and 12. Push to GitHub and submit the URL
--
-- Nothing to write here. Follow the handout.
-- =================================================================

-- nothing to run here, this part is just pushing to github and turning in the link
