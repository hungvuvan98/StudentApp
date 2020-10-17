using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Data.IRepositories
{
    public interface ISectionRepository : IRepository<Section>
    {
    }
}