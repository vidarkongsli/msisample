using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace managedidentitysample.app.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GroupsController : ControllerBase
    {
        private readonly GraphServiceClientFactory _graphServiceClientFactory;

        public GroupsController(GraphServiceClientFactory graphServiceClientFactory)
        {
            _graphServiceClientFactory = graphServiceClientFactory;
        }
        
        // GET
        public async Task<IActionResult> Index()
        {
            var groups = await _graphServiceClientFactory.GetClient().Groups.Request().GetAsync();
            return Ok(new
            {
                Groups = groups.Select(g => g.DisplayName)
            });
        }
    }
}