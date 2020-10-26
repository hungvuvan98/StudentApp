using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using StudentAppServer.Infrastructure.Services;
using StudentAppServer.Models.ListClass;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    public class ClassController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        private readonly ICurrentUserService _currentUserService;

        public ClassController(IUnitOfWork unitOfWork, ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
        }

        [HttpGet]
        [Route(nameof(GetAll))]
        public async Task<List<ListClassModel>> GetAll(string semester)
        {
            var listdetail = new List<ListClassModel>();
            var list = await _unitOfWork.GetListClasses.GetListClass(semester);

            foreach (var item in list)
            {
                var total = await _unitOfWork.GetListClasses.TotalRegistered(item.SecId);
                var detail = new ListClassModel()
                {
                    SecId = item.SecId,
                    Semester = item.Semester,
                    Status = item.Status,
                    Building = item.Building,
                    RoomNumber = item.RoomNumber,
                    StartHr = item.StartHr,
                    StartMin = item.StartMin,
                    EndHr = item.EndHr,
                    EndMin = item.EndMin,
                    Day = item.Day,
                    CourseId = item.CourseId,
                    Title = item.Title,
                    Capacity = item.Capacity,
                    Name = item.Name,
                    TotalRegistered = total,
                    Credit = item.Credit
                };
                listdetail.Add(detail);
            }

            return listdetail;
        }

        [HttpGet(nameof(GetClassBySecId))]
        public async Task<GetListClass> GetClassBySecId(string secId, string semester)
         => await _unitOfWork.GetListClasses.GetListClassBySecId(secId, semester);

        /// <summary>
        /// Get Registered Class of any student follow semester
        /// </summary>
        /// <returns>List registered class of student</returns>
        [HttpGet(nameof(GetRegisteredClassByStudentId))]
        public async Task<List<GetRegisteredClassByStudentId>> GetRegisteredClassByStudentId(string semester, string studentId = null)
        {
            if (studentId == null) // underfined
                studentId = _currentUserService.GetId();
            return await _unitOfWork.GetRegisteredClassByStudentIds.GetRegisteredClassByStudentId(studentId, semester);
        }
    }
}