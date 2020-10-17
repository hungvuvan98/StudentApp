using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories.IProcedure;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Repositories.Procedure
{
    public class GetStudentRepository : Repository<GetStudent>, IGetStudentRepository
    {
        public GetStudentRepository(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;

        public async Task<List<GetStudent>> GetStudent()
       => await _appContext.GetStudents.FromSqlRaw("EXEC dbo.SP_GetStudent")
                                 .ToListAsync();

        public string Test()
        {
            var test = from s in _appContext.Students
                       join t in _appContext.Takes on s.Id equals t.Id
                       where s.Id == "20160024"
                       select new { t.Id, s.Name };

            var list = test.First();
            return list.Name;
        }
    }
}