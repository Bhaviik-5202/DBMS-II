--=========================
-- Part A 
--=========================

-- 1. Create a cursor Course_Cursor to fetch all rows from COURSE table and display them.
GO
DECLARE 
    @CourseID VARCHAR(10),
    @CourseName VARCHAR(100),
    @CourseCredits INT,
    @CourseDepartment VARCHAR(50),
    @CourseSemester INT;
    
DECLARE cursor_Course CURSOR
FOR SELECT 
    CourseID,
    CourseName,
    CourseCredits,
    CourseDepartment,
    CourseSemester
    FROM COURSE
    ORDER BY CourseID;
    
OPEN cursor_Course;

FETCH NEXT FROM cursor_Course INTO
    @CourseID,
    @CourseName,
    @CourseCredits,
    @CourseDepartment,
    @CourseSemester;

PRINT '--- COURSE TABLE DATA ---';
PRINT 'CourseID | CourseName | Credits | Department | Semester';
PRINT '--------------------------------------------------------';

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @CourseID + ' | ' + 
          @CourseName + ' | ' + 
          CAST(@CourseCredits AS VARCHAR) + ' | ' + 
          @CourseDepartment + ' | ' + 
          CAST(@CourseSemester AS VARCHAR);
    
    FETCH NEXT FROM cursor_Course INTO
        @CourseID,
        @CourseName,
        @CourseCredits,
        @CourseDepartment,
        @CourseSemester;
END;

PRINT '--- END OF DATA ---';

CLOSE cursor_Course;
DEALLOCATE cursor_Course;


-- 2. Create a cursor Student_Cursor_Fetch to fetch records in form of StudentID_StudentName
GO
DECLARE 
    @StudentID INT,
    @StuName VARCHAR(100);
    
-- Create temp table to store results
CREATE TABLE #StudentResults (
    ID_Name VARCHAR(150)
);

DECLARE Student_Cursor_Fetch CURSOR
FOR SELECT 
    StudentID,
    StuName
    FROM STUDENT
    ORDER BY StudentID;
    
OPEN Student_Cursor_Fetch;

FETCH NEXT FROM Student_Cursor_Fetch INTO
    @StudentID,
    @StuName;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #StudentResults 
    VALUES (CAST(@StudentID AS VARCHAR) + '_' + @StuName);
    
    FETCH NEXT FROM Student_Cursor_Fetch INTO
        @StudentID,
        @StuName;
END;

CLOSE Student_Cursor_Fetch;
DEALLOCATE Student_Cursor_Fetch;

-- Display all results
SELECT * FROM #StudentResults;

-- Cleanup
DROP TABLE #StudentResults;


-- 3. Create a cursor to find and display all courses with Credits greater than 3.
GO
DECLARE 
    @CourseID VARCHAR(10),
    @CourseName VARCHAR(100),
    @CourseCredits INT,
    @CourseDepartment VARCHAR(50),
    @CourseSemester INT;
    
-- Create table variable to store results
DECLARE @HighCreditCourses TABLE (
    CourseID VARCHAR(10),
    CourseName VARCHAR(100),
    CourseCredits INT,
    CourseDepartment VARCHAR(50),
    CourseSemester INT
);

DECLARE cursor_Course_Credits CURSOR
FOR SELECT 
    CourseID,
    CourseName,
    CourseCredits,
    CourseDepartment,
    CourseSemester
    FROM COURSE
    WHERE CourseCredits > 3
    ORDER BY CourseCredits DESC, CourseID;
    
OPEN cursor_Course_Credits;

FETCH NEXT FROM cursor_Course_Credits INTO
    @CourseID,
    @CourseName,
    @CourseCredits,
    @CourseDepartment,
    @CourseSemester;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @HighCreditCourses 
    VALUES (@CourseID, @CourseName, @CourseCredits, @CourseDepartment, @CourseSemester);
    
    FETCH NEXT FROM cursor_Course_Credits INTO
        @CourseID,
        @CourseName,
        @CourseCredits,
        @CourseDepartment,
        @CourseSemester;
END;

CLOSE cursor_Course_Credits;
DEALLOCATE cursor_Course_Credits;

