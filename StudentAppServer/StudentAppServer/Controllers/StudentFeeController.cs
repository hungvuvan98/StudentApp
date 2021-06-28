using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Infrastructure.Extensions;
using StudentAppServer.Models.Students;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    [ApiController]
    [Route("StudentFee")]
    public class StudentFeeController : ControllerBase
    {
        private readonly IUnitOfWork unitOfWork;

        public StudentFeeController(IUnitOfWork unitOfWork)
        {
            this.unitOfWork = unitOfWork;
        }

        [HttpGet("{studentId}")]
        public async Task<ActionResult<StudentFeeDtos>> GetStudentFee(string studentId)
        {
            var semester = this.unitOfWork.Semesters.GetAll().Last();
            var student = this.unitOfWork.Students.GetById(studentId);
            var department = this.unitOfWork.Departments.Find(x => x.DepartmentId == student.DepartmentId).FirstOrDefault();
            var fee = this.unitOfWork.TuitionFees.Find(x => x.Semester == semester.Id && x.DepartmentId == department.DepartmentId).FirstOrDefault().Fee;
            var registeredClass = await this.unitOfWork.GetRegisteredClassByStudentIds.GetRegisteredClassByStudentId(studentId, semester.Id);
            var studentFeeDtos = new List<StudentFeeDtos>();

            foreach (var item in registeredClass)
            {
                studentFeeDtos.Add(item.AsStudentFeeDto(fee));
            }
            return Ok(studentFeeDtos);
        }
    }
}