using StudentAppServer.Data.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Models.Students
{
    public class CreateStudentModel
    {
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

        public string StudentClassName { get; set; }

        public string DepartmentName { get; set; }
    }
}