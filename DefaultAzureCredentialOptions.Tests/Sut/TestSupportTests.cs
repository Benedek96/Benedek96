using System;
using System.Collections.Generic;
using Xunit;

namespace Azure.Core.Tests.Sut
{
    public class TestSupportTests
    {
        private class SimpleClass
        {
            public int Number { get; set; } = 42;
        }

        [Fact]
        public void Clone_Generic_ReturnsNewInstance()
        {
            var options = new TokenCredentialOptions();

            var cloned = options.Clone<SimpleClass>();

            Assert.NotNull(cloned);
            // Ensure it's a distinct instance with default values
            Assert.IsType<SimpleClass>(cloned);
            Assert.Equal(0, cloned.Number); // default(int) because Clone uses new T()
        }

        [Fact]
        public void ResourceIdentifier_ConstructorsAndProperty_Work()
        {
            var empty = new ResourceIdentifier();
            Assert.Null(empty.Id);

            var id = new ResourceIdentifier("/subscriptions/123/resourceGroups/rg");
            Assert.Equal("/subscriptions/123/resourceGroups/rg", id.Id);

            id.Id = "changed";
            Assert.Equal("changed", id.Id);
        }

        [Fact]
        public void EnvironmentVariables_Defaults()
        {
            // The test support defines these to return null or an empty list.
            Assert.Null(Azure.Identity.EnvironmentVariables.TenantId);
            Assert.Null(Azure.Identity.EnvironmentVariables.ClientId);
            Assert.Null(Azure.Identity.EnvironmentVariables.Username);

            var list = Azure.Identity.EnvironmentVariables.AdditionallyAllowedTenants;
            Assert.NotNull(list);
            Assert.IsType<List<string>>(list);
            Assert.Empty(list);
        }
    }
}
