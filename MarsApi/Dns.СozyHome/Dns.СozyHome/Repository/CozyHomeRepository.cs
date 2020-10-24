using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dns.СozyHome.Core;
using Dns.СozyHome.Repository.Models;
using Microsoft.EntityFrameworkCore;

namespace Dns.СozyHome.Repository
{
    public class CozyHomeRepository : ICozyHomeRepository
    {
        public async Task<List<ICatalogItem>> GetCatalogItemsAsync(Guid parentId)
        {
            await using var dbContext = new DnsСozyHomeContext();
            var res = await dbContext.CatalogItems
                .Where(item => item.ParentId == parentId)
                .Include(item => item.GoodAdditionalInfo)
                .Include(item => item.GoodPrice)
                .Include(item => item.CatalogItemImages)
                .ToListAsync();

            return res.ConvertAll(ConvertToModel);
        }

        public async Task<Good> GetGoodAsync(Guid id)
        {
            await using var dbContext = new DnsСozyHomeContext();
            var res = await dbContext.CatalogItems
                .Where(item => item.Id == id)
                .Include(item => item.GoodAdditionalInfo)
                .Include(item => item.GoodPrice)
                .Include(item => item.CatalogItemImages)
                .SingleAsync();

            return new Good(res.Id, res.ParentId, res.Name, res.GoodAdditionalInfo.IsAR, res.GoodPrice.Price,
                res.CatalogItemImages.Select(image => image.Image).ToList(), res.GoodAdditionalInfo.Description);
        }

        private ICatalogItem ConvertToModel(CatalogItem item) =>
            item.IsFolder switch
            {
                true => new FolderCatalogItem(item.Id, item.ParentId, item.Name,
                    item.CatalogItemImages.FirstOrDefault()?.Image),
                false => new GoodCatalogItem(item.Id, item.ParentId, item.Name, item.GoodAdditionalInfo.IsAR,
                    item.GoodPrice.Price, item.CatalogItemImages.FirstOrDefault()?.Image)
            };
    }
}