using StudentAppServer.Data.Base;
using StudentAppServer.Data.Entities;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Data
{
    public class DbIntinializer
    {
        private readonly AppDbContext _context;

        public DbIntinializer(AppDbContext context)
        {
            _context = context;
        }

        public async Task Seed()
        {
            if (!_context.AppGroups.Any())
            {
                _context.AppGroups.Add(new AppGroup()
                {
                    Id = "1",
                    Name = "Administrator",
                    Role = "Administrator",
                    Status = Status.Active
                });
                _context.AppGroups.Add(new AppGroup()
                {
                    Id = "2",
                    Name = "Student",
                    Role = "Student",
                    Status = Status.Active
                });
                _context.AppGroups.Add(new AppGroup()
                {
                    Id = "3",
                    Name = "Instructor",
                    Role = "Instructor",
                    Status = Status.Active
                });
            }

            if (!_context.Departments.Any())
            {
                _context.Departments.Add(new Department()
                {
                    DepartmentId = "MI",
                    Building = "D3",
                    Name = "Viện Toán Ứng Dụng Và Tin Học",
                    Status = Status.Active
                });
            }

            if (!_context.StudentClasses.Any())
            {
                _context.StudentClasses.Add(new StudentClass()
                {
                    Id = "MI1-20161",
                    DepartmentId = "MI",
                    Year = "2016",
                    Name = "Toan tin - 2016- 01"
                });

                _context.StudentClasses.Add(new StudentClass()
                {
                    Id = "MI1-20162",
                    DepartmentId = "MI",
                    Year = "2016",
                    Name = "Toan Tin - 2016 -02"
                });

                _context.StudentClasses.Add(new StudentClass()
                {
                    Id = "MI1-2017",
                    DepartmentId = "MI",
                    Year = "2017",
                    Name = "Toan Tin - 2017",
                });
                _context.StudentClasses.Add(new StudentClass()
                {
                    Id = "MI2-20171",
                    DepartmentId = "MI",
                    Year = "2017",
                    Name = "HTTTQL - 2017 -01",
                });
                _context.StudentClasses.Add(new StudentClass()
                {
                    Id = "MI2-20172",
                    DepartmentId = "MI",
                    Year = "2017",
                    Name = "HTTTQL - 2017 - 02",
                });
            }

            if (!_context.Students.Any())
            {
                _context.Students.Add(new Student()
                {
                    Id = "20161997",
                    DepartmentId = "MI",
                    Email = "hung.vvh@gmail.com",
                    StudentClassId = "MI1-20161",
                    CreatedYear = "2016",
                    Name = "Hung Vu Van Toan tin 01",
                    BirthDay = DateTime.Now,
                    CardId = 174629083,
                    Status = Status.Active,
                    GroupId = "2"
                });
                _context.Students.Add(new Student()
                {
                    Id = "20161998",
                    DepartmentId = "MI",
                    StudentClassId = "MI1-20162",
                    CreatedYear = "2016",
                    Name = "Hung Vu Van Toan tin 02",
                    BirthDay = DateTime.Now,
                    CardId = 174629083,
                    Status = Status.Active,
                    GroupId = "2"
                });
                _context.Students.Add(new Student()
                {
                    Id = "20161999",
                    DepartmentId = "MI",
                    StudentClassId = "MI2-20171",
                    CreatedYear = "2017",
                    Name = "Hung Vu Van htttql 01",
                    BirthDay = DateTime.Now,
                    CardId = 174629083,
                    Status = Status.Active,
                    GroupId = "2"
                });
                _context.Students.Add(new Student()
                {
                    Id = "20162000",
                    DepartmentId = "MI",
                    StudentClassId = "MI2-20172",
                    CreatedYear = "2017",
                    Name = "Hung Vu Van htttql 02",
                    BirthDay = DateTime.Now,
                    CardId = 174629083,
                    Status = Status.Active,
                    GroupId = "2"
                });
            }
            await _context.SaveChangesAsync();
        }
    }
}