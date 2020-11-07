using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Infrastructure.Services;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    public class NotificationController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;

        public NotificationController(IUnitOfWork unitOfWork, ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
        }

        [HttpGet]
        [Route(nameof(GetAll))]
        [Authorize(Roles = "Student")]
        public async Task<List<Notification>> GetAll()
        {
            var id = _currentUserService.GetId();
            var listNotice = new List<Notification>();
            var listNotiId = await _unitOfWork.StudentNotifications.GetByStudentId(id);

            foreach (var item in listNotiId)
            {
                var notice = _unitOfWork.Notifications.GetById(item);
                listNotice.Add(notice);
            }
            return listNotice;
        }
    }
}