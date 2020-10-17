using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories.IProcedure
{
    public interface IGetResultLearningRepository : IRepository<GetResultLearning>
    {
        Task<List<GetResultLearning>> GetResultLearning(string id);
    }
}