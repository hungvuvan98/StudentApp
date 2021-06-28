using Microsoft.EntityFrameworkCore;
using StudentAppServer.Data.Entities;
using StudentAppServer.Data.Procedure;

namespace StudentAppServer.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext()
        {
        }

        public AppDbContext(DbContextOptions options) : base(options)
        {
        }

        public DbSet<Classroom> Classrooms { set; get; }
        public DbSet<Course> Courses { set; get; }
        public DbSet<Department> Departments { set; get; }
        public DbSet<Feedback> Feedbacks { set; get; }
        public DbSet<AppGroup> AppGroups { set; get; }
        public DbSet<Instructor> Instructors { set; get; }
        public DbSet<InstructorDepartment> InstructorDepartments { set; get; }
        public DbSet<InstructorNotification> InstructorNotifications { set; get; }
        public DbSet<Language> Languages { set; get; }
        public DbSet<Notification> Notifications { set; get; }
        public DbSet<Post> Posts { set; get; }
        public DbSet<PostCategory> PostCategories { set; get; }
        public DbSet<Prereq> Prereqs { set; get; }
        public DbSet<Section> Sections { set; get; }
        public DbSet<Student> Students { set; get; }
        public DbSet<StudentClass> StudentClasses { set; get; }
        public DbSet<StudentNotification> StudentNotifications { set; get; }
        public DbSet<Take> Takes { set; get; }
        public DbSet<Teach> Teaches { set; get; }
        public DbSet<TimeSlot> TimeSlots { set; get; }
        public DbSet<ToeicPoint> ToeicPoints { set; get; }
        public DbSet<Warn> Warns { get; set; }
        public DbSet<Semester> Semesters { set; get; }
        public DbSet<GetStudent> GetStudents { set; get; }
        public DbSet<GetStudentInfor> GetStudentInfors { set; get; }
        public DbSet<GetResultLearning> GetResultLearnings { set; get; }
        public DbSet<GetListClass> GetListClasses { set; get; }
        public DbSet<GetRegistered> GetRegistereds { set; get; }
        public DbSet<GetRegisteredClassByStudentId> GetRegisteredClassByStudentIds { set; get; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            #region Entity Config

            modelBuilder.Entity<AppGroup>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .HasName("PK__Appgroup");

                entity.ToTable("AppGroups");

                entity.Property(e => e.Id)
                    .HasColumnName("Id")
                    .HasMaxLength(20);

                entity.Property(e => e.Name)
                   .HasColumnName("Name")
                   .HasMaxLength(100);

                entity.Property(e => e.Role)
                  .HasColumnName("Role")
                  .HasMaxLength(50);
            });

            modelBuilder.Entity<Classroom>(entity =>
            {
                entity.HasKey(e => new { e.Building, e.RoomNumber })
                    .HasName("PK__classroom");

                entity.ToTable("Classrooms");

                entity.Property(e => e.Building)
                    .HasColumnName("Building")
                    .HasMaxLength(20);

                entity.Property(e => e.RoomNumber)
                    .HasColumnName("RoomNumber")
                    .HasMaxLength(20);
            });

            modelBuilder.Entity<Course>(entity =>
            {
                entity.ToTable("Courses");

                entity.Property(e => e.CourseId)
                    .HasColumnName("CourseId")
                    .HasMaxLength(20);

                entity.Property(e => e.DepartmentId)
                    .HasColumnName("DepartmentId")
                    .HasMaxLength(20);

                entity.Property(e => e.Title)
                    .HasColumnName("Title")
                    .HasMaxLength(200);

                entity.HasOne(d => d.Department)
                    .WithMany(p => p.Courses)
                    .HasForeignKey(d => d.DepartmentId)
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK__course__dept_nam__164452B1");
            });

            modelBuilder.Entity<Department>(entity =>
            {
                entity.HasKey(e => e.DepartmentId)
                    .HasName("PK__department");

                entity.ToTable("Departments");

                entity.Property(e => e.DepartmentId)
                    .HasColumnName("DepartmentId")
                    .HasMaxLength(20);

                entity.Property(e => e.Building)
                    .HasColumnName("Building")
                    .HasMaxLength(20);

                entity.Property(e => e.Name)
                    .HasColumnName("Name")
                    .HasMaxLength(200);
            });

        

            modelBuilder.Entity<TuitionFee>(entity =>
            {
                entity.HasKey(e => new { e.DepartmentId,e.Semester})
                    .HasName("PK__tuitionFee");

                entity.ToTable("TuitionFees");

                entity.Property(e => e.DepartmentId)
                    .HasColumnName("DepartmentId")
                    .HasMaxLength(20);
                entity.Property(e => e.Semester)
                    .HasMaxLength(20);

                entity.HasOne(t => t.Department)
                   .WithMany(d => d.TuitionFees)
                   .HasForeignKey(t => t.DepartmentId)
                   .OnDelete(DeleteBehavior.Cascade)
                   .HasConstraintName("FK__tuitionFees_department");

                entity.HasOne(t => t.SemesterTable)
                       .WithMany(s => s.TuitionFees)
                       .HasForeignKey(x => x.Semester);
            });

            modelBuilder.Entity<Instructor>(entity =>
            {
                entity.ToTable("Instructors");

                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .HasMaxLength(20);

                entity.Property(e => e.InstructorDepartmentId)
                    .HasColumnName("InstructorDepartmentId")
                    .HasMaxLength(20);

                entity.Property(e => e.DepartmentId)
                   .HasColumnName("DepartmentId")
                   .HasMaxLength(20);

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("Name")
                    .HasMaxLength(200);

                entity.Property(e => e.Salary)
                    .HasColumnName("Salary")
                    .HasColumnType("numeric(8, 2)");

                entity.HasOne(d => d.InstructorDepartment)
                    .WithMany(p => p.Instructors)
                    .HasForeignKey(d => new { d.InstructorDepartmentId, d.DepartmentId })
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK__instructor_instructordepartment");

                entity.HasOne(d => d.AppGroup)
                    .WithMany(p => p.Instructors)
                    .HasForeignKey(d => d.GroupId)
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK__instructor_Appgroup");
            });
            modelBuilder.Entity<InstructorDepartment>(entity =>
            {
                entity.HasKey(e => new { e.Id, e.DepartmentId })
                   .HasName("PK_InstructorDepartment");

                entity.ToTable("InstructorDepartments");

                entity.Property(e => e.Id)
                    .HasMaxLength(20);

                entity.Property(e => e.DepartmentId)
                    .HasMaxLength(20);

                entity.HasOne(d => d.Department)
                    .WithMany(p => p.InstructorDepartments)
                    .HasForeignKey(d => d.DepartmentId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__instructordept_dept");
            });

            modelBuilder.Entity<InstructorNotification>(entity =>
            {
                entity.HasKey(e => new { e.InstructorId, e.NotificationId })
                   .HasName("PK_InstructorNotice");

                entity.ToTable("InstructorNotification");

                entity.Property(e => e.InstructorId)
                    .HasMaxLength(20);

                entity.Property(e => e.NotificationId)
                    .HasMaxLength(20);

                entity.HasOne(d => d.Instructor)
                    .WithMany(p => p.InstructorNotifications)
                    .HasForeignKey(d => d.InstructorId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__instructorNotification12");

                entity.HasOne(d => d.Notification)
                    .WithMany(p => p.InstructorNotifications)
                    .HasForeignKey(d => d.NotificationId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__NoticeInstrucNotification");
            });

            modelBuilder.Entity<StudentNotification>(entity =>
            {
                entity.HasKey(e => new { e.StudentId, e.NotificationId })
                   .HasName("PK_StudentNotice");

                entity.ToTable("StudentNotification");

                entity.Property(e => e.StudentId)
                    .HasMaxLength(20);

                entity.Property(e => e.NotificationId)
                    .HasMaxLength(20);

                entity.HasOne(d => d.Student)
                    .WithMany(p => p.StudentNotifications)
                    .HasForeignKey(d => d.StudentId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__StudentNotification12");

                entity.HasOne(d => d.Notification)
                    .WithMany(p => p.StudentNotifications)
                    .HasForeignKey(d => d.NotificationId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__NoticeStudentNotification");
            });

            modelBuilder.Entity<Language>(entity =>
            {
                entity.HasKey(e => e.Id)
                   .HasName("PK_language");

                entity.ToTable("Languages");

                entity.Property(e => e.Id)
                       .HasMaxLength(20);
            });

            modelBuilder.Entity<Notification>(entity =>
            {
                entity.HasKey(e => e.Id)
                   .HasName("PK_Notification");

                entity.ToTable("Notifications");

                entity.Property(e => e.Id)
                    .HasMaxLength(20);
                entity.Property(e => e.Title)
                   .HasMaxLength(200);
            });

            modelBuilder.Entity<Post>(entity =>
            {
                entity.HasKey(e => e.Id)
                   .HasName("PK_Post");

                entity.ToTable("Posts");

                entity.Property(e => e.Id)
                    .HasMaxLength(20);

                entity.HasOne(d => d.PostCategory)
                    .WithMany(p => p.Posts)
                    .HasForeignKey(d => d.PostCategoryId)
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK__Post_PostCategory");
            });

            modelBuilder.Entity<PostCategory>(entity =>
            {
                entity.HasKey(e => e.Id)
                   .HasName("PK_Postcategory");

                entity.ToTable("PostCategories");

                entity.Property(e => e.Id)
                    .HasMaxLength(20);
            });

            modelBuilder.Entity<Prereq>(entity =>
            {
                entity.HasKey(e => new { e.CourseId, e.PrereqId })
                    .HasName("PK__prereq");

                entity.ToTable("Prereqs");

                entity.Property(e => e.CourseId)
                    .HasColumnName("CourseId")
                    .HasMaxLength(20);

                entity.Property(e => e.PrereqId)
                    .HasColumnName("PrereqId")
                    .HasMaxLength(20);

                entity.HasOne(d => d.Course)
                    .WithMany(p => p.Prereqs)
                    .HasForeignKey(d => d.CourseId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__prereq__course");
            });

            modelBuilder.Entity<Section>(entity =>
            {
                entity.HasKey(e => e.SecId)
                    .HasName("PK__section");

                entity.ToTable("Sections");

                entity.Property(e => e.CourseId)
                    .HasColumnName("CourseId")
                    .HasMaxLength(20);

                entity.Property(e => e.SecId)
                    .HasColumnName("SecId")
                    .HasMaxLength(20);

                entity.Property(e => e.Semester)
                    .HasColumnName("Semester")
                    .HasMaxLength(20);

                entity.Property(e => e.Year)
                    .HasColumnName("Year")
                    .HasMaxLength(20);

                entity.Property(e => e.Building)
                    .HasColumnName("Building")
                    .HasMaxLength(20);

                entity.Property(e => e.RoomNumber)
                    .HasColumnName("RoomNumber")
                    .HasMaxLength(20);

                entity.Property(e => e.TimeSlotId)
                    .HasColumnName("TimeSlotId")
                    .HasMaxLength(20);

                entity.Property(e => e.Day)
                    .HasColumnName("Day")
                    .HasMaxLength(20);

                entity.HasOne(d => d.Course)
                    .WithMany(p => p.Sections)
                    .HasForeignKey(d => d.CourseId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__section__course___1ED998B2");

                entity.HasOne(d => d.TimeSlot)
                   .WithMany(p => p.Sections)
                   .HasForeignKey(d => new { d.TimeSlotId, d.Day })
                   .OnDelete(DeleteBehavior.SetNull)
                   .HasConstraintName("FK__section__timeslot");

                entity.HasOne(d => d.Classroom)
                    .WithMany(p => p.Sections)
                    .HasForeignKey(d => new { d.Building, d.RoomNumber })
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK__section__1FCDBCEB");
                entity.HasOne(section => section.SemesterTable)
                      .WithMany(semester => semester.Sections)
                      .HasForeignKey(sec => sec.Semester);
            });

            modelBuilder.Entity<Student>(entity =>
            {
                entity.HasKey(e => e.Id)
                   .HasName("PK__Student");

                entity.ToTable("Students");

                entity.Property(e => e.Id)
                    .HasColumnName("Id")
                    .HasMaxLength(20);

                entity.Property(e => e.DepartmentId)
                    .HasColumnName("DepartmentId")
                    .HasMaxLength(20);

                entity.Property(e => e.StudentClassId)
                   .HasColumnName("StudentClassId")
                   .HasMaxLength(20);

                entity.Property(e => e.CreatedYear)
                  .HasColumnName("CreatedYear")
                  .HasMaxLength(20);

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("Name")
                    .HasMaxLength(200);

                entity.Property(e => e.Password)
                    .HasColumnName("Password")
                    .HasMaxLength(20);

                entity.HasOne(d => d.StudentClass)
                    .WithMany(p => p.Students)
                    .HasForeignKey(d => new { d.StudentClassId, d.DepartmentId })
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK__student__dept_na__276EDEB3");

                entity.HasOne(d => d.AppGroup)
                    .WithMany(p => p.Students)
                    .HasForeignKey(d => d.GroupId)
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK__student__appgroup");
            });

            modelBuilder.Entity<StudentClass>(entity =>
            {
                entity.HasKey(e => new { e.Id, e.DepartmentId })
                   .HasName("PK__StudentClass");

                entity.ToTable("StudentClasses");

                entity.Property(e => e.Id)
                    .HasColumnName("Id")
                    .HasMaxLength(20);

                entity.Property(e => e.DepartmentId)
                    .HasColumnName("DepartmentId")
                    .HasMaxLength(20);

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("Name")
                    .HasMaxLength(200);

                entity.Property(e => e.Year)
                    .IsRequired()
                    .HasColumnName("Year")
                    .HasMaxLength(20);

                entity.HasOne(d => d.Department)
                    .WithMany(p => p.StudentClasses)
                    .HasForeignKey(d => new { d.DepartmentId })
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__studentclass__dept");
            });

            modelBuilder.Entity<Take>(entity =>
            {
                entity.HasKey(e => new { e.Id, e.SecId })
                    .HasName("PK__takes__A0A7458A976F2631");

                entity.ToTable("Takes");

                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .HasMaxLength(20);

                entity.Property(e => e.SecId)
                    .HasColumnName("SecId")
                    .HasMaxLength(20);

                entity.Property(e => e.WordScore)
                    .HasColumnName("WordScore")
                    .HasMaxLength(2);

                entity.HasOne(d => d.Student)
                    .WithMany(p => p.Takes)
                    .HasForeignKey(d => d.Id)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__takes__ID__2B3F6F97");

                entity.HasOne(d => d.Section)
                    .WithMany(p => p.Takes)
                    .HasForeignKey(d => d.SecId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__takes__2A4B4B5E");
            });

            modelBuilder.Entity<Teach>(entity =>
            {
                entity.HasKey(e => new { e.Id, e.SecId })
                    .HasName("PK__teaches__A0A7458ABC151A07");

                entity.ToTable("Teaches");

                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .HasMaxLength(20);

                entity.Property(e => e.SecId)
                    .HasColumnName("SecId")
                    .HasMaxLength(20);

                entity.HasOne(d => d.Instructor)
                    .WithMany(p => p.Teaches)
                    .HasForeignKey(d => d.Id)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__teaches_instructor");

                entity.HasOne(d => d.Section)
                    .WithMany(p => p.Teaches)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasForeignKey(d => d.SecId)
                    .HasConstraintName("FK__teaches_section");
            });

            modelBuilder.Entity<TimeSlot>(entity =>
            {
                entity.HasKey(e => new { e.TimeSlotId, e.Day })
                    .HasName("PK__timeslot");

                entity.ToTable("TimeSlots");

                entity.Property(e => e.TimeSlotId)
                    .HasColumnName("TimeSlotId")
                    .HasMaxLength(20);

                entity.Property(e => e.Day)
                    .HasColumnName("Day")
                    .HasMaxLength(20);
            });

            modelBuilder.Entity<ToeicPoint>(entity =>
            {
                entity.HasKey(e => new { e.Id, e.StudentId })
                    .HasName("PK__toeicpoint");

                entity.ToTable("ToeicPoints");

                entity.Property(e => e.StudentId)
                    .HasColumnName("StudentId")
                    .HasMaxLength(20);

                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .HasMaxLength(20);

                entity.HasOne(d => d.Student)
                   .WithMany(p => p.ToeicPoints)
                   .HasForeignKey(d => d.StudentId)
                   .OnDelete(DeleteBehavior.Cascade)
                   .HasConstraintName("FK__toeic_student");
            });

            modelBuilder.Entity<Warn>(entity =>
            {
                entity.HasKey(e => new { e.StudentId, e.Semester })
                    .HasName("PK_warn");

                entity.ToTable("Warns");

                entity.Property(e => e.StudentId)
                    .HasColumnName("StudentId")
                    .HasMaxLength(20);

                entity.Property(e => e.Semester)
                    .HasMaxLength(20);

                entity.HasOne(d => d.Student)
                   .WithMany(p => p.Warns)
                   .HasForeignKey(d => d.StudentId)
                   .OnDelete(DeleteBehavior.Cascade)
                   .HasConstraintName("FK__warnc_student");
            });

            modelBuilder.Entity<Feedback>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .HasName("PK__feedback");

                entity.ToTable("Feedbacks");

                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .HasMaxLength(20);

                entity.Property(e => e.Name)
                    .HasColumnName("Name")
                    .HasMaxLength(200);

                entity.Property(e => e.Email)
                    .HasColumnName("Email")
                    .HasMaxLength(200);
            });
            modelBuilder.Entity<Semester>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .HasName("PK__semester");

                entity.Property(e => e.Id)
                    .HasColumnName("Id")
                    .HasMaxLength(20);
            });

            #endregion Entity Config

            #region Procedure

            modelBuilder.Entity<GetStudent>().ToView("GetStudents").HasNoKey();
            modelBuilder.Entity<GetStudentInfor>().ToView("GetStudentInfors").HasNoKey();
            modelBuilder.Entity<GetResultLearning>().ToView("GetResultLearnings").HasNoKey();
            modelBuilder.Entity<GetListClass>().ToView("GetListClasses").HasNoKey();
            modelBuilder.Entity<GetRegistered>().ToView("GetRegistereds").HasNoKey();
            modelBuilder.Entity<GetRegisteredClassByStudentId>().ToView("GetRegisteredClassByStudentIds").HasNoKey();

            #endregion Procedure
        }
    }
}