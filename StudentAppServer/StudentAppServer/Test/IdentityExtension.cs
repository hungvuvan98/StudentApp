using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Security.Principal;
using System.Threading.Tasks;

namespace StudentAppServer.Test
{
    public static class IdentityExtension
    {
        public static string GiveName(this IIdentity identity)
        {
            var claim = ((ClaimsIdentity)identity).FindFirst(ClaimTypes.GivenName);
            return (claim != null) ? claim.Value : string.Empty;
        }
        public static string StressAddress(this IIdentity identity)
        {
            var claim = ((ClaimsIdentity)identity).FindFirst(ClaimTypes.StreetAddress);
            return (claim != null) ? claim.Value : string.Empty;
        }   
    }
}
