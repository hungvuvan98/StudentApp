using Microsoft.EntityFrameworkCore.Migrations;

namespace StudentAppServer.Data.Migrations
{
    public partial class addTableTuitionFree : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TuitionFees",
                columns: table => new
                {
                    DepartmentId = table.Column<string>(maxLength: 20, nullable: false),
                    SemesterId = table.Column<string>(maxLength: 20, nullable: false),
                    Fee = table.Column<double>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__tuitionFee", x => new { x.DepartmentId, x.SemesterId });
                    table.ForeignKey(
                        name: "FK__tuitionFees_department",
                        column: x => x.DepartmentId,
                        principalTable: "Departments",
                        principalColumn: "DepartmentId",
                        onDelete: ReferentialAction.Cascade);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TuitionFees");
        }
    }
}
