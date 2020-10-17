using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
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
    }
}