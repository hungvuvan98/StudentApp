using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Procedure
{
    public class GetResultLearning
    {
        public string Semester { get; set; }

        public double GPA { get; set; }

        public double CPA { get; set; }

        public int TCQua { get; set; }

        public int TCTichLuy { get; set; }

        public int TCNoDK { get; set; }

        public int TCDK { get; set; }

        public string TrinhDo { get; set; }

        public int MucCC { get; set; }
    }
}