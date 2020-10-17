using Microsoft.Data.SqlClient;
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
    public class GetStudentInfoRepository : Repository<GetStudentInfor>, IGetStudentInfoRepository
    {
        public GetStudentInfoRepository(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;

        public async Task<List<GetStudentInfor>> GetStudentInfor(string id)
        {
            var para = new SqlParameter("@id", id);

            var student = await _appContext.GetStudentInfors
                                        .FromSqlRaw("EXEC dbo.SP_GetStudentInfor @id", para)
                                        .ToListAsync();
            return student;
        }
    }
}