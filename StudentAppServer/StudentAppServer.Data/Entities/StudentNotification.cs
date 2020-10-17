namespace StudentAppServer.Data.Entities
{
    public class StudentNotification
    {
        public string StudentId { get; set; }
        public Student Student { get; set; }

        public string NotificationId { get; set; }
        public Notification Notification { get; set; }
    }
}