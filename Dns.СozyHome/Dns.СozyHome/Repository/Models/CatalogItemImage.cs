using System;

namespace Dns.СozyHome.Repository.Models
{
    public partial class CatalogItemImage
    {
        public Guid ItemId { get; set; }
        public byte ImageIndex { get; set; }
        public byte[] Image { get; set; }

        public virtual CatalogItem Item { get; set; }
    }
}
