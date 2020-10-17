using System;

namespace StudentAppServer.Data.Entities
{
    public class ToeicPoint
    {
        public string Id { get; set; }

        public string Semester { get; set; }

        public string year { get; set; }

        public string Description { get; set; }

        public int HearPoint { get; set; }

        public int ReadPoint { get; set; }

        public int TotalPoint { get; set; }

        public DateTime? CreatedDate { get; set; }

        public string StudentId { get; set; }
        public Student Student { get; set; }
    }
}