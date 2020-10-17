using StudentAppServer.Data.Base;
using System;
using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class Student
    {
        public Student()
        {
            Takes = new HashSet<Take>();

            ToeicPoints = new HashSet<ToeicPoint>();

            StudentNotifications = new HashSet<StudentNotification>();

            Warns = new HashSet<Warn>();
        }

        public string Id { get; set; }

        public string Name { get; set; }

        public string Password { get; set; }

        public string Email { get; set; }

        public DateTime? BirthDay { get; set; }

        public string Address { get; set; }

        public int? CardId { get; set; }

        public string Birthplace { get; set; }

        public string Avatar { get; set; }

        public string CreatedYear { get; set; }

        public Status Status { get; set; }

        public string GroupId { get; set; }
        public AppGroup AppGroup { get; set; }

        public string StudentClassId { get; set; }
        public string DepartmentId { get; set; }
        public StudentClass StudentClass { get; set; }

        public ICollection<Take> Takes { get; set; }

        public ICollection<StudentNotification> StudentNotifications { get; set; }

        public ICollection<ToeicPoint> ToeicPoints { get; set; }

        public ICollection<Warn> Warns { get; set; }
    }
}