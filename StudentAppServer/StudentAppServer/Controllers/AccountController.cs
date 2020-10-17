﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Infrastructure.Services;
using StudentAppServer.Models;
using StudentAppServer.Models.Students;

namespace StudentAppServer.Controllers
{
    public class AccountController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        private readonly JwtService _jwtService;

        public AccountController(IUnitOfWork unitOfWork, JwtService jwtService)
        {
            _unitOfWork = unitOfWork;
            _jwtService = jwtService;
        }

        [HttpPost]
        [Route(nameof(Login))]
        public ActionResult<LoginResponseModel> Login(LoginModel model)
        {
            var student = _unitOfWork.Students
                                      .GetSingleOrDefault(x => x.Id == model.Id
                                                          && x.Password == model.Password);
            if (student == null)
            {
                //1
                return NotFound("Account does not exist! ");
            }
            var appGroup = _unitOfWork.AppGroups.GetById(student.GroupId);
            var token = _jwtService.GenerateToken(student.Id, student.Name, appGroup.Role);
            return token;
        }
    }
}