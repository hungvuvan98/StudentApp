using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Base
{
    public class ByUser : IByUser
    {
        public string CreatedBy { get; set; }

        public string ModifiedBy { get; set; }
    }
}