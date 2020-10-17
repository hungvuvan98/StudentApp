using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;
using System;
using System.Collections.Generic;
using System.Text;

namespace StudentAppServer.Data.Repositories
{
    public class SemesterRepository : Repository<Semester>, ISemesterRepository
    {
        public SemesterRepository(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;
    }
}