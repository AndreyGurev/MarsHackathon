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
                .Select(item => new
                {
                    item,
                    Images = item.CatalogItemImages
                        .Where(image => image.ImageIndex != 0)
                        .Select(image => image.Image)
                })
                .SingleAsync();

            return new Good(res.item.Id, res.item.ParentId, res.item.Name, res.item.GoodAdditionalInfo.IsAR, res.item.GoodPrice.Price,
                res.Images.ToList(), res.item.GoodAdditionalInfo.Description);
        }

        public async Task<byte[]> GetARModelAsync(Guid goodId)
        {
            await using var dbContext = new DnsСozyHomeContext();
            return await dbContext.GoodARModels
                .Where(model => model.GoodId == goodId && model.ARModelType == 0)
                .Select(model => model.Armodel)
                .SingleAsync();
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