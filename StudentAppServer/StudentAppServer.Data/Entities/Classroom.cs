using StudentAppServer.Data.Base;
using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class Classroom
    {
        public Classroom()
        {
            Sections = new HashSet<Section>();
        }

        public string Building { get; set; }

        public string RoomNumber { get; set; }

        public int Capacity { get; set; }

        public Status Status { get; set; }

        public ICollection<Section> Sections { get; set; }
    }
}