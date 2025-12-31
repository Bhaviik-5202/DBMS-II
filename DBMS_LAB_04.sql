--Part-A 
--1. Write a scalar function to print "Welcome to DBMS Lab". 
CREATE OR ALTER FUNCTION FN_WELCOME_DB()
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN 'WELCOME TO DBMS-II';
END;

SELECT dbo.FN_WELCOME_DB() AS WelcomeMessage;

--2. Write a scalar function to calculate simple interest. 
CREATE OR ALTER FUNCTION FN_CAL_SI
(@P DECIMAL(10,2), @R DECIMAL(5,2), @T INT)
RETURNS DECIMAL(10,2)
AS 
BEGIN 
	DECLARE @SI DECIMAL(10,2);
	SET @SI = (@P * @R * @T) / 100;
	RETURN @SI;
END;

SELECT dbo.FN_CAL_SI(1000, 2.5, 2) AS SimpleInterest;

--3. Function to Get Difference in Days Between Two Given Dates 
CREATE OR ALTER FUNCTION FN_GIVEN_BET_DATES (
@DATE1 DATE,
@DATE2 DATE
)
RETURNS INT
AS
BEGIN 
	DECLARE @DIFF INT;
	SET @DIFF = DATEDIFF(DAY, @DATE1, @DATE2);
	RETURN ABS(@DIFF);
END;

SELECT dbo.FN_GIVEN_BET_DATES('2024-12-31', '2025-12-31') AS DaysDifference;

--4. Write a scalar function which returns the sum of Credits for two given CourseIDs.
CREATE OR ALTER FUNCTION FN_SUM_CREDITS
(@CID1 VARCHAR(10), @CID2 VARCHAR(10))
RETURNS INT
AS
BEGIN
	DECLARE @SUM INT = 0;
	SELECT @SUM = ISNULL(SUM(CourseCredits), 0)
	FROM COURSE
	WHERE CourseID IN (@CID1, @CID2);

	RETURN @SUM;
END;

SELECT dbo.FN_SUM_CREDITS('CS101', 'CS201') AS TotalCredits;

--5. Write a function to check whether the given number is ODD or EVEN.
CREATE OR ALTER FUNCTION FN_ODD_EVEN
(@NUM INT)
RETURNS VARCHAR(10)
AS
BEGIN
	IF @NUM % 2 = 0
		RETURN 'EVEN';
	RETURN 'ODD';
END;

SELECT dbo.FN_ODD_EVEN(5) AS NumberType;
SELECT dbo.FN_ODD_EVEN(10) AS NumberType;

--6. Write a function to print number from 1 to N. (Using while loop)
CREATE OR ALTER FUNCTION FN_1_TO_N
(@NUM INT)
RETURNS VARCHAR(1000)
AS
BEGIN
	DECLARE @MSG VARCHAR(1000) = '';
	DECLARE @COUNT INT = 1;
	
	IF @NUM <= 0
		RETURN 'Please enter a positive number';
		
	WHILE (@COUNT <= @NUM)
	BEGIN 
		SET @MSG = @MSG + CAST(@COUNT AS VARCHAR) + ' ';
		SET @COUNT = @COUNT + 1;
	END;
	    
	RETURN RTRIM(@MSG);
END;

SELECT dbo.FN_1_TO_N(10) AS Numbers;

--7. Write a scalar function to calculate factorial of total credits for a given CourseID.
CREATE OR ALTER FUNCTION FN_FAC_OF_CREDITS
(@CID VARCHAR(10))
RETURNS BIGINT
AS
BEGIN
	DECLARE @FAC BIGINT = 1;
	DECLARE @N INT;
	
	SELECT @N = CourseCredits 
	FROM COURSE
	WHERE CourseID = @CID;
	
	IF @N IS NULL
		RETURN NULL;
	
	WHILE @N > 1
	BEGIN
		SET @FAC = @FAC * @N;
		SET @N = @N - 1;
	END;

	RETURN @FAC;
END;

SELECT dbo.FN_FAC_OF_CREDITS('CS101') AS FactorialOfCredits;

--8. Write a scalar function to check whether a given EnrollmentYear is in the past, current or future (Case 
--statement)  
CREATE OR ALTER FUNCTION FN_ENROLL_TENSE
(@Y INT)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @CURRENT_YEAR INT = YEAR(GETDATE());
	RETURN CASE
		WHEN @Y = @CURRENT_YEAR THEN 'CURRENT'
		WHEN @Y < @CURRENT_YEAR THEN 'PAST'
		ELSE 'FUTURE'
	END;
END;

SELECT dbo.FN_ENROLL_TENSE(2026) AS YearStatus;
SELECT dbo.FN_ENROLL_TENSE(2023) AS YearStatus;
SELECT dbo.FN_ENROLL_TENSE(YEAR(GETDATE())) AS YearStatus;

--9. Write a table-valued function that returns details of students whose names start with a given letter. 
CREATE OR ALTER FUNCTION FN_STUDENTS_BY_LETTER
(@LETTER CHAR(1))
RETURNS TABLE
AS
RETURN (
	SELECT StudentID, StuName, StuEmail, StuPhone, StuDepartment, StuDateOfBirth, StuEnrollmentYear
	FROM STUDENT
	WHERE StuName LIKE @LETTER + '%'
);

