-- ============================================
-- LAB-7: INSTEAD OF TRIGGERS
-- ============================================

-- Create Log table for logging operations
CREATE TABLE Log (
    LogMessage VARCHAR(100),
    LogDate DATETIME
);

SELECT * FROM Log;
GO

-- ============================================
-- PART A
-- ============================================

-- 1. Trigger for blocking student deletion
GO
CREATE OR ALTER TRIGGER TR_BLOCK_STUDENT_DELETION
ON STUDENT
INSTEAD OF DELETE 
AS
BEGIN
    PRINT 'Student deletion is blocked! Operation rolled back.';
    INSERT INTO Log (LogMessage, LogDate)
    VALUES ('Attempted student deletion blocked by trigger', GETDATE());
    ROLLBACK TRANSACTION;
END;
GO

-- Test 1: Try to delete a student
PRINT '=== Test 1: Attempting to delete student ===';
DELETE FROM STUDENT WHERE StudentID = 1;
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- 2. Trigger for making course read-only
GO
CREATE OR ALTER TRIGGER TR_MAKE_COURSE_READONLY
ON COURSE 
INSTEAD OF INSERT, UPDATE, DELETE 
AS
BEGIN
    PRINT 'Course table is read-only! INSERT/UPDATE/DELETE operations are not allowed.';
    INSERT INTO Log (LogMessage, LogDate)
    VALUES ('Attempted modification on read-only COURSE table blocked', GETDATE());
    ROLLBACK TRANSACTION;
END;
GO

-- Test 2: Try to update course
PRINT '=== Test 2: Attempting to update course ===';
UPDATE COURSE SET CourseCredits = 5 WHERE CourseID = 'CS101';
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- 3. Trigger for preventing faculty removal
GO
CREATE OR ALTER TRIGGER TR_PREVENT_FACULTY_REMOVAL
ON FACULTY
INSTEAD OF DELETE 
AS
BEGIN
    PRINT 'Faculty removal is not allowed!';
    INSERT INTO Log (LogMessage, LogDate)
    VALUES ('Attempted faculty deletion blocked by trigger', GETDATE());
    ROLLBACK TRANSACTION;
END;
GO

-- Test 3: Try to delete faculty
PRINT '=== Test 3: Attempting to delete faculty ===';
DELETE FROM FACULTY WHERE FacultyID = 101;
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- 4. Instead of trigger to log all operations on COURSE
GO
CREATE OR ALTER TRIGGER TR_LOG_COURSE_OPERATIONS
ON COURSE
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @OperationType VARCHAR(20);
    
    -- Determine operation type
    IF EXISTS (SELECT * FROM DELETED) AND EXISTS (SELECT * FROM INSERTED)
        SET @OperationType = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM DELETED)
        SET @OperationType = 'DELETE';
    ELSE IF EXISTS (SELECT * FROM INSERTED)
        SET @OperationType = 'INSERT';
    
    -- Log the operation
    INSERT INTO Log (LogMessage, LogDate)
    VALUES 
    ('Attempted ' + @OperationType + ' operation on COURSE table - Blocked by trigger', GETDATE());
    
    PRINT 'Course table modifications are blocked! ' + @OperationType + ' operation prevented.';
    ROLLBACK TRANSACTION;
END;
GO

-- Test 4: Try to insert a course
PRINT '=== Test 4: Attempting to insert course ===';
INSERT INTO COURSE (CourseID, CourseName, CourseCredits, CourseDepartment, CourseSemester)
VALUES ('TEST101', 'Test Course', 3, 'CSE', 1);
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- 5. Trigger to block student enrollment year update
GO
CREATE OR ALTER TRIGGER TR_BLOCK_ENROLLMENT_YEAR_UPDATE
ON STUDENT 
INSTEAD OF UPDATE 
AS
BEGIN
    IF UPDATE(StuEnrollmentYear)
    BEGIN 
        PRINT 'Students are not allowed to update their enrollment year';
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Attempted to update student enrollment year - Blocked', GETDATE());
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Allow other updates to proceed
        UPDATE s
        SET 
            s.StuName = i.StuName,
            s.StuEmail = i.StuEmail,
            s.StuPhone = i.StuPhone,
            s.StuDepartment = i.StuDepartment,
            s.StuDOB = i.StuDOB
        FROM STUDENT s
        INNER JOIN INSERTED i ON s.StudentID = i.StudentID;
        
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Student record updated (excluding enrollment year)', GETDATE());
    END
