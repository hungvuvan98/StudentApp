using StudentAppServer.Data.Base;
using System;

namespace StudentAppServer.Data.Entities
{
    public class Post : IDate, IByUser
    {
        public string Id { get; set; }

        public string PostCategoryId { get; set; }

        public string Title { get; set; }

        public string Content { get; set; }

        public DateTime? CreatedOn { get; set; }

        public DateTime? ModifiedOn { get; set; }

        public string CreatedBy { get; set; }

        public string ModifiedBy { get; set; }

        public Status Status { get; set; }

        public PostCategory PostCategory { get; set; }
    }
}