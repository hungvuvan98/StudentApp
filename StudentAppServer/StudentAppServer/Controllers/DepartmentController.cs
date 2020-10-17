﻿using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using System.Collections.Generic;

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

        [HttpGet(nameof(GetById))]
        public string GetById(string id)
         => _unitOfWork.Departments.GetById(id).Name;
    }
}