-- Display results
SELECT 
    CourseID AS 'Course ID',
    CourseName AS 'Course Name',
    CourseCredits AS 'Credits',
    CourseDepartment AS 'Department',
    CourseSemester AS 'Semester'
FROM @HighCreditCourses
ORDER BY CourseCredits DESC, CourseID;

-- Display summary
DECLARE @TotalCourses INT;
SELECT @TotalCourses = COUNT(*) FROM @HighCreditCourses;
PRINT 'Total courses with credits > 3: ' + CAST(@TotalCourses AS VARCHAR);


-- 4. Create a cursor to display all students who enrolled in year 2021 or later.
GO
DECLARE 
    @StudentID INT,
    @StuName VARCHAR(100),
    @StuEmail VARCHAR(100),
    @StuPhone VARCHAR(15),
    @StuDepartment VARCHAR(50),
    @StuDateOfBirth DATE,
    @StuEnrollmentYear INT;
    
DECLARE Student_Cursor_YEAR CURSOR
FOR SELECT 
    StudentID,
    StuName,
    StuEmail,
    StuPhone,
    StuDepartment,
    StuDateOfBirth,
    StuEnrollmentYear
    FROM STUDENT
    WHERE StuEnrollmentYear >= 2021
    ORDER BY StuEnrollmentYear DESC, StuName;
    
OPEN Student_Cursor_YEAR;

FETCH NEXT FROM Student_Cursor_YEAR INTO
    @StudentID,
    @StuName,
    @StuEmail,
    @StuPhone,
    @StuDepartment,
    @StuDateOfBirth,
    @StuEnrollmentYear;

-- Display header
PRINT 'Students Enrolled in 2021 or Later:';
PRINT '===================================================================================================';
PRINT 'ID    Student Name           Email                     Phone         Department   DOB         Enr Year';
PRINT '---------------------------------------------------------------------------------------------------';

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Format Date of Birth as string
    DECLARE @DOBString VARCHAR(10);
    SET @DOBString = CONVERT(VARCHAR(10), @StuDateOfBirth, 105); -- Format: dd-mm-yyyy
    
    -- Format output
    PRINT RIGHT(SPACE(5) + CAST(@StudentID AS VARCHAR), 5) + ' ' +
          LEFT(@StuName + SPACE(22), 22) + ' ' +
          LEFT(@StuEmail + SPACE(26), 26) + ' ' +
          LEFT(@StuPhone + SPACE(13), 13) + ' ' +
          LEFT(@StuDepartment + SPACE(12), 12) + ' ' +
          LEFT(@DOBString + SPACE(11), 11) + ' ' +
          CAST(@StuEnrollmentYear AS VARCHAR);
    
    FETCH NEXT FROM Student_Cursor_YEAR INTO
        @StudentID,
        @StuName,
        @StuEmail,
        @StuPhone,
        @StuDepartment,
        @StuDateOfBirth,
        @StuEnrollmentYear;
END;

PRINT '===================================================================================================';
CLOSE Student_Cursor_YEAR;
DEALLOCATE Student_Cursor_YEAR;


-- 5. Create a cursor Course_CursorUpdate that retrieves all courses and increases Credits by 1 
-- for courses with Credits less than 4.
GO
DECLARE 
    @UCID VARCHAR(10), 
    @UCredits INT;
    
DECLARE Course_CursorUpdate CURSOR
FOR 
    SELECT CourseID, CourseCredits 
    FROM COURSE;
    
OPEN Course_CursorUpdate;

FETCH NEXT FROM Course_CursorUpdate INTO @UCID, @UCredits;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @UCredits < 4
    BEGIN
        UPDATE COURSE 
        SET CourseCredits = CourseCredits + 1 
        WHERE CourseID = @UCID;
        
        PRINT 'Updated Course: ' + @UCID + ' from ' + CAST(@UCredits AS VARCHAR) + ' to ' + CAST((@UCredits + 1) AS VARCHAR) + ' credits';
    END
    ELSE
    BEGIN
        PRINT 'Course: ' + @UCID + ' has ' + CAST(@UCredits AS VARCHAR) + ' credits (no update needed)';
    END
    
    FETCH NEXT FROM Course_CursorUpdate INTO @UCID, @UCredits;
