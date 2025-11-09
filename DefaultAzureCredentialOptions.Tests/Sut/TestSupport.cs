using System;
using System.Collections.Generic;

namespace Azure.Core
{
    // Minimal stub of TokenCredentialOptions to allow tests to compile
    public class TokenCredentialOptions
    {
        internal virtual T Clone<T>() where T : new()
        {
            return new T();
        }
    }

    // Minimal stub of ResourceIdentifier
    public class ResourceIdentifier
    {
        public string Id { get; set; }
        public ResourceIdentifier() { }
        public ResourceIdentifier(string id) => Id = id;
    }
}

namespace Azure.Identity
{
    using System.Collections.Generic;

    internal static class EnvironmentVariables
    {
        public static string TenantId => null;
        public static string ClientId => null;
        public static string Username => null;
        public static IList<string> AdditionallyAllowedTenants { get; } = new List<string>();
    }
}