SELECT * FROM dbo.FN_STUDENTS_BY_LETTER('A');
SELECT * FROM dbo.FN_STUDENTS_BY_LETTER('R');

--10. Write a table-valued function that returns unique department names from the STUDENT table. 
CREATE OR ALTER FUNCTION FN_UNIQUE_DEPARTMENTS()
RETURNS TABLE
AS
RETURN (
	SELECT DISTINCT StuDepartment AS DepartmentName
	FROM STUDENT
);

SELECT * FROM dbo.FN_UNIQUE_DEPARTMENTS();

--Part-B 
--11. Write a scalar function that calculates age in years given a DateOfBirth. 
CREATE OR ALTER FUNCTION FN_CALCULATE_AGE
(@DOB DATE)
RETURNS INT
AS
BEGIN
	DECLARE @AGE INT;
	SET @AGE = DATEDIFF(YEAR, @DOB, GETDATE());
	
	-- Adjust if birthday hasn't occurred this year
	IF (MONTH(@DOB) > MONTH(GETDATE())) OR 
	   (MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE()))
		SET @AGE = @AGE - 1;
		
	RETURN @AGE;
END;

SELECT dbo.FN_CALCULATE_AGE('2000-05-15') AS AgeInYears;
SELECT dbo.FN_CALCULATE_AGE('1995-12-31') AS AgeInYears;

--12. Write a scalar function to check whether given number is palindrome or not. 
CREATE OR ALTER FUNCTION FN_IS_PALINDROME
(@NUM INT)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @REV INT = 0;
	DECLARE @TEMP INT = @NUM;
	DECLARE @REM INT;
	
	WHILE @TEMP > 0
	BEGIN
		SET @REM = @TEMP % 10;
		SET @REV = @REV * 10 + @REM;
		SET @TEMP = @TEMP / 10;
	END;
	
	IF @NUM = @REV
		RETURN 'PALINDROME';
		
	RETURN 'NOT PALINDROME';
END;

SELECT dbo.FN_IS_PALINDROME(121) AS PalindromeCheck;
SELECT dbo.FN_IS_PALINDROME(123) AS PalindromeCheck;
SELECT dbo.FN_IS_PALINDROME(1221) AS PalindromeCheck;

--12. Write a scalar function to check whether given number OR string is palindrome or not. 
CREATE OR ALTER FUNCTION FN_IS_PALINDROME
(@INPUT VARCHAR(100))  -- Changed to VARCHAR to handle both numbers and strings
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @LEN INT;
    DECLARE @I INT = 1;
    DECLARE @IS_PALINDROME BIT = 1;  -- 1 = TRUE, 0 = FALSE
    
    -- Remove spaces and convert to uppercase for string comparison
    SET @INPUT = UPPER(REPLACE(@INPUT, ' ', ''));
    SET @LEN = LEN(@INPUT);
    
    -- Check for empty string or single character
    IF @LEN <= 1
        RETURN 'PALINDROME';
    
    -- Compare characters from start and end
    WHILE @I <= @LEN / 2
    BEGIN
        IF SUBSTRING(@INPUT, @I, 1) <> SUBSTRING(@INPUT, @LEN - @I + 1, 1)
        BEGIN
            SET @IS_PALINDROME = 0;
            BREAK;
        END
        SET @I = @I + 1;
    END
    
    IF @IS_PALINDROME = 1
        RETURN 'PALINDROME';
        
    RETURN 'NOT PALINDROME';
END;

