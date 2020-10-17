using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Entities
{
    public class Warn
    {
        public string StudentId { get; set; }

        public string Semester { get; set; }

        public int Level { get; set; }

        public Student Student { get; set; }
    }
}