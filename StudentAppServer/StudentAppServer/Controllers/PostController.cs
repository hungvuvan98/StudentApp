﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    [AllowAnonymous]
    public class PostController:ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        public PostController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        [HttpGet("GetByCategory/{categoryId}")]
        public ActionResult<List<Post>> GetByCategory(string categoryId)
        => _unitOfWork.Posts.Find(x => x.PostCategoryId == categoryId).ToList();

    }
}