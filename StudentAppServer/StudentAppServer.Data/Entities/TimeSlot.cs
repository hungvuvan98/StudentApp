using System.Collections.Generic;

namespace StudentAppServer.Data.Entities
{
    public class TimeSlot
    {
        public TimeSlot()
        {
            Sections = new HashSet<Section>();
        }

        public string TimeSlotId { get; set; }

        public string Day { get; set; }

        public int? StartHr { get; set; }

        public int? StartMin { get; set; }

        public int? EndHr { get; set; }

        public int? EndMin { get; set; }

        public ICollection<Section> Sections { get; set; }
    }
}