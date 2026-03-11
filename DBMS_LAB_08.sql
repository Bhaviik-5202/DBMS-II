------------- LAB 8: Exception Handling  ---->

---------------------------
-- PART A :--
--------------------------- 
--1. Handle Divide by Zero Error and Print message like: Error occurs that is - Divide by zero error.
BEGIN TRY
    DECLARE @num1 INT = 10, @num2 INT = 0, @result INT;
    SET @result = @num1 / @num2;
    PRINT 'Result: ' + CAST(@result AS VARCHAR);
END TRY
BEGIN CATCH
    PRINT 'Error occurs that is - Divide by zero error.';
END CATCH;
GO


--2. Try to convert string to integer and handle the error using try…catch block.
BEGIN TRY
    DECLARE @str VARCHAR(10) = 'ABC', @num INT;
    SET @num = CAST(@str AS INT);
    PRINT 'Converted number: ' + CAST(@num AS VARCHAR);
END TRY
BEGIN CATCH
    PRINT 'Error: Cannot convert string to integer.';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
END CATCH;
GO


--3. Create a procedure that prints the sum of two numbers: take both numbers as integer & handle
--exception with all error functions if any one enters string value in numbers otherwise print result.
CREATE OR ALTER PROCEDURE sp_SumNumbers
    @num1 VARCHAR(20),
    @num2 VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        DECLARE @int1 INT, @int2 INT, @sum INT;
        
        SET @int1 = CAST(@num1 AS INT);
        SET @int2 = CAST(@num2 AS INT);
        SET @sum = @int1 + @int2;
        
        PRINT 'First Number: ' + CAST(@int1 AS VARCHAR);
        PRINT 'Second Number: ' + CAST(@int2 AS VARCHAR);
        PRINT 'Sum: ' + CAST(@sum AS VARCHAR);
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'Ad-hoc');
    END CATCH
END;
GO

-- Test the procedure
EXEC sp_SumNumbers '10', '20';  -- Valid input
EXEC sp_SumNumbers '10', 'ABC';  -- Invalid input
GO
 

--4. Handle a Primary Key Violation while inserting data into student table and print the error details such 
--as the error message, error number, severity, and state.
CREATE TABLE student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    course VARCHAR(50)
);
GO

-- Insert some sample data
INSERT INTO student VALUES (1, 'John Doe', 'Computer Science');
INSERT INTO student VALUES (2, 'Jane Smith', 'Mathematics');
GO

-- Try to insert duplicate primary key
BEGIN TRY
    INSERT INTO student VALUES (1, 'Bob Wilson', 'Physics');
END TRY
BEGIN CATCH
    PRINT 'Primary Key Violation Error Details:';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH;
GO


--5. Throw custom exception using stored procedure which accepts StudentID as input & that throws 
--Error like no StudentID is available in database.
CREATE OR ALTER PROCEDURE sp_CheckStudent
    @StudentID INT
AS
BEGIN
    DECLARE @student_count INT;
    
    SELECT @student_count = COUNT(*) FROM student WHERE student_id = @StudentID;
    
    IF @student_count = 0
    BEGIN
        -- Throw custom exception
        DECLARE @ErrorMessage NVARCHAR(4000) = 'No StudentID ' + CAST(@StudentID AS VARCHAR) + ' is available in database.';
        RAISERROR(@ErrorMessage, 16, 1);
    END
    ELSE
    BEGIN
        PRINT 'Student ID ' + CAST(@StudentID AS VARCHAR) + ' exists in database.';
        SELECT * FROM student WHERE student_id = @StudentID;
    END
END;
GO

-- Test the procedure
BEGIN TRY
    EXEC sp_CheckStudent 1;  -- Existing student
    EXEC sp_CheckStudent 5;  -- Non-existing student
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;
GO


--6. Handle a Foreign Key Violation while inserting data into Enrollment table and print appropriate error 
--message. 
CREATE TABLE enrollment (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_name VARCHAR(50),
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES student(student_id)
);
GO

-- Insert some valid data
INSERT INTO enrollment VALUES (1, 1, 'Database Systems', '2024-01-15');
INSERT INTO enrollment VALUES (2, 2, 'Data Structures', '2024-01-16');
GO

-- Try to insert with invalid foreign key
BEGIN TRY
    INSERT INTO enrollment VALUES (3, 5, 'Algorithms', '2024-01-17');
END TRY
BEGIN CATCH
    PRINT 'Foreign Key Violation Error:';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'The StudentID you are trying to reference does not exist in the student table.';
    PRINT 'Please ensure the student exists before enrolling them in a course.';
END CATCH;
GO


