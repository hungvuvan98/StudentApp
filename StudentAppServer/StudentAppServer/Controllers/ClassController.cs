using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using StudentAppServer.Infrastructure.Services;
using StudentAppServer.Models.ListClass;
using System.Collections.Generic;
using System.Linq;
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
        public async Task<ActionResult<GetListClass>> GetClassBySecId(string secId, string semester)
        {
          var result= await _unitOfWork.GetListClasses.GetListClassBySecId(secId, semester);
            if (result == null)
                return NotFound($"Không tồn tại mã lớp {secId} trong học kì {semester}");
          return result;
        }
        

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

        [HttpPost]
        [Route(nameof(CheckDuplicateTime))]
        public ActionResult<string> CheckDuplicateTime(List<GetRegisteredClassByStudentId> listClass)
        {
            var section = _unitOfWork.Sections.Find(x => x.SecId == listClass.Last().SecId).FirstOrDefault();
            listClass.Remove(listClass.Last());
            foreach(var item in listClass)
            {
                var temp = _unitOfWork.Sections.Find(x => x.SecId == item.SecId).FirstOrDefault();
                if (section.TimeSlotId == temp.TimeSlotId && section.Day == temp.Day)
                    return temp.SecId;
            }
            return "1";
        }
    }
}