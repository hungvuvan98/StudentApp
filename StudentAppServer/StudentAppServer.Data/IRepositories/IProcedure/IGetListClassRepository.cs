using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories.IProcedure
{
    public interface IGetListClassRepository
    {
        Task<List<GetListClass>> GetListClass(string semetser);

        Task<int> TotalRegistered(string secId);

        Task<GetListClass> GetListClassBySecId(string secId, string semester);
    }
}