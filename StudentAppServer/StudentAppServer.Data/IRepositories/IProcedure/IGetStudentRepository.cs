using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories.IProcedure
{
    public interface IGetStudentRepository : IRepository<GetStudent>
    {
        Task<List<GetStudent>> GetStudent();

        string Test();
    }
}