using Microsoft.EntityFrameworkCore.Migrations;

namespace StudentAppServer.Data.Migrations
{
    public partial class ConnectSetionToSemester : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "Semesters",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sections_Semester",
                table: "Sections",
                column: "Semester");

            migrationBuilder.AddForeignKey(
                name: "FK_Sections_Semesters_Semester",
                table: "Sections",
                column: "Semester",
                principalTable: "Semesters",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Sections_Semesters_Semester",
                table: "Sections");

            migrationBuilder.DropIndex(
                name: "IX_Sections_Semester",
                table: "Sections");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "Semesters");
        }
    }
}