END;
GO

-- Test 5: Try to update enrollment year
PRINT '=== Test 5: Attempting to update enrollment year ===';
UPDATE STUDENT SET StuEnrollmentYear = 2025 WHERE StudentID = 1;
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 5a: Try to update other student info (should work)
PRINT '=== Test 5a: Attempting to update other student info ===';
UPDATE STUDENT SET StuEmail = 'updated@univ.edu' WHERE StudentID = 1;
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- 6. Trigger for student age validation (Min 18)
GO
CREATE OR ALTER TRIGGER TR_VALIDATE_STUDENT_AGE
ON STUDENT 
INSTEAD OF INSERT 
AS
BEGIN
    -- Check if any inserted student is under 18
    IF EXISTS (
        SELECT 1 
        FROM INSERTED 
        WHERE DATEDIFF(YEAR, StuDOB, GETDATE()) < 18
    )
    BEGIN 
        PRINT 'Cannot add student under 18 years old!';
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Attempted to insert student under 18 years - Blocked', GETDATE());
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Insert valid records
        INSERT INTO STUDENT (StudentID, StuName, StuEmail, StuPhone, StuDepartment, StuDOB, StuEnrollmentYear)
        SELECT StudentID, StuName, StuEmail, StuPhone, StuDepartment, StuDOB, StuEnrollmentYear
        FROM INSERTED;
        
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('New student(s) inserted successfully', GETDATE());
    END
END;
GO

-- Test 6: Try to insert student under 18
PRINT '=== Test 6: Attempting to insert student under 18 ===';
INSERT INTO STUDENT (StudentID, StuName, StuEmail, StuPhone, StuDepartment, StuDOB, StuEnrollmentYear)
VALUES (100, 'Young Student', 'young@univ.edu', '9999999999', 'CSE', '2010-01-01', 2024);
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 6a: Try to insert student above 18 (should work)
PRINT '=== Test 6a: Attempting to insert student above 18 ===';
INSERT INTO STUDENT (StudentID, StuName, StuEmail, StuPhone, StuDepartment, StuDOB, StuEnrollmentYear)
VALUES (101, 'Adult Student', 'adult@univ.edu', '8888888888', 'IT', '2000-01-01', 2024);
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- ============================================
-- PART B
-- ============================================

-- 7. Trigger for unique faculty email check
GO
CREATE OR ALTER TRIGGER TR_ENSURE_UNIQUE_FACULTY_EMAIL
ON FACULTY
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    -- Check for duplicate emails in the inserted/updated data
    IF EXISTS (
        SELECT 1 
        FROM INSERTED i
        INNER JOIN FACULTY f ON i.FacultyEmail = f.FacultyEmail
        WHERE i.FacultyID <> f.FacultyID
    )
    BEGIN
        PRINT 'Email already exists! Faculty emails must be unique.';
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Duplicate faculty email detected - Operation blocked', GETDATE());
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- If UPDATE operation
    IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        UPDATE f
        SET 
            f.FacultyName = i.FacultyName,
            f.FacultyEmail = i.FacultyEmail,
            f.FacultyDepartment = i.FacultyDepartment,
            f.FacultyDesignation = i.FacultyDesignation,
            f.FacultyJoiningDate = i.FacultyJoiningDate
        FROM FACULTY f
        INNER JOIN INSERTED i ON f.FacultyID = i.FacultyID;
        
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Faculty record updated successfully', GETDATE());
    END
    ELSE -- INSERT operation
    BEGIN
        INSERT INTO FACULTY (FacultyID, FacultyName, FacultyEmail, FacultyDepartment, FacultyDesignation, FacultyJoiningDate)
        SELECT FacultyID, FacultyName, FacultyEmail, FacultyDepartment, FacultyDesignation, FacultyJoiningDate
        FROM INSERTED;
        
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('New faculty record inserted successfully', GETDATE());
    END
END;
GO

