using StudentAppServer.Data.Base;
using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Procedure
{
    public class GetRegisteredClassByStudentId
    {
        public string Id { get; set; }

        public string SecId { get; set; }

        public Status Status { get; set; }

        public string Building { get; set; }

        public string RoomNumber { get; set; }

        public int StartHr { get; set; }

        public int StartMin { get; set; }

        public string Day { get; set; }

        public int EndHr { get; set; }

        public int EndMin { get; set; }

        public string CourseId { get; set; }

        public string Title { get; set; }

        public int Credit { get; set; }

        public string Semester { get; set; }
    }
}