using StudentAppServer.Data.Base;
using System;
using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class Notification
    {
        public Notification()
        {
            InstructorNotifications = new HashSet<InstructorNotification>();

            StudentNotifications = new HashSet<StudentNotification>();
        }

        public string Id { get; set; }

        public string Title { get; set; }

        public string Message { get; set; }

        public DateTime? CreatedDate { get; set; }

        public DateTime? ModifiedDate { get; set; }

        public Status Status { get; set; }

        public ICollection<InstructorNotification> InstructorNotifications { get; set; }

        public ICollection<StudentNotification> StudentNotifications { get; set; }
    }
}