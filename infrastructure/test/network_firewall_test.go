package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the network firewall infrastructure.
func TestNetworkFirewall(t *testing.T) {
	t.Parallel()

	// The AWS region to deploy to. This should match the region in your terraform.tfvars.
	awsRegion := "eu-central-1"

	// Configure Terraform options.
	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located.
		TerraformDir: "..",

		// Variables to pass to our Terraform code using -var options.
		// Vars: map[string]interface{}{
		// 	"project_prefix": "terratest-fw",
		// },
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// --- Validation --- //

	// Get the ID of the Transit Gateway from the Terraform output.
	tgwId := terraform.Output(t, terraformOptions, "transit_gateway_id")

	// Use the AWS SDK to verify that the Transit Gateway exists.
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(awsRegion))
	assert.NoError(t, err, "Failed to load AWS config")

	client := ec2.NewFromConfig(cfg)

	_, err = client.DescribeTransitGateways(context.TODO(), &ec2.DescribeTransitGatewaysInput{
		TransitGatewayIds: []string{tgwId},
	})

	// Assert that the DescribeTransitGateways call was successful (meaning the TGW was found).
	assert.NoError(t, err, "Transit Gateway not found")

	// Add more assertions here to validate VPCs, subnets, routes, firewall, etc.
}
