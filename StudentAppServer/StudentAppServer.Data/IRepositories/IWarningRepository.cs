using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.IRepositories
{
    public interface IWarningRepository : IRepository<Warn>
    {
    }
}