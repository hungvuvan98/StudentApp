using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BotDetect.Web;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
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

        private readonly ICurrentUserService _currentUserService;

        private readonly ReCaptchaService _reCaptchaService;

        public AccountController(IUnitOfWork unitOfWork, JwtService jwtService,
                                  ICurrentUserService currentUserService, ReCaptchaService reCaptchaService)
        {
            _unitOfWork = unitOfWork;
            _jwtService = jwtService;
            _currentUserService = currentUserService;
            _reCaptchaService = reCaptchaService;
        }

        //[HttpPost]
        //[AllowAnonymous]
        //[Route(nameof(Login))]
        //public ActionResult<LoginResponseModel> Login(LoginModel model)
        //{
        //    var student = _unitOfWork.Students
        //                              .GetSingleOrDefault(x => x.Id == model.Id
        //                                                  && x.Password == model.Password);
        //    if (student == null)
        //    {
        //        return NotFound("Account does not exist! ");
        //    }
        //    var appGroup = _unitOfWork.AppGroups.GetById(student.GroupId);
        //    var token = _jwtService.GenerateToken(student.Id, student.Name, appGroup.Role);
        //    return token;
        //}

        [HttpPost]
        [Route(nameof(ChangePassword))]
        public async Task<ActionResult<int>> ChangePassword(ChangePasswordModel model)
        {
            var currentId = _currentUserService.GetId();
            var student = _unitOfWork.Students.Find(x => x.Id == currentId && x.Password == model.OldPassword).FirstOrDefault();

            if (student == null) return NotFound("Sai mat khau");

            student.Password = model.NewPassword;
            _unitOfWork.Students.Update(student);
            await _unitOfWork.SaveChanges();
            return 1;
        }

        [HttpGet]
        [Route(nameof(GetUserId))]
        public string GetUserId()
        {
            var id = _currentUserService.GetId();
            return id;
        }

        [HttpPost]
        [AllowAnonymous]
        [Route(nameof(Login))]
        public ActionResult<LoginResponseModel> Login(LoginModel model)
        {
            if (String.IsNullOrEmpty(model.Recaptcha))
            {
                return BadRequest("Recaptcha code is incorrect");
            }

            bool resultRecaptcha = _reCaptchaService.IsValidCaptcha(model.Recaptcha);

            if (resultRecaptcha)
            {
                var student = _unitOfWork.Students
                                      .GetSingleOrDefault(x => x.Id == model.Id
                                                          && x.Password == model.Password);
                if (student == null)
                {
                    return NotFound("Account does not exist! ");
                }
                var appGroup = _unitOfWork.AppGroups.GetById(student.GroupId);

                var token = _jwtService.GenerateToken(student.Id, student.Name, appGroup.Role);

                return token;
            }

            return NotFound("Account does not exist! ");
        }

    }
}