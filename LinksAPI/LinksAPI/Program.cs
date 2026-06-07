// Program.cs
using LinksAPI.Data;
using LinksAPI.Endpoints;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter",
        policy => policy.WithOrigins("https://linksapp-two.vercel.app")
                        .AllowAnyMethod()
                        .AllowAnyHeader()
                        .SetPreflightMaxAge(TimeSpan.FromMinutes(10)));
});
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

if (connectionString!.StartsWith("postgres://") || connectionString.StartsWith("postgresql://"))
{
    var uri = new Uri(connectionString);
    connectionString = $"Host={uri.Host};Database={uri.AbsolutePath.TrimStart('/')};Username={uri.UserInfo.Split(':')[0]};Password={uri.UserInfo.Split(':')[1]}";
}

builder.Services.AddDbContext<LinksDbContext>(options =>
    options.UseNpgsql(connectionString));


builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
    };
});
builder.Services.AddAuthorization();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<LinksDbContext>();
    db.Database.Migrate();
}

app.UseCors("AllowFlutter");
app.UseAuthentication();
app.UseAuthorization();

app.MapEventEndPoints();
app.MapGroupEndPoints();
app.MapMessageEndPoints();
app.MapUserEndPoints();
app.MapFriendEndPoints();

app.Run();