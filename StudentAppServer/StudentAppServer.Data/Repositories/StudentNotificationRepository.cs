using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Repositories
{
    public class StudentNotificationRepository : Repository<StudentNotification>, IStudentNotificationRepository
    {
        public StudentNotificationRepository(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;

        public async Task<List<string>> GetByStudentId(string Id)
       => await _appContext.StudentNotifications.Where(x => x.StudentId == Id)
                                                   .Select(p => p.NotificationId)
                                                   .ToListAsync();
    }
}