---------------------------
-- PART B :--
--------------------------- 
--7. Handle Invalid Date Format 
CREATE OR ALTER PROCEDURE sp_CheckDate
    @date_string VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        DECLARE @valid_date DATE;
        SET @valid_date = CONVERT(DATE, @date_string);
        PRINT 'Valid Date: ' + CONVERT(VARCHAR, @valid_date);
    END TRY
    BEGIN CATCH
        PRINT 'Invalid Date Format Error:';
        PRINT 'The provided date "' + @date_string + '" is not in a valid format.';
        PRINT 'Please use formats like: YYYY-MM-DD, MM/DD/YYYY, or DD-MM-YYYY';
        PRINT 'Error Details: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Test the procedure
EXEC sp_CheckDate '2024-03-15';  -- Valid date
EXEC sp_CheckDate '15-03-2024';  -- Valid date
EXEC sp_CheckDate '2024/03/15';  -- Valid date
EXEC sp_CheckDate 'invalid-date'; -- Invalid date
EXEC sp_CheckDate '2024-13-45';  -- Invalid date
GO

--8. Procedure to Update faculty’s Email with Error Handling.
CREATE TABLE faculty_info (
    faculty_id INT PRIMARY KEY,
    faculty_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),    department VARCHAR(50),
    salary DECIMAL(10, 2)
);
GO

-- Insert sample data with correct column count
INSERT INTO faculty_info (faculty_id, faculty_name, email, department, salary) 
VALUES 
    (1, 'Dr. Smith', 'smith@university.edu', 'Computer Science', 75000.00),
    (2, 'Prof. Johnson', 'johnson@university.edu', 'Mathematics', 68000.00),
    (3, 'Dr. Williams', 'williams@university.edu', 'Physics', 72000.00);
GO

-- Create the stored procedure
CREATE OR ALTER PROCEDURE sp_UpdateFacultyEmailInfo
    @faculty_id INT,
    @new_email VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        -- Check if email is NULL
        IF @new_email IS NULL
        BEGIN
            RAISERROR('Email cannot be NULL. Please provide a valid email address.', 16, 1);
            RETURN;
        END
        
        -- Check if email format is valid (contains @ and .)
        IF @new_email NOT LIKE '%@%.%'
        BEGIN
            RAISERROR('Invalid email format. Email must contain @ and a domain (e.g., name@domain.com).', 16, 1);
            RETURN;
        END
        
        -- Check if faculty exists
        IF NOT EXISTS (SELECT 1 FROM faculty_info WHERE faculty_id = @faculty_id)
        BEGIN
            RAISERROR('Faculty ID %d not found in the database.', 16, 1, @faculty_id);
            RETURN;
        END
        
        -- Check if email already exists for another faculty
        IF EXISTS (SELECT 1 FROM faculty_info WHERE email = @new_email AND faculty_id != @faculty_id)
        BEGIN
            RAISERROR('Email %s is already in use by another faculty member.', 16, 1, @new_email);
            RETURN;
        END
        
        -- Update the email
        UPDATE faculty_info 
        SET email = @new_email 
        WHERE faculty_id = @faculty_id;
        
        PRINT '========================================';
        PRINT 'Email updated successfully!';
        PRINT 'Faculty ID: ' + CAST(@faculty_id AS VARCHAR);
        PRINT 'New Email: ' + @new_email;
        PRINT '========================================';
        
        -- Display updated record
        SELECT * FROM faculty_info WHERE faculty_id = @faculty_id;
        
    END TRY
    BEGIN CATCH
        PRINT '----------------------------------------------------';
        PRINT 'ERROR OCCURRED WHILE UPDATING FACULTY EMAIL:';
        PRINT '----------------------------------------------------';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'Ad-hoc');
        PRINT '----------------------------------------------------';
    END CATCH
END;
GO

-- Test the procedure with different scenarios
EXEC sp_UpdateFacultyEmailInfo @faculty_id = 1, @new_email = 'dr.smith@university.edu';
EXEC sp_UpdateFacultyEmailInfo @faculty_id = 2, @new_email = 'invalid-email';
EXEC sp_UpdateFacultyEmailInfo @faculty_id = 10, @new_email = 'newfaculty@university.edu';
EXEC sp_UpdateFacultyEmailInfo @faculty_id = 3, @new_email = NULL;

-- First set an email for faculty 2
UPDATE faculty_info SET email = 'prof.j@university.edu' WHERE faculty_id = 2;
-- Try to use the same email for faculty 3
EXEC sp_UpdateFacultyEmailInfo @faculty_id = 3, @new_email = 'prof.j@university.edu';

SELECT * FROM faculty_info;
GO


