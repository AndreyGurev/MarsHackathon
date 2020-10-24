using System;

namespace Dns.СozyHome.Core
{
    public class GoodCatalogItem: ICatalogItem
    {
        public Guid Id { get; }
        public Guid ParentId { get; }
        public string Name { get; }
        public bool IsAR { get; }
        public decimal Price { get; }
        public byte[] Preview { get; }

        public GoodCatalogItem(Guid id, Guid parentId, string name, bool isAr, decimal price, byte[] preview)
        {
            Id = id;
            ParentId = parentId;
            Name = name;
            IsAR = isAr;
            Price = price;
            Preview = preview;
        }
    }
}