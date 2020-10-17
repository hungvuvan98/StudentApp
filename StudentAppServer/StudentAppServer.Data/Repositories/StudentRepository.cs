using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;
using StudentAppServer.Data.Procedure;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Repositories
{
    public class StudentRepository : Repository<Student>, IStudentRepository
    {
        private AppDbContext _appContext => (AppDbContext)_context;

        public StudentRepository(AppDbContext context) : base(context)
        {
        }
    }
}