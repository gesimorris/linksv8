using LinksAPI.Data;
using LinksAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace LinksAPI.Endpoints;

public static class MessageEndPoints
{
    public static void MapMessageEndPoints(this WebApplication app)
    {   
        // Get all messages for a specific group
        app.MapGet("/messages/{groupId}", async (int groupId, int userId, LinksDbContext db) =>
        {
            var isMember = await db.GroupMembers.AnyAsync(gm => gm.GroupId == groupId && gm.UserId == userId);
            if (!isMember)
            {
                return Results.Forbid();
            }
            var messages = await db.Messages.Where(m => m.GroupId == groupId).ToListAsync();
            return Results.Ok(messages);
        });
        
        // Create a new message in a group
        app.MapPost("/messages", async (Message message, LinksDbContext db) =>
        {
            db.Messages.Add(message);
            await db.SaveChangesAsync();
            return Results.Created($"/messages/{message.Id}", message);
        });

        // Delete a message (only the creator of the message can delete it)
        app.MapDelete("/messages/{id}", async (int id, int userId, LinksDbContext db) =>
        {
            var message = await db.Messages.FindAsync(id);
            if (message == null)
            {
                return Results.NotFound();
            }
            if (message.UserId != userId)
            {
                return Results.Forbid();
            }

            db.Messages.Remove(message);
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        // Update a message (only the creator of the message can update it)
        app.MapPut("/messages/{id}", async (int id, Message updatedMessage, int userId, LinksDbContext db) =>
        {
            var message = await db.Messages.FindAsync(id);
            if (message == null)
            {
                return Results.NotFound();
            }
            if (message.UserId != userId)
            {
                return Results.Forbid();
            }

            message.MessageText = updatedMessage.MessageText;
            message.MessageDate = DateTime.UtcNow;

            await db.SaveChangesAsync();
            return Results.Ok(message);
        });
    }
}