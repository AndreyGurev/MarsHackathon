using System;
using System.Collections.Generic;

namespace Dns.СozyHome.Core
{
    public class Good
    {
        public Guid Id { get; }
        public Guid ParentId { get; }
        public string Name { get; }
        public bool IsAR { get; }
        public decimal Price { get; }
        public List<byte[]> Images { get; }
        public string Description { get; }

        public Good(Guid id, Guid parentId, string name, bool isAr, decimal price, List<byte[]> images, string description)
        {
            Id = id;
            ParentId = parentId;
            Name = name;
            IsAR = isAr;
            Price = price;
            Images = images;
            Description = description;
        }
    }
}