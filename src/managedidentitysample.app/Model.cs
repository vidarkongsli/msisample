using System.Data.SqlClient;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.EntityFrameworkCore;

namespace managedidentitysample.app
{
    public class SampleContext : DbContext
    {
        public SampleContext(DbContextOptions<SampleContext> options, IHostingEnvironment host)
            : base(options)
        {
            if (host.IsDevelopment()) return;
            var conn = (SqlConnection)Database.GetDbConnection();
            conn.AccessToken = (new AzureServiceTokenProvider())
                .GetAccessTokenAsync("https://database.windows.net/").Result;
        }

       public DbSet<Secret> Chamber { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
            => modelBuilder.Entity<Secret>().HasData(new Secret {Name = "basilisk", Id = -1});
    }

    public class Secret
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}
