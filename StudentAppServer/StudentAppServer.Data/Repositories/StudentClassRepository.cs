using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Repositories
{
    public class StudentClassRepository : Repository<StudentClass>, IStudentClassRepository
    {
        private AppDbContext _appContext => (AppDbContext)_context;

        public StudentClassRepository(AppDbContext context) : base(context)
        {
        }

        public async Task<List<string>> GetClassName(string year, string dept_name)
        => await _appContext.StudentClasses
                            .Where(x => x.Department.Name == dept_name && x.Year == year)
                            .Select(p => p.Name)
                            .ToListAsync();
    }
}