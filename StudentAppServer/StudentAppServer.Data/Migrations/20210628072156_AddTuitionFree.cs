using Microsoft.EntityFrameworkCore.Migrations;

namespace StudentAppServer.Data.Migrations
{
    public partial class AddTuitionFree : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK__tuitionFee",
                table: "TuitionFees");

            migrationBuilder.DropColumn(
                name: "SemesterId",
                table: "TuitionFees");

            migrationBuilder.AlterColumn<decimal>(
                name: "Fee",
                table: "TuitionFees",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "float");

            migrationBuilder.AddColumn<string>(
                name: "Semester",
                table: "TuitionFees",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK__tuitionFee",
                table: "TuitionFees",
                columns: new[] { "DepartmentId", "Semester" });

            migrationBuilder.CreateIndex(
                name: "IX_TuitionFees_Semester",
                table: "TuitionFees",
                column: "Semester");

            migrationBuilder.AddForeignKey(
                name: "FK_TuitionFees_Semesters_Semester",
                table: "TuitionFees",
                column: "Semester",
                principalTable: "Semesters",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TuitionFees_Semesters_Semester",
                table: "TuitionFees");

            migrationBuilder.DropPrimaryKey(
                name: "PK__tuitionFee",
                table: "TuitionFees");

            migrationBuilder.DropIndex(
                name: "IX_TuitionFees_Semester",
                table: "TuitionFees");

            migrationBuilder.DropColumn(
                name: "Semester",
                table: "TuitionFees");

            migrationBuilder.AlterColumn<double>(
                name: "Fee",
                table: "TuitionFees",
                type: "float",
                nullable: false,
                oldClrType: typeof(decimal));

            migrationBuilder.AddColumn<string>(
                name: "SemesterId",
                table: "TuitionFees",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK__tuitionFee",
                table: "TuitionFees",
                columns: new[] { "DepartmentId", "SemesterId" });
        }
    }
}
