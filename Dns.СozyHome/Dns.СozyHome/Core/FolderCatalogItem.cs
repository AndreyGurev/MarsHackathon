using System;

namespace Dns.СozyHome.Core
{
    public class FolderCatalogItem: ICatalogItem
    {
        public Guid Id { get; }
        public Guid ParentId { get; }
        public string Name { get; }
        public byte[] Preview { get; }

        public FolderCatalogItem(Guid id, Guid parentId, string name, byte[] preview)
        {
            Id = id;
            ParentId = parentId;
            Name = name;
            Preview = preview;
        }
    }
}