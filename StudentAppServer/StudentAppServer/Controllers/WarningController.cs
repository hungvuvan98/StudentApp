using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using System.Linq;

namespace StudentAppServer.Controllers
{
    public class WarningController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public WarningController(IUnitOfWork unitOfWork)
        => _unitOfWork = unitOfWork;

        [HttpGet(nameof(GetLevel))]
        public int GetLevel(string studentId)
        {
            var list = _unitOfWork.Warns.Find(x => x.StudentId == studentId).ToList();
            if (list.Count == 0)
            {
                return -1;
            }
            var level = list.ElementAt(list.Count - 1).Level;
            return level;
        }

        [HttpGet]
        [Route(nameof(Test))]
        public string Test()
        => _unitOfWork.GetStudents.Test();
    }
}