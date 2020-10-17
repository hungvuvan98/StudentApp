using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Infrastructure;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    public class NotificationController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public NotificationController(IUnitOfWork unitOfWork)
        => _unitOfWork = unitOfWork;

        [HttpGet]
        [Route("getbystudent/{studentId}")]
        public async Task<List<Notification>> GetByStudent(string studentId)
        {
            var listNotice = new List<Notification>();
            var listNotiId = await _unitOfWork.StudentNotifications.GetByStudentId(studentId);

            foreach (var item in listNotiId)
            {
                var notice = _unitOfWork.Notifications.GetById(item);
                listNotice.Add(notice);
            }
            return listNotice;
        }
    }
}