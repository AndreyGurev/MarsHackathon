using System;

namespace Dns.СozyHome.Core
{
    public interface ICatalogItem
    {
        public Guid Id { get; }
        public Guid ParentId { get; }
        public string Name { get; }
        public bool IsFolder => this is FolderCatalogItem;
        public bool IsAr => this is GoodCatalogItem goodCatalogItem && goodCatalogItem.IsAR;
        public decimal Price => this is GoodCatalogItem goodCatalogItem ? goodCatalogItem.Price : 0;
        public byte[] Preview { get; }
    }
}