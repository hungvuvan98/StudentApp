using Microsoft.AspNetCore.Mvc;
using StudentAppServer.Data.Infrastructure;
using StudentAppServer.Data.Procedure;
using StudentAppServer.Models.ListClass;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace StudentAppServer.Controllers
{
    public class ClassController : ApiControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public ClassController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
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

        [HttpGet(nameof(GetRegisteredClassByStudentId))]
        public async Task<List<GetRegisteredClassByStudentId>> GetRegisteredClassByStudentId(string studentId, string semester)
        => await _unitOfWork.GetRegisteredClassByStudentIds.GetRegisteredClassByStudentId(studentId, semester);
    }
}