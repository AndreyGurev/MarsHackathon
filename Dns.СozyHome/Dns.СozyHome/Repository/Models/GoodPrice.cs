using System;

namespace Dns.СozyHome.Repository.Models
{
    public partial class GoodPrice
    {
        public Guid GoodId { get; set; }
        public decimal Price { get; set; }

        public virtual CatalogItem Good { get; set; }
    }
}
