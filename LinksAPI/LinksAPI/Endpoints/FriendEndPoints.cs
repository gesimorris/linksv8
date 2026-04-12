namespace LinksAPI.Endpoints;

using LinksAPI.Data;
using LinksAPI.Models;
using Microsoft.EntityFrameworkCore;
public static class FriendEndPoints
{
    public static void MapFriendEndPoints(this WebApplication app)
    {
        // Create a new friendship request
        app.MapPost("/friends", async (int senderId, int receiverId, LinksDbContext db) =>
        {
            var user = await db.Users.FindAsync(senderId);
            var friend = await db.Users.FindAsync(receiverId);
            if (user == null || friend == null)
            {
                return Results.NotFound();
            }

            var existingFriendship = await db.Friends.AnyAsync(f =>
                (f.SenderId == senderId && f.ReceiverId == receiverId) ||
                (f.SenderId == receiverId && f.ReceiverId == senderId));

            if (existingFriendship)
            {
                return Results.BadRequest("Friendship already exists");
            }

            var friendship = new Friend
            {
                SenderId = senderId,
                ReceiverId = receiverId,
                Status = "Pending",
                CreatedAt = DateTime.UtcNow
            };
            db.Friends.Add(friendship);
            await db.SaveChangesAsync();
            return Results.Created($"/friends/{friendship.Id}", friendship);
        });

        // Accept a friendship request
        app.MapPut("/friends/{id}", async (int id, LinksDbContext db) =>
        {
            var friendship = await db.Friends.FindAsync(id);

            if (friendship == null)
            {
                return Results.NotFound();
            }
            friendship.Status = "Accepted";
            await db.SaveChangesAsync();
            return Results.Ok(friendship);
        });

        // Deny a friendship request
        app.MapDelete("/friends/{id}", async (int id, LinksDbContext db) =>
        {
            var friendship = await db.Friends.FindAsync(id);

            if (friendship == null)
            {
                return Results.NotFound();
            }
            db.Friends.Remove(friendship);
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        // Get all friends for a specific user
        app.MapGet("/friends/{userId}", async (int userId, LinksDbContext db) =>
        {
            var user = await db.Users.FindAsync(userId);
            if (user == null)
            {
                return Results.NotFound();
            }

            var friends = await db.Friends
                .Where(f => (f.SenderId == userId || f.ReceiverId == userId) && f.Status == "Accepted")
                .ToListAsync();

            return Results.Ok(friends);
        });

        // Get all pending friendship requests for a specific user
        app.MapGet("/friends/pending/{userId}", async (int userId, LinksDbContext db) =>
        {
            var user = await db.Users.FindAsync(userId);
            if (user == null)
            {
                return Results.NotFound();
            }

            var pendingFriends = await db.Friends
                .Where(f => f.ReceiverId == userId && f.Status == "Pending")
                .ToListAsync();

            return Results.Ok(pendingFriends);
        });
    }
}