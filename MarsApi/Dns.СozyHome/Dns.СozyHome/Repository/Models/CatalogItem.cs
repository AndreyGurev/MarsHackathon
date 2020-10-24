using System;
using System.Collections.Generic;

namespace Dns.СozyHome.Repository.Models
{
    public partial class CatalogItem
    {
        public CatalogItem()
        {
            CatalogItemImages = new HashSet<CatalogItemImage>();
            GoodARModels = new HashSet<GoodARModel>();
        }

        public Guid Id { get; set; }
        public Guid ParentId { get; set; }
        public string Name { get; set; }
        public bool IsFolder { get; set; }

        public virtual GoodAdditionalInfo GoodAdditionalInfo { get; set; }
        public virtual GoodPrice GoodPrice { get; set; }
        public virtual ICollection<CatalogItemImage> CatalogItemImages { get; set; }
        public virtual ICollection<GoodARModel> GoodARModels { get; set; }
    }
}
