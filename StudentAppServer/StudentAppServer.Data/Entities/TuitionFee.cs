namespace StudentAppServer.Data.Entities
{
    public class TuitionFee
    {
        public string DepartmentId { get; set; }
        public string Semester { get; set; }

        public decimal Fee { get; set; }

        public Department Department { get; set; }

        public Semester SemesterTable { get; set; }
    }
}