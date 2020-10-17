using StudentAppServer.Data.Base;
using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class Section
    {
        public Section()
        {
            Takes = new HashSet<Take>();

            Teaches = new HashSet<Teach>();
        }

        public string SecId { get; set; }

        public string Semester { get; set; }

        public string Year { get; set; }

        public Status Status { get; set; }

        public string Building { get; set; }
        public string RoomNumber { get; set; }
        public Classroom Classroom { get; set; }

        public string TimeSlotId { get; set; }
        public string Day { get; set; }
        public TimeSlot TimeSlot { get; set; }

        public string CourseId { get; set; }
        public Course Course { get; set; }

        public virtual ICollection<Take> Takes { get; set; }
        public ICollection<Teach> Teaches { get; set; }
    }
}