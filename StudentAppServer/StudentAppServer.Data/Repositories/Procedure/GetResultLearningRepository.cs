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
    public class GetResultLearningRepository : Repository<GetResultLearning>, IGetResultLearningRepository
    {
        public GetResultLearningRepository(AppDbContext context) : base(context)
        {
        }

        private AppDbContext _appContext => (AppDbContext)_context;

        public async Task<List<GetResultLearning>> GetResultLearning(string id)
        {
            var para = new SqlParameter("@id", id);

            var result = await _appContext.GetResultLearnings
                                        .FromSqlRaw("EXEC sp_result_learning @id", para)
                                        .ToListAsync();

            return result;
        }
    }
}