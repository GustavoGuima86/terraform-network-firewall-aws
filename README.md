# 🚧 Work In Progress (WIP)

This project is under active development. Features, structure, and documentation may change frequently.

# Terraform Network Firewall AWS

This repository provides a modular and reusable Terraform configuration to deploy a secure AWS network architecture using AWS Network Firewall, Transit Gateway, and VPCs. The solution is designed to enable inspection and segmentation of network traffic between application workloads and the internet, following best practices for security and scalability.

## Features

- **Spoke VPC**: For application workloads, with private subnets.
- **Inspection VPC**: Hosts AWS Network Firewall and NAT Gateway for traffic inspection.
- **Transit Gateway**: Centralized routing between VPCs and the internet.
- **AWS Network Firewall**: Provides stateful, managed network security.
- **Modular Design**: Uses Terraform modules for VPC, Transit Gateway, and Network Firewall for easy customization and reuse.

## Directory Structure

```
infrastructure/           # Root Terraform configuration
  main.tf                 # Main entrypoint
  outputs.tf              # Outputs for integration and reference
  variables.tf            # Input variables
  terraform.tfvars        # Variable values
modules/
  vpc/                    # VPC module
  transit_gateway/        # Transit Gateway module
  network_firewall/       # Network Firewall module
```

## Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.0
- AWS account and credentials with permissions to create VPCs, Transit Gateway, Network Firewall, etc.

## Usage

1. Clone the repository:
   ```sh
   git clone <repo-url>
   cd terraform-network-firewall-aws/infrastructure
   ```
2. Initialize Terraform:
   ```sh
   terraform init
   ```
3. Review and customize `terraform.tfvars` as needed.
4. Plan and apply the configuration:
   ```sh
   terraform plan
   terraform apply
   ```

## Outputs

Key outputs include:
- Spoke VPC and subnet IDs
- Inspection VPC and NAT Gateway IDs
- Transit Gateway ID
- AWS Network Firewall ARN

See `infrastructure/outputs.tf` for details.

## Customization

- Modify variables in `infrastructure/variables.tf` and `terraform.tfvars` to fit your environment.
- Extend or replace modules in `modules/` as needed.

## License

This project is licensed under the MIT License.

---

**Note:** This project is a work in progress. Contributions and feedback are welcome!

