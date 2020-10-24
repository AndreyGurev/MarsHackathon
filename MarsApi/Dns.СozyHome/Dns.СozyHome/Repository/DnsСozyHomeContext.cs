using Dns.СozyHome.Repository.Models;
using Microsoft.EntityFrameworkCore;

namespace Dns.СozyHome.Repository
{
    public partial class DnsСozyHomeContext : DbContext
    {
        public DnsСozyHomeContext()
        {
        }

        public DnsСozyHomeContext(DbContextOptions<DnsСozyHomeContext> options)
            : base(options)
        {
        }

        public virtual DbSet<CatalogItemImage> CatalogItemImages { get; set; }
        public virtual DbSet<CatalogItem> CatalogItems { get; set; }
        public virtual DbSet<GoodAdditionalInfo> GoodAdditionalInfos { get; set; }
        public virtual DbSet<GoodARModel> GoodARModels { get; set; }
        public virtual DbSet<GoodPrice> GoodPrices { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. See http://go.microsoft.com/fwlink/?LinkId=723263 for guidance on storing connection strings.
                optionsBuilder.UseSqlServer("Server=localhost;Database=DnsСozyHome;User Id=sa;Password=1;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<CatalogItemImage>(entity =>
            {
                entity.HasKey(e => new { e.ItemId, e.ImageIndex });

                entity.Property(e => e.Image).IsRequired();

                entity.HasOne(d => d.Item)
                    .WithMany(p => p.CatalogItemImages)
                    .HasForeignKey(d => d.ItemId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_CatalogItemImages_CatalogItems");
            });

            modelBuilder.Entity<CatalogItem>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .IsClustered(false);

                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasMaxLength(250);
            });

            modelBuilder.Entity<GoodAdditionalInfo>(entity =>
            {
                entity.HasKey(e => e.GoodId);

                entity.Property(e => e.GoodId).ValueGeneratedNever();

                entity.Property(e => e.Description).IsRequired();

                entity.Property(e => e.IsAR).HasColumnName("IsAR");

                entity.HasOne(d => d.Good)
                    .WithOne(p => p.GoodAdditionalInfo)
                    .HasForeignKey<GoodAdditionalInfo>(d => d.GoodId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_GoodAdditionalInfos_CatalogItems");
            });

            modelBuilder.Entity<GoodARModel>(entity =>
            {
                entity.HasKey(e => new { e.GoodId, e.ArmodelType });

                entity.ToTable("GoodARModels");

                entity.Property(e => e.ArmodelType).HasColumnName("ARModelType");

                entity.Property(e => e.Armodel)
                    .IsRequired()
                    .HasColumnName("ARModel");

                entity.HasOne(d => d.Good)
                    .WithMany(p => p.GoodARModels)
                    .HasForeignKey(d => d.GoodId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_GoodARModels_CatalogItems");
            });

            modelBuilder.Entity<GoodPrice>(entity =>
            {
                entity.HasKey(e => e.GoodId);

                entity.Property(e => e.GoodId).ValueGeneratedNever();

                entity.Property(e => e.Price).HasColumnType("numeric(18, 2)");

                entity.HasOne(d => d.Good)
                    .WithOne(p => p.GoodPrice)
                    .HasForeignKey<GoodPrice>(d => d.GoodId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_GoodPrices_CatalogItems");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
