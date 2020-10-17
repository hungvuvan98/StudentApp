using StudentAppServer.Data.Base;

namespace StudentAppServer.Data.Procedure
{
    public class GetStudent
    {
        public string Id { get; set; }

        public string StudentName { get; set; }

        public Status Status { get; set; }

        public string CreatedYear { get; set; }

        public string StudentClassName { get; set; }

        public string DepartmentName { get; set; }

        public string StudentClassId { get; set; }

        public string DepartmentId { get; set; }
    }
}