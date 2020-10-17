using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    //[Authorize]
    public class StudentClassController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public StudentClassController(IUnitOfWork unitOfWork)
        => _unitOfWork = unitOfWork;

        [HttpGet]
        [Route(nameof(GetClassName))]
        public async Task<List<string>> GetClassName(string year, string dept_name)
        => await _unitOfWork.StudentClasses.GetClassName(year, dept_name);

        [HttpGet]
        [Route(nameof(GetClassNameByStudent))]
        public ActionResult<string> GetClassNameByStudent(string studentId)
        {
            var student = _unitOfWork.Students.GetById(studentId);
            var studentClassName = _unitOfWork.StudentClasses.GetSingleOrDefault(x => x.Id == student.StudentClassId).Name;
            return studentClassName.ToString();
        }
    }
}