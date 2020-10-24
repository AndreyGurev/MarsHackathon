using System;
using Dns.СozyHome.Core;

namespace Dns.СozyHome.Api
{
    public class CatalogItemView
    {
        public Guid Id { get; }
        public Guid ParentId { get; }
        public string Name { get; }
        public bool IsFolder { get; }
        public bool IsAR { get; }
        public decimal Price { get; }
        public byte[] Preview { get; }

        public CatalogItemView(ICatalogItem item)
        {
            Id = item.Id;
            ParentId = item.Id;
            Name = item.Name;
            IsFolder = item.IsFolder;
            IsAR = item.IsAr;
            Price = item.Price;
            Preview = item.Preview;
        }
    }
}