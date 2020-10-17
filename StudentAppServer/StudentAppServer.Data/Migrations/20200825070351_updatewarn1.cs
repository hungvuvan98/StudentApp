using Microsoft.EntityFrameworkCore.Migrations;

namespace StudentAppServer.Data.Migrations
{
    public partial class updatewarn1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_warn",
                table: "Warns");

            migrationBuilder.AlterColumn<string>(
                name: "Semester",
                table: "Warns",
                maxLength: 20,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20,
                oldNullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_warn",
                table: "Warns",
                columns: new[] { "StudentId", "Semester" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_warn",
                table: "Warns");

            migrationBuilder.AlterColumn<string>(
                name: "Semester",
                table: "Warns",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true,
                oldClrType: typeof(string),
                oldMaxLength: 20);

            migrationBuilder.AddPrimaryKey(
                name: "PK_warn",
                table: "Warns",
                column: "StudentId");
        }
    }
}
