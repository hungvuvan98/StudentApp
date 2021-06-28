using StudentAppServer.Data.IRepositories;
using StudentAppServer.Data.IRepositories.IProcedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Infrastructure
{
    public interface IUnitOfWork
    {
        IAppGroupRepository AppGroups { get; }
        IClassroomRepository Classrooms { get; }
        ICourseRepository Courses { get; }
        IDepartmentRepository Departments { get; }
        IFeedbackRepository Feedbacks { get; }
        IInstructorDepartmentRepository InstructorDepartments { get; }
        IInstructorNotificationRepository InstructorNotifications { get; }
        IInstructorRepository Instructors { get; }
        ILanguageRepository Languages { get; }
        INotificationRepository Notifications { get; }
        IPostCategoryRepository PostCategories { get; }
        IPostRepository Posts { get; }
        IPrereqRepository Prereqs { get; }
        ISectionRepository Sections { get; }
        IStudentClassRepository StudentClasses { get; }
        IStudentNotificationRepository StudentNotifications { get; }
        IStudentRepository Students { get; }
        ITakeRepository Takes { get; }
        ITeachRepository Teachs { get; }
        ITimeSlotRepository TimeSlots { get; }
        IToeicPointRepository ToeicPoints { get; }
        IWarningRepository Warns { get; }
        IGetListClassRepository GetListClasses { get; }
        IGetRegisteredClassByStudentIdRepository GetRegisteredClassByStudentIds { get; }
        IGetResultLearningRepository GetResultLearnings { get; }
        IGetStudentInfoRepository GetStudentInfos { get; }
        IGetStudentRepository GetStudents { get; }
        ISemesterRepository Semesters { get; }
        ITuitionFeeRepository TuitionFees { get; }
        Task<int> SaveChanges();
    }
}