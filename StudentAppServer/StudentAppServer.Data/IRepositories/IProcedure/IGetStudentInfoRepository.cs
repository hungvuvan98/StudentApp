using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories.IProcedure
{
    public interface IGetStudentInfoRepository : IRepository<GetStudentInfor>
    {
        Task<List<GetStudentInfor>> GetStudentInfor(string id);
    }
}