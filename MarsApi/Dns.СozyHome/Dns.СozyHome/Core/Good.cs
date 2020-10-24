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
    }
}