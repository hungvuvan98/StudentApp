using StudentAppServer.Data.Base;
using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class AppGroup
    {
        public AppGroup()
        {
            Instructors = new HashSet<Instructor>();

            Students = new HashSet<Student>();
        }

        public string Id { get; set; }

        public string Name { get; set; }

        public string Role { get; set; }

        public Status Status { get; set; }

        public ICollection<Instructor> Instructors { get; set; }

        public ICollection<Student> Students { get; set; }
    }
}