using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Base
{
    public class Date : IDate
    {
        public DateTime? CreatedOn { get; set; }

        public DateTime? ModifiedOn { get; set; }
    }
}