using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories.IProcedure;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Repositories.Procedure
{
    public class GetRegisteredClassByStudentIdRepository : IGetRegisteredClassByStudentIdRepository
    {
        private AppDbContext _appContext;

        public GetRegisteredClassByStudentIdRepository(AppDbContext context)
        {
            _appContext = context;
        }

        public async Task<List<GetRegisteredClassByStudentId>> GetRegisteredClassByStudentId(string studentId, string semester)
        {
            SqlParameter[] param =
            {
                new SqlParameter("@studentId",studentId),
                new SqlParameter("@semester",semester)
            };

            var result = await _appContext.GetRegisteredClassByStudentIds
                                    .FromSqlRaw("EXEC sp_GetListClassRegisteredByStudentId @studentId,@semester", param)
                                    .ToListAsync();
            return result;
        }
    }
}