------------- LAB 3 : Advanced Stored Procedure ---->

---------------------------
-- PART A :--
--------------------------- 
--1. Create a stored procedure that accepts a date and returns all faculty members who joined on that 
--date.
CREATE OR ALTER PROCEDURE PR_FACULTY_DATE
@JOINDATE DATE
AS
BEGIN
	SELECT *
	FROM FACULTY
	WHERE FacultyJoiningDate = @JOINDATE;
END;

EXEC PR_FACULTY_DATE '2012-08-20';

--2. Create a stored procedure for ENROLLMENT table where user enters either StudentID OR CourseID and returns 
--EnrollmentID, EnrollmentDate, Grade, and Status. 
CREATE OR ALTER PROCEDURE PR_ID_ENID_ENDATE_GRADE_STATUS
@SID INT = NULL,
@CID VARCHAR(10) = NULL
AS
BEGIN 
	SELECT EnrollmentID, EnrollmentDate, Grade, EnrollmentStatus
	FROM ENROLLMENT
	WHERE StudentID = @SID OR CourseID = @CID;
END;

EXEC PR_ID_ENID_ENDATE_GRADE_STATUS @SID = 1; -- STORE TO SID (INT)
EXEC PR_ID_ENID_ENDATE_GRADE_STATUS @CID = 'CS101'; -- STORE TO CID (VARCHAR)
EXEC PR_ID_ENID_ENDATE_GRADE_STATUS @SID = 1, @CID = 'CS101'; -- BOTH PARAMETERS

--3. Create a stored procedure that accepts two integers (min and max credits) and returns all courses 
--whose credits fall between these values. 
CREATE OR ALTER PROCEDURE PR_MIN_MAX_CREDITS
@MINC INT,
@MAXC INT
AS
BEGIN
	SELECT CourseName, CourseCredits
	FROM COURSE
	WHERE CourseCredits BETWEEN @MINC AND @MAXC;
END;

EXEC PR_MIN_MAX_CREDITS 2, 10;

--4. Create a stored procedure that accepts Course Name and returns the list of students enrolled in that 
--course. 
CREATE OR ALTER PROCEDURE PR_COURSENAME
@CNAME VARCHAR(50)
AS
BEGIN 
	SELECT S.StuName, C.CourseName, E.EnrollmentDate
	FROM STUDENT S
	JOIN ENROLLMENT E 
	ON S.StudentID = E.StudentID 
	JOIN COURSE C 
	ON E.CourseID = C.CourseID
	WHERE C.CourseName = @CNAME;
END;

EXEC PR_COURSENAME 'Data Structures';

--5. Create a stored procedure that accepts Faculty Name and returns all course assignments.
CREATE OR ALTER PROCEDURE PR_FACULTYNAME
@FNAME VARCHAR(50)
AS
BEGIN 
	SELECT C.CourseName, F.FacultyName, CA.ClassRoom, CA.Semester, CA.Year
	FROM COURSE C
	JOIN COURSE_ASSIGNMENT CA 
	ON C.CourseID = CA.CourseID
	JOIN FACULTY F 
	ON F.FacultyID = CA.FacultyID
	WHERE F.FacultyName = @FNAME;
END;

EXEC PR_FACULTYNAME 'Dr. Sheth';

--6. Create a stored procedure that accepts Semester number and Year, and returns all course 
--assignments with faculty and classroom details. 
CREATE OR ALTER PROCEDURE PR_SEM_YEAR
@SEMN INT,
@YEAR INT
AS
BEGIN 
	SELECT C.CourseName, F.FacultyName, CA.ClassRoom, CA.Semester, CA.Year
	FROM COURSE_ASSIGNMENT CA
	JOIN COURSE C 
	ON CA.CourseID = C.CourseID
	JOIN FACULTY F 
	ON F.FacultyID = CA.FacultyID
	WHERE CA.Semester = @SEMN AND CA.Year = @YEAR;
END;

EXEC PR_SEM_YEAR 3, 2024;

---------------------------
-- PART B :--
--------------------------- 
--7. Create a stored procedure that accepts the first letter of Status ('A', 'C', 'D') and returns enrollment 
--details. 
CREATE OR ALTER PROCEDURE PR_ENROLLMENT_DETAILS_BY_FL
@FL CHAR(1)
AS
BEGIN
	SELECT *
	FROM ENROLLMENT
	WHERE EnrollmentStatus LIKE @FL + '%';
END;

