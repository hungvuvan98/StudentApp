using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Base
{
    public interface IByUser
    {
        string CreatedBy { get; set; }

        string ModifiedBy { get; set; }
    }
}