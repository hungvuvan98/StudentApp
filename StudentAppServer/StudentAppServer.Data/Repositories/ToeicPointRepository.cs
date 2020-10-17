using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;

namespace StudentAppServer.Data.Repositories
{
    public class ToeicPointRepository : Repository<ToeicPoint>, IToeicPointRepository
    {
        public ToeicPointRepository(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;
    }
}