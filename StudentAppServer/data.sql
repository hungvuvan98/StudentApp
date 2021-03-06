CREATE DATABASE [StudentApp]
GO
USE [StudentApp]
GO
/****** Object:  UserDefinedTableType [dbo].[ResultLearning]    Script Date: 10/13/2020 2:16:33 PM ******/
CREATE TYPE [dbo].[ResultLearning] AS TABLE(
	[Semester] [nvarchar](10) NULL,
	[GPA] [float] NULL,
	[CPA] [float] NULL,
	[TCQua] [int] NULL,
	[TCTichLuy] [int] NULL,
	[TCNoDK] [int] NULL,
	[TCDK] [int] NULL,
	[TrinhDo] [nvarchar](30) NULL,
	[MucCC] [int] NULL
)
GO
/****** Object:  StoredProcedure [dbo].[sp_GetListClass]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetListClass] (@semester NVARCHAR(20))
AS
BEGIN
	SELECT se.SecId,se.Semester,se.Status,se.Building,se.RoomNumber,
			dbo.Courses.Credits AS 'Credit',
			t.StartHr,t.StartMin,t.EndHr,t.EndMin,t.Day,
			Courses.CourseId,Title,
			dbo.Classrooms.Capacity,
			dbo.Departments.Name 
			 FROM dbo.Sections se 
			INNER JOIN dbo.TimeSlots t ON t.TimeSlotId = se.TimeSlotId 
										AND t.Day = se.Day
			INNER JOIN dbo.Courses ON Courses.CourseId = se.CourseId
			INNER JOIN dbo.Departments ON Departments.DepartmentId = Courses.DepartmentId
			INNER JOIN dbo.Classrooms ON Classrooms.Building = se.Building 
										 AND Classrooms.RoomNumber = se.RoomNumber
			WHERE se.Semester=@semester AND se.Status=0
			ORDER BY se.CourseId 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetListClassRegisteredByStudentId]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetListClassRegisteredByStudentId] ( @studentId NVARCHAR(20),@semester NVARCHAR(20))
AS
BEGIN
	SELECT  dbo.Takes.ID,
			se.SecId,se.Status,se.Building,se.RoomNumber,se.Semester,
			dbo.Courses.Credits AS 'Credit',
			t.StartHr,t.StartMin,t.EndHr,t.EndMin,t.Day,
			Courses.CourseId,Title
			 FROM dbo.Sections se 
			INNER JOIN dbo.TimeSlots t ON t.TimeSlotId = se.TimeSlotId 
										AND t.Day = se.Day
			INNER JOIN dbo.Courses ON Courses.CourseId = se.CourseId
			INNER JOIN dbo.Departments ON Departments.DepartmentId = Courses.DepartmentId
			INNER JOIN dbo.Classrooms ON Classrooms.Building = se.Building 
										 AND Classrooms.RoomNumber = se.RoomNumber
			INNER JOIN dbo.Takes ON Takes.SecId = se.SecId
			WHERE dbo.Takes.ID=@studentId AND se.Semester=@semester
			ORDER BY se.SecId 
END

--EXEC dbo.sp_GetListClassRegisteredByStudentId @studentId = N'20160024',@semester='20201' -- nvarchar(20)

GO
/****** Object:  StoredProcedure [dbo].[SP_GetStudent]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetStudent]
               AS
                BEGIN
                    SET NOCOUNT ON;
	                SELECT st.Id,st.Name AS'StudentName',st.Status,st.CreatedYear,
		                sc.Name AS'StudentClassName',sc.Id AS'StudentClassId',
		                d.Name AS'DepartmentName',d.DepartmentId

	                FROM dbo.Students st
                    INNER JOIN dbo.StudentClasses sc ON sc.Id = st.StudentClassId
											      AND sc.DepartmentId = st.DepartmentId
				    INNER JOIN dbo.Departments d ON d.DepartmentId = sc.DepartmentId
                END; 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetStudentInfor]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetStudentInfor]( @id VARCHAR(20) )
                AS
				BEGIN
					SET NOCOUNT ON;
				SELECT st.Id,st.Name AS'StudentName',st.Password,st.BirthDay,st.Address,st.CardId,st.Birthplace,
						st.Avatar,st.Status,st.CreatedYear,
					ta.Midterm,ta.Endterm,ta.WordScore,
					se.Semester,se.year,se.SecId,
					co.Title,co.Credits,co.CourseId,
					cl.Building,cl.RoomNumber,
					sc.Name AS'StudentClassName',
					d.Name AS'DepartmentName'

				 FROM dbo.Students st
					INNER JOIN dbo.Takes ta ON ta.ID = st.Id
					INNER JOIN dbo.Sections se ON se.SecId = ta.SecId
					INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
					INNER JOIN dbo.Classrooms cl ON cl.Building = se.Building
											 AND cl.RoomNumber = se.RoomNumber

					INNER JOIN dbo.StudentClasses sc ON sc.Id = st.StudentClassId
												AND sc.DepartmentId = st.DepartmentId

					INNER JOIN dbo.Departments d ON d.DepartmentId = sc.DepartmentId
					WHERE st.Id=@id
					ORDER BY se.year;
				END;

GO
/****** Object:  StoredProcedure [dbo].[sp_maxscore]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_maxscore](@semester NVARCHAR(20),@id nvarchar(20))
AS
begin
		SELECT se.CourseId, co.Credits, MAX(dbo.fn_convertscore( t.WordScore)) AS maxscore
		FROM takes t INNER JOIN dbo.Sections se ON se.SecId = t.SecId
		INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
		WHERE t.ID=@id AND se.Semester<=@semester
		GROUP BY se.CourseId ,co.Credits,t.ID
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_result_learning]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_result_learning] (@id NVARCHAR(20))
AS
BEGIN
	SET NOCOUNT ON ;

	DECLARE @resultlearning AS ResultLearning; --ResultLearning is type table
	DECLARE @sem NVARCHAR(10),@TCQua INT,@TCTichLuy INT,@TCDK INT, @TCNoDK INT,@TrinhDo NVARCHAR(30);
	DECLARE @MucCC INT;
	DECLARE @TCTichLuy_cursor CURSOR;
	DECLARE @fetch_TCTichLuy_cursor NVARCHAR(20);
	DECLARE @fetch_semester_cursor NVARCHAR(20);
	DECLARE @temp_courseId NVARCHAR(20),@temp_credit INT,@temp_maxscore  FLOAT;
	SET @TCNoDK=0;
	SET @TCTichLuy=0;

	DECLARE semester_cursor CURSOR STATIC LOCAL FOR   
	SELECT DISTINCT se.Semester FROM dbo.Takes t 
	INNER JOIN dbo.Sections  se ON se.SecId = t.SecId
    WHERE t.ID =@id ;

	OPEN semester_cursor;

	FETCH NEXT FROM semester_cursor  INTO @sem;
	select @fetch_semester_cursor = @@FETCH_STATUS
	WHILE @fetch_semester_cursor = 0    
		BEGIN    		
			-- tc lich luy

			SET @TCTichLuy_cursor= CURSOR STATIC LOCAL FOR  
							SELECT se.CourseId, co.Credits, MAX(dbo.fn_convertscore( t.WordScore)) AS maxscore
							FROM takes t INNER JOIN dbo.Sections se ON se.SecId = t.SecId
							INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
							WHERE t.ID=@id AND se.Semester<=@sem
							GROUP BY se.CourseId ,co.Credits;
			OPEN @TCTichLuy_cursor;
			FETCH NEXT FROM @TCTichLuy_cursor INTO @temp_courseId,@temp_credit,@temp_maxscore;				
			select @fetch_TCTichLuy_cursor = @@FETCH_STATUS
			WHILE @fetch_TCTichLuy_cursor = 0    
			   BEGIN 
					SET @TCTichLuy = @TCTichLuy + @temp_credit;
					FETCH NEXT FROM @TCTichLuy_cursor  INTO @temp_courseId,@temp_credit,@temp_maxscore;	
				   select @fetch_TCTichLuy_cursor = @@FETCH_STATUS ;
			   END
		   CLOSE @TCTichLuy_cursor;
		   DEALLOCATE @TCTichLuy_cursor;
		    --TC Qua mỗi kì
			 SELECT @TCQua=SUM(co.Credits) FROM dbo.Takes t 
				INNER JOIN dbo.Sections  se ON se.SecId = t.SecId
				INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
				WHERE t.ID =@id AND t.WordScore != 'F' AND se.Semester = @sem ;
			
			 IF @TCQua IS NULL SET @TCQua=0;

			--TC Nợ ĐK
			SELECT @TCNoDK =SUM(co.Credits) FROM dbo.Takes t 
				INNER JOIN dbo.Sections  se ON se.SecId = t.SecId
				INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
			    WHERE t.ID =@id AND t.WordScore ='F' AND se.Semester <= @sem ;
			
			IF @TCNoDK IS NULL SET @TCNoDK=0;

			--TC da dk
			SELECT @TCDK=SUM(co.Credits) FROM dbo.Takes t 
				INNER JOIN dbo.Sections  se ON se.SecId = t.SecId
				INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
				WHERE t.ID =@id  AND se.Semester <= @sem ;
			IF @TCDK IS NULL SET @TCDK=0;
			-- trinh do
				IF @TCTichLuy<=31
				BEGIN
					SET @TrinhDo=N'Sinh Vien Nam 1';
				END
			   ELSE IF @TCTichLuy>=32 AND @TCTichLuy<=63
				BEGIN
					SET @TrinhDo=N'Sinh Vien Nam 2';
				END
			   ELSE IF @TCTichLuy>=64 AND @TCTichLuy<=95
				BEGIN
					SET @TrinhDo=N'Sinh Vien Nam 3';
				END
			   ELSE IF @TCTichLuy>=96 AND @TCTichLuy<=128
				BEGIN
					SET @TrinhDo=N'Sinh Vien Nam 4';
				END
			   ELSE IF @TCTichLuy>128 
			   BEGIN
					SET @TrinhDo=N'Sinh Vien Nam 5';
				END
			   ELSE SET @TrinhDo=N'Sinh Vien Nam 1';

			-- get Muc canh cao
			   SELECT @MucCC=Level FROM dbo.Warns WHERE StudentId=@id AND Semester=@sem;

			 --get all data to show front-end
			 INSERT INTO @resultlearning
			 SELECT @sem AS 'Semester', dbo.fn_gpa(@sem,@id) AS GPA,dbo.fn_cpa(@sem,@id) AS CPA,
					@TCQua AS TCQua, @TCTichLuy AS TCTichLuy, @TCNoDk AS TCNoDK, @TCDK AS TCDK, 
					@TrinhDo AS TrinhDo,@MucCC AS MucCC ;

			 SET @TCTichLuy=0;
			 FETCH NEXT FROM semester_cursor  INTO @sem;
			 select @fetch_semester_cursor = @@FETCH_STATUS ;
		END 

	SELECT * FROM @resultlearning;

	CLOSE semester_cursor; 
	DEALLOCATE semester_cursor;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SoLuongDaDK]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SoLuongDaDK] (@secId NVARCHAR(20))
AS
BEGIN
	SELECT COUNT(DISTINCT dbo.Takes.ID) AS'Count' FROM dbo.Takes 
				INNER JOIN dbo.Sections ON Sections.SecId = Takes.SecId  
				WHERE Sections.SecId=@secId

END
GO
/****** Object:  StoredProcedure [dbo].[sp_update_wordscore]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_update_wordscore]
							AS
							BEGIN
								SET NOCOUNT ON;
								UPDATE dbo.Takes SET WordScore=(
										CASE
										WHEN 3.95<= (Midterm * 0.3 + Endterm * 0.7) AND (Midterm * 0.3 + Endterm * 0.7)<4.95 THEN 'D'
										WHEN 4.95<= (Midterm * 0.3 + Endterm * 0.7) AND (Midterm * 0.3 + Endterm * 0.7)<5.45 THEN 'D+'
										WHEN 5.45<= (Midterm * 0.3 + Endterm * 0.7) AND (Midterm * 0.3 + Endterm * 0.7)<6.45 THEN 'C'
										WHEN 6.45<= (Midterm * 0.3 + Endterm * 0.7) AND (Midterm * 0.3 + Endterm * 0.7)<6.95 THEN 'C+'
										WHEN 6.95<= (Midterm * 0.3 + Endterm * 0.7) AND (Midterm * 0.3 + Endterm * 0.7)<7.95 THEN 'B'
										WHEN 7.95<= (Midterm * 0.3 + Endterm * 0.7) AND (Midterm * 0.3 + Endterm * 0.7)<8.45 THEN 'B+'
										WHEN 8.45<= (Midterm * 0.3 + Endterm * 0.7) AND (Midterm * 0.3 + Endterm * 0.7)<9 THEN 'A'
										WHEN 9<= (Midterm * 0.3 + Endterm * 0.7) THEN 'A+'
										ELSE 'F'
										END );
							END;

GO
/****** Object:  StoredProcedure [dbo].[sp_updateLevelWarn]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_updateLevelWarn]
AS
BEGIN
	SET NOCOUNT ON ;
	DECLARE @studentId NVARCHAR(20);
	DECLARE @semester NVARCHAR(10),@TCNoDK INT;
	DECLARE @semester_cursor CURSOR;
	DECLARE @fetch_studentId_cursor NVARCHAR(20);
	DECLARE @fetch_semester_cursor NVARCHAR(20);

	DECLARE studentid_cursor CURSOR STATIC LOCAL FOR  
			SELECT DISTINCT t.ID FROM dbo.Takes t 
			INNER JOIN dbo.Sections  se ON se.SecId = t.SecId

	OPEN studentid_cursor;

	FETCH NEXT FROM studentid_cursor  INTO @studentId;
	select @fetch_studentId_cursor = @@FETCH_STATUS

	WHILE @fetch_studentId_cursor = 0    
		BEGIN    				
					SET @semester_cursor= CURSOR STATIC LOCAL FOR  
							SELECT DISTINCT se.Semester FROM dbo.Takes t 
							INNER JOIN dbo.Sections  se ON se.SecId = t.SecId
							WHERE t.ID=@studentId;
					OPEN @semester_cursor ;
					FETCH NEXT FROM @semester_cursor INTO @semester;				
					select @fetch_semester_cursor = @@FETCH_STATUS
					WHILE @fetch_semester_cursor = 0    
						BEGIN    
							--TC Nợ ĐK
									SELECT @TCNoDK =SUM(co.Credits) FROM dbo.Takes t 
									    INNER JOIN dbo.Sections  se ON se.SecId = t.SecId
										INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
										WHERE t.ID =@studentId AND t.WordScore ='F' AND se.Semester <= @semester; 
									IF @TCNoDK IS NULL SET @TCNoDK=0;

									IF @TCNoDK>8 
									BEGIN
										IF @semester NOT IN (SELECT Semester FROM Warns WHERE StudentId=@studentId )
										BEGIN
											INSERT INTO dbo.Warns (StudentId,Semester,Level)
												VALUES (@studentId,@semester,1)
										END			
									END
			
									ELSE IF @TCNoDK>16 AND @TCNoDK <=27
									BEGIN
										IF @semester NOT IN (SELECT Semester FROM Warns WHERE StudentId=@studentId )
										BEGIN
											INSERT INTO dbo.Warns (StudentId,Semester,Level)
												VALUES (@studentId,@semester,2)
										END			
									END

									ELSE IF @TCNoDK>27
									BEGIN
										IF @semester NOT IN (SELECT Semester FROM Warns WHERE StudentId=@studentId )
										BEGIN
											INSERT INTO dbo.Warns (StudentId,Semester,Level)
												VALUES (@studentId,@semester,3)
										END			
									END

									ELSE IF @semester NOT IN (SELECT Semester FROM Warns WHERE StudentId=@studentId )
										BEGIN
											INSERT INTO dbo.Warns (StudentId,Semester,Level)
												VALUES (@studentId,@semester,10)
										END			

									 FETCH NEXT FROM @semester_cursor  INTO @semester ;
									 select @fetch_semester_cursor = @@FETCH_STATUS ;
									 													
						END 
						CLOSE @semester_cursor;
						DEALLOCATE @semester_cursor;

			FETCH NEXT FROM studentid_cursor  INTO @studentId;
			SELECT @fetch_studentId_cursor = @@FETCH_STATUS
			
		END 	
	CLOSE studentid_cursor;
	DEALLOCATE studentid_cursor;
END

--EXEC sp_updateLevelWarn




GO
/****** Object:  UserDefinedFunction [dbo].[fn_convertscore]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_convertscore]( @score varchar(2))

returns FLOAT

BEGIN

	RETURN
        CASE 
		    WHEN @score ='A+' OR @score='A' THEN  4
			WHEN @score = 'B+' THEN  3.5
			WHEN @score = 'B' THEN  3
			WHEN @score = 'C+' THEN  2.5
			WHEN @score = 'C' THEN 2
			WHEN @score = 'D+' THEN 1.5
			WHEN @score = 'D' THEN 1
			WHEN @score = 'F' THEN 0
        END 
END;

--SELECT dbo.fn_convertscore(t.WordScore) AS score 
GO
/****** Object:  UserDefinedFunction [dbo].[fn_cpa]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_cpa](@semester VARCHAR(5), @id VARCHAR(20))
RETURNS FLOAT
AS
BEGIN
	DECLARE @cpa FLOAT;
	DECLARE @totalCredit INT, @credit int,@maxscore FLOAT,@courseId NVARCHAR(20);

	SET @totalCredit = 0;
	SET @cpa = 0;

	DECLARE my_cursor CURSOR FOR     
		SELECT se.CourseId, co.Credits, MAX(dbo.fn_convertscore( t.WordScore)) AS maxscore
		FROM takes t INNER JOIN dbo.Sections se ON se.SecId = t.SecId
		INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
		WHERE t.ID=@id AND se.Semester<=@semester
		GROUP BY se.CourseId ,co.Credits;
	
	OPEN my_cursor;

	FETCH NEXT FROM my_cursor  
	INTO @courseId, @credit,@maxscore ;
		
	WHILE @@FETCH_STATUS = 0    
		BEGIN    
			 SET @totalCredit = @totalCredit + @credit ;
			 
			 SET @cpa = @cpa + (@credit * @maxscore)
			
			 FETCH NEXT FROM my_cursor
			 INTO @courseId, @credit,@maxscore ;
   
		END 
	SET @cpa = @cpa/@totalCredit ;   
	CLOSE my_cursor; 
	DEALLOCATE my_cursor;
	
	RETURN ROUND(@cpa,2);
END;

--SELECT dbo.fn_cpa('20161','20160398') AS cpa



GO
/****** Object:  UserDefinedFunction [dbo].[fn_gpa]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_gpa](@semester VARCHAR(5), @id VARCHAR(20))
RETURNS FLOAT
AS
BEGIN
	DECLARE @gpa FLOAT;
	SELECT @gpa= SUM( dbo.fn_convertscore(t.WordScore) * co.Credits)/SUM(co.Credits) 
    FROM takes t 
		INNER JOIN dbo.Sections se ON se.SecId = t.SecId
		INNER JOIN dbo.Courses co ON co.CourseId = se.CourseId
	WHERE se.Semester=@semester AND t.ID=@id
	
	RETURN ROUND(@gpa,2);
END;

--SELECT dbo.fn_gpa('20161','20160398') AS cpa

GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AppGroups]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppGroups](
	[Id] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Role] [nvarchar](50) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK__Appgroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Classrooms]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Classrooms](
	[Building] [nvarchar](20) NOT NULL,
	[RoomNumber] [nvarchar](20) NOT NULL,
	[Capacity] [int] NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK__classroom] PRIMARY KEY CLUSTERED 
(
	[Building] ASC,
	[RoomNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Courses]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[CourseId] [nvarchar](20) NOT NULL,
	[Title] [nvarchar](200) NULL,
	[Credits] [int] NOT NULL,
	[DepartmentId] [nvarchar](20) NULL,
 CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Departments]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[DepartmentId] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Building] [nvarchar](20) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK__department] PRIMARY KEY CLUSTERED 
(
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Feedbacks]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feedbacks](
	[ID] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Email] [nvarchar](200) NULL,
	[Message] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK__feedback] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InstructorDepartments]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstructorDepartments](
	[Id] [nvarchar](20) NOT NULL,
	[DepartmentId] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_InstructorDepartment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InstructorNotification]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstructorNotification](
	[InstructorId] [nvarchar](20) NOT NULL,
	[NotificationId] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_InstructorNotice] PRIMARY KEY CLUSTERED 
(
	[InstructorId] ASC,
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Instructors]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Instructors](
	[ID] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Password] [nvarchar](max) NULL,
	[BitrhDay] [datetime2](7) NULL,
	[Address] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[Gender] [int] NOT NULL,
	[CardId] [int] NULL,
	[Birthplace] [nvarchar](max) NULL,
	[CreatedYear] [nvarchar](max) NULL,
	[Avatar] [nvarchar](max) NULL,
	[Salary] [numeric](8, 2) NULL,
	[Status] [int] NOT NULL,
	[GroupId] [nvarchar](20) NULL,
	[DepartmentId] [nvarchar](20) NULL,
	[InstructorDepartmentId] [nvarchar](20) NULL,
 CONSTRAINT [PK_Instructors] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Languages]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Languages](
	[Id] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[IsDefault] [bit] NOT NULL,
	[Resources] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_language] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[Id] [nvarchar](20) NOT NULL,
	[Message] [nvarchar](max) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[Title] [nvarchar](200) NULL,
 CONSTRAINT [PK_Notification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PostCategories]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostCategories](
	[Id] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_Postcategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Posts]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Posts](
	[Id] [nvarchar](20) NOT NULL,
	[PostCategoryId] [nvarchar](20) NULL,
	[Content] [nvarchar](max) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](max) NULL,
	[ModifiedBy] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_Post] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Prereqs]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prereqs](
	[CourseId] [nvarchar](20) NOT NULL,
	[PrereqId] [nvarchar](20) NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK__prereq] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC,
	[PrereqId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sections]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sections](
	[SecId] [nvarchar](20) NOT NULL,
	[Semester] [nvarchar](20) NULL,
	[Year] [nvarchar](20) NULL,
	[Status] [int] NOT NULL,
	[Building] [nvarchar](20) NULL,
	[RoomNumber] [nvarchar](20) NULL,
	[TimeSlotId] [nvarchar](20) NULL,
	[Day] [nvarchar](20) NULL,
	[CourseId] [nvarchar](20) NULL,
 CONSTRAINT [PK__section] PRIMARY KEY CLUSTERED 
(
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Semesters]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Semesters](
	[Id] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK__semester] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StudentClasses]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentClasses](
	[Id] [nvarchar](20) NOT NULL,
	[DepartmentId] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Year] [nvarchar](20) NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK__StudentClass] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StudentNotification]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentNotification](
	[StudentId] [nvarchar](20) NOT NULL,
	[NotificationId] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_StudentNotice] PRIMARY KEY CLUSTERED 
(
	[StudentId] ASC,
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Students]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[Id] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Password] [nvarchar](20) NULL,
	[Email] [nvarchar](max) NULL,
	[BirthDay] [datetime2](7) NULL,
	[Address] [nvarchar](max) NULL,
	[CardId] [int] NULL,
	[Birthplace] [nvarchar](max) NULL,
	[Avatar] [nvarchar](max) NULL,
	[CreatedYear] [nvarchar](20) NULL,
	[Status] [int] NOT NULL,
	[GroupId] [nvarchar](20) NULL,
	[StudentClassId] [nvarchar](20) NULL,
	[DepartmentId] [nvarchar](20) NULL,
 CONSTRAINT [PK__Student] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Takes]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Takes](
	[ID] [nvarchar](20) NOT NULL,
	[SecId] [nvarchar](20) NOT NULL,
	[Midterm] [real] NULL,
	[Endterm] [real] NULL,
	[WordScore] [nvarchar](2) NULL,
 CONSTRAINT [PK__takes__A0A7458A976F2631] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Teaches]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teaches](
	[ID] [nvarchar](20) NOT NULL,
	[SecId] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK__teaches__A0A7458ABC151A07] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TimeSlots]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeSlots](
	[TimeSlotId] [nvarchar](20) NOT NULL,
	[Day] [nvarchar](20) NOT NULL,
	[StartHr] [int] NULL,
	[StartMin] [int] NULL,
	[EndHr] [int] NULL,
	[EndMin] [int] NULL,
 CONSTRAINT [PK__timeslot] PRIMARY KEY CLUSTERED 
(
	[TimeSlotId] ASC,
	[Day] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ToeicPoints]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToeicPoints](
	[ID] [nvarchar](20) NOT NULL,
	[StudentId] [nvarchar](20) NOT NULL,
	[Semester] [nvarchar](max) NULL,
	[year] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[HearPoint] [int] NOT NULL,
	[ReadPoint] [int] NOT NULL,
	[TotalPoint] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK__toeicpoint] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[StudentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Warns]    Script Date: 10/13/2020 2:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Warns](
	[StudentId] [nvarchar](20) NOT NULL,
	[Semester] [nvarchar](20) NOT NULL,
	[Level] [int] NOT NULL,
 CONSTRAINT [PK_warn] PRIMARY KEY CLUSTERED 
(
	[StudentId] ASC,
	[Semester] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200817233615_itinial', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200817234451_updatestclass', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200818013945_create_procedure', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200823055632_alterproc', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200824052056_create_proc_GetResultLearning', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200825063005_addWarnTable', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200825070209_updatewarn', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200825070351_updatewarn1', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200901005053_updatetablenotification', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200902144508_create_table_getlistclass', N'3.1.7')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200908081826_addsemester', N'3.1.7')
INSERT [dbo].[AppGroups] ([Id], [Name], [Role], [Status]) VALUES (N'1', N'Administrator', N'Administrator', 0)
INSERT [dbo].[AppGroups] ([Id], [Name], [Role], [Status]) VALUES (N'2', N'Student', N'Student', 0)
INSERT [dbo].[AppGroups] ([Id], [Name], [Role], [Status]) VALUES (N'3', N'Instructor', N'Instructor', 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C3', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C4', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C5', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C6', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C7', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C8', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'C9', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D3', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D4', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D5', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D6', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'103', 500, 0)
GO
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D7', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D8', N'109', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'101', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'102', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'103', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'104', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'105', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'106', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'107', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'108', 500, 0)
INSERT [dbo].[Classrooms] ([Building], [RoomNumber], [Capacity], [Status]) VALUES (N'D9', N'109', 500, 0)
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT1010', N'Tin học đại cương', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT1011', N'Nhập môn CNTT và TT', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3010', N'Cấu trúc dữ liệu và giải thuật', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3021', N'Toán rời rạc', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3030', N'Kiến trúc máy tính', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3040', N'Kỹ thuật lập trình', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3071', N'Hệ điều hành', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3081', N'Mạng máy tính', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3090', N'Cơ sở dữ liệu', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3100', N'Lập trình hướng đối tượng', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3110', N'Linux và phần mềm nguồn mở', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3120', N'Phân tích và thiết kế hệ thống', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3130', N'IT3130', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3151', N'Lý thuyết thông tin', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT3680', N'Thuật toán ứng dụng', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4010', N'An toàn và bảo mật thông tin', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4060', N'Lập trình mạng', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4090', N'Xử lý ảnh', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4130', N'Lập trình song song', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4180', N'Chương trình dịch', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4371', N'Các hệ phân tán', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4404', N'Phát triển Web trên nền tảng mã nguồn mở', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4430', N'Kỹ thuật phần mềm', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4756', N'Thương mại điện tử', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4757', N'Kỹ thuật mô hình hóa và mô phỏng', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4766', N'Lập trình kịch bản với JavaScript', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4779', N'Xử lý dữ liệu lớn', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4867', N'Xử lý dữ liệu phân tán', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4868', N'Khai phá Web', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'IT4912', N'Điện toán đám mây - nguồn mở', 3, N'IT')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI1110', N'Giải tích I', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI1120', N'Giải tích II', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI1130', N'Giải tích III', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI1140', N'Đại số', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI1150', N'Đại số đại cương', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI2000', N'Nhập môn Toán-Tin', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI2060', N'Cơ sở giải tích hàm', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3010', N'Toán rời rạc', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3030', N'Xác suất thống kê', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3040', N'Giải tích số', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3050', N'Các phương pháp tối ưu', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3060', N'Cấu trúc dữ liệu và giải thuật', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3070', N'Phương trình đạo hàm riêng', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3080', N'Giải tích phức và ứng dụng', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3090', N'Cơ sở dữ liệu', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3120', N'Phân tích và thiết kế hệ thống', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3310', N'Kỹ thuật lập trình', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3370', N'Hệ điều hành', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3380', N'Đồ án I', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI3390', N'Đồ án II', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4010', N'Lý thuyết Otomat và ngôn ngữ hình thức', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4020', N'Phân tích số liệu', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4030', N'Mô hình toán kinh tế', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4060', N'Hệ thống và mạng máy tính', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4090', N'Lập trình hướng đối tượng', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4100', N'Mật mã và độ phức tạp thuật toán', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4140', N'Cơ sở dữ liệu nâng cao', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4150', N'Lý thuyết nhận dạng', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4311', N'Tối ưu tổ hợp I', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4344', N'Kiến trúc máy tính', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI4352', N'Xêmina II (Tin ứng dụng)', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI5020', N'An toàn máy tính', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI5030', N'Điều khiển tối ưu', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI5040', N'Các mô hình ngẫu nhiên và ứng dụng', 3, N'MI')
INSERT [dbo].[Courses] ([CourseId], [Title], [Credits], [DepartmentId]) VALUES (N'MI5060', N'Lôgic thuật toán', 3, N'MI')
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'CK', N'Viện Cơ Khí', N'C3', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'CKDL', N'Viện Cơ Khí Động Lực', N'C4', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'IT', N'Viện Công Nghệ Thông Tin Và Truyền Thông', N'B1', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'MI', N'Viện Toán Ứng Dụng Và Tin Học', N'D3', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VCNSHVTP', N'Viện Công Nghệ Sinh Học Và Thực Phẩm', N'C7', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VD', N'Viện Điện', N'D5', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VDMĐVTT', N'Viện Dệt May Da Giày Và Thời Trang', N'D4', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VDTVT', N'Viện Điện Tử Viễn Thông', N'D5', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VKTHH', N'Viện Kỹ Thuật Hóa Học', N'D7', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VKTVQL', N'Viện Kinh Tế Và Quản Lí', N'D6', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VNN', N'Viện Ngoại Ngữ', N'D8', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VSPKT', N'Viện Sư Phạm Kỹ Thuật', N'D3', 0)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [Building], [Status]) VALUES (N'VVLKT', N'Viện Vật Lý Kỹ Thuật', N'D9', 0)
INSERT [dbo].[Notifications] ([Id], [Message], [CreatedDate], [ModifiedDate], [Status], [Title]) VALUES (N'st1', N'this is message of student has notificationId is st1', CAST(N'2020-08-31 14:52:24.6530000' AS DateTime2), CAST(N'2020-08-31 14:52:24.6530000' AS DateTime2), 0, N'this is title of this message')
INSERT [dbo].[Notifications] ([Id], [Message], [CreatedDate], [ModifiedDate], [Status], [Title]) VALUES (N'st2', N'this is message of student has notificationId is st2', CAST(N'2020-08-31 14:52:31.4670000' AS DateTime2), CAST(N'2020-08-31 14:52:31.4670000' AS DateTime2), 0, N'this is title of this message')
INSERT [dbo].[Notifications] ([Id], [Message], [CreatedDate], [ModifiedDate], [Status], [Title]) VALUES (N'st3', N'this is message of student has notificationId is st3', CAST(N'2020-08-31 14:52:43.3270000' AS DateTime2), CAST(N'2020-08-31 14:52:43.3270000' AS DateTime2), 0, N'this is title of this message')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'1  ', N'20161', N'2016', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'10 ', N'20202', N'2020', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'100', N'20162', N'2016', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'1000', N'20161', N'2016', 0, N'D8', N'106', N'2', N'2', N'MI5040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'101', N'20171', N'2017', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'102', N'20172', N'2017', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'103', N'20181', N'2018', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'104', N'20182', N'2018', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'105', N'20191', N'2019', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'106', N'20192', N'2019', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'107', N'20201', N'2020', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'108', N'20202', N'2020', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'109', N'20161', N'2016', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'11 ', N'20161', N'2016', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'110', N'20162', N'2016', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'111', N'20171', N'2017', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'112', N'20172', N'2017', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'113', N'20181', N'2018', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'114', N'20182', N'2018', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'115', N'20191', N'2019', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'116', N'20192', N'2019', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'117', N'20201', N'2020', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'118', N'20202', N'2020', 0, N'C4', N'109', N'1', N'3', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'119', N'20161', N'2016', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'12 ', N'20162', N'2016', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'120', N'20162', N'2016', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'121', N'20171', N'2017', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'122', N'20172', N'2017', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'123', N'20181', N'2018', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'124', N'20182', N'2018', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'125', N'20191', N'2019', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'126', N'20192', N'2019', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'127', N'20201', N'2020', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'128', N'20202', N'2020', 0, N'C5', N'104', N'2', N'5', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'129', N'20161', N'2016', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'13 ', N'20171', N'2017', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'130', N'20162', N'2016', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'131', N'20171', N'2017', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'132', N'20172', N'2017', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'133', N'20181', N'2018', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'134', N'20182', N'2018', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'135', N'20191', N'2019', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'136', N'20192', N'2019', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'137', N'20201', N'2020', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'138', N'20202', N'2020', 0, N'C5', N'109', N'2', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'139', N'20161', N'2016', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'14 ', N'20172', N'2017', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'140', N'20162', N'2016', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'141', N'20171', N'2017', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'142', N'20172', N'2017', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'143', N'20181', N'2018', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'144', N'20182', N'2018', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'145', N'20191', N'2019', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'146', N'20192', N'2019', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'147', N'20201', N'2020', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'148', N'20202', N'2020', 0, N'C5', N'109', N'1', N'3', N'IT3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'149', N'20161', N'2016', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'15 ', N'20181', N'2018', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'150', N'20162', N'2016', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'151', N'20171', N'2017', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'152', N'20172', N'2017', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'153', N'20181', N'2018', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'154', N'20182', N'2018', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'155', N'20191', N'2019', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'156', N'20192', N'2019', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'157', N'20201', N'2020', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'158', N'20202', N'2020', 0, N'C5', N'104', N'2', N'6', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'159', N'20161', N'2016', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'16 ', N'20182', N'2018', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'160', N'20162', N'2016', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'161', N'20171', N'2017', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'162', N'20172', N'2017', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'163', N'20181', N'2018', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'164', N'20182', N'2018', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'165', N'20191', N'2019', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'166', N'20192', N'2019', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'167', N'20201', N'2020', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'168', N'20202', N'2020', 0, N'C5', N'107', N'2', N'5', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'169', N'20161', N'2016', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'17 ', N'20191', N'2019', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'170', N'20162', N'2016', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'171', N'20171', N'2017', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'172', N'20172', N'2017', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'173', N'20181', N'2018', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'174', N'20182', N'2018', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'175', N'20191', N'2019', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'176', N'20192', N'2019', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'177', N'20201', N'2020', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'178', N'20202', N'2020', 0, N'C5', N'101', N'2', N'2', N'IT3040')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'179', N'20161', N'2016', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'18 ', N'20192', N'2019', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'180', N'20162', N'2016', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'181', N'20171', N'2017', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'182', N'20172', N'2017', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'183', N'20181', N'2018', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'184', N'20182', N'2018', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'185', N'20191', N'2019', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'186', N'20192', N'2019', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'187', N'20201', N'2020', 0, N'C5', N'103', N'4', N'2', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'188', N'20202', N'2020', 0, N'C5', N'103', N'4', N'2', N'IT3071')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'189', N'20161', N'2016', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'19 ', N'20201', N'2020', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'190', N'20162', N'2016', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'191', N'20171', N'2017', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'192', N'20172', N'2017', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'193', N'20181', N'2018', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'194', N'20182', N'2018', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'195', N'20191', N'2019', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'196', N'20192', N'2019', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'197', N'20201', N'2020', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'198', N'20202', N'2020', 0, N'C5', N'103', N'2', N'4', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'199', N'20161', N'2016', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'2  ', N'20162', N'2016', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'20 ', N'20202', N'2020', 0, N'C3', N'103', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'200', N'20162', N'2016', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'201', N'20171', N'2017', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'202', N'20172', N'2017', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'203', N'20181', N'2018', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'204', N'20182', N'2018', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'205', N'20191', N'2019', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'206', N'20192', N'2019', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'207', N'20201', N'2020', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'208', N'20202', N'2020', 0, N'C5', N'103', N'2', N'3', N'IT3071')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'209', N'20161', N'2016', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'21 ', N'20171', N'2017', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'210', N'20162', N'2016', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'211', N'20171', N'2017', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'212', N'20172', N'2017', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'213', N'20181', N'2018', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'214', N'20182', N'2018', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'215', N'20191', N'2019', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'216', N'20192', N'2019', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'217', N'20201', N'2020', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'218', N'20202', N'2020', 0, N'C6', N'109', N'4', N'2', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'219', N'20161', N'2016', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'22 ', N'20172', N'2017', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'220', N'20162', N'2016', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'221', N'20171', N'2017', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'222', N'20172', N'2017', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'223', N'20181', N'2018', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'224', N'20182', N'2018', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'225', N'20191', N'2019', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'226', N'20192', N'2019', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'227', N'20201', N'2020', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'228', N'20202', N'2020', 0, N'C6', N'102', N'4', N'3', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'229', N'20161', N'2016', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'23 ', N'20181', N'2018', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'230', N'20162', N'2016', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'231', N'20171', N'2017', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'232', N'20172', N'2017', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'233', N'20181', N'2018', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'234', N'20182', N'2018', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'235', N'20191', N'2019', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'236', N'20192', N'2019', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'237', N'20201', N'2020', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'238', N'20202', N'2020', 0, N'C6', N'105', N'3', N'6', N'IT3081')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'239', N'20161', N'2016', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'24 ', N'20182', N'2018', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'240', N'20162', N'2016', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'241', N'20171', N'2017', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'242', N'20172', N'2017', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'243', N'20181', N'2018', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'244', N'20182', N'2018', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'245', N'20191', N'2019', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'246', N'20192', N'2019', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'247', N'20201', N'2020', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'248', N'20202', N'2020', 0, N'C7', N'103', N'3', N'2', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'249', N'20161', N'2016', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'25 ', N'20191', N'2019', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'250', N'20162', N'2016', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'251', N'20171', N'2017', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'252', N'20172', N'2017', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'253', N'20181', N'2018', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'254', N'20182', N'2018', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'255', N'20191', N'2019', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'256', N'20192', N'2019', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'257', N'20201', N'2020', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'258', N'20202', N'2020', 0, N'C7', N'105', N'3', N'4', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'259', N'20161', N'2016', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'26 ', N'20192', N'2019', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'260', N'20162', N'2016', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'261', N'20171', N'2017', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'262', N'20172', N'2017', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'263', N'20181', N'2018', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'264', N'20182', N'2018', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'265', N'20191', N'2019', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'266', N'20192', N'2019', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'267', N'20201', N'2020', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'268', N'20202', N'2020', 0, N'C7', N'108', N'3', N'6', N'IT3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'269', N'20161', N'2016', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'27 ', N'20201', N'2020', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'270', N'20162', N'2016', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'271', N'20171', N'2017', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'272', N'20172', N'2017', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'273', N'20181', N'2018', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'274', N'20182', N'2018', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'275', N'20191', N'2019', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'276', N'20192', N'2019', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'277', N'20201', N'2020', 0, N'C8', N'103', N'3', N'2', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'278', N'20202', N'2020', 0, N'C8', N'103', N'3', N'2', N'IT3100')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'279', N'20161', N'2016', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'28 ', N'20202', N'2020', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'280', N'20162', N'2016', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'281', N'20171', N'2017', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'282', N'20172', N'2017', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'283', N'20181', N'2018', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'284', N'20182', N'2018', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'285', N'20191', N'2019', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'286', N'20192', N'2019', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'287', N'20201', N'2020', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'288', N'20202', N'2020', 0, N'C8', N'106', N'3', N'3', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'289', N'20161', N'2016', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'29 ', N'20161', N'2016', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'290', N'20162', N'2016', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'291', N'20171', N'2017', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'292', N'20172', N'2017', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'293', N'20181', N'2018', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'294', N'20182', N'2018', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'295', N'20191', N'2019', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'296', N'20192', N'2019', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'297', N'20201', N'2020', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'298', N'20202', N'2020', 0, N'C8', N'108', N'3', N'5', N'IT3100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'299', N'20161', N'2016', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'3  ', N'20171', N'2017', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'30 ', N'20162', N'2016', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'300', N'20162', N'2016', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'301', N'20171', N'2017', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'302', N'20172', N'2017', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'303', N'20181', N'2018', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'304', N'20182', N'2018', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'305', N'20191', N'2019', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'306', N'20192', N'2019', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'307', N'20201', N'2020', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'308', N'20202', N'2020', 0, N'C9', N'104', N'2', N'2', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'309', N'20161', N'2016', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'31 ', N'20171', N'2017', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'310', N'20162', N'2016', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'311', N'20171', N'2017', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'312', N'20172', N'2017', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'313', N'20181', N'2018', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'314', N'20182', N'2018', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'315', N'20191', N'2019', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'316', N'20192', N'2019', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'317', N'20201', N'2020', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'318', N'20202', N'2020', 0, N'C9', N'101', N'3', N'6', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'319', N'20161', N'2016', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'32 ', N'20172', N'2017', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'320', N'20162', N'2016', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'321', N'20171', N'2017', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'322', N'20172', N'2017', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'323', N'20181', N'2018', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'324', N'20182', N'2018', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'325', N'20191', N'2019', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'326', N'20192', N'2019', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'327', N'20201', N'2020', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'328', N'20202', N'2020', 0, N'C9', N'108', N'3', N'5', N'IT3110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'329', N'20161', N'2016', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'33 ', N'20181', N'2018', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'330', N'20162', N'2016', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'331', N'20171', N'2017', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'332', N'20172', N'2017', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'333', N'20181', N'2018', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'334', N'20182', N'2018', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'335', N'20191', N'2019', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'336', N'20192', N'2019', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'337', N'20201', N'2020', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'338', N'20202', N'2020', 0, N'C5', N'104', N'2', N'2', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'339', N'20161', N'2016', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'34 ', N'20182', N'2018', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'340', N'20162', N'2016', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'341', N'20171', N'2017', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'342', N'20172', N'2017', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'343', N'20181', N'2018', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'344', N'20182', N'2018', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'345', N'20191', N'2019', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'346', N'20192', N'2019', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'347', N'20201', N'2020', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'348', N'20202', N'2020', 0, N'C5', N'104', N'2', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'349', N'20161', N'2016', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'35 ', N'20191', N'2019', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'350', N'20162', N'2016', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'351', N'20171', N'2017', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'352', N'20172', N'2017', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'353', N'20181', N'2018', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'354', N'20182', N'2018', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'355', N'20191', N'2019', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'356', N'20192', N'2019', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'357', N'20201', N'2020', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'358', N'20202', N'2020', 0, N'C5', N'106', N'3', N'6', N'IT3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'359', N'20161', N'2016', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'36 ', N'20192', N'2019', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'360', N'20162', N'2016', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'361', N'20171', N'2017', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'362', N'20172', N'2017', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'363', N'20181', N'2018', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'364', N'20182', N'2018', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'365', N'20191', N'2019', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'366', N'20192', N'2019', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'367', N'20201', N'2020', 0, N'C4', N'106', N'1', N'4', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'368', N'20202', N'2020', 0, N'C4', N'106', N'1', N'4', N'IT3130')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'369', N'20161', N'2016', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'37 ', N'20201', N'2020', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'370', N'20162', N'2016', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'371', N'20171', N'2017', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'372', N'20172', N'2017', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'373', N'20181', N'2018', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'374', N'20182', N'2018', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'375', N'20191', N'2019', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'376', N'20192', N'2019', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'377', N'20201', N'2020', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'378', N'20202', N'2020', 0, N'C4', N'106', N'1', N'6', N'IT3130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'379', N'20161', N'2016', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'38 ', N'20202', N'2020', 0, N'C3', N'105', N'2', N'2', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'380', N'20162', N'2016', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'381', N'20171', N'2017', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'382', N'20172', N'2017', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'383', N'20181', N'2018', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'384', N'20182', N'2018', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'385', N'20191', N'2019', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'386', N'20192', N'2019', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'387', N'20201', N'2020', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'388', N'20202', N'2020', 0, N'C7', N'102', N'2', N'4', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'389', N'20161', N'2016', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'39 ', N'20161', N'2016', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'390', N'20162', N'2016', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'391', N'20171', N'2017', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'392', N'20172', N'2017', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'393', N'20181', N'2018', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'394', N'20182', N'2018', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'395', N'20191', N'2019', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'396', N'20192', N'2019', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'397', N'20201', N'2020', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'398', N'20202', N'2020', 0, N'C7', N'109', N'1', N'3', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'399', N'20161', N'2016', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'4  ', N'20172', N'2017', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'40 ', N'20162', N'2016', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'400', N'20162', N'2016', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'401', N'20171', N'2017', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'402', N'20172', N'2017', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'403', N'20181', N'2018', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'404', N'20182', N'2018', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'405', N'20191', N'2019', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'406', N'20192', N'2019', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'407', N'20201', N'2020', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'408', N'20202', N'2020', 0, N'C7', N'107', N'1', N'2', N'IT3151')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'409', N'20161', N'2016', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'41 ', N'20171', N'2017', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'410', N'20162', N'2016', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'411', N'20171', N'2017', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'412', N'20172', N'2017', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'413', N'20181', N'2018', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'414', N'20182', N'2018', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'415', N'20191', N'2019', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'416', N'20192', N'2019', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'417', N'20201', N'2020', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'418', N'20202', N'2020', 0, N'C9', N'102', N'2', N'4', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'419', N'20161', N'2016', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'42 ', N'20172', N'2017', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'420', N'20162', N'2016', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'421', N'20171', N'2017', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'422', N'20172', N'2017', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'423', N'20181', N'2018', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'424', N'20182', N'2018', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'425', N'20191', N'2019', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'426', N'20192', N'2019', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'427', N'20201', N'2020', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'428', N'20202', N'2020', 0, N'C9', N'103', N'2', N'6', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'429', N'20161', N'2016', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'43 ', N'20181', N'2018', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'430', N'20162', N'2016', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'431', N'20171', N'2017', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'432', N'20172', N'2017', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'433', N'20181', N'2018', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'434', N'20182', N'2018', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'435', N'20191', N'2019', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'436', N'20192', N'2019', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'437', N'20201', N'2020', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'438', N'20202', N'2020', 0, N'C9', N'106', N'2', N'2', N'IT3680')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'439', N'20161', N'2016', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'44 ', N'20182', N'2018', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'440', N'20162', N'2016', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'441', N'20171', N'2017', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'442', N'20172', N'2017', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'443', N'20181', N'2018', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'444', N'20182', N'2018', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'445', N'20191', N'2019', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'446', N'20192', N'2019', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'447', N'20201', N'2020', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'448', N'20202', N'2020', 0, N'C6', N'106', N'4', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'449', N'20161', N'2016', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'45 ', N'20191', N'2019', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'450', N'20162', N'2016', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'451', N'20171', N'2017', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'452', N'20172', N'2017', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'453', N'20181', N'2018', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'454', N'20182', N'2018', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'455', N'20191', N'2019', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'456', N'20192', N'2019', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'457', N'20201', N'2020', 0, N'C6', N'106', N'2', N'2', N'IT4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'458', N'20202', N'2020', 0, N'C6', N'106', N'2', N'2', N'IT4010')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'459', N'20161', N'2016', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'46 ', N'20192', N'2019', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'460', N'20162', N'2016', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'461', N'20171', N'2017', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'462', N'20172', N'2017', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'463', N'20181', N'2018', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'464', N'20182', N'2018', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'465', N'20191', N'2019', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'466', N'20192', N'2019', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'467', N'20201', N'2020', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'468', N'20202', N'2020', 0, N'C6', N'109', N'2', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'469', N'20161', N'2016', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'47 ', N'20201', N'2020', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'470', N'20162', N'2016', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'471', N'20171', N'2017', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'472', N'20172', N'2017', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'473', N'20181', N'2018', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'474', N'20182', N'2018', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'475', N'20191', N'2019', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'476', N'20192', N'2019', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'477', N'20201', N'2020', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'478', N'20202', N'2020', 0, N'C6', N'102', N'4', N'4', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'479', N'20161', N'2016', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'48 ', N'20202', N'2020', 0, N'C3', N'106', N'2', N'3', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'480', N'20162', N'2016', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'481', N'20171', N'2017', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'482', N'20172', N'2017', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'483', N'20181', N'2018', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'484', N'20182', N'2018', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'485', N'20191', N'2019', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'486', N'20192', N'2019', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'487', N'20201', N'2020', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'488', N'20202', N'2020', 0, N'C6', N'107', N'4', N'6', N'IT4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'489', N'20161', N'2016', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'49 ', N'20161', N'2016', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'490', N'20162', N'2016', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'491', N'20171', N'2017', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'492', N'20172', N'2017', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'493', N'20181', N'2018', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'494', N'20182', N'2018', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'495', N'20191', N'2019', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'496', N'20192', N'2019', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'497', N'20201', N'2020', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'498', N'20202', N'2020', 0, N'C6', N'104', N'3', N'2', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'499', N'20161', N'2016', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'5  ', N'20181', N'2018', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'50 ', N'20162', N'2016', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'500', N'20162', N'2016', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'501', N'20171', N'2017', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'502', N'20172', N'2017', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'503', N'20181', N'2018', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'504', N'20182', N'2018', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'505', N'20191', N'2019', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'506', N'20192', N'2019', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'507', N'20201', N'2020', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'508', N'20202', N'2020', 0, N'C6', N'105', N'3', N'3', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'509', N'20161', N'2016', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'51 ', N'20171', N'2017', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'510', N'20162', N'2016', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'511', N'20171', N'2017', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'512', N'20172', N'2017', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'513', N'20181', N'2018', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'514', N'20182', N'2018', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'515', N'20191', N'2019', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'516', N'20192', N'2019', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'517', N'20201', N'2020', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'518', N'20202', N'2020', 0, N'C6', N'106', N'3', N'6', N'IT4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'519', N'20161', N'2016', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'52 ', N'20172', N'2017', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'520', N'20162', N'2016', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'521', N'20171', N'2017', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'522', N'20172', N'2017', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'523', N'20181', N'2018', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'524', N'20182', N'2018', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'525', N'20191', N'2019', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'526', N'20192', N'2019', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'527', N'20201', N'2020', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'528', N'20202', N'2020', 0, N'C7', N'101', N'2', N'3', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'529', N'20161', N'2016', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'53 ', N'20181', N'2018', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'530', N'20162', N'2016', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'531', N'20171', N'2017', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'532', N'20172', N'2017', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'533', N'20181', N'2018', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'534', N'20182', N'2018', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'535', N'20191', N'2019', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'536', N'20192', N'2019', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'537', N'20201', N'2020', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'538', N'20202', N'2020', 0, N'C7', N'105', N'3', N'5', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'539', N'20161', N'2016', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'54 ', N'20182', N'2018', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'540', N'20162', N'2016', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'541', N'20171', N'2017', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'542', N'20172', N'2017', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'543', N'20181', N'2018', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'544', N'20182', N'2018', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'545', N'20191', N'2019', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'546', N'20192', N'2019', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'547', N'20201', N'2020', 0, N'C7', N'106', N'3', N'6', N'IT4130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'548', N'20202', N'2020', 0, N'C7', N'106', N'3', N'6', N'IT4130')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'549', N'20161', N'2016', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'55 ', N'20191', N'2019', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'550', N'20162', N'2016', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'551', N'20171', N'2017', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'552', N'20172', N'2017', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'553', N'20181', N'2018', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'554', N'20182', N'2018', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'555', N'20191', N'2019', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'556', N'20192', N'2019', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'557', N'20201', N'2020', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'558', N'20202', N'2020', 0, N'C7', N'101', N'2', N'3', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'559', N'20161', N'2016', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'56 ', N'20192', N'2019', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'560', N'20162', N'2016', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'561', N'20171', N'2017', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'562', N'20172', N'2017', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'563', N'20181', N'2018', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'564', N'20182', N'2018', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'565', N'20191', N'2019', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'566', N'20192', N'2019', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'567', N'20201', N'2020', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'568', N'20202', N'2020', 0, N'C7', N'103', N'2', N'4', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'569', N'20161', N'2016', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'57 ', N'20201', N'2020', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'570', N'20162', N'2016', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'571', N'20171', N'2017', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'572', N'20172', N'2017', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'573', N'20181', N'2018', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'574', N'20182', N'2018', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'575', N'20191', N'2019', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'576', N'20192', N'2019', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'577', N'20201', N'2020', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'578', N'20202', N'2020', 0, N'C7', N'105', N'2', N'6', N'IT4180')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'579', N'20161', N'2016', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'58 ', N'20202', N'2020', 0, N'C3', N'107', N'3', N'4', N'IT1011')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'580', N'20162', N'2016', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'581', N'20171', N'2017', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'582', N'20172', N'2017', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'583', N'20181', N'2018', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'584', N'20182', N'2018', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'585', N'20191', N'2019', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'586', N'20192', N'2019', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'587', N'20201', N'2020', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'588', N'20202', N'2020', 0, N'C3', N'107', N'2', N'6', N'IT4371')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'589', N'20161', N'2016', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'59 ', N'20161', N'2016', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'590', N'20162', N'2016', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'591', N'20171', N'2017', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'592', N'20172', N'2017', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'593', N'20181', N'2018', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'594', N'20182', N'2018', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'595', N'20191', N'2019', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'596', N'20192', N'2019', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'597', N'20201', N'2020', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'598', N'20202', N'2020', 0, N'C9', N'107', N'2', N'6', N'IT4404')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'599', N'20161', N'2016', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'6  ', N'20182', N'2018', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'60 ', N'20162', N'2016', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'600', N'20162', N'2016', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'601', N'20171', N'2017', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'602', N'20172', N'2017', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'603', N'20181', N'2018', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'604', N'20182', N'2018', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'605', N'20191', N'2019', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'606', N'20192', N'2019', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'607', N'20201', N'2020', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'608', N'20202', N'2020', 0, N'C8', N'106', N'2', N'3', N'IT4430')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'609', N'20161', N'2016', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'61 ', N'20171', N'2017', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'610', N'20162', N'2016', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'611', N'20171', N'2017', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'612', N'20172', N'2017', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'613', N'20181', N'2018', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'614', N'20182', N'2018', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'615', N'20191', N'2019', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'616', N'20192', N'2019', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'617', N'20201', N'2020', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'618', N'20202', N'2020', 0, N'C8', N'102', N'2', N'4', N'IT4756')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'619', N'20161', N'2016', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'62 ', N'20172', N'2017', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'620', N'20162', N'2016', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'621', N'20171', N'2017', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'622', N'20172', N'2017', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'623', N'20181', N'2018', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'624', N'20182', N'2018', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'625', N'20191', N'2019', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'626', N'20192', N'2019', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'627', N'20201', N'2020', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'628', N'20202', N'2020', 0, N'C8', N'102', N'2', N'5', N'IT4757')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'629', N'20161', N'2016', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'63 ', N'20181', N'2018', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'630', N'20162', N'2016', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'631', N'20171', N'2017', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'632', N'20172', N'2017', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'633', N'20181', N'2018', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'634', N'20182', N'2018', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'635', N'20191', N'2019', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'636', N'20192', N'2019', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'637', N'20201', N'2020', 0, N'C3', N'107', N'2', N'5', N'IT4766')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'638', N'20202', N'2020', 0, N'C3', N'107', N'2', N'5', N'IT4766')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'639', N'20161', N'2016', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'64 ', N'20182', N'2018', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'640', N'20162', N'2016', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'641', N'20171', N'2017', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'642', N'20172', N'2017', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'643', N'20181', N'2018', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'644', N'20182', N'2018', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'645', N'20191', N'2019', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'646', N'20192', N'2019', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'647', N'20201', N'2020', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'648', N'20202', N'2020', 0, N'C3', N'109', N'2', N'6', N'IT4779')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'649', N'20161', N'2016', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'65 ', N'20191', N'2019', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'650', N'20162', N'2016', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'651', N'20171', N'2017', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'652', N'20172', N'2017', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'653', N'20181', N'2018', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'654', N'20182', N'2018', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'655', N'20191', N'2019', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'656', N'20192', N'2019', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'657', N'20201', N'2020', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'658', N'20202', N'2020', 0, N'C5', N'105', N'2', N'6', N'IT4867')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'659', N'20161', N'2016', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'66 ', N'20192', N'2019', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'660', N'20162', N'2016', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'661', N'20171', N'2017', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'662', N'20172', N'2017', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'663', N'20181', N'2018', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'664', N'20182', N'2018', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'665', N'20191', N'2019', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'666', N'20192', N'2019', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'667', N'20201', N'2020', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'668', N'20202', N'2020', 0, N'C5', N'105', N'3', N'6', N'IT4868')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'669', N'20161', N'2016', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'67 ', N'20201', N'2020', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'670', N'20162', N'2016', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'671', N'20171', N'2017', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'672', N'20172', N'2017', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'673', N'20181', N'2018', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'674', N'20182', N'2018', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'675', N'20191', N'2019', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'676', N'20192', N'2019', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'677', N'20201', N'2020', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'678', N'20202', N'2020', 0, N'C5', N'109', N'3', N'3', N'IT4912')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'679', N'20161', N'2016', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'68 ', N'20202', N'2020', 0, N'C3', N'107', N'1', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'680', N'20162', N'2016', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'681', N'20171', N'2017', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'682', N'20172', N'2017', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'683', N'20181', N'2018', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'684', N'20182', N'2018', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'685', N'20191', N'2019', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'686', N'20192', N'2019', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'687', N'20201', N'2020', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'688', N'20202', N'2020', 0, N'D3', N'109', N'3', N'3', N'MI1110')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'689', N'20161', N'2016', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'69 ', N'20161', N'2016', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'690', N'20162', N'2016', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'691', N'20171', N'2017', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'692', N'20172', N'2017', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'693', N'20181', N'2018', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'694', N'20182', N'2018', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'695', N'20191', N'2019', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'696', N'20192', N'2019', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'697', N'20201', N'2020', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'698', N'20202', N'2020', 0, N'D3', N'105', N'3', N'3', N'MI1120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'699', N'20161', N'2016', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'7  ', N'20191', N'2019', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'70 ', N'20162', N'2016', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'700', N'20162', N'2016', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'701', N'20171', N'2017', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'702', N'20172', N'2017', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'703', N'20181', N'2018', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'704', N'20182', N'2018', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'705', N'20191', N'2019', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'706', N'20192', N'2019', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'707', N'20201', N'2020', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'708', N'20202', N'2020', 0, N'D3', N'105', N'3', N'6', N'MI1130')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'709', N'20161', N'2016', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'71 ', N'20171', N'2017', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'710', N'20162', N'2016', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'711', N'20171', N'2017', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'712', N'20172', N'2017', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'713', N'20181', N'2018', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'714', N'20182', N'2018', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'715', N'20191', N'2019', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'716', N'20192', N'2019', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'717', N'20201', N'2020', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'718', N'20202', N'2020', 0, N'D3', N'106', N'3', N'4', N'MI1140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'719', N'20161', N'2016', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'72 ', N'20172', N'2017', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'720', N'20162', N'2016', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'721', N'20171', N'2017', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'722', N'20172', N'2017', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'723', N'20181', N'2018', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'724', N'20182', N'2018', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'725', N'20191', N'2019', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'726', N'20192', N'2019', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'727', N'20201', N'2020', 0, N'D4', N'106', N'3', N'4', N'MI1150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'728', N'20202', N'2020', 0, N'D4', N'106', N'3', N'4', N'MI1150')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'729', N'20161', N'2016', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'73 ', N'20181', N'2018', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'730', N'20162', N'2016', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'731', N'20171', N'2017', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'732', N'20172', N'2017', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'733', N'20181', N'2018', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'734', N'20182', N'2018', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'735', N'20191', N'2019', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'736', N'20192', N'2019', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'737', N'20201', N'2020', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'738', N'20202', N'2020', 0, N'D4', N'106', N'3', N'4', N'MI2000')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'739', N'20161', N'2016', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'74 ', N'20182', N'2018', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'740', N'20162', N'2016', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'741', N'20171', N'2017', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'742', N'20172', N'2017', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'743', N'20181', N'2018', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'744', N'20182', N'2018', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'745', N'20191', N'2019', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'746', N'20192', N'2019', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'747', N'20201', N'2020', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'748', N'20202', N'2020', 0, N'D4', N'106', N'3', N'5', N'MI2060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'749', N'20161', N'2016', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'75 ', N'20191', N'2019', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'750', N'20162', N'2016', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'751', N'20171', N'2017', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'752', N'20172', N'2017', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'753', N'20181', N'2018', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'754', N'20182', N'2018', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'755', N'20191', N'2019', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'756', N'20192', N'2019', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'757', N'20201', N'2020', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'758', N'20202', N'2020', 0, N'D4', N'107', N'3', N'6', N'MI3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'759', N'20161', N'2016', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'76 ', N'20192', N'2019', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'760', N'20162', N'2016', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'761', N'20171', N'2017', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'762', N'20172', N'2017', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'763', N'20181', N'2018', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'764', N'20182', N'2018', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'765', N'20191', N'2019', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'766', N'20192', N'2019', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'767', N'20201', N'2020', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'768', N'20202', N'2020', 0, N'D4', N'104', N'3', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'769', N'20161', N'2016', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'77 ', N'20201', N'2020', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'770', N'20162', N'2016', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'771', N'20171', N'2017', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'772', N'20172', N'2017', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'773', N'20181', N'2018', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'774', N'20182', N'2018', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'775', N'20191', N'2019', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'776', N'20192', N'2019', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'777', N'20201', N'2020', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'778', N'20202', N'2020', 0, N'D4', N'104', N'2', N'6', N'MI3030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'779', N'20161', N'2016', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'78 ', N'20202', N'2020', 0, N'C3', N'107', N'3', N'2', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'780', N'20162', N'2016', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'781', N'20171', N'2017', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'782', N'20172', N'2017', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'783', N'20181', N'2018', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'784', N'20182', N'2018', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'785', N'20191', N'2019', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'786', N'20192', N'2019', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'787', N'20201', N'2020', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'788', N'20202', N'2020', 0, N'D4', N'109', N'2', N'4', N'MI3050')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'789', N'20161', N'2016', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'79 ', N'20161', N'2016', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'790', N'20162', N'2016', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'791', N'20171', N'2017', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'792', N'20172', N'2017', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'793', N'20181', N'2018', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'794', N'20182', N'2018', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'795', N'20191', N'2019', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'796', N'20192', N'2019', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'797', N'20201', N'2020', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'798', N'20202', N'2020', 0, N'D5', N'109', N'2', N'5', N'MI3060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'799', N'20161', N'2016', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'8  ', N'20192', N'2019', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'80 ', N'20162', N'2016', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'800', N'20162', N'2016', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'801', N'20171', N'2017', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'802', N'20172', N'2017', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'803', N'20181', N'2018', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'804', N'20182', N'2018', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'805', N'20191', N'2019', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'806', N'20192', N'2019', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'807', N'20201', N'2020', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'808', N'20202', N'2020', 0, N'D5', N'109', N'4', N'2', N'MI3070')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'809', N'20161', N'2016', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'81 ', N'20171', N'2017', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'810', N'20162', N'2016', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'811', N'20171', N'2017', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'812', N'20172', N'2017', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'813', N'20181', N'2018', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'814', N'20182', N'2018', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'815', N'20191', N'2019', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'816', N'20192', N'2019', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'817', N'20201', N'2020', 0, N'D5', N'109', N'4', N'4', N'MI3080')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'818', N'20202', N'2020', 0, N'D5', N'109', N'4', N'4', N'MI3080')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'819', N'20161', N'2016', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'82 ', N'20172', N'2017', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'820', N'20162', N'2016', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'821', N'20171', N'2017', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'822', N'20172', N'2017', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'823', N'20181', N'2018', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'824', N'20182', N'2018', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'825', N'20191', N'2019', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'826', N'20192', N'2019', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'827', N'20201', N'2020', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'828', N'20202', N'2020', 0, N'D5', N'102', N'4', N'5', N'MI3090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'829', N'20161', N'2016', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'83 ', N'20181', N'2018', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'830', N'20162', N'2016', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'831', N'20171', N'2017', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'832', N'20172', N'2017', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'833', N'20181', N'2018', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'834', N'20182', N'2018', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'835', N'20191', N'2019', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'836', N'20192', N'2019', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'837', N'20201', N'2020', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'838', N'20202', N'2020', 0, N'D5', N'103', N'4', N'6', N'MI3120')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'839', N'20161', N'2016', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'84 ', N'20182', N'2018', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'840', N'20162', N'2016', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'841', N'20171', N'2017', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'842', N'20172', N'2017', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'843', N'20181', N'2018', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'844', N'20182', N'2018', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'845', N'20191', N'2019', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'846', N'20192', N'2019', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'847', N'20201', N'2020', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'848', N'20202', N'2020', 0, N'D5', N'105', N'4', N'3', N'MI3310')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'849', N'20161', N'2016', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'85 ', N'20191', N'2019', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'850', N'20162', N'2016', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'851', N'20171', N'2017', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'852', N'20172', N'2017', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'853', N'20181', N'2018', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'854', N'20182', N'2018', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'855', N'20191', N'2019', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'856', N'20192', N'2019', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'857', N'20201', N'2020', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'858', N'20202', N'2020', 0, N'D6', N'105', N'4', N'3', N'MI3370')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'859', N'20161', N'2016', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'86 ', N'20192', N'2019', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'860', N'20162', N'2016', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'861', N'20171', N'2017', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'862', N'20172', N'2017', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'863', N'20181', N'2018', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'864', N'20182', N'2018', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'865', N'20191', N'2019', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'866', N'20192', N'2019', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'867', N'20201', N'2020', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'868', N'20202', N'2020', 0, N'D6', N'108', N'4', N'6', N'MI3380')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'869', N'20161', N'2016', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'87 ', N'20201', N'2020', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'870', N'20162', N'2016', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'871', N'20171', N'2017', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'872', N'20172', N'2017', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'873', N'20181', N'2018', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'874', N'20182', N'2018', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'875', N'20191', N'2019', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'876', N'20192', N'2019', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'877', N'20201', N'2020', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'878', N'20202', N'2020', 0, N'D6', N'103', N'4', N'5', N'MI3390')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'879', N'20161', N'2016', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'88 ', N'20202', N'2020', 0, N'C3', N'107', N'3', N'4', N'IT3010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'880', N'20162', N'2016', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'881', N'20171', N'2017', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'882', N'20172', N'2017', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'883', N'20181', N'2018', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'884', N'20182', N'2018', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'885', N'20191', N'2019', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'886', N'20192', N'2019', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'887', N'20201', N'2020', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'888', N'20202', N'2020', 0, N'D6', N'106', N'4', N'6', N'MI4010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'889', N'20161', N'2016', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'89 ', N'20161', N'2016', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'890', N'20162', N'2016', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'891', N'20171', N'2017', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'892', N'20172', N'2017', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'893', N'20181', N'2018', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'894', N'20182', N'2018', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'895', N'20191', N'2019', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'896', N'20192', N'2019', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'897', N'20201', N'2020', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'898', N'20202', N'2020', 0, N'D6', N'106', N'4', N'2', N'MI4020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'899', N'20161', N'2016', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'9  ', N'20201', N'2020', 0, N'C3', N'101', N'1', N'2', N'IT1010')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'90 ', N'20162', N'2016', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'900', N'20162', N'2016', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'901', N'20171', N'2017', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'902', N'20172', N'2017', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'903', N'20181', N'2018', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'904', N'20182', N'2018', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'905', N'20191', N'2019', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'906', N'20192', N'2019', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'907', N'20201', N'2020', 0, N'D6', N'108', N'4', N'2', N'MI4030')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'908', N'20202', N'2020', 0, N'D6', N'108', N'4', N'2', N'MI4030')
GO
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'909', N'20161', N'2016', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'91 ', N'20171', N'2017', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'910', N'20162', N'2016', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'911', N'20171', N'2017', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'912', N'20172', N'2017', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'913', N'20181', N'2018', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'914', N'20182', N'2018', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'915', N'20191', N'2019', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'916', N'20192', N'2019', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'917', N'20201', N'2020', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'918', N'20202', N'2020', 0, N'D6', N'102', N'4', N'5', N'MI4060')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'919', N'20161', N'2016', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'92 ', N'20172', N'2017', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'920', N'20162', N'2016', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'921', N'20171', N'2017', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'922', N'20172', N'2017', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'923', N'20181', N'2018', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'924', N'20182', N'2018', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'925', N'20191', N'2019', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'926', N'20192', N'2019', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'927', N'20201', N'2020', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'928', N'20202', N'2020', 0, N'D7', N'102', N'4', N'6', N'MI4090')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'929', N'20161', N'2016', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'93 ', N'20181', N'2018', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'930', N'20162', N'2016', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'931', N'20171', N'2017', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'932', N'20172', N'2017', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'933', N'20181', N'2018', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'934', N'20182', N'2018', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'935', N'20191', N'2019', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'936', N'20192', N'2019', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'937', N'20201', N'2020', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'938', N'20202', N'2020', 0, N'D7', N'102', N'4', N'4', N'MI4100')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'939', N'20161', N'2016', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'94 ', N'20182', N'2018', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'940', N'20162', N'2016', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'941', N'20171', N'2017', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'942', N'20172', N'2017', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'943', N'20181', N'2018', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'944', N'20182', N'2018', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'945', N'20191', N'2019', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'946', N'20192', N'2019', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'947', N'20201', N'2020', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'948', N'20202', N'2020', 0, N'D7', N'105', N'2', N'3', N'MI4140')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'949', N'20161', N'2016', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'95 ', N'20191', N'2019', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'950', N'20162', N'2016', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'951', N'20171', N'2017', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'952', N'20172', N'2017', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'953', N'20181', N'2018', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'954', N'20182', N'2018', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'955', N'20191', N'2019', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'956', N'20192', N'2019', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'957', N'20201', N'2020', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'958', N'20202', N'2020', 0, N'D7', N'106', N'2', N'4', N'MI4150')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'959', N'20161', N'2016', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'96 ', N'20192', N'2019', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'960', N'20162', N'2016', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'961', N'20171', N'2017', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'962', N'20172', N'2017', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'963', N'20181', N'2018', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'964', N'20182', N'2018', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'965', N'20191', N'2019', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'966', N'20192', N'2019', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'967', N'20201', N'2020', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'968', N'20202', N'2020', 0, N'D7', N'109', N'2', N'6', N'MI4311')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'969', N'20161', N'2016', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'97 ', N'20201', N'2020', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'970', N'20162', N'2016', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'971', N'20171', N'2017', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'972', N'20172', N'2017', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'973', N'20181', N'2018', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'974', N'20182', N'2018', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'975', N'20191', N'2019', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'976', N'20192', N'2019', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'977', N'20201', N'2020', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'978', N'20202', N'2020', 0, N'D7', N'101', N'2', N'6', N'MI4344')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'979', N'20161', N'2016', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'98 ', N'20202', N'2020', 0, N'C4', N'107', N'1', N'2', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'980', N'20162', N'2016', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'981', N'20171', N'2017', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'982', N'20172', N'2017', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'983', N'20181', N'2018', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'984', N'20182', N'2018', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'985', N'20191', N'2019', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'986', N'20192', N'2019', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'987', N'20201', N'2020', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'988', N'20202', N'2020', 0, N'D8', N'101', N'2', N'6', N'MI4352')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'989', N'20161', N'2016', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'99 ', N'20161', N'2016', 0, N'C4', N'101', N'1', N'4', N'IT3021')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'990', N'20162', N'2016', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'991', N'20171', N'2017', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'992', N'20172', N'2017', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'993', N'20181', N'2018', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'994', N'20182', N'2018', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'995', N'20191', N'2019', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'996', N'20192', N'2019', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'997', N'20201', N'2020', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'998', N'20202', N'2020', 0, N'D8', N'103', N'2', N'6', N'MI5020')
INSERT [dbo].[Sections] ([SecId], [Semester], [Year], [Status], [Building], [RoomNumber], [TimeSlotId], [Day], [CourseId]) VALUES (N'999', N'20161', N'2016', 0, N'D8', N'106', N'2', N'6', N'MI5030')
GO
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20161')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20162')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20163')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20171')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20172')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20173')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20181')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20182')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20183')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20191')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20192')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20193')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20201')
INSERT [dbo].[Semesters] ([Id]) VALUES (N'20202')
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK1-2016', N'CK', N'Cơ khí 1 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK1-2017', N'CK', N'Cơ khí 1 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK1-2018', N'CK', N'Cơ khí 1 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK1-2019', N'CK', N'Cơ khí 1 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK1-2020', N'CK', N'Cơ khí 1 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK2-2016', N'CK', N'Cơ khí 2 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK2-2017', N'CK', N'Cơ khí 2 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK2-2018', N'CK', N'Cơ khí 2 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK2-2019', N'CK', N'Cơ khí 2 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CK2-2020', N'CK', N'Cơ khí 2 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL1-2016', N'CKDL', N'Cơ khí động lực 1 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL1-2017', N'CKDL', N'Cơ khí động lực 1 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL1-2018', N'CKDL', N'Cơ khí động lực 1 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL1-2019', N'CKDL', N'Cơ khí động lực 1 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL1-2020', N'CKDL', N'Cơ khí động lực 1 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL2-2016', N'CKDL', N'Cơ khí động lực 2 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL2-2017', N'CKDL', N'Cơ khí động lực 2 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL2-2018', N'CKDL', N'Cơ khí động lực 2 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL2-2019', N'CKDL', N'Cơ khí động lực 2 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'CKDL2-2020', N'CKDL', N'Cơ khí động lực 2 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT1-2016', N'IT', N'Khoa Học Máy tính 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT1-2017', N'IT', N'Khoa học máy tính 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT1-2018', N'IT', N'Khoa học máy tính 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT1-2019', N'IT', N'Khoa học máy tính 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT1-2020', N'IT', N'Khoa học máy tính 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT2-2016', N'IT', N'Công nghệ phần mềm 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT2-2017', N'IT', N'Công nghệ phần mềm 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT2-2018', N'IT', N'Công nghệ phần mềm 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT2-2019', N'IT', N'Công nghệ phần mềm 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'IT2-2020', N'IT', N'Công nghệ phần mềm 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI1-2016', N'MI', N'Toán tin 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI1-2017', N'MI', N'Toán tin 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI1-2018', N'MI', N'Toán tin 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI1-2019', N'MI', N'Toán tin 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI1-2020', N'MI', N'Toán tin 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI2-2016', N'MI', N'Hệ thống thông tin quản lí 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI2-2017', N'MI', N'Hệ thống thông tin quản lí 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI2-2018', N'MI', N'Hệ thống thông tin quản lí 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI2-2019', N'MI', N'Hệ thống thông tin quản lí 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'MI2-2020', N'MI', N'Hệ thống thông tin quản lí 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP1-2016', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 1 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP1-2017', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 1 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP1-2018', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 1 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP1-2019', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 1 2019', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP1-2020', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 1 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP2-2016', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 2 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP2-2017', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 2 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP2-2018', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 2 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP2-2019', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 2 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VCNSHVTP2-2020', N'VCNSHVTP', N'Lớp Sinh Học Và Thực Phẩm 2 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD1-2016', N'VD', N'Lớp điện 1 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD1-2017', N'VD', N'Lớp điện 1 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD1-2018', N'VD', N'Lớp điện 1 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD1-2019', N'VD', N'Lớp điện 1 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD1-2020', N'VD', N'Lớp điện 1 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD2-2016', N'VD', N'Lớp điện 2 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD2-2017', N'VD', N'Lớp điện 2 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD2-2018', N'VD', N'Lớp điện 2 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD2-2019', N'VD', N'Lớp điện 2 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VD2-2020', N'VD', N'Lớp điện 2 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT1-2016', N'VDMĐVTT', N'Thời trang 1 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT1-2017', N'VDMĐVTT', N'Thời trang 1 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT1-2018', N'VDMĐVTT', N'Thời trang 1 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT1-2019', N'VDMĐVTT', N'Thời trang 1 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT1-2020', N'VDMĐVTT', N'Thời trang 1 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT2-2016', N'VDMĐVTT', N'Thời trang 2 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT2-2017', N'VDMĐVTT', N'Thời trang 2 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT2-2018', N'VDMĐVTT', N'Thời trang 2 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT2-2019', N'VDMĐVTT', N'Thời trang 2 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDMĐVTT2-2020', N'VDMĐVTT', N'Thời trang 2 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT1-2016', N'VDTVT', N'Điện tử viễn thông 1  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT1-2017', N'VDTVT', N'Điện tử viễn thông 1  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT1-2018', N'VDTVT', N'Điện tử viễn thông 1  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT1-2019', N'VDTVT', N'Điện tử viễn thông 1  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT1-2020', N'VDTVT', N'Điện tử viễn thông 1  2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT2-2016', N'VDTVT', N'Điện tử viễn thông 2  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT2-2017', N'VDTVT', N'Điện tử viễn thông 2  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT2-2018', N'VDTVT', N'Điện tử viễn thông 2  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT2-2019', N'VDTVT', N'Điện tử viễn thông 2  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VDTVT2-2020', N'VDTVT', N'Điện tử viễn thông 2  2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH1-2016', N'VKTHH', N'Kỹ thuật hóa học 1  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH1-2017', N'VKTHH', N'Kỹ thuật hóa học 1  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH1-2018', N'VKTHH', N'Kỹ thuật hóa học 1  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH1-2019', N'VKTHH', N'Kỹ thuật hóa học 1  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH1-2020', N'VKTHH', N'Kỹ thuật hóa học 1  2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH2-2016', N'VKTHH', N'Kỹ thuật hóa học 2  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH2-2017', N'VKTHH', N'Kỹ thuật hóa học 2  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH2-2018', N'VKTHH', N'Kỹ thuật hóa học 2  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH2-2019', N'VKTHH', N'Kỹ thuật hóa học 2  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTHH2-2020', N'VKTHH', N'Kỹ thuật hóa học 2  2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL1-2016', N'VKTVQL', N'Lớp kinh tế và quản lí 1  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL1-2017', N'VKTVQL', N'Lớp kinh tế và quản lí 1  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL1-2018', N'VKTVQL', N'Lớp kinh tế và quản lí 1  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL1-2019', N'VKTVQL', N'Lớp kinh tế và quản lí 1  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL1-2020', N'VKTVQL', N'Lớp kinh tế và quản lí 1  2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL2-2016', N'VKTVQL', N'Lớp kinh tế và quản lí 2  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL2-2017', N'VKTVQL', N'Lớp kinh tế và quản lí 2  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL2-2018', N'VKTVQL', N'Lớp kinh tế và quản lí 2  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL2-2019', N'VKTVQL', N'Lớp kinh tế và quản lí 2  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VKTVQL2-2020', N'VKTVQL', N'Lớp kinh tế và quản lí 2  2020', N'2020', NULL)
GO
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN1-2016', N'VNN', N'Lớp ngoại ngữ 1  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN1-2017', N'VNN', N'Lớp ngoại ngữ 1  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN1-2018', N'VNN', N'Lớp ngoại ngữ 1  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN1-2019', N'VNN', N'Lớp ngoại ngữ 1  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN1-2020', N'VNN', N'Lớp ngoại ngữ 1  2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN2-2016', N'VNN', N'Lớp ngoại ngữ 2  2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN2-2017', N'VNN', N'Lớp ngoại ngữ 2  2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN2-2018', N'VNN', N'Lớp ngoại ngữ 2  2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN2-2019', N'VNN', N'Lớp ngoại ngữ 2  2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VNN2-2020', N'VNN', N'Lớp ngoại ngữ 2  2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT1-2016', N'VSPKT', N'Lop su pham 1 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT1-2017', N'VSPKT', N'Lop su pham 1 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT1-2018', N'VSPKT', N'Lop su pham 1 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT1-2019', N'VSPKT', N'Lop su pham 1 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT1-2020', N'VSPKT', N'Lop su pham 1 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT2-2016', N'VSPKT', N'Lop su pham 2 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT2-2017', N'VSPKT', N'Lop su pham 2 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT2-2018', N'VSPKT', N'Lop su pham 2 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT2-2019', N'VSPKT', N'Lop su pham 2 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VSPKT2-2020', N'VSPKT', N'Lop su pham 2 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT1-2016', N'VVLKT', N'Lớp vật lí kỹ thuât 1 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT1-2017', N'VVLKT', N'Lớp vật lí kỹ thuât 1 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT1-2018', N'VVLKT', N'Lớp vật lí kỹ thuât 1 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT1-2019', N'VVLKT', N'Lớp vật lí kỹ thuât 1 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT1-2020', N'VVLKT', N'Lớp vật lí kỹ thuât 1 2020', N'2020', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT2-2016', N'VVLKT', N'Lớp vật lí kỹ thuât 2 2016', N'2016', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT2-2017', N'VVLKT', N'Lớp vật lí kỹ thuât 2 2017', N'2017', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT2-2018', N'VVLKT', N'Lớp vật lí kỹ thuât 2 2018', N'2018', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT2-2019', N'VVLKT', N'Lớp vật lí kỹ thuât 2 2019', N'2019', NULL)
INSERT [dbo].[StudentClasses] ([Id], [DepartmentId], [Name], [Year], [Status]) VALUES (N'VVLKT2-2020', N'VVLKT', N'Lớp vật lí kỹ thuât 2 2020', N'2020', NULL)
INSERT [dbo].[StudentNotification] ([StudentId], [NotificationId]) VALUES (N'20160024', N'st1')
INSERT [dbo].[StudentNotification] ([StudentId], [NotificationId]) VALUES (N'20161997', N'st1')
INSERT [dbo].[StudentNotification] ([StudentId], [NotificationId]) VALUES (N'20160024', N'st2')
INSERT [dbo].[StudentNotification] ([StudentId], [NotificationId]) VALUES (N'20161997', N'st2')
INSERT [dbo].[StudentNotification] ([StudentId], [NotificationId]) VALUES (N'20160024', N'st3')
INSERT [dbo].[StudentNotification] ([StudentId], [NotificationId]) VALUES (N'20161997', N'st3')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160024', N'Tran Trong An', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:26:19.0600000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160067', N'Đỗ Trung Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:17:33.2100000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160187', N'Nguyễn Tuấn Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:17:51.1200000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160215', N'Phạm Hoàng Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:18:03.5800000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160258', N'Vũ Việt Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:18:15.4630000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160264', N'Do Thi Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:27:26.5930000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160361', N'Đỗ Thanh Bình', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:18:32.8930000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160398', N'Đặng Thị Cần', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:18:47.6200000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160405', N'Nguyen Kim Chi', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:27:56.0600000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160555', N'Nguyen Huu Cuong', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:27:45.0100000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160624', N'Nguyễn Thị Dinh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:19:03.7970000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160626', N'Phan Thanh Dinh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:19:17.9100000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160629', N'Hoang Ngoc Doanh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:28:10.8400000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160705', N'Pham Viet Dung', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:19:37.5600000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160721', N'Vũ Văn Dũng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:17:48.5170000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160753', N'Đào Khánh Duy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:28:28.0570000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160779', N'Phạm Đình Duy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:28:40.1000000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160818', N'Đoàn Văn Dương', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:28:52.3930000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160836', N'Luong Tung Duong', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:19:53.8300000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160850', N'Nguyễn Tiến Dương', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:20:22.8030000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160871', N'Trần Tùng Dương', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:20:39.2000000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160902', N'Trần Quang Đại', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:29:05.9000000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160921', N'Lê Võ Minh Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:18:04.5300000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160933', N'Nguyễn Hữu Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:20:56.4200000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160954', N'Nguyễn Xuân Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:29:21.7700000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160986', N'Nguyễn Hài Đăng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:29:33.3130000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20160988', N'Nguyễn Hồng Đăng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:18:24.8030000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161027', N'Nguyễn Thiện Đông', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:21:22.6400000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161029', N'Nguyễn Văn Đông', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:21:28.3400000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/31-1590724773766990774507.jpg', N'2017', 0, N'2', N'IT2-2017', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161035', N'Nguyễn Xuân Đồng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:21:10.3170000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161040', N'Hoàng Minh Định', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:18:42.4300000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161068', N'Hà Văn Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:18:58.9930000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161092', N'Nguyễn Anh Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:21:39.8170000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161109', N'Nguyễn Minh Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:21:51.5270000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161130', N'Phạm Minh Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:22:04.1530000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161222', N'Lê Thị Thu	Hà', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:19:12.3330000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161232', N'Nguyễn Thanh Hà', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:22:21.3000000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161286', N'Lê Thanh Hải', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:30:02.3270000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161326', N'Trần Hưng Hải', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:30:14.6530000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161337', N'Hà Thị Hảo', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:22:44.7270000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161340', N'Lê Thị Hảo', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:22:58.1070000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161384', N'Nguyễn Thị Hằng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:22:32.9470000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161385', N'Nguyễn Thị Hải	Hằng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:19:28.8170000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161390', N'Phạm Thị Thu Hằng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:30:36.3830000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161549', N'Nguyễn Trọng Hiếu', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:30:47.6700000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161575', N'Trần Minh Hiếu', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:23:10.0530000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161667', N'Lê Minh Hoàng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:30:59.0330000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161673', N'Ngô Minh Hoàng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:31:08.6970000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161701', N'Nguyễn Việt Hoàng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:31:19.8230000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161729', N'Vũ Nguyên Hoàng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:19:42.0530000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/33-1590724773772355990473.jpg', N'2016', 0, N'2', N'IT2-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161775', N'Lê Thị Huệ', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:23:24.9100000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161857', N'Phạm Quốc Duy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:31:42.0870000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161866', N'Trần Quốc Huy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:23:49.6530000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161898', N'Nguyễn Thị Ngọc Huyền', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:24:07.3130000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161980', N'Phạm Huy Hùng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:31:32.0570000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20161997', N'Vũ Văn Hùng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:23:34.6970000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20162041', N'Phạm Văn Hưng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:24:19.9030000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20162095', N'Vũ Thu Hường', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:24:32.0930000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://2.bp.blogspot.com/-fjf5yU5r1Jk/WE1VD1BBKpI/AAAAAAAAjgI/bXwGoigAPJYvScMPtzJtzbOJfoGQO2C_ACEw/s1600/15349541_533868826819201_3350340522319981193_n.jpg', N'2016', 0, N'2', N'MI1-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20162201', N'Hoàng Sỹ Khôi', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:32:16.9130000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20162260', N'Vũ Khắc Kiên', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:32:01.8500000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 1, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20162319', N'Nguyễn Thanh Lâm', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:32:29.4930000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20162523', N'Nguyễn Bảo Long', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:32:43.4200000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20162625', N'Nguyễn Thị Mai', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:32:53.0700000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2016', 0, N'2', N'MI2-2016', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165772', N'Vương Minh Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:09:33.4370000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165798', N'Trần Thị Bích', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:09:50.2070000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165813', N'Nguyễn Quang Chung', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:10:26.4770000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165831', N'Trịnh Thành Công', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:10:06.8000000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165864', N'Bùi	Doãn Dũng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:10:41.0870000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165886', N'Nguyễn Việt	Dũng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:10:55.5630000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165914', N'Lý	Văn	Dưỡng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:11:27.1000000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20165922', N'Nguyễn Trọng Dương', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:11:41.2930000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20167945', N'Lê Hữu Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:11:57.3470000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20167946', N'Trần Tuấn Dũng', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:11:10.3870000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/49-1590724976630165483391.jpg', N'2016', 0, N'2', N'IT1-2016', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20172398', N'Trần Trung Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:20:43.7530000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/31-1590724773766990774507.jpg', N'2017', 0, N'2', N'IT2-2017', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20172955', N'Vũ Tiến Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:21:02.6070000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/31-1590724773766990774507.jpg', N'2017', 0, N'2', N'IT2-2017', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20172975', N'Nguyễn Quốc	Chiến', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:21:15.0300000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/31-1590724773766990774507.jpg', N'2017', 0, N'2', N'IT2-2017', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173477', N'Cao	Thúy An', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:20:27.5700000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/31-1590724773766990774507.jpg', N'2017', 0, N'2', N'IT2-2017', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173478', N'Đoàn Ngọc An', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:34:52.8630000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://phunugioi.com/wp-content/uploads/2020/04/anh-hot-girl-2k6-moc-mac-voi-ao-dong-phuc.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173480', N'Nguyễn Thị Kim Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:41:11.9300000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI2-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173481', N'Đặng Thị Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:35:42.4900000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173483', N'Đỗ Thị Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:35:52.1330000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173485', N'Ngô Việt Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:36:03.5100000' AS DateTime2), N'Phuong Bach Khoa', 12345678, N'Ha Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173490', N'Nguyễn Nam Đàn', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:38:48.8530000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173491', N'Nguyễn văn Đăng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:42:10.2800000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI2-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173493', N'Nguyễn Tiến Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:41:58.9530000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI2-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173494', N'Lê Quốc Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:41:46.7800000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI2-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173495', N'Nguyễn Thị Định', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:39:03.8970000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173500', N'Nguyễn Việt Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:39:14.8630000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173503', N'Mạc Tùng Dương', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:41:36.5300000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI2-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173504', N'Vũ Ngọc DUy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:41:25.1700000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI2-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173507', N'Nguyễn Thị Hà', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:42:27.5600000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI2-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173509', N'Nguyễn Thị Hải', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:39:29.2170000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173511', N'Mai Thị Hằng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:39:40.8570000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173514', N'Đỗ Thị Hiền', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:39:53.0100000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173516', N'Nguyễn Trung Hiếu', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:40:04.5070000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173525', N'Nguyễn Trọng Huy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:40:18.6370000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173528', N'Nguyễn Xuân Huy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:40:31.9970000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173532', N'Tống Thị Huyền', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:40:44.7200000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/05/gai-xinh-toc-ngan-facebook-586x580.jpg', N'2017', 0, N'2', N'MI1-2017', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20173825', N'Cao	Phạm Ngọc Hải', N'12345678', N'email@gmail.com', CAST(N'2020-08-17 09:21:40.1670000' AS DateTime2), N'Dong Da', 0, N'Ha Noi', N'https://kenh14cdn.com/thumb_w/660/2020/5/29/31-1590724773766990774507.jpg', N'2017', 0, N'2', N'IT2-2017', N'IT')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20180262', N'Phạm Đức Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:44:34.4700000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
GO
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185322', N'Phạm Quốc Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:46:14.1370000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185324', N'Nguyễn Thị Kim Ánh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:46:27.2970000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185328', N'Nguyễn Đắc CAo', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:46:38.8270000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185330', N'Phan Anh Chiến', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:47:04.2630000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185332', N'Hoàng Phương Cúc', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:46:51.7830000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185334', N'Nguyễn Thành Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:47:37.9770000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185336', N'Phạm Hồng Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:47:48.5300000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185338', N'Phạm Văn Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:47:58.0870000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185340', N'Nguyễn Tiến Dũng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:47:16.8630000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185342', N'Nguyễn Lê Duy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:47:27.7930000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hinh-girl-toc-ngan-xinh-dep-thanh-khiet-400x580.jpg', N'2018', 0, N'2', N'MI1-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185429', N'Đinh Tuấn Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:44:00.5100000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185430', N'Hoàng Thị lan Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:44:13.9570000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185431', N'Nguyễn Tuấn Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:44:24.2170000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185432', N'Phạm Vân Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:44:43.9370000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185433', N'Đặng Thị ÁNh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:44:54.4730000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185434', N'Đỗ Thị Thanh Châu', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:45:28.5730000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185435', N'Phạm Chí Công', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:45:05.6100000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20185436', N'Ngô Quốc CƯơng', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:45:16.5070000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20186309', N'Nguyễn Văn Chiến', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:45:40.1770000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/girl-10x-toc-ngan-xinh-dep-khien-ai-cung-cam-nang-387x580.jpg', N'2018', 0, N'2', N'MI2-2018', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20190111', N'Đoàn Minh Bảo', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:54:15.0800000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195836', N'Nguyễn Hữu An', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:50:08.3200000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195838', N'Lê Thảo Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:50:31.3200000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195840', N'Phạm Tuấn Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:50:42.4670000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195842', N'Nguyễn Quý Bách', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:50:55.2200000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195844	', N'Hoàng Văn Chung', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:51:07.3770000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195848', N'Phạm Văn Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:51:44.4630000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195850', N'Cao Đình Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:51:54.3500000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195852', N'Nguyễn Bá Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:52:06.5070000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195855', N'Thịnh Xuân Đông', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:52:19.3100000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195856', N'Lê Minh Đức', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:52:30.4830000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195864	', N'Bùi Khương Duy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:51:16.4500000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195866', N'Nguyễn Thị Duyên', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:51:33.5370000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/anh-girl-xinh-toc-ngan-tuyet-dep-387x580.jpg', N'2019', 0, N'2', N'MI1-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195946', N'Giang Thế An', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:53:27.6000000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195947', N'Đặng Minh Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:53:38.4000000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195948', N'Nguyễn Quỳnh Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:53:49.5870000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195949', N'Nguyễn Thị Vân Anh', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:54:05.0800000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195950', N'Hoàng Thanh Bình', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:54:27.1800000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195951', N'Nguyễn Minh Châu', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:54:42.1000000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195952', N'Bùi Thị Lan Chi', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:54:55.5770000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195953', N'Nguyễn Tiến CHung', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:55:07.1430000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195954', N'Đỗ Anh Đạt', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:55:28.2600000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Students] ([Id], [Name], [Password], [Email], [BirthDay], [Address], [CardId], [Birthplace], [Avatar], [CreatedYear], [Status], [GroupId], [StudentClassId], [DepartmentId]) VALUES (N'20195960', N'Bùi Văn Duy', N'12345678', N'email@gmail.com', CAST(N'2020-08-16 20:55:17.9230000' AS DateTime2), N'Phường bách khoa', 0, N'HA Noi', N'https://thuthuatnhanh.com/wp-content/uploads/2019/08/hot-girl-toc-ngan-hoc-sinh-cute-435x580.jpg', N'2019', 0, N'2', N'MI2-2019', N'MI')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160024', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160067', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160187', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'720', 7, 7, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160215', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160258', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160264', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'761', 7, 7, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160361', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160398', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160405', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'803', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160555', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160624', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160626', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'844', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160629', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160705', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160753', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'885', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160779', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160818', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160836', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'927', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160850', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160871', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160902', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'968', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160933', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160954', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20160986', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161027', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'679', 7, 7, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161035', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161092', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161109', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'720', 7, 7, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161130', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161232', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161286', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'761', 7, 7, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161326', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161337', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161340', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'803', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161384', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161549', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161575', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'844', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161667', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161673', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'885', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161775', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'679', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'689', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'699', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'710', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'720', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'730', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'741', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'751', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'761', 7, 7, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'772', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'782', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'792', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'803', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'813', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'823', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'834', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'844', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'854', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'865', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'875', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'885', 8, 8, N'B+')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'896', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'906', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'916', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'927', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'937', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'947', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'958', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'968', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'978', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'988', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20161857', N'998', 8, 8, N'B+')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173478', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173480', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173481', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173483', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'701', 8, 7.5, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173485', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173490', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173491', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173493', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173494', N'995', 8, 7.5, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173495', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173500', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173503', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173504', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'936', 8, 7.5, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173507', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173509', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173511', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173514', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173516', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'804', 8, 7.5, N'B')
GO
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173525', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173528', N'995', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'681', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'682', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'691', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'692', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'701', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'702', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'763', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'773', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'783', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'794', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'804', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'814', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'824', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'896', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'916', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'936', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'946', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'965', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'975', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'985', 8, 7.5, N'B')
INSERT [dbo].[Takes] ([ID], [SecId], [Midterm], [Endterm], [WordScore]) VALUES (N'20173532', N'995', 8, 7.5, N'B')
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'1', N'2', 6, 45, 9, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'1', N'3', 6, 45, 9, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'1', N'4', 6, 45, 9, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'1', N'5', 6, 45, 9, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'1', N'6', 6, 45, 9, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'2', N'2', 9, 15, 11, 45)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'2', N'3', 9, 15, 11, 45)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'2', N'4', 9, 15, 11, 45)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'2', N'5', 9, 15, 11, 45)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'2', N'6', 9, 15, 11, 45)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'3', N'2', 12, 30, 15, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'3', N'3', 12, 30, 15, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'3', N'4', 12, 30, 15, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'3', N'5', 12, 30, 15, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'3', N'6', 12, 30, 15, 0)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'4', N'2', 15, 0, 17, 30)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'4', N'3', 15, 0, 17, 30)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'4', N'4', 15, 0, 17, 30)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'4', N'5', 15, 0, 17, 30)
INSERT [dbo].[TimeSlots] ([TimeSlotId], [Day], [StartHr], [StartMin], [EndHr], [EndMin]) VALUES (N'4', N'6', 15, 0, 17, 30)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160024', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160067', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160187', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160215', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160258', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160264', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160361', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160398', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160405', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160555', N'20202', 0)
GO
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160624', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160626', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160629', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160705', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160753', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160779', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160818', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160836', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160850', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160871', N'20202', 0)
GO
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160902', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160933', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160954', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20160986', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161027', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161035', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161092', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161109', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161130', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161232', N'20202', 0)
GO
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161286', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161326', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161337', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161340', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161384', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161549', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161575', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161667', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161673', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161775', N'20202', 0)
GO
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20161', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20162', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20201', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20161857', N'20202', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173478', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173478', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173478', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173478', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173478', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173478', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173480', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173480', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173480', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173480', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173480', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173480', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173481', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173481', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173481', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173481', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173481', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173481', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173483', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173483', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173483', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173483', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173483', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173483', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173485', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173485', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173485', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173485', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173485', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173485', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173490', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173490', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173490', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173490', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173490', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173490', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173491', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173491', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173491', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173491', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173491', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173491', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173493', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173493', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173493', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173493', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173493', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173493', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173494', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173494', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173494', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173494', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173494', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173494', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173495', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173495', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173495', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173495', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173495', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173495', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173500', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173500', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173500', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173500', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173500', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173500', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173503', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173503', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173503', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173503', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173503', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173503', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173504', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173504', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173504', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173504', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173504', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173504', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173507', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173507', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173507', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173507', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173507', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173507', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173509', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173509', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173509', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173509', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173509', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173509', N'20192', 0)
GO
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173511', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173511', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173511', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173511', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173511', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173511', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173514', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173514', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173514', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173514', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173514', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173514', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173516', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173516', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173516', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173516', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173516', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173516', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173525', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173525', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173525', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173525', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173525', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173525', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173528', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173528', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173528', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173528', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173528', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173528', N'20192', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173532', N'20171', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173532', N'20172', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173532', N'20181', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173532', N'20182', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173532', N'20191', 0)
INSERT [dbo].[Warns] ([StudentId], [Semester], [Level]) VALUES (N'20173532', N'20192', 0)
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK__course__dept_nam__164452B1] FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([DepartmentId])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK__course__dept_nam__164452B1]
GO
ALTER TABLE [dbo].[InstructorDepartments]  WITH CHECK ADD  CONSTRAINT [FK__instructordept_dept] FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([DepartmentId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InstructorDepartments] CHECK CONSTRAINT [FK__instructordept_dept]
GO
ALTER TABLE [dbo].[InstructorNotification]  WITH CHECK ADD  CONSTRAINT [FK__instructorNotification12] FOREIGN KEY([InstructorId])
REFERENCES [dbo].[Instructors] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InstructorNotification] CHECK CONSTRAINT [FK__instructorNotification12]
GO
ALTER TABLE [dbo].[InstructorNotification]  WITH CHECK ADD  CONSTRAINT [FK__NoticeInstrucNotification] FOREIGN KEY([NotificationId])
REFERENCES [dbo].[Notifications] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InstructorNotification] CHECK CONSTRAINT [FK__NoticeInstrucNotification]
GO
ALTER TABLE [dbo].[Instructors]  WITH CHECK ADD  CONSTRAINT [FK__instructor_Appgroup] FOREIGN KEY([GroupId])
REFERENCES [dbo].[AppGroups] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Instructors] CHECK CONSTRAINT [FK__instructor_Appgroup]
GO
ALTER TABLE [dbo].[Instructors]  WITH CHECK ADD  CONSTRAINT [FK__instructor_instructordepartment] FOREIGN KEY([InstructorDepartmentId], [DepartmentId])
REFERENCES [dbo].[InstructorDepartments] ([Id], [DepartmentId])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Instructors] CHECK CONSTRAINT [FK__instructor_instructordepartment]
GO
ALTER TABLE [dbo].[Posts]  WITH CHECK ADD  CONSTRAINT [FK__Post_PostCategory] FOREIGN KEY([PostCategoryId])
REFERENCES [dbo].[PostCategories] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Posts] CHECK CONSTRAINT [FK__Post_PostCategory]
GO
ALTER TABLE [dbo].[Prereqs]  WITH CHECK ADD  CONSTRAINT [FK__prereq__course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
GO
ALTER TABLE [dbo].[Prereqs] CHECK CONSTRAINT [FK__prereq__course]
GO
ALTER TABLE [dbo].[Sections]  WITH CHECK ADD  CONSTRAINT [FK__section__1FCDBCEB] FOREIGN KEY([Building], [RoomNumber])
REFERENCES [dbo].[Classrooms] ([Building], [RoomNumber])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Sections] CHECK CONSTRAINT [FK__section__1FCDBCEB]
GO
ALTER TABLE [dbo].[Sections]  WITH CHECK ADD  CONSTRAINT [FK__section__course___1ED998B2] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Sections] CHECK CONSTRAINT [FK__section__course___1ED998B2]
GO
ALTER TABLE [dbo].[Sections]  WITH CHECK ADD  CONSTRAINT [FK__section__timeslot] FOREIGN KEY([TimeSlotId], [Day])
REFERENCES [dbo].[TimeSlots] ([TimeSlotId], [Day])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Sections] CHECK CONSTRAINT [FK__section__timeslot]
GO
ALTER TABLE [dbo].[StudentClasses]  WITH CHECK ADD  CONSTRAINT [FK__studentclass__dept] FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([DepartmentId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentClasses] CHECK CONSTRAINT [FK__studentclass__dept]
GO
ALTER TABLE [dbo].[StudentNotification]  WITH CHECK ADD  CONSTRAINT [FK__NoticeStudentNotification] FOREIGN KEY([NotificationId])
REFERENCES [dbo].[Notifications] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentNotification] CHECK CONSTRAINT [FK__NoticeStudentNotification]
GO
ALTER TABLE [dbo].[StudentNotification]  WITH CHECK ADD  CONSTRAINT [FK__StudentNotification12] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentNotification] CHECK CONSTRAINT [FK__StudentNotification12]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [FK__student__appgroup] FOREIGN KEY([GroupId])
REFERENCES [dbo].[AppGroups] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [FK__student__appgroup]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [FK__student__dept_na__276EDEB3] FOREIGN KEY([StudentClassId], [DepartmentId])
REFERENCES [dbo].[StudentClasses] ([Id], [DepartmentId])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [FK__student__dept_na__276EDEB3]
GO
ALTER TABLE [dbo].[Takes]  WITH CHECK ADD  CONSTRAINT [FK__takes__2A4B4B5E] FOREIGN KEY([SecId])
REFERENCES [dbo].[Sections] ([SecId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Takes] CHECK CONSTRAINT [FK__takes__2A4B4B5E]
GO
ALTER TABLE [dbo].[Takes]  WITH CHECK ADD  CONSTRAINT [FK__takes__ID__2B3F6F97] FOREIGN KEY([ID])
REFERENCES [dbo].[Students] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Takes] CHECK CONSTRAINT [FK__takes__ID__2B3F6F97]
GO
ALTER TABLE [dbo].[Teaches]  WITH CHECK ADD  CONSTRAINT [FK__teaches_instructor] FOREIGN KEY([ID])
REFERENCES [dbo].[Instructors] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Teaches] CHECK CONSTRAINT [FK__teaches_instructor]
GO
ALTER TABLE [dbo].[Teaches]  WITH CHECK ADD  CONSTRAINT [FK__teaches_section] FOREIGN KEY([SecId])
REFERENCES [dbo].[Sections] ([SecId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Teaches] CHECK CONSTRAINT [FK__teaches_section]
GO
ALTER TABLE [dbo].[ToeicPoints]  WITH CHECK ADD  CONSTRAINT [FK__toeic_student] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ToeicPoints] CHECK CONSTRAINT [FK__toeic_student]
GO
ALTER TABLE [dbo].[Warns]  WITH CHECK ADD  CONSTRAINT [FK__warnc_student] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Warns] CHECK CONSTRAINT [FK__warnc_student]
GO
