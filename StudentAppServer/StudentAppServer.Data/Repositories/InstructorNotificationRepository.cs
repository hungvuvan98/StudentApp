using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;

namespace StudentAppServer.Data.Repositories
{
    public class InstructorNotificationRepository_ : Repository<InstructorNotification>, IInstructorNotificationRepository
    {
        public InstructorNotificationRepository_(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;
    }
}