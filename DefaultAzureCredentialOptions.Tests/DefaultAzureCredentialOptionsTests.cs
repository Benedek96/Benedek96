using System;
using Xunit;
using Azure.Identity;

namespace DefaultAzureCredentialOptions.Tests
{
    public class DefaultAzureCredentialOptionsTests
    {
        [Fact]
        public void TenantId_Set_PropagatesToOtherTenantIds()
        {
            var options = new DefaultAzureCredentialOptions();
            options.TenantId = "tenant-a";

            Assert.Equal("tenant-a", options.TenantId);
            Assert.Equal("tenant-a", options.InteractiveBrowserTenantId);
            Assert.Equal("tenant-a", options.SharedTokenCacheTenantId);
            Assert.Equal("tenant-a", options.VisualStudioTenantId);
            Assert.Equal("tenant-a", options.VisualStudioCodeTenantId);
        }

        [Fact]
        public void Setting_InteractiveBrowserTenantId_When_TenantId_AlreadySet_Throws()
        {
            var options = new DefaultAzureCredentialOptions();
            options.TenantId = "tenant-a";

            var ex = Assert.Throws<InvalidOperationException>(() => options.InteractiveBrowserTenantId = "tenant-b");
            Assert.Contains("InteractiveBrowserTenantId", ex.Message);
        }

        [Fact]
        public void Setting_SharedTokenCacheTenantId_When_TenantId_AlreadySet_Throws()
        {
            var options = new DefaultAzureCredentialOptions();
            options.TenantId = "tenant-a";

            var ex = Assert.Throws<InvalidOperationException>(() => options.SharedTokenCacheTenantId = "tenant-b");
            Assert.Contains("SharedTokenCacheTenantId", ex.Message);
        }

        [Fact]
        public void Setting_VisualStudioTenantId_When_TenantId_AlreadySet_Throws()
        {
            var options = new DefaultAzureCredentialOptions();
            options.TenantId = "tenant-a";

            var ex = Assert.Throws<InvalidOperationException>(() => options.VisualStudioTenantId = "tenant-b");
            Assert.Contains("VisualStudioTenantId", ex.Message);
        }

        [Fact]
        public void Setting_VisualStudioCodeTenantId_When_TenantId_AlreadySet_Throws()
        {
            var options = new DefaultAzureCredentialOptions();
            options.TenantId = "tenant-a";

            var ex = Assert.Throws<InvalidOperationException>(() => options.VisualStudioCodeTenantId = "tenant-b");
            Assert.Contains("VisualStudioCodeTenantId", ex.Message);
        }
    }
}
