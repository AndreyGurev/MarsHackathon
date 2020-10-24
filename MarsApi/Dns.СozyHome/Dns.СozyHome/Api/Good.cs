using System;
using System.Collections.Generic;
using Dns.СozyHome.Core;

namespace Dns.СozyHome.Api
{
    public class GoodView
    {
        public Guid Id { get; }
        public Guid ParentId { get; }
        public string Name { get; }
        public bool IsAR { get; }
        public decimal Price { get; }
        public List<byte[]> Images { get; }
        public string Description { get; }

        public GoodView(Good good)
        {
            Id = good.Id;
            ParentId = good.ParentId;
            Name = good.Name;
            IsAR = good.IsAR;
            Price = good.Price;
            Images = good.Images;
            Description = good.Description;
        }
    }
}