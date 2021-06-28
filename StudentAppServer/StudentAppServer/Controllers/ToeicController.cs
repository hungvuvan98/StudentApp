using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Infrastructure.Services;
using StudentAppServer.Test;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    public class ToeicController:ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        public ToeicController(IUnitOfWork unitOfWork,ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
        }

        [HttpGet]
        [Route(nameof(Get))]
        public List<ToeicPoint> Get()
        {

            var userId = _currentUserService.GetId();
            var userName = _currentUserService.GetUserName();
            var result= _unitOfWork.ToeicPoints.Find(x => x.StudentId == userId).ToList();
            return result;
        }

        [HttpGet]
        [Route(nameof(CheckConditionToRegister))]
        public  int CheckConditionToRegister()
        {
            var userId = _currentUserService.GetId();
            var resultLearning = _unitOfWork.GetResultLearnings.GetResultLearning(userId).Result.Last();
            if (resultLearning == null)
            {
                return 24;
            }
            var toeic = _unitOfWork.ToeicPoints.Find(x => x.StudentId == userId).OrderByDescending(x => x.TotalPoint);

            int[] point = new int[4] { 300, 350, 400, 450 };
            string[] trinhDo = new string[4]
            {
                "Sinh Vien Nam 2",
                "Sinh Vien Nam 3",
                "Sinh Vien Nam 4",
                "Sinh Vien Nam 5"
            };
            for (int i = 0; i < 4; i++)
            {
                if (resultLearning.TrinhDo == trinhDo[i])
                {
                    foreach (var item in toeic)
                    {
                        double timeSpan = DateTime.Today.Subtract(Convert.ToDateTime(item.CreatedDate)).TotalDays;
                        if (item.TotalPoint > point[i] - 1 && timeSpan < 730)
                        {
                            switch (resultLearning.MucCC)
                            {
                                case 0: return 24;
                                case 1: return 18;
                                case 2: return 14;
                                case 3: return 0;
                            }
                        }
                        else return 14;
                    }
                }
            }

            return 24;

        }
    }
}
