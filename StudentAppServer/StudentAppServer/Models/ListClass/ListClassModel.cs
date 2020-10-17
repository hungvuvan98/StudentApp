using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Models.ListClass
{
    public class ListClassModel
    {
        public string SecId { get; set; }

        public string Semester { get; set; }

        public int Status { get; set; }

        public string Building { get; set; }

        public string RoomNumber { get; set; }

        public int StartHr { get; set; }

        public int StartMin { get; set; }

        public string Day { get; set; }

        public int EndHr { get; set; }

        public int EndMin { get; set; }

        public string CourseId { get; set; }

        public string Title { get; set; }

        public int Capacity { get; set; }

        public int Credit { get; set; }

        public string Name { get; set; }

        public int TotalRegistered { get; set; }
    }
}