using StudentAppServer.Data.Base;

namespace StudentAppServer.Data.Entities
{
    public class Prereq
    {
        public string CourseId { get; set; }

        public string PrereqId { get; set; }

        public Status Status { get; set; }

        public Course Course { get; set; }
    }
}