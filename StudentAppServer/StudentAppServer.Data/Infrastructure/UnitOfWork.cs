using StudentAppServer.Data.IRepositories;
using StudentAppServer.Data.IRepositories.IProcedure;
using StudentAppServer.Data.Repositories;
using StudentAppServer.Data.Repositories.Procedure;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Infrastructure
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly AppDbContext _context;
        private IAppGroupRepository _appGroup;
        private IClassroomRepository _classRoom;
        private ICourseRepository _courses;
        private IDepartmentRepository _department;
        private IFeedbackRepository _feedback;
        private IInstructorDepartmentRepository _instructorDepartment;
        private IInstructorNotificationRepository _instructorNotification;
        private IInstructorRepository _instructor;
        private ILanguageRepository _language;
        private INotificationRepository _notification;
        private IPostRepository _post;
        private IPostCategoryRepository _postcategory;
        private IPrereqRepository _prereq;
        private ISectionRepository _section;
        private IStudentClassRepository _studentClass;
        private IStudentNotificationRepository _studentNotification;
        private IStudentRepository _student;
        private ITakeRepository _take;
        private ITeachRepository _teach;
        private ITimeSlotRepository _timeSlot;
        private IToeicPointRepository _toeicPoint;
        private IWarningRepository _warn;
        private IGetListClassRepository _getListClass;
        private IGetRegisteredClassByStudentIdRepository _getRegisteredClassByStudentId;
        private IGetResultLearningRepository _getResultLearning;
        private IGetStudentInfoRepository _getStudentInfo;
        private IGetStudentRepository _getStudents;
        private ISemesterRepository _semester;

        public UnitOfWork(AppDbContext context)
        {
            _context = context;
        }

        public IAppGroupRepository AppGroups
        {
            get
            {
                if (_appGroup == null)
                    _appGroup = new AppGroupRepository(_context);

                return _appGroup;
            }
        }

        public IClassroomRepository Classrooms
        {
            get
            {
                if (_classRoom == null)
                    _classRoom = new ClassroomRepository(_context);

                return _classRoom;
            }
        }

        public ICourseRepository Courses
        {
            get
            {
                if (_courses == null)
                    _courses = new CourseRepository(_context);

                return _courses;
            }
        }

        public ISemesterRepository Semesters
        {
            get
            {
                if (_semester == null)
                    _semester = new SemesterRepository(_context);

                return _semester;
            }
        }

        public IDepartmentRepository Departments
        {
            get
            {
                if (_department == null)
                    _department = new DepartmentRepository(_context);

                return _department;
            }
        }

        public IFeedbackRepository Feedbacks
        {
            get
            {
                if (_feedback == null)
                    _feedback = new FeedbackRepository(_context);

                return _feedback;
            }
        }

        public IInstructorDepartmentRepository InstructorDepartments
        {
            get
            {
                if (_instructorDepartment == null)
                    _instructorDepartment = new InstructorDepartmentRepository(_context);

                return _instructorDepartment;
            }
        }

        public IInstructorNotificationRepository InstructorNotifications
        {
            get
            {
                if (_instructorNotification == null)
                    _instructorNotification = new InstructorNotificationRepository_(_context);

                return _instructorNotification;
            }
        }

        public IInstructorRepository Instructors
        {
            get
            {
                if (_instructor == null)
                    _instructor = new InstructorRepository(_context);

                return _instructor;
            }
        }

        public ILanguageRepository Languages
        {
            get
            {
                if (_language == null)
                    _language = new LanguageRepository(_context);

                return _language;
            }
        }

        public INotificationRepository Notifications
        {
            get
            {
                if (_notification == null)
                    _notification = new NotificationRepository(_context);

                return _notification;
            }
        }

        public IPostCategoryRepository PostCategories
        {
            get
            {
                if (_postcategory == null)
                    _postcategory = new PostCategoryRepository(_context);

                return _postcategory;
            }
        }

        public IPostRepository Posts
        {
            get
            {
                if (_post == null)
                    _post = new PostRepository(_context);

                return _post;
            }
        }

        public IPrereqRepository Prereqs
        {
            get
            {
                if (_prereq == null)
                    _prereq = new PrereqRepository(_context);

                return _prereq;
            }
        }

        public ISectionRepository Sections
        {
            get
            {
                if (_section == null)
                    _section = new SectionRepository(_context);

                return _section;
            }
        }

        public IStudentClassRepository StudentClasses
        {
            get
            {
                if (_studentClass == null)
                    _studentClass = new StudentClassRepository(_context);

                return _studentClass;
            }
        }

        public IStudentNotificationRepository StudentNotifications
        {
            get
            {
                if (_studentNotification == null)
                    _studentNotification = new StudentNotificationRepository(_context);

                return _studentNotification;
            }
        }

        public IStudentRepository Students
        {
            get
            {
                if (_student == null)
                    _student = new StudentRepository(_context);

                return _student;
            }
        }

        public ITakeRepository Takes
        {
            get
            {
                if (_take == null)
                    _take = new TakeRepository(_context);

                return _take;
            }
        }

        public ITeachRepository Teachs
        {
            get
            {
                if (_teach == null)
                    _teach = new TeachRepository(_context);

                return _teach;
            }
        }

        public ITimeSlotRepository TimeSlots
        {
            get
            {
                if (_timeSlot == null)
                    _timeSlot = new TimeSlotRepository(_context);

                return _timeSlot;
            }
        }

        public IToeicPointRepository ToeicPoints
        {
            get
            {
                if (_toeicPoint == null)
                    _toeicPoint = new ToeicPointRepository(_context);

                return _toeicPoint;
            }
        }

        public IWarningRepository Warns
        {
            get
            {
                if (_warn == null)
                    _warn = new WarningRepository(_context);

                return _warn;
            }
        }

        public IGetListClassRepository GetListClasses
        {
            get
            {
                if (_getListClass == null)
                    _getListClass = new GetListClassRepository(_context);

                return _getListClass;
            }
        }

        public IGetRegisteredClassByStudentIdRepository GetRegisteredClassByStudentIds
        {
            get
            {
                if (_getRegisteredClassByStudentId == null)
                    _getRegisteredClassByStudentId = new GetRegisteredClassByStudentIdRepository(_context);

                return _getRegisteredClassByStudentId;
            }
        }

        public IGetResultLearningRepository GetResultLearnings
        {
            get
            {
                if (_getResultLearning == null)
                    _getResultLearning = new GetResultLearningRepository(_context);

                return _getResultLearning;
            }
        }

        public IGetStudentInfoRepository GetStudentInfos
        {
            get
            {
                if (_getStudentInfo == null)
                    _getStudentInfo = new GetStudentInfoRepository(_context);

                return _getStudentInfo;
            }
        }

        public IGetStudentRepository GetStudents
        {
            get
            {
                if (_getStudents == null)
                    _getStudents = new GetStudentRepository(_context);

                return _getStudents;
            }
        }

        public async Task<int> SaveChanges()
        => await _context.SaveChangesAsync();
    }
}