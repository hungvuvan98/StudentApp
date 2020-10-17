namespace StudentAppServer.Data.Entities
{
    public class Teach
    {
        public string Id { get; set; }

        public string SecId { get; set; }

        public Instructor Instructor { get; set; }

        public Section Section { get; set; }
    }
}