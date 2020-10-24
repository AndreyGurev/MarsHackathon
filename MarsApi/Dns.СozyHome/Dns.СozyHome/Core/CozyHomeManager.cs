using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Dns.СozyHome.Core
{
    public class CozyHomeManager
    {
        private readonly ICozyHomeRepository _repository;

        public CozyHomeManager(ICozyHomeRepository repository)
        {
            _repository = repository;
        }

        public Task<List<ICatalogItem>> GetCatalogItemsAsync(Guid parentId) =>
            _repository.GetCatalogItemsAsync(parentId);

        public Task<Good> GetGoodAsync(Guid id) =>
            _repository.GetGoodAsync(id);
    }
}