using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Base;
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
    public class GetListClassRepository : IGetListClassRepository
    {
        private AppDbContext _appContext;

        public GetListClassRepository(AppDbContext context)
        {
            _appContext = context;
        }

        public async Task<List<GetListClass>> GetListClass(string semester)
       => await _appContext.GetListClasses.FromSqlRaw("EXEC dbo.sp_GetListClass @semester",
                                                    new SqlParameter("@semester", semester))
                                           .ToListAsync();

        public async Task<int> TotalRegistered(string secId)
        {
            var para = new SqlParameter("@secId", secId);
            var result = await _appContext.GetRegistereds.FromSqlRaw("EXEC dbo.sp_SoLuongDaDK @secId", para)
                                                 .ToListAsync();
            var count = result.ElementAt(0).Count;
            return count;
        }

        public async Task<GetListClass> GetListClassBySecId(string secId, string semester)
        {
            var list = await _appContext.GetListClasses.FromSqlRaw("EXEC dbo.sp_GetListClass @semester",
                                                                    new SqlParameter("@semester", semester))
                                                        .ToListAsync();

            return list.Where(x => x.SecId == secId).FirstOrDefault();
        }
    }
}