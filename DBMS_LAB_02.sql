------------- LAB 2 : Stored Procedure ---->


---------------------------
-- PART A :--
---------------------------
--1.	INSERT Procedures: Create stored procedures to insert records into STUDENT tables (SP_INSERT_STUDENT)
--StuID	Name	Email	Phone	Department	DOB	EnrollmentYear
--10	Harsh Parmar	harsh@univ.edu	9876543219	CSE	2005-09-18	2023
--11	Om Patel	om@univ.edu	9876543220	IT	2002-08-22	2022
CREATE OR ALTER PROC PR_INSERT_STUDENT
@SID INT,
@Name VARCHAR(50),
@Email VARCHAR(50),
@Phone VARCHAR(15),
@Department VARCHAR(10),
@DOB DATE,
@EnrollmentYear INT
AS
BEGIN
	INSERT INTO STUDENT (StudentID, StuName, StuEmail, StuPhone, StuDepartment, StuDateOfBirth, StuEnrollmentYear) 
	VALUES (@SID, @Name, @Email, @Phone, @Department, @DOB, @EnrollmentYear)
END; 

EXEC PR_INSERT_STUDENT 10, 'Harsh Parmar', 'harsh@univ.edu', '9876543219', 'CSE', '2005-09-18', 2023
EXEC PR_INSERT_STUDENT 11, 'Om Patel', 'om@univ.edu', '9876543220', 'IT', '2002-08-22', 2022


--2.	INSERT Procedures: Create stored procedures to insert records into COURSE tables 
--(SP_INSERT_COURSE)
--CourseID	CourseName	Credits	Dept  Semester
--CS330	Computer Networks	4	CSE		5
--EC120	Electronic Circuits	3	ECE		2
CREATE OR ALTER PROC PR_INSERT_COURSE
@CourseID VARCHAR(10),
@CourseName VARCHAR(50),
@Credits INT,
@Department VARCHAR(10),
@Semester INT
AS
BEGIN 
	INSERT INTO COURSE (CourseID, CourseName, CourseCredits, CourseDepartment, CourseSemester) 
	VALUES (@CourseID, @CourseName, @Credits, @Department, @Semester)
END;

EXEC PR_INSERT_COURSE 'CS330', 'Computer Networks', 4, 'CSE', 5 
EXEC PR_INSERT_COURSE 'EC120', 'Electronic Circuits', 3, 'ECE', 2 

--3.	UPDATE Procedures: Create stored procedure SP_UPDATE_STUDENT to update Email and Phone in STUDENT table. (Update using studentID)
CREATE OR ALTER PROC PR_UPDATE_STUDENT 
@StudentID INT,
@Email VARCHAR(50),
@Phone VARCHAR(15)
AS 
BEGIN 
	UPDATE STUDENT
	SET StuEmail = @Email, StuPhone = @Phone
	WHERE StudentID = @StudentID;
END;
GO

--4.	DELETE Procedures: Create stored procedure SP_DELETE_STUDENT to delete records from STUDENT where Student Name is Om Patel.
CREATE OR ALTER PROC PR_DELETE_STUDENT
@StudentName VARCHAR(50)
AS
BEGIN
	DELETE FROM STUDENT
	WHERE StuName = @StudentName;
END;
GO

--5.	SELECT BY PRIMARY KEY: Create stored procedures to SELECT records by primary key (SP_SELECT_STUDENT_BY_ID) from Student table.
CREATE OR ALTER PROC PR_SELECT_STUDENT_BY_ID
@SID INT
AS 
BEGIN 
	SELECT * 
	FROM STUDENT
	WHERE StudentID = @SID;
END;
GO

--6.	Create a stored procedure that shows details of the first 5,8 students ordered by EnrollmentYear.
CREATE OR ALTER PROC PR_SHOW_DETAILS_BY_YEARS
@N INT
AS
BEGIN 
	SELECT TOP (@N) * 
	FROM STUDENT
	ORDER BY StuEnrollmentYear;
END;
GO

EXEC PR_SHOW_DETAILS_BY_YEARS 5;
EXEC PR_SHOW_DETAILS_BY_YEARS 8;

---------------------------
-- PART B :--
--------------------------- 
--7.	Create a stored procedure which displays faculty designation-wise count.
CREATE OR ALTER PROC PR_DISPLAY_FACULTY_DESIGNATION_COUNT
AS
BEGIN
	SELECT FacultyDesignation, COUNT(FacultyID) AS DesignationCount
	FROM FACULTY
	GROUP BY FacultyDesignation;
END;
GO

--8.	Create a stored procedure that takes department name as input and returns all students in that department.
CREATE OR ALTER PROC PR_GET_STUDENTS_BY_DEPARTMENT
@DEPT VARCHAR(50)
AS 
BEGIN 
	SELECT *
	FROM STUDENT
	WHERE StuDepartment = @DEPT;
END;
GO

---------------------------
-- PART C :--
-----------------------------9.	Create a stored procedure which displays department-wise maximum, minimum, and average credits of courses.
CREATE OR ALTER PROC PR_GET_COURSE_CREDIT_STATS
AS 
BEGIN 
	SELECT 
		CourseDepartment,
		MAX(CourseCredits) AS MaxCredits,
		MIN(CourseCredits) AS MinCredits,
		AVG(CourseCredits) AS AvgCredits
	FROM COURSE
	GROUP BY CourseDepartment;
END;
GO

EXEC PR_GET_COURSE_CREDIT_STATS;

--10.	Create a stored procedure that accepts StudentID as parameter and returns all courses the student is enrolled in with their grades.
CREATE OR ALTER PROC PR_GET_STUDENT_COURSES_GRADES
@StudentID INT
AS
BEGIN 
	SELECT 
		S.StuName,
		C.CourseName,
		C.CourseCredits,
		E.Grade
	FROM STUDENT S
	JOIN ENROLLMENT E ON S.StudentID = E.StudentID
	JOIN COURSE C ON E.CourseID = C.CourseID
	WHERE S.StudentID = @StudentID;
END;
GO
