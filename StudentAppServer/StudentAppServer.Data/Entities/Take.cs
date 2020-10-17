namespace StudentAppServer.Data.Entities
{
    public class Take
    {
        public string Id { get; set; }

        public float? Midterm { get; set; }

        public float? Endterm { get; set; }

        public string WordScore { get; set; }

        public Student Student { get; set; }

        public string SecId { get; set; }
        public Section Section { get; set; }
    }
}