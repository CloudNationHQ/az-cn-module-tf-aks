package main

import (
	"context"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerservice/armcontainerservice"
	"github.com/cloudnationhq/az-cn-module-tf-aks/shared"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

type AksDetails struct {
	ResourceGroupName string
	Name              string
}

type ClientSetup struct {
	SubscriptionID string
	AksClient      *armcontainerservice.ManagedClustersClient
}

func (clientSetup *ClientSetup) GetAks(t *testing.T, details AksDetails) *armcontainerservice.ManagedCluster {
	resp, err := clientSetup.AksClient.Get(context.Background(), details.ResourceGroupName, details.Name, nil)
	require.NoError(t, err, "Failed to get aks cluster")
	return &resp.ManagedCluster
}

func (setup *ClientSetup) InitializeAksClient(t *testing.T, cred *azidentity.DefaultAzureCredential) {
	var err error
	setup.AksClient, err = armcontainerservice.NewManagedClustersClient(setup.SubscriptionID, cred, nil)
	require.NoError(t, err, "Failed to create aks client")
}

func TestAks(t *testing.T) {
	t.Run("VerifyAks", func(t *testing.T) {
		t.Parallel()

		cred, err := azidentity.NewDefaultAzureCredential(nil)
		require.NoError(t, err, "Failed to create credential")

		tfOpts := shared.GetTerraformOptions("../examples/complete")
		defer shared.Cleanup(t, tfOpts)
		terraform.InitAndApply(t, tfOpts)

		aksMap := terraform.OutputMap(t, tfOpts, "aks")
		subscriptionID := terraform.Output(t, tfOpts, "subscriptionId")

		aksDetails := AksDetails{
			ResourceGroupName: aksMap["resource_group_name"],
			Name:              aksMap["name"],
		}

		ClientSetup := &ClientSetup{SubscriptionID: subscriptionID}
		ClientSetup.InitializeAksClient(t, cred)
		aks := ClientSetup.GetAks(t, aksDetails)

		t.Run("VerifyAks", func(t *testing.T) {
			verifyAks(t, &aksDetails, aks)
		})
	})
}

func verifyAks(t *testing.T, details *AksDetails, aks *armcontainerservice.ManagedCluster) {
	t.Helper()

	require.Equal(
		t,
		details.Name,
		*aks.Name,
		"Aks name does not match expected value",
	)

	require.Equal(
		t,
		"Succeeded",
		string(*aks.Properties.ProvisioningState),
		"Aks provisioning state is not Suceeded",
	)

	require.True(
		t,
		strings.HasPrefix(details.Name, "aks"),
		"Aks name does not start with the right abbreviation",
	)
}
