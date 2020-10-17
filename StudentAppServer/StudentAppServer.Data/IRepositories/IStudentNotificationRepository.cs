using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories
{
    public interface IStudentNotificationRepository : IRepository<StudentNotification>
    {
        Task<List<string>> GetByStudentId(string Id);
    }
}