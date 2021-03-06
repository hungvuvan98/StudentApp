﻿using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace StudentAppServer.Data.Entities
{
    public class Semester
    {
        public string Id { get; set; }

        public string Description { get; set; }

        public ICollection<Section> Sections { get; set; }

        public ICollection<TuitionFee> TuitionFees { get; set; }

    }
}