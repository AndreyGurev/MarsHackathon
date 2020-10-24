using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dns.СozyHome.Core;
using Microsoft.EntityFrameworkCore;

namespace Dns.СozyHome.Repository
{
    public class CozyHomeRepository : ICozyHomeRepository
    {
        private readonly Config _config;

        public CozyHomeRepository(Config config)
        {
            _config = config;
        }
        
        public async Task<List<ICatalogItem>> GetCatalogItemsAsync(Guid parentId)
        {
            await using var dbContext = new DnsСozyHomeContext(_config.DbConnectionString);
            var res = await dbContext.CatalogItems
                .Where(item => item.ParentId == parentId)
                .Select(item => new
                {
                    item,
                    IsAR = !item.IsFolder && item.GoodAdditionalInfo.IsAR,
                    Price = item.IsFolder ? 0 : item.GoodPrice.Price,
                    Preview = item.CatalogItemImages
                        .Where(image => image.ImageIndex == 0)
                        .Select(image => image.Image)
                        .Single()
                })
                .ToListAsync();

            return res.ConvertAll(item =>
                (ICatalogItem)(item.item.IsFolder switch
                {
                    true => new FolderCatalogItem(item.item.Id, item.item.ParentId, item.item.Name,
                        item.Preview),
                    false => new GoodCatalogItem(item.item.Id, item.item.ParentId, item.item.Name,
                        item.IsAR, item.Price, item.Preview)
                }));
        }

        public async Task<Good> GetGoodAsync(Guid id)
        {
            await using var dbContext = new DnsСozyHomeContext(_config.DbConnectionString);
            var res = await dbContext.CatalogItems
                .Where(item => item.Id == id)
                .Include(item => item.GoodAdditionalInfo)
                .Include(item => item.GoodPrice)
                .Select(item => new
                {
                    item,
                    Images = item.CatalogItemImages
                        .Where(image => image.ImageIndex != 0)
                        .Select(image => image.Image)
                })
                .SingleAsync();

            return new Good(res.item.Id, res.item.ParentId, res.item.Name, res.item.GoodAdditionalInfo.IsAR,
                res.item.GoodPrice.Price,
                res.Images.ToList(), res.item.GoodAdditionalInfo.Description);
        }

        public async Task<byte[]> GetARModelAsync(Guid goodId)
        {
            await using var dbContext = new DnsСozyHomeContext(_config.DbConnectionString);
            return await dbContext.GoodARModels
                .Where(model => model.GoodId == goodId && model.ARModelType == 0)
                .Select(model => model.Armodel)
                .SingleAsync();
        }
    }
}