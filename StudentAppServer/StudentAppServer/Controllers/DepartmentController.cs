using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using System.Collections.Generic;
using System.Linq;

namespace StudentAppServer.Controllers
{
    public class DepartmentController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public DepartmentController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        [HttpGet]
        [AllowAnonymous]
        public ActionResult<Department> GetDepartments()
        {
            var departments = _unitOfWork.Departments.GetAll();
            return Ok(departments);
        }

        [HttpGet]
        [Route("getname")]
        public List<string> GetDepartmentName()
        {
            var lisdept = _unitOfWork.Departments.GetAll();
            var listDeptName = new List<string>();
            foreach (var item in lisdept)
            {
                listDeptName.Add(item.Name);
            }
            return listDeptName;
        }

        [HttpGet("getbyid/{id}")]
        public ActionResult<string> GetById(string id)
        {
            return Ok(_unitOfWork.Departments.GetById(id).Name);
        }
    }
}