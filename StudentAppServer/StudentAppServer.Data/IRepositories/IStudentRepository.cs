using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories
{
    public interface IStudentRepository : IRepository<Student>
    {
    }
}