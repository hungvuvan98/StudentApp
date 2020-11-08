using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace StudentAppServer.Controllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public abstract class ApiControllerBase : ControllerBase
    {
    }
}