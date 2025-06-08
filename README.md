3-Tier Architecture Provisioning with Terraform on AWS
Project Overview
This project provisions a secure, scalable, and highly available 3-tier architecture on AWS using Terraform. The architecture includes a Virtual Private Cloud (VPC), Application Load Balancer (ALB), Auto Scaling groups, EC2 instances, RDS for the database tier, S3 for Terraform state storage, DynamoDB for state locking, AWS Secrets Manager for secure credential management, and Route 53 for DNS configuration.
Architecture Overview
The 3-tier architecture consists of:

Presentation Tier: An Application Load Balancer (ALB) distributes incoming traffic to EC2 instances in an Auto Scaling group.
Application Tier: EC2 instances in multiple Availability Zones, managed by an Auto Scaling group for high availability and scalability.
Data Tier: An RDS instance for relational database storage, configured with Multi-AZ for fault tolerance.
Networking: A VPC with public and private subnets across multiple Availability Zones, integrated with Route 53 for DNS management.
State Management: Terraform state is stored in an S3 bucket, with state locking handled by DynamoDB.
Security: AWS Secrets Manager stores sensitive credentials, such as RDS database credentials.

AWS Services Used

VPC: Isolated network environment with public and private subnets.
ALB: Distributes incoming HTTP/HTTPS traffic to EC2 instances.
Auto Scaling: Dynamically scales EC2 instances based on demand.
EC2: Hosts the application in the presentation and application tiers.
RDS: Managed relational database service for the data tier.
S3: Stores Terraform state files securely.
DynamoDB: Provides state locking to prevent concurrent Terraform runs.
AWS Secrets Manager: Securely stores and manages sensitive information.
Route 53: Manages DNS records for the application.

The key objectives of the project include:

  Automation: Using Terraform to automate the provisioning of a complete 3-tier architecture, reducing manual configuration errors and deployment time.
  Scalability: Incorporating Auto Scaling and ALB to handle varying traffic loads dynamically, ensuring the application remains responsive during demand spikes.
  High Availability: Utilizing multiple Availability Zones, Multi-AZ RDS, and load balancing to minimize downtime and ensure fault tolerance.
  Security: Implementing AWS Secrets Manager for secure credential management and encryption for sensitive data in S3 and RDS.
  State Management: Using S3 and DynamoDB for Terraform state storage and locking to enable safe, collaborative infrastructure management.
  DNS Management: Integrating Route 53 for reliable and customizable domain name resolution.
