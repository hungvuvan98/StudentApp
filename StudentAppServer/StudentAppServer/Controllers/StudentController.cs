using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Base;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using StudentAppServer.Infrastructure.Services;
using StudentAppServer.Models;
using StudentAppServer.Models.ListClass;
using StudentAppServer.Models.Students;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    [Authorize]
    public class StudentController : ApiControllerBase
    {
        private readonly ICurrentUserService _currentUserService;

        private readonly IUnitOfWork _unitOfWork;

        public StudentController(ICurrentUserService currentUserService,
                               IUnitOfWork unitOfWork)
        {
            _currentUserService = currentUserService;
            _unitOfWork = unitOfWork;
        }

        //  [Authorize(Roles = "Admin")]
        [HttpPost]
        [Route("create")]
        public async Task<IActionResult> Create(CreateStudentModel model)
        {
            var departmentId = _unitOfWork.Departments
                                          .GetSingleOrDefault(x => x.Name == model.DepartmentName)
                                          .DepartmentId;
            var studentClassId = _unitOfWork.StudentClasses
                                            .GetSingleOrDefault(x => x.Name == model.StudentClassName
                                                                 && x.DepartmentId == departmentId)
                                            .Id;
            var student = new Student()
            {
                Id = model.Id,
                Name = model.Name,
                Password = model.Password,
                Email = model.Email,
                BirthDay = model.BirthDay,
                Address = model.Address,
                CardId = model.CardId,
                Birthplace = model.Birthplace,
                Avatar = model.Avatar,
                CreatedYear = model.CreatedYear,
                Status = Status.Active,
                GroupId = "2",
                DepartmentId = departmentId,
                StudentClassId = studentClassId
            };
            _unitOfWork.Students.Add(student);
            await _unitOfWork.SaveChanges();

            return Created(nameof(Created), "ok");
        }

        // [Authorize(Roles = "Admin")]
        [HttpDelete]
        [Route(nameof(Delete))]
        public async Task<IActionResult> Delete(string id)
        {
            var studen = _unitOfWork.Students.GetById(id);
            if (studen == null) return BadRequest("Khong co ma sinh vien");
            _unitOfWork.Students.Remove(id);
            await _unitOfWork.SaveChanges();

            return Ok("Deleted!");
        }

        [HttpPut]
        [Route(nameof(Update))]
        public async Task<IActionResult> Update(Student model)
        {
            _unitOfWork.Students.Update(model);
            await _unitOfWork.SaveChanges();
            return Ok("Updated!");
        }

        [HttpGet]
        [Route(nameof(GetAll))]
        public async Task<List<GetStudent>> GetAll()
        => await _unitOfWork.GetStudents.GetStudent();

        [HttpGet("Filter")]
        public async Task<List<GetStudent>> FilterStudent(string year = null, string dept = null, string className = null)
        {
            var temp = await _unitOfWork.GetStudents.GetStudent();
            var student = new List<GetStudent>();
            if (year != null && dept == null)
            {
                student = temp.Where(x => x.CreatedYear == year)
                                            .ToList();
            }
            if (year != null && dept != null)
            {
                student = temp.Where(x => x.CreatedYear == year && x.DepartmentName == dept)
                                          .ToList();
            }
            if (year != null && dept != null && className != null)
            {
                student = temp.Where(x => x.CreatedYear == year
                                                        && x.DepartmentName == dept
                                                        && x.StudentClassName == className)
                                         .ToList();
            }
            return student;
        }

        [HttpGet("getscore/{id}")]
        public async Task<List<GetStudentInfor>> GetTableScore(string id)
         => await _unitOfWork.GetStudentInfos.GetStudentInfor(id);

        [HttpGet("result/{id}")]
        public async Task<List<GetResultLearning>> GetResultLearning(string id)
        => await _unitOfWork.GetResultLearnings.GetResultLearning(id);

        [HttpGet]
        [Route("info/{id}")]
        public Student GetById(string id)
        => _unitOfWork.Students.GetById(id);

        [HttpPost]
        [Route(nameof(SendRegister))]
        public async Task<List<int>> SendRegister(List<SendRegisterModel> listModel)
        {
            int countAdd = 0, countDel = 0;
            var listAdd = new List<Take>();
            var listDelete = new List<Take>();
            // var filter = _unitOfWork.Takes.Find(x => x.Id == listModel.ElementAt(0).Id);
            var listClass = await _unitOfWork.GetRegisteredClassByStudentIds
                             .GetRegisteredClassByStudentId(listModel.ElementAt(0).Id, listModel.ElementAt(0).Semester);

            foreach (var item in listClass)
            {
                var take = new Take()
                {
                    Id = item.Id,
                    SecId = item.SecId
                };
                bool checkDel = listModel.Any(x => x.SecId == take.SecId);
                if (!checkDel)
                {
                    listDelete.Add(take);
                    countDel++;
                }
            }

            foreach (var item in listModel)
            {
                var take = new Take()
                {
                    Id = listModel.ElementAt(0).Id,
                    SecId = item.SecId
                };
                bool checkAdd = listClass.Any(x => x.SecId == take.SecId);
                if (!checkAdd)
                {
                    listAdd.Add(take);
                    countAdd++;
                }
            }
            _unitOfWork.Takes.RemoveRange(listDelete);
            _unitOfWork.Takes.AddRange(listAdd);

            await _unitOfWork.SaveChanges();

            return new List<int>() {
                countAdd,countDel
            };
        }
    }
}