using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;
using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Repositories
{
    public class WarningRepository : Repository<Warn>, IWarningRepository
    {
        public WarningRepository(AppDbContext context) : base(context)
        {
        }
    }
}