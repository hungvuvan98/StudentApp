using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.IRepositories;

namespace StudentAppServer.Data.Repositories
{
    public class TuitionFeerepository : Repository<TuitionFee>, ITuitionFeeRepository
    {
        public TuitionFeerepository(DbContext context) : base(context)
        {
        }
    }
}