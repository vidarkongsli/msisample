using System.Net.Http.Headers;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Graph;

namespace managedidentitysample.app
{
    public class GraphServiceClientFactory
    {
        public virtual GraphServiceClient GetClient()
            => new GraphServiceClient(new DelegateAuthenticationProvider(
                async requestMessage =>
                {
                    var accessToken = await new AzureServiceTokenProvider()
                        .GetAccessTokenAsync("00000003-0000-0000-c000-000000000000");
                    
                    requestMessage.Headers.Authorization = new AuthenticationHeaderValue("Bearer",
                        accessToken);
                }));
    }
}