-- Test with numbers (they'll be converted to strings automatically)
SELECT dbo.FN_IS_PALINDROME('121') AS PalindromeCheck;         -- PALINDROME
SELECT dbo.FN_IS_PALINDROME('123') AS PalindromeCheck;         -- NOT PALINDROME
SELECT dbo.FN_IS_PALINDROME('1221') AS PalindromeCheck;        -- PALINDROME
SELECT dbo.FN_IS_PALINDROME('12321') AS PalindromeCheck;       -- PALINDROME

-- Test with strings
SELECT dbo.FN_IS_PALINDROME('MADAM') AS PalindromeCheck;       -- PALINDROME
SELECT dbo.FN_IS_PALINDROME('RACECAR') AS PalindromeCheck;     -- PALINDROME
SELECT dbo.FN_IS_PALINDROME('HELLO') AS PalindromeCheck;       -- NOT PALINDROME
SELECT dbo.FN_IS_PALINDROME('A MAN A PLAN A CANAL PANAMA') AS PalindromeCheck;  -- PALINDROME (with spaces)


-- 12. Write a scalar function to check palindrome using REVERSE() function
CREATE OR ALTER FUNCTION FN_IS_PALINDROME_REVERSE
(@INPUT VARCHAR(100))
RETURNS VARCHAR(20)
AS
BEGIN
    -- Clean the input: remove spaces, convert to uppercase
    DECLARE @CLEAN_INPUT VARCHAR(100);
    SET @CLEAN_INPUT = UPPER(REPLACE(@INPUT, ' ', ''));
    
    -- Remove other punctuation if needed (optional)
    -- SET @CLEAN_INPUT = REPLACE(REPLACE(@CLEAN_INPUT, ',', ''), '.', '');
    
    -- Check if cleaned string is empty or single character
    IF LEN(@CLEAN_INPUT) <= 1
        RETURN 'PALINDROME';
    
    -- Compare original with reversed string
    IF @CLEAN_INPUT = REVERSE(@CLEAN_INPUT)
        RETURN 'PALINDROME';
        
    RETURN 'NOT PALINDROME';
END;

-- Test the REVERSE version
SELECT dbo.FN_IS_PALINDROME_REVERSE('121') AS PalindromeCheck;
SELECT dbo.FN_IS_PALINDROME_REVERSE('MADAM') AS PalindromeCheck;
SELECT dbo.FN_IS_PALINDROME_REVERSE('HELLO') AS PalindromeCheck;
SELECT dbo.FN_IS_PALINDROME_REVERSE('A MAN A PLAN A CANAL PANAMA') AS PalindromeCheck;

-- 12. Write a scalar function to check if a number is palindrome
CREATE OR ALTER FUNCTION FN_IS_NUMBER_PALINDROME
(@NUM INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @NUM_STR VARCHAR(20) = CAST(@NUM AS VARCHAR(20));
    
    IF @NUM_STR = REVERSE(@NUM_STR)
        RETURN 'PALINDROME';
        
    RETURN 'NOT PALINDROME';
END;

-- Test the number-specific version
SELECT dbo.FN_IS_NUMBER_PALINDROME(121) AS NumberPalindrome;
SELECT dbo.FN_IS_NUMBER_PALINDROME(123) AS NumberPalindrome;
SELECT dbo.FN_IS_NUMBER_PALINDROME(12321) AS NumberPalindrome;


--13. Write a scalar function to calculate the sum of Credits for all courses in the 'CSE' department. 
CREATE OR ALTER FUNCTION FN_SUM_CSE_CREDITS()
RETURNS INT
AS
BEGIN
	DECLARE @TOTAL INT;
	SELECT @TOTAL = SUM(CourseCredits)
	FROM COURSE
	WHERE CourseDepartment = 'CSE';
	
	RETURN ISNULL(@TOTAL, 0);
END;

SELECT dbo.FN_SUM_CSE_CREDITS() AS TotalCSECredits;

--14. Write a table-valued function that returns all courses taught by faculty with a specific designation. 
CREATE OR ALTER FUNCTION FN_COURSES_BY_DESIGNATION
(@DESIGNATION VARCHAR(50))
RETURNS TABLE
AS
RETURN (
	SELECT 
		C.CourseID,
		C.CourseName,
		C.CourseCredits,
		C.CourseDepartment,
		F.FacultyName,
		F.FacultyDesignation
	FROM COURSE C
	JOIN COURSE_ASSIGNMENT CA ON C.CourseID = CA.CourseID
	JOIN FACULTY F ON CA.FacultyID = F.FacultyID
	WHERE F.FacultyDesignation = @DESIGNATION
);

SELECT * FROM dbo.FN_COURSES_BY_DESIGNATION('Professor');
SELECT * FROM dbo.FN_COURSES_BY_DESIGNATION('Associate Professor');

--Part - C 
--15. Write a scalar function that accepts StudentID and returns their total enrolled credits (sum of credits 
--from all active enrollments).
CREATE OR ALTER FUNCTION FN_TOTAL_ENROLLED_CREDITS
(@STUDENTID INT)
RETURNS INT
AS
BEGIN
	DECLARE @TOTAL_CREDITS INT;
	
	SELECT @TOTAL_CREDITS = ISNULL(SUM(C.CourseCredits), 0)
	FROM ENROLLMENT E
	JOIN COURSE C ON E.CourseID = C.CourseID
	WHERE E.StudentID = @STUDENTID 
	  AND E.EnrollmentStatus = 'Active';
	
	RETURN @TOTAL_CREDITS;
END;

SELECT dbo.FN_TOTAL_ENROLLED_CREDITS(1) AS TotalEnrolledCredits;
SELECT dbo.FN_TOTAL_ENROLLED_CREDITS(2) AS TotalEnrolledCredits;

--16. Write a scalar function that accepts two dates (joining date range) and returns the count of faculty who 
--joined in that period.
CREATE OR ALTER FUNCTION FN_FACULTY_COUNT_BY_JOIN_RANGE
(@START_DATE DATE, @END_DATE DATE)
RETURNS INT
AS
BEGIN
	DECLARE @COUNT INT;
	
	SELECT @COUNT = COUNT(*)
	FROM FACULTY
	WHERE FacultyJoiningDate BETWEEN @START_DATE AND @END_DATE;
	
	RETURN ISNULL(@COUNT, 0);
END;

SELECT dbo.FN_FACULTY_COUNT_BY_JOIN_RANGE('2010-01-01', '2020-12-31') AS FacultyCount;
SELECT dbo.FN_FACULTY_COUNT_BY_JOIN_RANGE('2015-01-01', GETDATE()) AS RecentFacultyCount;