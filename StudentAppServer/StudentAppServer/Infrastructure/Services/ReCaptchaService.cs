using Newtonsoft.Json;
using StudentAppServer.Models;
using System.Net;

namespace StudentAppServer.Infrastructure.Services
{
    public class ReCaptchaService
    {
        public bool IsValidCaptcha(string tokenResponse)
        {

            string secretKey = "6Ldhk-cZAAAAAO7tMFR5kYrNQ2pgRdO2kKRimsFf";

            var client = new WebClient();

            var GoogleReply = client.DownloadString(string.Format($"https://www.google.com/recaptcha/api/siteverify?secret={secretKey}&response={tokenResponse}"));

            var captchaResponse = JsonConvert.DeserializeObject<RecaptchaResult>(GoogleReply);

            var result = captchaResponse.Success;

            if (result == "true") return true;

            else return false;
        }
    }
}