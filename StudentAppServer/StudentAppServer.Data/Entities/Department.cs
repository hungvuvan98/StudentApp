using StudentAppServer.Data.Base;
using System;
using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class Department
    {
        public Department()
        {
            Courses = new HashSet<Course>();

            InstructorDepartments = new HashSet<InstructorDepartment>();

            StudentClasses = new HashSet<StudentClass>();
        }

        public string DepartmentId { get; set; }

        public string Name { get; set; }

        public string Building { get; set; }

        public Status Status { get; set; }

        public ICollection<Course> Courses { get; set; }

        public ICollection<InstructorDepartment> InstructorDepartments { get; set; }

        public ICollection<StudentClass> StudentClasses { get; set; }

        public ICollection<TuitionFee> TuitionFees { get; set; }
    }
}