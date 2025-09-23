# AWS Network Firewall with Transit Gateway

This repository provides a modular and reusable Terraform configuration to deploy a secure AWS network architecture using AWS Network Firewall, Transit Gateway, and VPCs. The solution enables centralized network inspection and segmentation between application workloads and the internet.

## Architecture

```
                    ┌──────────┐    ┌──────────┐
                    │  Spoke   │    │  Spoke   │
                    │  VPC 1   │    │  VPC 2   │
                    └────┬─────┘    └─────┬────┘
                         │                │
                         └───────┬────────┘
                                │
                         ┌──────▼──────┐
                         │   Transit   │
                         │  Gateway    │
                         └──────┬──────┘
                                │
                    ┌───────────▼───────────┐
                    │    Inspection VPC     │
                    │                       │
                    │   ┌───────────────┐   │
                    │   │    Network    │   │
                    │   │   Firewall    │   │
                    │   └───────┬───────┘   │
                    │           │           │
                    │   ┌───────▼───────┐   │
                    │   │     NAT       │   │
                    │   │   Gateway     │   │
                    │   └───────┬───────┘   │
                    └───────────┼───────────┘
                                │
                         ┌──────▼──────┐
                         │    IGW      │
                         └──────┬──────┘
                                │
                                ▼
                            Internet
```

## Features

- **Centralized Security**: All internet-bound traffic is inspected through AWS Network Firewall
- **Scalable Architecture**: Easy to add new spoke VPCs without changing the core infrastructure
- **High Availability**: Multi-AZ deployment for all components
- **Modular Design**: Separate modules for VPC, Transit Gateway, Network Firewall, and VPC attachments

## Architecture Components

### Core Modules
- **VPC Module**: Creates VPCs with customizable subnet types (public, private, attachment, firewall)
- **Transit Gateway Module**: Handles the creation of Transit Gateway and route tables
- **VPC Attachments Module**: Manages VPC attachments to Transit Gateway and route associations
- **Network Firewall Module**: Configures AWS Network Firewall with stateful inspection rules

### Network Flow
1. Spoke VPCs route all traffic to Transit Gateway
2. Transit Gateway forwards traffic to Inspection VPC
3. Network Firewall inspects traffic according to defined rules
4. Allowed traffic proceeds through NAT Gateway to Internet
5. Return traffic follows the reverse path

## Security Considerations

- All internet-bound traffic from spoke VPCs is inspected by Network Firewall
- Stateful firewall rules for egress filtering
- Private subnets with no direct internet access
- Network segmentation using Transit Gateway route tables
- Supports compliance requirements through centralized logging and inspection

## Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.0
- AWS account and credentials with permissions to create:
  - VPCs and related networking components
  - Transit Gateway
  - Network Firewall
  - IAM roles and policies

## Module Structure

```
modules/
├── network_firewall/        # AWS Network Firewall configuration
│   ├── Stateful rule groups
│   ├── Firewall policy
│   └── Network Firewall endpoints
├── transit_gateway/         # Transit Gateway and route tables
│   ├── Transit Gateway
│   └── Route tables (inspection and spoke)
├── vpc/                     # VPC with customizable subnet types
│   ├── Subnet configurations
│   ├── Route tables
│   └── NAT Gateway
└── vpc_attachments/        # Transit Gateway attachment management
    ├── VPC attachments
    ├── Route table associations
    └── Route propagations
```

## Running Tests

The project uses Terratest, which requires Go to be installed. Follow these steps to run the tests:

1. Install Go:
   ```sh
   # Using Homebrew on macOS
   brew install go

   # Or download from https://go.dev/dl/
   ```

2. Install test dependencies:
   ```sh
   cd infrastructure/test
   go mod download
   ```

3. Run the tests:
   ```sh
   go test -timeout 60m -v
   ```

Note: Make sure you have valid AWS credentials configured before running the tests.

## Known Limitations

- AWS Network Firewall endpoints must be deployed in their own subnets
- Transit Gateway attachments require dedicated subnets
- Initial rule group creation may take up to 30 seconds

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes with clear descriptions
4. Create a pull request

## Support

For bug reports and feature requests, please open an issue in the repository.

## License

This project is licensed under the MIT License.

---

