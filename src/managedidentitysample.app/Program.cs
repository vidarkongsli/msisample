using System;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureKeyVault;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace managedidentitysample.app
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = CreateWebHostBuilder(args).Build();

            var services = (IServiceScopeFactory)host.Services.GetService(typeof(IServiceScopeFactory));

            using (var scope = services.CreateScope())
            {
                var sampleContext = scope.ServiceProvider.GetService<SampleContext>();
                Console.WriteLine($"Running migrations on db {sampleContext.Database.GetDbConnection().ConnectionString}");
                sampleContext.Database.Migrate();
                Console.WriteLine("Done running migrations");
            }

            host.Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseApplicationInsights()
                .UseStartup<Startup>()
                .ConfigureAppConfiguration((ctx, builder) =>
                {
                    var config = builder.Build();
                    var keyVaultBaseUrl = config["KeyVault:BaseUrl"];
                    if (string.IsNullOrWhiteSpace(keyVaultBaseUrl))
                    {
                        return;
                    }

                    Console.WriteLine("Using keyvault");
                    var tokenProvider = new AzureServiceTokenProvider();
                    var kvClient = new KeyVaultClient((authority, resource, scope) => tokenProvider.KeyVaultTokenCallback(authority, resource, scope));
                    builder.AddAzureKeyVault(keyVaultBaseUrl, kvClient, new DefaultKeyVaultSecretManager());
                })
                .ConfigureLogging(logging =>
                {
                    logging.AddApplicationInsights();
                });
    }
}
