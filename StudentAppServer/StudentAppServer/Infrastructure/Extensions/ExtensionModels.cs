using StudentAppServer.Data.Procedure;
using StudentAppServer.Models.Students;
using System;

namespace StudentAppServer.Infrastructure.Extensions
{
    public static class ExtensionModels
    {
        public static StudentFeeDtos AsStudentFeeDto(this GetRegisteredClassByStudentId entity, decimal fee)
        {
            return new StudentFeeDtos()
            {
                CourseTitle = entity.Title,
                Credit = entity.Credit,
                Fee = fee,
                CourseId=entity.CourseId,
                SecId=entity.SecId
            };
        }

        public static bool GreaterThan(this string semester, string compareSemester)
        {
            return Convert.ToInt32(semester) >= Convert.ToInt32(compareSemester);
        }
    }
}