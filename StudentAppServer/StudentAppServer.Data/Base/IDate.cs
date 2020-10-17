using System;

namespace StudentAppServer.Data.Base
{
    public interface IDate
    {
        DateTime? CreatedOn { get; set; }

        DateTime? ModifiedOn { get; set; }
    }
}