END;

CLOSE Course_CursorUpdate;
DEALLOCATE Course_CursorUpdate;

-- Verify the updates
PRINT '--- Final Course Credits ---';
SELECT CourseID, CourseName, CourseCredits 
FROM COURSE 
ORDER BY CourseID;


-- 6. Create a Cursor to fetch Student Name with Course Name 
-- (Example: Raj Patel is enrolled in Database Management System) 
GO
DECLARE 
    @StudentName VARCHAR(100),
    @CourseName VARCHAR(100);
    
DECLARE Student_Course_Cursor CURSOR
FOR
    SELECT S.StuName, C.CourseName
    FROM STUDENT S
    JOIN ENROLLMENT E ON S.StudentID = E.StudentID
    JOIN COURSE C ON E.CourseID = C.CourseID
    ORDER BY S.StuName, C.CourseName;
    
OPEN Student_Course_Cursor;

FETCH NEXT FROM Student_Course_Cursor INTO @StudentName, @CourseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @StudentName + ' is enrolled in ' + @CourseName;
    FETCH NEXT FROM Student_Course_Cursor INTO @StudentName, @CourseName;
END;

CLOSE Student_Course_Cursor;
DEALLOCATE Student_Course_Cursor;


-- 7. Create a cursor to insert data into new table if student belong to 'CSE' department.
-- (create new table CSEStudent with relevant columns)
GO
-- First create the new table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CSEStudent')
BEGIN
    CREATE TABLE CSEStudent
    (
        StudentID INT PRIMARY KEY,
        StudentName VARCHAR(100),
        StudentEmail VARCHAR(100),
        StudentPhone VARCHAR(15),
        Department VARCHAR(50),
        DateOfBirth DATE,
        EnrollmentYear INT
    );
    PRINT 'CSEStudent table created successfully.';
END
ELSE
BEGIN
    -- Clear existing data if table exists
    TRUNCATE TABLE CSEStudent;
    PRINT 'CSEStudent table already exists. Data truncated.';
END

-- Cursor to insert CSE students
DECLARE 
    @CSID INT,
    @CSName VARCHAR(100),
    @CSEmail VARCHAR(100),
    @CSPhone VARCHAR(15),
    @CSDept VARCHAR(50),
    @CSDOB DATE,
    @CSEnrollYear INT;
    
DECLARE CSE_Cursor CURSOR
FOR 
    SELECT 
        StudentID,
        StuName,
        StuEmail,
        StuPhone,
        StuDepartment,
        StuDateOfBirth,
        StuEnrollmentYear
    FROM STUDENT 
    WHERE StuDepartment = 'CSE'
    ORDER BY StudentID;
    
OPEN CSE_Cursor;

FETCH NEXT FROM CSE_Cursor INTO 
    @CSID, @CSName, @CSEmail, @CSPhone, @CSDept, @CSDOB, @CSEnrollYear;

DECLARE @InsertCount INT = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO CSEStudent VALUES(
        @CSID, @CSName, @CSEmail, @CSPhone, @CSDept, @CSDOB, @CSEnrollYear
    );
    
    SET @InsertCount = @InsertCount + 1;
    
    FETCH NEXT FROM CSE_Cursor INTO 
        @CSID, @CSName, @CSEmail, @CSPhone, @CSDept, @CSDOB, @CSEnrollYear;
END;

CLOSE CSE_Cursor;
DEALLOCATE CSE_Cursor;

-- Verify the inserted data
PRINT 'Total ' + CAST(@InsertCount AS VARCHAR) + ' CSE students inserted.';
SELECT * FROM CSEStudent ORDER BY StudentID;


--=========================
-- Part B 
--=========================

