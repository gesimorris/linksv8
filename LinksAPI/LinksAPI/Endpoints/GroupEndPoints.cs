using LinksAPI.Data;
using LinksAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace LinksAPI.Endpoints;

public static class GroupEndPoints
{
    public static void MapGroupEndPoints(this WebApplication app)
    {   
        // Get all groups for a specific user
        app.MapGet("/groups/{userId}", async (int userId, LinksDbContext db) =>
        {
            var user = await db.Users.FindAsync(userId);
            if (user == null)
            {
                return Results.NotFound();
            }

            var group = await db.Groups.Where(g => db.GroupMembers.Any(gm => gm.GroupId == g.Id && gm.UserId == userId)).ToListAsync();
            return Results.Ok(group);
        });

        // Get all groups for a specific event
        app.MapGet("/groups/event/{eventId}", async (int eventId, LinksDbContext db) =>
        {
            var evnt = await db.Events.FindAsync(eventId);
            if (evnt == null)
            {
                return Results.NotFound();
            }

            var groups = await db.Groups.Where(g => g.EventId == eventId).ToListAsync();
            return Results.Ok(groups);
        });

        // Create a new group for an event (the creator is automatically added as a member of the group)
        app.MapPost("/groups", async (Group group, LinksDbContext db) =>
        {
            db.Groups.Add(group);
            await db.SaveChangesAsync();

            var member = new GroupMember
            {
                GroupId = group.Id,
                UserId = group.CreatorId
            };
            db.GroupMembers.Add(member);
            await db.SaveChangesAsync();

            return Results.Created($"/groups/{group.Id}", group);
        });

        // Join a group
        app.MapPost("/groups/{groupId}/join", async (int groupId, int userId, LinksDbContext db) =>
        {
            var group = await db.Groups.FindAsync(groupId);
            if (group == null)
            {
                return Results.NotFound();
            }

            var members = await db.GroupMembers.CountAsync(gm => gm.GroupId == groupId);
            if (members >= group.MaxMembers)
            {
                return Results.BadRequest("Group is full");
            }

            var member = new GroupMember
            {
                GroupId = groupId,
                UserId = userId
            };            

            db.GroupMembers.Add(member);
            await db.SaveChangesAsync();

            return Results.Ok();
        });

        // Leave a group
        app.MapDelete("/groups/{groupId}/leave", async (int groupId, int userId, LinksDbContext db) =>
        {
            var member = await db.GroupMembers.FirstOrDefaultAsync(gm => gm.GroupId == groupId && gm.UserId == userId);
            if (member == null)
            {
                return Results.NotFound();
            }

            db.GroupMembers.Remove(member);
            await db.SaveChangesAsync();

            return Results.Ok();
        });

        // Delete a group (only the creator can delete the group, and only if the event is not starting within 24 hours)
        app.MapDelete("/groups/{groupId}", async (int groupId, int userId, LinksDbContext db) =>
        {
            var group = await db.Groups.FindAsync(groupId);
            if (group == null)
            {
                return Results.NotFound();
            }

            if (group.CreatorId != userId)
            {
                return Results.Forbid();
            }
            var evnt = await db.Events.FindAsync(group.EventId);
            if (evnt == null)
            {
                return Results.NotFound();
            }   
            if (evnt.Date <= DateTime.UtcNow.AddHours(24))
            {
                return Results.BadRequest("Cannot delete group for an event that is starting within 24 hours");
            }

            var members = await db.GroupMembers.Where(gm => gm.GroupId == groupId).ToListAsync();
            db.GroupMembers.RemoveRange(members);
            db.Groups.Remove(group);
            await db.SaveChangesAsync();

            return Results.Ok();
        });

    }
}