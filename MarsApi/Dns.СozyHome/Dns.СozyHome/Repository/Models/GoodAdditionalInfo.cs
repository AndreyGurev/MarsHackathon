using System;

namespace Dns.СozyHome.Repository.Models
{
    public partial class GoodAdditionalInfo
    {
        public Guid GoodId { get; set; }
        public string Description { get; set; }
        public bool IsAR { get; set; }

        public virtual CatalogItem Good { get; set; }
    }
}
