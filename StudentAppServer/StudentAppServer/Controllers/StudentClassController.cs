using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
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

        [Authorize(Roles="Student")]
        [HttpGet]      
        [Route("GetListStudent/{studentId}")]
        public  ActionResult<List<Student>>  GetListStudent(string studentId){

            var student =  _unitOfWork.Students.GetById(studentId);
            var listStudent =  _unitOfWork.Students.Find(x=>x.StudentClassId==student.StudentClassId).ToList();
            return listStudent ;
        }
    }
}