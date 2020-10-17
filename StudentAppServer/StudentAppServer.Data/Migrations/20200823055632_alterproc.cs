using Microsoft.EntityFrameworkCore.Migrations;

namespace StudentAppServer.Data.Migrations
{
    public partial class alterproc : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            var getInfor = @"alter PROCEDURE [dbo].[SP_GetStudentInfor]( @id VARCHAR(20) )
                AS
				BEGIN
					SET NOCOUNT ON;
				SELECT st.Id,st.Name AS'StudentName',st.Password,st.BirthDay,st.Address,st.CardId,st.Birthplace,
						st.Avatar,st.Status,st.CreatedYear,
					ta.Midterm,ta.Endterm,ta.WordScore,
					se.Semester,se.year,se.SecId
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
            migrationBuilder.Sql(getInfor);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}