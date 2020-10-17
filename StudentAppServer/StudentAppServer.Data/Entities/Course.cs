using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class Course
    {
        public Course()
        {
            Prereqs = new HashSet<Prereq>();

            Sections = new HashSet<Section>();
        }

        public string CourseId { get; set; }

        public string Title { get; set; }

        public int Credits { get; set; }

        public string DepartmentId { get; set; }
        public Department Department { get; set; }

        public ICollection<Prereq> Prereqs { get; set; }

        public ICollection<Section> Sections { get; set; }
    }
}