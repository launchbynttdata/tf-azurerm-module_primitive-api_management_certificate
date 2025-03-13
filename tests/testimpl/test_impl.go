package testimpl

import (
	"context"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	apiManagement "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/apimanagement/armapimanagement"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestApiManagementModule(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %e\n", err)
	}

	t.Run("doesApiManagementBackendExist", func(t *testing.T) {
		resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
		serviceName := terraform.Output(t, ctx.TerratestTerraformOptions(), "api_management_name")
		certificateName := terraform.Output(t, ctx.TerratestTerraformOptions(), "certificate_name")
		certificateThumbprint := terraform.Output(t, ctx.TerratestTerraformOptions(), "certificate_thumbprint")

		options := arm.ClientOptions{
			ClientOptions: azcore.ClientOptions{
				Cloud: cloud.AzurePublic,
			},
		}

		certificateClient, err := apiManagement.NewCertificateClient(subscriptionId, credential, &options)
		if err != nil {
			t.Fatalf("Error getting API Management backend client: %v", err)
		}

		response, err := certificateClient.Get(context.Background(), resourceGroupName, serviceName, certificateName, nil)
		if err != nil {
			t.Fatalf("Error getting API Management backend: %v", err)
		}

		assert.Equal(t, certificateThumbprint, *response.Properties.Thumbprint)
	})
}
