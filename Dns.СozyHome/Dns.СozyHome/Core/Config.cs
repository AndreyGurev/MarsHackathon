namespace Dns.СozyHome.Core
{
    public class Config
    {
        public string DbConnectionString { get; }

        public Config(string dbConnectionString)
        {
            DbConnectionString = dbConnectionString;
        }
    }
}