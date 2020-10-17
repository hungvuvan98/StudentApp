using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace StudentAppServer.Data.Migrations
{
    public partial class itinial : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AppGroups",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(maxLength: 100, nullable: true),
                    Role = table.Column<string>(maxLength: 50, nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Appgroup", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Classrooms",
                columns: table => new
                {
                    Building = table.Column<string>(maxLength: 20, nullable: false),
                    RoomNumber = table.Column<string>(maxLength: 20, nullable: false),
                    Capacity = table.Column<int>(nullable: false),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__classroom", x => new { x.Building, x.RoomNumber });
                });

            migrationBuilder.CreateTable(
                name: "Departments",
                columns: table => new
                {
                    DepartmentId = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(maxLength: 200, nullable: true),
                    Building = table.Column<string>(maxLength: 20, nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__department", x => x.DepartmentId);
                });

            migrationBuilder.CreateTable(
                name: "Feedbacks",
                columns: table => new
                {
                    ID = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(maxLength: 200, nullable: true),
                    Email = table.Column<string>(maxLength: 200, nullable: true),
                    Message = table.Column<string>(nullable: true),
                    DateCreated = table.Column<DateTime>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__feedback", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Languages",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(nullable: true),
                    IsDefault = table.Column<bool>(nullable: false),
                    Resources = table.Column<string>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_language", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    Message = table.Column<string>(nullable: true),
                    CreatedDate = table.Column<DateTime>(nullable: true),
                    ModifiedDate = table.Column<DateTime>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notification", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PostCategories",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Postcategory", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TimeSlots",
                columns: table => new
                {
                    TimeSlotId = table.Column<string>(maxLength: 20, nullable: false),
                    Day = table.Column<string>(maxLength: 20, nullable: false),
                    StartHr = table.Column<int>(nullable: true),
                    StartMin = table.Column<int>(nullable: true),
                    EndHr = table.Column<int>(nullable: true),
                    EndMin = table.Column<int>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__timeslot", x => new { x.TimeSlotId, x.Day });
                });

            migrationBuilder.CreateTable(
                name: "Courses",
                columns: table => new
                {
                    CourseId = table.Column<string>(maxLength: 20, nullable: false),
                    Title = table.Column<string>(maxLength: 200, nullable: true),
                    Credits = table.Column<int>(nullable: false),
                    DepartmentId = table.Column<string>(maxLength: 20, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Courses", x => x.CourseId);
                    table.ForeignKey(
                        name: "FK__course__dept_nam__164452B1",
                        column: x => x.DepartmentId,
                        principalTable: "Departments",
                        principalColumn: "DepartmentId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "InstructorDepartments",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    DepartmentId = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(nullable: true),
                    Description = table.Column<string>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InstructorDepartment", x => new { x.Id, x.DepartmentId });
                    table.ForeignKey(
                        name: "FK__instructordept_dept",
                        column: x => x.DepartmentId,
                        principalTable: "Departments",
                        principalColumn: "DepartmentId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StudentClasses",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    DepartmentId = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(maxLength: 200, nullable: false),
                    Year = table.Column<string>(maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__StudentClass", x => new { x.Id, x.DepartmentId });
                    table.ForeignKey(
                        name: "FK__studentclass__dept",
                        column: x => x.DepartmentId,
                        principalTable: "Departments",
                        principalColumn: "DepartmentId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Posts",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    PostCategoryId = table.Column<string>(nullable: true),
                    Content = table.Column<string>(nullable: true),
                    CreatedOn = table.Column<DateTime>(nullable: true),
                    ModifiedOn = table.Column<DateTime>(nullable: true),
                    CreatedBy = table.Column<string>(nullable: true),
                    ModifiedBy = table.Column<string>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Post", x => x.Id);
                    table.ForeignKey(
                        name: "FK__Post_PostCategory",
                        column: x => x.PostCategoryId,
                        principalTable: "PostCategories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Prereqs",
                columns: table => new
                {
                    CourseId = table.Column<string>(maxLength: 20, nullable: false),
                    PrereqId = table.Column<string>(maxLength: 20, nullable: false),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__prereq", x => new { x.CourseId, x.PrereqId });
                    table.ForeignKey(
                        name: "FK__prereq__course",
                        column: x => x.CourseId,
                        principalTable: "Courses",
                        principalColumn: "CourseId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Sections",
                columns: table => new
                {
                    SecId = table.Column<string>(maxLength: 20, nullable: false),
                    Semester = table.Column<string>(maxLength: 20, nullable: true),
                    Year = table.Column<string>(maxLength: 20, nullable: true),
                    Status = table.Column<int>(nullable: false),
                    Building = table.Column<string>(maxLength: 20, nullable: true),
                    RoomNumber = table.Column<string>(maxLength: 20, nullable: true),
                    TimeSlotId = table.Column<string>(maxLength: 20, nullable: true),
                    Day = table.Column<string>(maxLength: 20, nullable: true),
                    CourseId = table.Column<string>(maxLength: 20, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__section", x => x.SecId);
                    table.ForeignKey(
                        name: "FK__section__course___1ED998B2",
                        column: x => x.CourseId,
                        principalTable: "Courses",
                        principalColumn: "CourseId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__section__1FCDBCEB",
                        columns: x => new { x.Building, x.RoomNumber },
                        principalTable: "Classrooms",
                        principalColumns: new[] { "Building", "RoomNumber" },
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK__section__timeslot",
                        columns: x => new { x.TimeSlotId, x.Day },
                        principalTable: "TimeSlots",
                        principalColumns: new[] { "TimeSlotId", "Day" },
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Instructors",
                columns: table => new
                {
                    ID = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(maxLength: 200, nullable: false),
                    Password = table.Column<string>(nullable: true),
                    BitrhDay = table.Column<DateTime>(nullable: true),
                    Address = table.Column<string>(nullable: true),
                    Email = table.Column<string>(nullable: true),
                    Gender = table.Column<int>(nullable: false),
                    CardId = table.Column<int>(nullable: true),
                    Birthplace = table.Column<string>(nullable: true),
                    CreatedYear = table.Column<string>(nullable: true),
                    Avatar = table.Column<string>(nullable: true),
                    Salary = table.Column<decimal>(type: "numeric(8, 2)", nullable: true),
                    Status = table.Column<int>(nullable: false),
                    GroupId = table.Column<string>(nullable: true),
                    DepartmentId = table.Column<string>(maxLength: 20, nullable: true),
                    InstructorDepartmentId = table.Column<string>(maxLength: 20, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Instructors", x => x.ID);
                    table.ForeignKey(
                        name: "FK__instructor_Appgroup",
                        column: x => x.GroupId,
                        principalTable: "AppGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK__instructor_instructordepartment",
                        columns: x => new { x.InstructorDepartmentId, x.DepartmentId },
                        principalTable: "InstructorDepartments",
                        principalColumns: new[] { "Id", "DepartmentId" },
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Students",
                columns: table => new
                {
                    Id = table.Column<string>(maxLength: 20, nullable: false),
                    Name = table.Column<string>(maxLength: 200, nullable: false),
                    Password = table.Column<string>(maxLength: 20, nullable: true),
                    Email = table.Column<string>(nullable: true),
                    BirthDay = table.Column<DateTime>(nullable: true),
                    Address = table.Column<string>(nullable: true),
                    CardId = table.Column<int>(nullable: true),
                    Birthplace = table.Column<string>(nullable: true),
                    Avatar = table.Column<string>(nullable: true),
                    CreatedYear = table.Column<string>(maxLength: 20, nullable: true),
                    Status = table.Column<int>(nullable: false),
                    GroupId = table.Column<string>(nullable: true),
                    StudentClassId = table.Column<string>(maxLength: 20, nullable: true),
                    DepartmentId = table.Column<string>(maxLength: 20, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Student", x => x.Id);
                    table.ForeignKey(
                        name: "FK__student__appgroup",
                        column: x => x.GroupId,
                        principalTable: "AppGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK__student__dept_na__276EDEB3",
                        columns: x => new { x.StudentClassId, x.DepartmentId },
                        principalTable: "StudentClasses",
                        principalColumns: new[] { "Id", "DepartmentId" },
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "InstructorNotification",
                columns: table => new
                {
                    InstructorId = table.Column<string>(maxLength: 20, nullable: false),
                    NotificationId = table.Column<string>(maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InstructorNotice", x => new { x.InstructorId, x.NotificationId });
                    table.ForeignKey(
                        name: "FK__instructorNotification12",
                        column: x => x.InstructorId,
                        principalTable: "Instructors",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__NoticeInstrucNotification",
                        column: x => x.NotificationId,
                        principalTable: "Notifications",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Teaches",
                columns: table => new
                {
                    ID = table.Column<string>(maxLength: 20, nullable: false),
                    SecId = table.Column<string>(maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__teaches__A0A7458ABC151A07", x => new { x.ID, x.SecId });
                    table.ForeignKey(
                        name: "FK__teaches_instructor",
                        column: x => x.ID,
                        principalTable: "Instructors",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__teaches_section",
                        column: x => x.SecId,
                        principalTable: "Sections",
                        principalColumn: "SecId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StudentNotification",
                columns: table => new
                {
                    StudentId = table.Column<string>(maxLength: 20, nullable: false),
                    NotificationId = table.Column<string>(maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StudentNotice", x => new { x.StudentId, x.NotificationId });
                    table.ForeignKey(
                        name: "FK__NoticeStudentNotification",
                        column: x => x.NotificationId,
                        principalTable: "Notifications",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__StudentNotification12",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Takes",
                columns: table => new
                {
                    ID = table.Column<string>(maxLength: 20, nullable: false),
                    SecId = table.Column<string>(maxLength: 20, nullable: false),
                    Midterm = table.Column<float>(nullable: true),
                    Endterm = table.Column<float>(nullable: true),
                    WordScore = table.Column<string>(maxLength: 2, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__takes__A0A7458A976F2631", x => new { x.ID, x.SecId });
                    table.ForeignKey(
                        name: "FK__takes__ID__2B3F6F97",
                        column: x => x.ID,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__takes__2A4B4B5E",
                        column: x => x.SecId,
                        principalTable: "Sections",
                        principalColumn: "SecId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ToeicPoints",
                columns: table => new
                {
                    ID = table.Column<string>(maxLength: 20, nullable: false),
                    StudentId = table.Column<string>(maxLength: 20, nullable: false),
                    Semester = table.Column<string>(nullable: true),
                    year = table.Column<string>(nullable: true),
                    Description = table.Column<string>(nullable: true),
                    HearPoint = table.Column<int>(nullable: false),
                    ReadPoint = table.Column<int>(nullable: false),
                    TotalPoint = table.Column<int>(nullable: false),
                    CreatedDate = table.Column<DateTime>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__toeicpoint", x => new { x.ID, x.StudentId });
                    table.ForeignKey(
                        name: "FK__toeic_student",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Courses_DepartmentId",
                table: "Courses",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_InstructorDepartments_DepartmentId",
                table: "InstructorDepartments",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_InstructorNotification_NotificationId",
                table: "InstructorNotification",
                column: "NotificationId");

            migrationBuilder.CreateIndex(
                name: "IX_Instructors_GroupId",
                table: "Instructors",
                column: "GroupId");

            migrationBuilder.CreateIndex(
                name: "IX_Instructors_InstructorDepartmentId_DepartmentId",
                table: "Instructors",
                columns: new[] { "InstructorDepartmentId", "DepartmentId" });

            migrationBuilder.CreateIndex(
                name: "IX_Posts_PostCategoryId",
                table: "Posts",
                column: "PostCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Sections_CourseId",
                table: "Sections",
                column: "CourseId");

            migrationBuilder.CreateIndex(
                name: "IX_Sections_Building_RoomNumber",
                table: "Sections",
                columns: new[] { "Building", "RoomNumber" });

            migrationBuilder.CreateIndex(
                name: "IX_Sections_TimeSlotId_Day",
                table: "Sections",
                columns: new[] { "TimeSlotId", "Day" });

            migrationBuilder.CreateIndex(
                name: "IX_StudentClasses_DepartmentId",
                table: "StudentClasses",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_StudentNotification_NotificationId",
                table: "StudentNotification",
                column: "NotificationId");

            migrationBuilder.CreateIndex(
                name: "IX_Students_GroupId",
                table: "Students",
                column: "GroupId");

            migrationBuilder.CreateIndex(
                name: "IX_Students_StudentClassId_DepartmentId",
                table: "Students",
                columns: new[] { "StudentClassId", "DepartmentId" });

            migrationBuilder.CreateIndex(
                name: "IX_Takes_SecId",
                table: "Takes",
                column: "SecId");

            migrationBuilder.CreateIndex(
                name: "IX_Teaches_SecId",
                table: "Teaches",
                column: "SecId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicPoints_StudentId",
                table: "ToeicPoints",
                column: "StudentId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Feedbacks");

            migrationBuilder.DropTable(
                name: "InstructorNotification");

            migrationBuilder.DropTable(
                name: "Languages");

            migrationBuilder.DropTable(
                name: "Posts");

            migrationBuilder.DropTable(
                name: "Prereqs");

            migrationBuilder.DropTable(
                name: "StudentNotification");

            migrationBuilder.DropTable(
                name: "Takes");

            migrationBuilder.DropTable(
                name: "Teaches");

            migrationBuilder.DropTable(
                name: "ToeicPoints");

            migrationBuilder.DropTable(
                name: "PostCategories");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "Instructors");

            migrationBuilder.DropTable(
                name: "Sections");

            migrationBuilder.DropTable(
                name: "Students");

            migrationBuilder.DropTable(
                name: "InstructorDepartments");

            migrationBuilder.DropTable(
                name: "Courses");

            migrationBuilder.DropTable(
                name: "Classrooms");

            migrationBuilder.DropTable(
                name: "TimeSlots");

            migrationBuilder.DropTable(
                name: "AppGroups");

            migrationBuilder.DropTable(
                name: "StudentClasses");

            migrationBuilder.DropTable(
                name: "Departments");
        }
    }
}
