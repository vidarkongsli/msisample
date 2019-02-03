using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;

namespace managedidentitysample.app.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DbValuesController : ControllerBase
    {
        private readonly SampleContext _ctx;
        public DbValuesController(SampleContext ctx) => _ctx = ctx;

        [HttpGet]
        public ActionResult<IEnumerable<string>> Get()
            => new[] { _ctx.Chamber.FirstOrDefault()?.Name };
    }
}