EXEC PR_ENROLLMENT_DETAILS_BY_FL 'A';
EXEC PR_ENROLLMENT_DETAILS_BY_FL 'C';
EXEC PR_ENROLLMENT_DETAILS_BY_FL 'D';

--8. Create a stored procedure that accepts either Student Name OR Department Name and returns 
--student data accordingly. 
CREATE OR ALTER PROCEDURE PR_SNAME_DNAME_BY_SDATA
@SNAME VARCHAR(50) = NULL,
@DNAME VARCHAR(20) = NULL
AS
BEGIN 
	SELECT *
	FROM STUDENT
	WHERE StuName = @SNAME OR StuDepartment = @DNAME;
END;

EXEC PR_SNAME_DNAME_BY_SDATA @SNAME = 'Raj Patel';
EXEC PR_SNAME_DNAME_BY_SDATA @DNAME = 'CSE';
EXEC PR_SNAME_DNAME_BY_SDATA @SNAME = 'Raj Patel', @DNAME = 'CSE';

--9. Create a stored procedure that accepts CourseID and returns all students enrolled grouped by 
--enrollment status with counts.
CREATE OR ALTER PROCEDURE PR_CID_STUDENT_DETAILS
@CID VARCHAR(10)
AS
BEGIN
	SELECT 
		E.EnrollmentStatus, 
		COUNT(S.StudentID) AS StudentCount,
		S.StuName
	FROM COURSE C
	JOIN ENROLLMENT E 
	ON C.CourseID = E.CourseID
	JOIN STUDENT S 
	ON E.StudentID = S.StudentID
	WHERE C.CourseID = @CID
	GROUP BY E.EnrollmentStatus, S.StuName;
END;

EXEC PR_CID_STUDENT_DETAILS 'CS101';

---------------------------
-- PART C :--
---------------------------  
--10. Create a stored procedure that accepts a year as input and returns all courses assigned to faculty in 
--that year with classroom details. 
CREATE OR ALTER PROCEDURE PR_YEAR_BY_ASSIGNCOU_WITH_FAC_DETAIL
@YEAR INT
AS
BEGIN 
	SELECT 
		C.CourseName,
		F.FacultyName,
		CA.ClassRoom,
		CA.Semester,
		CA.Year,
		C.CourseCredits
	FROM FACULTY F
	JOIN COURSE_ASSIGNMENT CA 
	ON F.FacultyID = CA.FacultyID
	JOIN COURSE C 
	ON CA.CourseID = C.CourseID
	WHERE CA.Year = @YEAR;
END;

EXEC PR_YEAR_BY_ASSIGNCOU_WITH_FAC_DETAIL 2024;

--11. Create a stored procedure that accepts From Date and To Date and returns all enrollments within 
--that range with student and course details.
CREATE OR ALTER PROCEDURE PR_ENROLLMENTS_BY_DATE_RANGE
@FROMDATE DATE,
@TODATE DATE
AS
BEGIN 
	SELECT 
		S.StuName,
		C.CourseName,
		E.EnrollmentDate,
		E.Grade,
		E.EnrollmentStatus
	FROM ENROLLMENT E
	JOIN STUDENT S 
	ON E.StudentID = S.StudentID
	JOIN COURSE C 
	ON E.CourseID = C.CourseID
	WHERE E.EnrollmentDate BETWEEN @FROMDATE AND @TODATE
	ORDER BY E.EnrollmentDate;
END;

EXEC PR_ENROLLMENTS_BY_DATE_RANGE '2023-01-01', '2023-12-31';

--12. Create a stored procedure that accepts FacultyID and calculates their total teaching load (sum of 
--credits of all courses assigned).
CREATE OR ALTER PROCEDURE PR_FACULTY_TEACHING_LOAD
@FACULTYID INT
AS
BEGIN 
	SELECT 
		F.FacultyName,
		F.FacultyDesignation,
		COUNT(CA.CourseID) AS TotalCourses,
		SUM(C.CourseCredits) AS TotalTeachingLoad
	FROM FACULTY F
	JOIN COURSE_ASSIGNMENT CA 
	ON F.FacultyID = CA.FacultyID
	JOIN COURSE C 
	ON CA.CourseID = C.CourseID
	WHERE F.FacultyID = @FACULTYID
	GROUP BY F.FacultyName, F.FacultyDesignation;
END;

EXEC PR_FACULTY_TEACHING_LOAD 101;
EXEC PR_FACULTY_TEACHING_LOAD 107;