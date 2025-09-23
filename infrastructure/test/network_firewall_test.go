package test

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestNetworkFirewall(t *testing.T) {
	t.Parallel()

	// Test configuration
	awsRegion := "eu-central-1"
	availabilityZones := []string{"eu-central-1a", "eu-central-1b"}

	// Skip cleanup if SKIP_CLEANUP is set
	skipCleanup := os.Getenv("SKIP_CLEANUP") != ""

	// Set test stages directory
	testFolder := "."
	test_structure.SaveString(t, testFolder, "region", awsRegion)

	terraformOptions := &terraform.Options{
		TerraformDir: "..",
		VarFiles:     []string{"test/terraform.tfvars"},
		NoColor:      true,
		// Variables
		Vars: map[string]interface{}{
			"aws_region":         awsRegion,
			"availability_zones": availabilityZones,
		},
		// Retry configuration for slow operations
		MaxRetries:         60,
		TimeBetweenRetries: 30 * time.Second,
		RetryableTerraformErrors: map[string]string{
			".*Error creating Network Firewall.*":   "Waiting for Network Firewall to be created...",
			".*Error deleting Network Firewall.*":   "Waiting for Network Firewall to be deleted...",
			".*RequestError: send request failed.*": "Waiting for AWS API to be available...",
		},
	}

	// Save options for later stages
	test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)

	// Cleanup only if not skipped
	if !skipCleanup {
		defer test_structure.RunTestStage(t, "cleanup", func() {
			terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
			terraform.Destroy(t, terraformOptions)
		})
	}

	// Initialize terraform
	test_structure.RunTestStage(t, "init", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Init(t, terraformOptions)
	})

	// Deploy the infrastructure
	test_structure.RunTestStage(t, "apply", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Apply(t, terraformOptions)
	})

	// Validate the infrastructure
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		awsRegion := test_structure.LoadString(t, testFolder, "region")

		// Validate Transit Gateway
		tgwId := terraform.Output(t, terraformOptions, "transit_gateway_id")
		assert.NotEmpty(t, tgwId, "Transit Gateway ID should not be empty")

		cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(awsRegion))
		if err != nil {
			t.Fatalf("Failed to load AWS config: %v", err)
		}

		client := ec2.NewFromConfig(cfg)

		tgwOutput, err := client.DescribeTransitGateways(context.TODO(), &ec2.DescribeTransitGatewaysInput{
			TransitGatewayIds: []string{tgwId},
		})

		assert.NoError(t, err, "Transit Gateway not found")
		assert.NotEmpty(t, tgwOutput.TransitGateways, "Transit Gateway details should not be empty")
	})
}