-- Test 7: Try to insert duplicate email
PRINT '=== Test 7: Attempting to insert duplicate faculty email ===';
INSERT INTO FACULTY (FacultyID, FacultyName, FacultyEmail, FacultyDepartment, FacultyDesignation, FacultyJoiningDate)
VALUES (200, 'Test Faculty', 'sheth@univ.edu', 'CSE', 'Professor', '2020-01-01');
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 7a: Try to update with duplicate email
PRINT '=== Test 7a: Attempting to update with duplicate faculty email ===';
UPDATE FACULTY SET FacultyEmail = 'gupta@univ.edu' WHERE FacultyID = 103;
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 7b: Try to insert unique email (should work)
PRINT '=== Test 7b: Attempting to insert unique faculty email ===';
INSERT INTO FACULTY (FacultyID, FacultyName, FacultyEmail, FacultyDepartment, FacultyDesignation, FacultyJoiningDate)
VALUES (201, 'Test Faculty', 'unique@univ.edu', 'CSE', 'Professor', '2020-01-01');
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- 8. Trigger for preventing duplicate enrollment
GO
CREATE OR ALTER TRIGGER TR_PREVENT_DUPLICATE_ENROLLMENT
ON ENROLLMENT
INSTEAD OF INSERT
AS
BEGIN
    -- Check for duplicate enrollments (same student in same course with same status)
    IF EXISTS (
        SELECT 1 
        FROM INSERTED i
        INNER JOIN ENROLLMENT e 
            ON i.StudentID = e.StudentID 
            AND i.CourseID = e.CourseID
            AND i.EnrollmentStatus = e.EnrollmentStatus
    )
    BEGIN
        PRINT 'Student is already enrolled in this course with the same status!';
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Duplicate enrollment detected - Operation blocked', GETDATE());
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Insert new enrollments
        INSERT INTO ENROLLMENT (StudentID, CourseID, EnrollmentDate, Grade, EnrollmentStatus)
        SELECT StudentID, CourseID, 
               ISNULL(EnrollmentDate, GETDATE()), -- Use current date if null
               Grade, EnrollmentStatus
        FROM INSERTED;
        
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('New enrollment(s) inserted successfully', GETDATE());
    END
END;
GO

-- Test 8: Try to create duplicate enrollment
PRINT '=== Test 8: Attempting to create duplicate enrollment ===';
INSERT INTO ENROLLMENT (StudentID, CourseID, EnrollmentDate, Grade, EnrollmentStatus)
VALUES (1, 'CS101', GETDATE(), 'A', 'Active');
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 8a: Try to create enrollment with different status (should work)
PRINT '=== Test 8a: Attempting to create enrollment with different status ===';
INSERT INTO ENROLLMENT (StudentID, CourseID, EnrollmentDate, Grade, EnrollmentStatus)
VALUES (1, 'CS101', GETDATE(), 'A', 'Completed');
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 8b: Try to create new enrollment (should work)
PRINT '=== Test 8b: Attempting to create new enrollment ===';
INSERT INTO ENROLLMENT (StudentID, CourseID, EnrollmentDate, Grade, EnrollmentStatus)
VALUES (2, 'CS302', GETDATE(), NULL, 'Active');
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- ============================================
-- PART C
-- ============================================

-- 9. Trigger to allow enrolment only from Jan to August
GO
CREATE OR ALTER TRIGGER TR_ENROLLMENT_MONTH_RESTRICTION
ON ENROLLMENT
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @CurrentMonth INT = MONTH(GETDATE());
    DECLARE @Message VARCHAR(100);
    
    -- Check if current month is between Jan (1) and Aug (8)
    IF @CurrentMonth BETWEEN 1 AND 8
    BEGIN
        -- Allow enrollment
        INSERT INTO ENROLLMENT (StudentID, CourseID, EnrollmentDate, Grade, EnrollmentStatus)
        SELECT StudentID, CourseID, 
               ISNULL(EnrollmentDate, GETDATE()), -- Use current date if null
               Grade, EnrollmentStatus
        FROM INSERTED;
        
        SET @Message = 'Enrollment(s) inserted successfully (Month ' + 
                      CAST(@CurrentMonth AS VARCHAR(2)) + ' is within Jan-Aug)';
        PRINT @Message;
        INSERT INTO Log (LogMessage, LogDate)
        VALUES (@Message, GETDATE());
    END
    ELSE
    BEGIN
        SET @Message = 'Enrollment closed! Current month ' + 
                      CAST(@CurrentMonth AS VARCHAR(2)) + 
                      ' is outside allowed range (Jan-Aug).';
        PRINT @Message;
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Enrollment attempted outside allowed months (Jan-Aug) - Blocked', GETDATE());
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Test 9: Try to enroll (will depend on current month)
PRINT '=== Test 9: Attempting to enroll (depends on current month) ===';
DECLARE @CurrentMonth INT = MONTH(GETDATE());
PRINT 'Current month is: ' + CAST(@CurrentMonth AS VARCHAR(2));

