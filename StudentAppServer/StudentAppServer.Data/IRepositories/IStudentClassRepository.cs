using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories
{
    public interface IStudentClassRepository : IRepository<StudentClass>
    {
        Task<List<string>> GetClassName(string year, string dept_name);
    }
}