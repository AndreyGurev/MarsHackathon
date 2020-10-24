using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Dns.СozyHome.Core;
using Microsoft.AspNetCore.Mvc;

namespace Dns.СozyHome.Api
{
    [ApiController]
    [Route("api")]
    public class CozyHomeController : ControllerBase
    {
        private readonly CozyHomeManager _manager;

        public CozyHomeController(CozyHomeManager manager)
        {
            _manager = manager;
        }

        [HttpGet]
        [Route("getCatalogItems")]
        public async Task<List<CatalogItemView>> GetCatalogItemsAsync(Guid parentId) =>
            (await _manager.GetCatalogItemsAsync(parentId))
            .ConvertAll(item => new CatalogItemView(item));

        [HttpGet]
        [Route("getGood")]
        public async Task<GoodView> GetGoodAsync(Guid id) =>
            new GoodView(await _manager.GetGoodAsync(id));

        [HttpGet]
        [Route("getARModel")]
        public async Task<byte[]> GetARModelAsync(Guid goodId) =>
            await _manager.GetARModelAsync(goodId);
    }
}