--9. Throw custom exception that throws error if the data is invalid. 
CREATE OR ALTER PROCEDURE sp_ValidateStudentData
    @student_id INT,
    @student_name VARCHAR(50),
    @course VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Validation checks
        IF @student_id <= 0
        BEGIN
            RAISERROR('Invalid Student ID: Student ID must be a positive number.', 16, 1);
            RETURN;
        END
        
        IF @student_name IS NULL OR LEN(@student_name) = 0
        BEGIN
            RAISERROR('Invalid Student Name: Student name cannot be empty.', 16, 1);
            RETURN;
        END
        
        IF @student_name LIKE '%[0-9]%'
        BEGIN
            RAISERROR('Invalid Student Name: Student name cannot contain numbers.', 16, 1);
            RETURN;
        END
        
        IF @course IS NULL OR LEN(@course) = 0
        BEGIN
            RAISERROR('Invalid Course: Course cannot be empty.', 16, 1);
            RETURN;
        END
        
        -- Check for duplicate student ID
        IF EXISTS (SELECT 1 FROM student WHERE student_id = @student_id)
        BEGIN
            RAISERROR('Duplicate Student ID: Student with ID %d already exists.', 16, 1, @student_id);
            RETURN;
        END
        
        -- If all validations pass, insert the student
        INSERT INTO student (student_id, student_name, course)
        VALUES (@student_id, @student_name, @course);
        
        PRINT 'Student data validated and inserted successfully:';
        PRINT 'ID: ' + CAST(@student_id AS VARCHAR) + ', Name: ' + @student_name + ', Course: ' + @course;
        
    END TRY
    BEGIN CATCH
        PRINT 'Data Validation Error:';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
    END CATCH
END;
GO

-- Test the procedure
EXEC sp_ValidateStudentData 3, 'Alice Brown', 'Physics';     -- Valid
EXEC sp_ValidateStudentData -1, 'Bob Wilson', 'Chemistry';   -- Invalid ID
EXEC sp_ValidateStudentData 4, '', 'Biology';                -- Empty name
EXEC sp_ValidateStudentData 5, 'Charlie123', 'History';      -- Name with numbers
EXEC sp_ValidateStudentData 1, 'David Lee', 'Art';           -- Duplicate ID
GO


---------------------------
-- PART C :--
--------------------------- 
--10. Write a script that checks if a faculty’s salary is NULL. If it is, use RAISERROR to show a message with a 
--severity of 16. (Note: Do not use any table)
DECLARE @faculty_name VARCHAR(50) = 'Dr. Williams';
DECLARE @salary DECIMAL(10,2) = NULL;  -- Simulating NULL salary

BEGIN TRY
    IF @salary IS NULL
    BEGIN
        -- RAISERROR with severity 16
        RAISERROR('Faculty %s has a NULL salary. Please update salary information immediately.', 
                   16, 1, @faculty_name);
    END
    ELSE
    BEGIN
        PRINT 'Faculty: ' + @faculty_name + ', Salary: $' + CAST(@salary AS VARCHAR);
    END
END TRY
BEGIN CATCH
    PRINT 'Error occurred:';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
END CATCH;
GO

-- Additional example with multiple faculty checks
DECLARE @faculty_table TABLE (
    faculty_id INT,
    faculty_name VARCHAR(50),
    salary DECIMAL(10,2)
);

INSERT INTO @faculty_table VALUES 
    (1, 'Dr. Smith', 75000.00),
    (2, 'Prof. Johnson', NULL),
    (3, 'Dr. Brown', 82000.00),
    (4, 'Prof. Davis', NULL);

DECLARE @faculty_id INT, @faculty_name VARCHAR(50), @salary DECIMAL(10,2);
DECLARE faculty_cursor CURSOR FOR 
    SELECT faculty_id, faculty_name, salary FROM @faculty_table;

OPEN faculty_cursor;
FETCH NEXT FROM faculty_cursor INTO @faculty_id, @faculty_name, @salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        IF @salary IS NULL
        BEGIN
            RAISERROR('Faculty ID %d: %s has a NULL salary. Please update salary information.', 
                      16, 1, @faculty_id, @faculty_name);
        END
        ELSE
        BEGIN
            PRINT 'Faculty ID ' + CAST(@faculty_id AS VARCHAR) + ': ' + 
                  @faculty_name + ', Salary: $' + CAST(@salary AS VARCHAR);
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error for Faculty ID ' + CAST(@faculty_id AS VARCHAR) + ':';
        PRINT 'Message: ' + ERROR_MESSAGE();
    END CATCH
    
    FETCH NEXT FROM faculty_cursor INTO @faculty_id, @faculty_name, @salary;
END

CLOSE faculty_cursor;
DEALLOCATE faculty_cursor;
GO