using Microsoft.EntityFrameworkCore.Migrations;

namespace StudentAppServer.Data.Migrations
{
    public partial class create_procedure : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            var getStudent = @"alter PROCEDURE [dbo].[SP_GetStudent]
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
                END; ";

            var getInfor = @"alter PROCEDURE [dbo].[SP_GetStudentInfor]( @id VARCHAR(20) )
                AS
				BEGIN
					SET NOCOUNT ON;
				SELECT st.Id,st.Name AS'StudentName',st.Password,st.BirthDay,st.Address,st.CardId,st.Birthplace,
						st.Avatar,st.Status,st.CreatedYear,
					ta.Midterm,ta.Endterm,ta.WordScore,
					se.Semester,se.year,
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
				END;";

            var update = @"CREATE PROC sp_update_wordscore
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
							END;";
            migrationBuilder.Sql(getStudent);
            migrationBuilder.Sql(getInfor);
            migrationBuilder.Sql(update);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}