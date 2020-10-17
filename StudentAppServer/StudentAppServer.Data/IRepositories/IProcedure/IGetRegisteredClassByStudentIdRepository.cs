using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories.IProcedure
{
    public interface IGetRegisteredClassByStudentIdRepository
    {
        Task<List<GetRegisteredClassByStudentId>> GetRegisteredClassByStudentId(string studentId, string semester);
    }
}