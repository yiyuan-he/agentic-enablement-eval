using Amazon.S3;
using Amazon.S3.Model;

var builder = WebApplication.CreateBuilder(args);

var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
var serviceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "dotnet-aspnetcore-app";

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(int.Parse(port));
});

var app = builder.Build();

var s3Client = new AmazonS3Client();

app.MapGet("/health", () =>
{
    return Results.Ok(new
    {
        status = "healthy",
        service = serviceName
    });
});

app.MapGet("/api/buckets", async () =>
{
    try
    {
        var response = await s3Client.ListBucketsAsync();
        var buckets = response.Buckets.Select(b => b.BucketName).ToList();

        return Results.Ok(new
        {
            bucket_count = buckets.Count,
            buckets = buckets
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});

Console.WriteLine($"Starting {serviceName} on port {port}");
app.Run();
