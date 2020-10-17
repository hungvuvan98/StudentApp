using StudentAppServer.Data.Base;
using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class StudentClass
    {
        public StudentClass()
        {
            Students = new HashSet<Student>();
        }

        public string Id { get; set; }

        public string Name { get; set; }

        public string Year { get; set; }

        public Status? Status { get; set; }

        public string DepartmentId { get; set; }
        public Department Department { get; set; }

        public ICollection<Student> Students { get; set; }
    }
}