-- 8. Create a cursor to update all NULL grades to 'F' for enrollments with Status 'Completed'
GO
-- Check if ENROLLMENT table exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ENROLLMENT')
BEGIN
    DECLARE 
        @EnrollmentID INT,
        @Grade CHAR(1),
        @Status VARCHAR(20);
        
    DECLARE Grade_Update_Cursor CURSOR
    FOR 
        SELECT EnrollmentID, Grade, Status
        FROM ENROLLMENT 
        WHERE Status = 'Completed'
        ORDER BY EnrollmentID;
        
    OPEN Grade_Update_Cursor;

    FETCH NEXT FROM Grade_Update_Cursor INTO @EnrollmentID, @Grade, @Status;

    DECLARE @UpdateCount INT = 0;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Grade IS NULL
        BEGIN
            UPDATE ENROLLMENT 
            SET Grade = 'F' 
            WHERE EnrollmentID = @EnrollmentID;
            
            SET @UpdateCount = @UpdateCount + 1;
            PRINT 'Updated EnrollmentID ' + CAST(@EnrollmentID AS VARCHAR) + ' to Grade F';
        END
        
        FETCH NEXT FROM Grade_Update_Cursor INTO @EnrollmentID, @Grade, @Status;
    END;

    CLOSE Grade_Update_Cursor;
    DEALLOCATE Grade_Update_Cursor;

    -- Verify the updates
    PRINT 'Total ' + CAST(@UpdateCount AS VARCHAR) + ' records updated.';
    SELECT * FROM ENROLLMENT WHERE Status = 'Completed' AND Grade = 'F' ORDER BY EnrollmentID;
END
ELSE
BEGIN
    PRINT 'ENROLLMENT table does not exist. Skipping question 8.';
END


-- 9. Cursor to show Faculty with Course they teach (EX: Dr. Sheth teaches Data structure)
GO
-- Check if FACULTY and COURSE tables exist with proper relationship
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FACULTY') 
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'COURSE')
   AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('COURSE') AND name = 'FacultyID')
BEGIN
    DECLARE 
        @FacultyName VARCHAR(100),
        @CourseName VARCHAR(100);
        
    DECLARE Faculty_Course_Cursor CURSOR
    FOR
        SELECT F.FacultyName, C.CourseName
        FROM FACULTY F
        JOIN COURSE C ON F.FacultyID = C.FacultyID
        ORDER BY F.FacultyName, C.CourseName;
        
    OPEN Faculty_Course_Cursor;

    FETCH NEXT FROM Faculty_Course_Cursor INTO @FacultyName, @CourseName;

    PRINT '--- Faculty and Courses They Teach ---';

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @FacultyName + ' teaches ' + @CourseName;
        FETCH NEXT FROM Faculty_Course_Cursor INTO @FacultyName, @CourseName;
    END;

    CLOSE Faculty_Course_Cursor;
    DEALLOCATE Faculty_Course_Cursor;
    
    PRINT '--- End of List ---';
END
ELSE
BEGIN
    PRINT 'Required tables/columns for Faculty-Course relationship not found. Skipping question 9.';
END


--=========================
-- Part C
--=========================

-- 10. Cursor to calculate total credits per student (Example: Raj Patel has total credits = 15)
GO
-- Check if all required tables exist
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'STUDENT')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'ENROLLMENT')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'COURSE')
BEGIN
    DECLARE 
        @StudentName VARCHAR(100),
        @TotalCredits INT;
        
    DECLARE Total_Credits_Cursor CURSOR
    FOR
        SELECT S.StuName, SUM(C.CourseCredits) as TotalCredits
        FROM STUDENT S
        JOIN ENROLLMENT E ON S.StudentID = E.StudentID
        JOIN COURSE C ON E.CourseID = C.CourseID
        GROUP BY S.StuName
        ORDER BY TotalCredits DESC, S.StuName;
        
    OPEN Total_Credits_Cursor;

    FETCH NEXT FROM Total_Credits_Cursor INTO @StudentName, @TotalCredits;

    PRINT '--- Total Credits per Student ---';
    PRINT '================================';

    DECLARE @Rank INT = 1;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CAST(@Rank AS VARCHAR) + '. ' + @StudentName + ' has total credits = ' + CAST(@TotalCredits AS VARCHAR);
        SET @Rank = @Rank + 1;
        FETCH NEXT FROM Total_Credits_Cursor INTO @StudentName, @TotalCredits;
    END;

    CLOSE Total_Credits_Cursor;
    DEALLOCATE Total_Credits_Cursor;
    
    PRINT '================================';
END
ELSE
BEGIN
    PRINT 'Required tables for credit calculation not found. Skipping question 10.';
END