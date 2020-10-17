namespace StudentAppServer.Data.Entities
{
    public class InstructorNotification
    {
        public string InstructorId { get; set; }
        public Instructor Instructor { get; set; }

        public string NotificationId { get; set; }
        public Notification Notification { get; set; }
    }
}