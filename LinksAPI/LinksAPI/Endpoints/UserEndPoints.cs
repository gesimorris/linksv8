using LinksAPI.Data;
using LinksAPI.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace LinksAPI.Endpoints;

public static class UserEndPoints
{
    public static void MapUserEndPoints(this WebApplication app)
    {
        // 1. Create the Group with the prefix "/users"
        // 2. Attach the "AllowFlutter" CORS policy to the entire group
        var users = app.MapGroup("/users")
                       .RequireCors("AllowFlutter");

        // REGISTER: Hits "POST /users/register"
        users.MapPost("/register", async (User user, LinksDbContext db) =>
        {
            var existingUser = await db.Users.FirstOrDefaultAsync(u => u.Email == user.Email);
            if (existingUser != null)
            {
                return Results.BadRequest("Email already in use.");
            }

            user.Password = BCrypt.Net.BCrypt.HashPassword(user.Password);
            db.Users.Add(user);
            await db.SaveChangesAsync();
            
            return Results.Created($"/users/{user.Id}", new { 
                user.Id, 
                user.FirstName, 
                user.LastName, 
                user.Email 
            });
        });

        // LOGIN: Hits "POST /users/login"
        users.MapPost("/login", async (User login, LinksDbContext db, IConfiguration config) =>
        {
            var user = await db.Users.FirstOrDefaultAsync(u => u.Email == login.Email);
            
            if (user == null || !BCrypt.Net.BCrypt.Verify(login.Password, user.Password))
            {
                return Results.Unauthorized();
            }

            // JWT Generation
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            
            var token = new JwtSecurityToken(
                issuer: config["Jwt:Issuer"],
                audience: config["Jwt:Audience"],
                claims: new[] { 
                    new Claim("userId", user.Id.ToString()),
                    new Claim(ClaimTypes.Name, user.FirstName ?? "") 
                },
                expires: DateTime.UtcNow.AddDays(7),
                signingCredentials: creds
            );

            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);
            
            return Results.Ok(new { 
                token = tokenString, 
                userId = user.Id, 
                firstName = user.FirstName 
            });
        });
    }
}