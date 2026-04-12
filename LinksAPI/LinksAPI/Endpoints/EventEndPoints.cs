using LinksAPI.Data;
using LinksAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace LinksAPI.Endpoints;

public static class EventEndPoints
{
    public static void MapEventEndPoints(this WebApplication app)
    {   
        // Return all events
        app.MapGet("/events", async (LinksDbContext db) =>
        {
            var events = await db.Events.ToListAsync();
            return Results.Ok(events);
        });

        // Return a specific event by ID
        app.MapGet("/events/{id}", async (int id, LinksDbContext db) =>
        {
            var evnt = await db.Events.FindAsync(id);
            if (evnt == null)
            {
                return Results.NotFound();
            }
            return Results.Ok(evnt);
        });


    }
}