using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;

namespace StudentAppServer.Data.Repositories
{
    public class PrereqRepository : Repository<Prereq>, IPrereqRepository
    {
        public PrereqRepository(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;
    }
}