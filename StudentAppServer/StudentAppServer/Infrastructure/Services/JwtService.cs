using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using StudentAppServer.Models;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace StudentAppServer.Infrastructure.Services
{
    public class JwtService
    {
        private readonly AppSettings _appSetting;

        public JwtService(IOptions<AppSettings> appSetting)
        {
            _appSetting = appSetting.Value;
        }

        public LoginResponseModel GenerateToken(string Id, string name, string role)
        {
            var tokenHandler = new JwtSecurityTokenHandler();

            var key = Encoding.ASCII.GetBytes(_appSetting.Secret);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[] {
                    //new Claim("name", name) ,
                    new Claim(ClaimTypes.Name,name),
                     new Claim(ClaimTypes.NameIdentifier,Id),
                      new Claim(ClaimTypes.Role,role)
                }),
                Expires = DateTime.UtcNow.AddDays(7),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            var encryptedToken = tokenHandler.WriteToken(token);
            return new LoginResponseModel
            {
                StudentId = Id,
                Token = encryptedToken
            };
        }
    }
}