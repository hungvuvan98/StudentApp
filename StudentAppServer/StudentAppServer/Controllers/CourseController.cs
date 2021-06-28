using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;

namespace StudentAppServer.Controllers
{
    [Route("course")]
    [ApiController]
    public class CourseController : ControllerBase
    {
        private readonly IUnitOfWork unitOfWork;

        public CourseController(IUnitOfWork unitOfWork)
        {
            this.unitOfWork = unitOfWork;
        }

        [HttpGet("{departmentId}")]
        public ActionResult<Course> Filter(string departmentId)
        {
            var courses= this.unitOfWork.Courses.Find(x => x.DepartmentId == departmentId);
            return Ok(courses);
        }
    }
}