using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace StudentAppServer.Models
{
    public class LoginModel
    {
        public string Id { get; set; }

        public string Password { get; set; }

        public string Recaptcha { get; set; }
    }
}