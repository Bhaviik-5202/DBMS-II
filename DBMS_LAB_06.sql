------------- LAB 6 : Trigger (After trigger)  ---->
--Table : Log(LogMessage varchar(100), logDate Datetime) 


---------------------------
-- PART A :--
---------------------------
--1. Create trigger for printing appropriate message after student registration.
GO
CREATE OR ALTER TRIGGER trg_AfterStudentRegistration
ON STUDENT
AFTER INSERT
AS
BEGIN
    PRINT 'New student has been successfully registered.';
END;

--2. Create trigger for printing appropriate message after faculty deletion.
GO
CREATE OR ALTER TRIGGER trg_AfterFacultyDeletion
ON FACULTY
AFTER DELETE
AS
BEGIN
    PRINT 'Faculty record has been deleted successfully.';
END;

--3. Create trigger for monitoring all events on course table. (print only appropriate message)
GO
CREATE OR ALTER TRIGGER trg_MonitorCourseEvents
ON COURSE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
            PRINT 'Course record has been updated.';
        ELSE
            PRINT 'New course has been inserted.';
    END
    ELSE
        PRINT 'Course record has been deleted.';
END;

--4. Create trigger for logging data on new student registration in Log table.
GO
CREATE OR ALTER TRIGGER trg_LogStudentRegistration
ON STUDENT
AFTER INSERT
AS
BEGIN
    DECLARE @StudentID INT, @StudentName VARCHAR(100);
    
    SELECT @StudentID = StudentID, @StudentName = StuName FROM inserted;
    
    INSERT INTO Log(LogMessage, logDate)
    VALUES ('New student registered: ' + @StudentName + ' (ID: ' + CAST(@StudentID AS VARCHAR(10)) + ')', GETDATE());
END;

--5. Create trigger for auto-uppercasing faculty names. 
GO
CREATE OR ALTER TRIGGER trg_AutoUppercaseFacultyNames
ON FACULTY
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE f
    SET f.FacultyName = UPPER(i.FacultyName)
    FROM FACULTY f
    INNER JOIN inserted i ON f.FacultyID = i.FacultyID;
END;

--6. Create trigger for calculating faculty experience (Note: Add required column in faculty table)
-- First add experience column to Faculty table
ALTER TABLE FACULTY ADD Experience INT NULL;

GO
CREATE OR ALTER TRIGGER trg_CalculateFacultyExperience
ON FACULTY
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE f
    SET f.Experience = DATEDIFF(YEAR, i.FacultyJoiningDate, GETDATE())
    FROM FACULTY f
    JOIN inserted i 
    ON f.FacultyID = i.FacultyID
    WHERE i.FacultyJoiningDate IS NOT NULL;
END;

---------------------------
-- PART B :--
---------------------------
--7. Create trigger for auto-stamping enrollment dates.
GO
CREATE OR ALTER TRIGGER trg_AutoStampEnrollmentDate
ON ENROLLMENT
AFTER INSERT
AS
BEGIN
    UPDATE e
    SET e.EnrollmentDate = GETDATE()
    FROM ENROLLMENT e
    JOIN inserted i 
    ON e.EnrollmentID = i.EnrollmentID
    WHERE e.EnrollmentDate IS NULL;
END;

--8. Create trigger for logging data After course assignment - log course and faculty detail. 
GO
CREATE OR ALTER TRIGGER trg_LogCourseAssignment
ON COURSE_ASSIGNMENT
AFTER INSERT
AS
BEGIN
    DECLARE @CourseID VARCHAR(10), @FacultyID INT, @CourseName VARCHAR(100), @FacultyName VARCHAR(100);
    
    SELECT @CourseID = i.CourseID, @FacultyID = i.FacultyID
    FROM inserted i;
    
    SELECT @CourseName = CourseName FROM COURSE WHERE CourseID = @CourseID;
    SELECT @FacultyName = FacultyName FROM FACULTY WHERE FacultyID = @FacultyID;
    
    INSERT INTO Log(LogMessage, logDate)
    VALUES ('Course "' + @CourseName + '" assigned to Faculty: ' + @FacultyName, GETDATE());
END;

--Part - C 
--9. Create trigger for updating student phone and print the old and new phone number. 
GO
CREATE OR ALTER TRIGGER trg_UpdateStudentPhone
ON STUDENT
AFTER UPDATE
AS
BEGIN
    IF UPDATE(StuPhone)
    BEGIN
        DECLARE @OldPhone VARCHAR(15), @NewPhone VARCHAR(15), @StudentID INT, @StudentName VARCHAR(100);
        
        SELECT @OldPhone = d.StuPhone, @NewPhone = i.StuPhone, 
               @StudentID = i.StudentID, @StudentName = i.StuName
        FROM deleted d
        INNER JOIN inserted i ON d.StudentID = i.StudentID;
        
        PRINT 'Student: ' + @StudentName + ' (ID: ' + CAST(@StudentID AS VARCHAR(10)) + 
              ') - Phone changed from ' + @OldPhone + ' to ' + @NewPhone;
    END
END;

--10. Create trigger for updating course credit log old and new credits in log table.
GO
CREATE OR ALTER TRIGGER trg_UpdateCourseCredit
ON COURSE
AFTER UPDATE
AS
BEGIN
    IF UPDATE(CourseCredits)
    BEGIN
        DECLARE @OldCredits INT, @NewCredits INT, @CourseID VARCHAR(10), @CourseName VARCHAR(100);
        
        SELECT @OldCredits = d.CourseCredits, @NewCredits = i.CourseCredits, 
               @CourseID = i.CourseID, @CourseName = i.CourseName
        FROM deleted d
        INNER JOIN inserted i ON d.CourseID = i.CourseID;
        
        INSERT INTO Log(LogMessage, logDate)
        VALUES ('Course "' + @CourseName + '" (ID: ' + @CourseID + 
                ') credits changed from ' + CAST(@OldCredits AS VARCHAR(5)) + 
                ' to ' + CAST(@NewCredits AS VARCHAR(5)), GETDATE());
    END
END;