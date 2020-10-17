using StudentAppServer.Data.Base;
using System;

namespace StudentAppServer.Data.Procedure
{
    public class GetStudentInfor
    {
        public string Id { get; set; }

        public string StudentName { get; set; }

        public float Midterm { get; set; }

        public float Endterm { get; set; }

        public string WordScore { get; set; }

        public string Semester { get; set; }

        public string Year { get; set; }

        public string Title { get; set; }

        public int Credits { get; set; }

        public string CourseId { get; set; }

        public string SecId { get; set; }

        public string Building { get; set; }

        public string RoomNumber { get; set; }

        public string Password { get; set; }

        public DateTime BirthDay { get; set; }

        public string Address { get; set; }

        public int CardId { get; set; }

        public string Birthplace { get; set; }

        public string Avatar { get; set; }

        public Status Status { get; set; }

        public string CreatedYear { get; set; }

        public string StudentClassName { get; set; }

        public string DepartmentName { get; set; }
    }
}