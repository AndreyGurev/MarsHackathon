using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Dns.СozyHome.Core
{
    public interface ICozyHomeRepository
    {
        Task<List<ICatalogItem>> GetCatalogItemsAsync(Guid parentId);
        Task<List<ICatalogItem>> GetCatalogItemsAsync(Guid parentId);
    }
}