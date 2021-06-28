using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Infrastructure.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    //admin role
    public class SemesterController : ApiControllerBase
    {
        private IUnitOfWork _unitOfWork;

        public SemesterController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        [HttpGet]
        [Route("insert")]
        public async Task<int> Insert(string id)
        {
            var entity = new Semester()
            {
                Id = id
            };
            _unitOfWork.Semesters.Add(entity);
            try
            {
                await _unitOfWork.SaveChanges();
                return 1;
            }
            catch
            {
                return 0;
            }
        }

        [HttpDelete]
        [Route(nameof(Delete))]
        public async void Delete(string id)
        {
            _unitOfWork.Semesters.Remove(new Semester() { Id = id });
            await _unitOfWork.SaveChanges();
        }

        [HttpGet(nameof(GetNewest))]
        public string GetNewest()
        => _unitOfWork.Semesters.GetAll().ToList().Last().Id;

        [AllowAnonymous]
        [HttpGet("{studentId}")]
        public ActionResult<List<string>> GetAllSemestersOfStudent(string studentId)
        {
            var student = _unitOfWork.Students.GetById(studentId);
            var createdYear = Convert.ToInt32(student.CreatedYear);
            var semesters = _unitOfWork.Semesters.GetAll().ToList();
            var result = new List<string>();
            foreach (var item in semesters)
            {
                if (Convert.ToInt32(item.Id.Substring(0, 4)) >= createdYear)
                    result.Add(item.Id);

            }
            return Ok(result);
        }
    }
}