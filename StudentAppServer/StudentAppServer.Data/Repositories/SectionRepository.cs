using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Repositories
{
    public class SectionRepository : Repository<Section>, ISectionRepository
    {
        private AppDbContext _appContext => (AppDbContext)_context;

        public SectionRepository(AppDbContext context) : base(context)
        {
        }
    }
}