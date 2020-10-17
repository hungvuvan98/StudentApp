using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace StudentAppServer.Infrastructure.Services
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly ClaimsPrincipal user;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor)
            => this.user = httpContextAccessor.HttpContext?.User;

        public string GetId()
        => user?.Claims?
                .FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)
                ?.Value;

        public string GetUserName()
         => this.user?.Identity?.Name;

        public string GetRole()
         => user?.Claims?
                .FirstOrDefault(c => c.Type == ClaimTypes.Role)
                ?.Value;
    }
}