using System;

namespace Dns.СozyHome.Repository.Models
{
    public partial class GoodARModel
    {
        public Guid GoodId { get; set; }
        public byte ARModelType { get; set; }
        public byte[] Armodel { get; set; }

        public virtual CatalogItem Good { get; set; }
    }
}