INSERT INTO ENROLLMENT (StudentID, CourseID, EnrollmentDate, Grade, EnrollmentStatus)
VALUES (3, 'IT101', GETDATE(), 'B+', 'Active');
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- 10. Trigger to allow only grade change in enrollment
GO
CREATE OR ALTER TRIGGER TR_ONLY_GRADE_CHANGE_ALLOWED
ON ENROLLMENT
INSTEAD OF UPDATE
AS
BEGIN
    -- Check if any column other than Grade is being updated
    IF UPDATE(StudentID) OR UPDATE(CourseID) OR UPDATE(EnrollmentDate) OR UPDATE(EnrollmentStatus)
    BEGIN
        PRINT 'Only grade changes are allowed in enrollment records!';
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Attempted to modify non-grade fields in ENROLLMENT - Blocked', GETDATE());
        ROLLBACK TRANSACTION;
    END
    ELSE IF UPDATE(Grade)
    BEGIN
        -- Allow grade update
        UPDATE e
        SET e.Grade = i.Grade
        FROM ENROLLMENT e
        INNER JOIN INSERTED i ON e.EnrollmentID = i.EnrollmentID;
        
        INSERT INTO Log (LogMessage, LogDate)
        VALUES ('Grade updated successfully in ENROLLMENT table', GETDATE());
        PRINT 'Grade updated successfully!';
    END
END;
GO

-- Test 10: Try to update non-grade field
PRINT '=== Test 10: Attempting to update enrollment status ===';
UPDATE ENROLLMENT SET EnrollmentStatus = 'Completed' WHERE EnrollmentID = 1;
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 10a: Try to update grade (should work)
PRINT '=== Test 10a: Attempting to update grade ===';
UPDATE ENROLLMENT SET Grade = 'A+' WHERE EnrollmentID = 1;
SELECT * FROM Log ORDER BY LogDate DESC;

-- Test 10b: Try to update multiple fields
PRINT '=== Test 10b: Attempting to update multiple fields ===';
UPDATE ENROLLMENT SET Grade = 'B', EnrollmentStatus = 'Active' WHERE EnrollmentID = 1;
SELECT * FROM Log ORDER BY LogDate DESC;
GO

-- ============================================
-- FINAL SUMMARY
-- ============================================

-- View all triggers created
PRINT '=== All INSTEAD OF Triggers Created ===';
SELECT 
    name AS TriggerName,
    OBJECT_NAME(parent_id) AS TableName,
    type_desc AS TriggerType,
    is_instead_of_trigger AS IsInsteadOfTrigger
FROM sys.triggers
WHERE is_instead_of_trigger = 1
ORDER BY TableName;

-- View all logs
PRINT '=== All Log Entries ===';
SELECT * FROM Log ORDER BY LogDate DESC;

-- Summary of log entries
PRINT '=== Summary of Log Entries ===';
SELECT 
    LEFT(LogMessage, 50) AS LogSummary,
    COUNT(*) AS Count,
    MAX(LogDate) AS LastOccurrence
FROM Log 
GROUP BY LEFT(LogMessage, 50)
ORDER BY Count DESC;

-- ============================================
-- CLEANUP (Optional - Comment out to keep triggers)
-- ============================================
/*
PRINT '=== Cleaning up all triggers ===';
DROP TRIGGER IF EXISTS TR_BLOCK_STUDENT_DELETION;
DROP TRIGGER IF EXISTS TR_MAKE_COURSE_READONLY;
DROP TRIGGER IF EXISTS TR_PREVENT_FACULTY_REMOVAL;
DROP TRIGGER IF EXISTS TR_LOG_COURSE_OPERATIONS;
DROP TRIGGER IF EXISTS TR_BLOCK_ENROLLMENT_YEAR_UPDATE;
DROP TRIGGER IF EXISTS TR_VALIDATE_STUDENT_AGE;
DROP TRIGGER IF EXISTS TR_ENSURE_UNIQUE_FACULTY_EMAIL;
DROP TRIGGER IF EXISTS TR_PREVENT_DUPLICATE_ENROLLMENT;
DROP TRIGGER IF EXISTS TR_ENROLLMENT_MONTH_RESTRICTION;
DROP TRIGGER IF EXISTS TR_ONLY_GRADE_CHANGE_ALLOWED;

PRINT '=== All triggers dropped ===';
SELECT COUNT(*) AS RemainingTriggers FROM sys.triggers WHERE is_instead_of_trigger = 1;
*/