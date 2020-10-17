using Microsoft.AspNetCore.Mvc;

namespace StudentAppServer.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public abstract class ApiControllerBase : ControllerBase
    {
    }
}