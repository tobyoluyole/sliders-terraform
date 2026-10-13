# Sliders AWS Infrastructure

Terraform infrastructure for deploying the Sliders microservices platform on Amazon EKS. I designed and implemented the networking, Kubernetes clusters, workload IAM roles, storage integration, and cluster bootstrap configuration, with shared modules for staging and production.

This repository provisions the AWS infrastructure and installs the controllers that support application delivery. The companion [Sliders GitOps repository](https://github.com/tobyoluyole/sliders-gitops) defines the application workloads, database deployments, secret store, StorageClass, and monitoring stack reconciled by Argo CD.

## Infrastructure capabilities

- Separate staging and production configurations with independent remote state keys
- VPC networking with public and private subnets across three Availability Zones
- Amazon EKS clusters with managed node groups and configurable capacity bounds
- IAM Roles for Service Accounts (IRSA) for the AWS Load Balancer Controller, External Secrets Operator, and EBS CSI controller
- Amazon EBS CSI managed add-on with a version pinned per environment
- Helm installation of Argo CD, AWS Load Balancer Controller, and External Secrets Operator
- GitHub Actions authentication to AWS through OIDC
- Automatic Terraform plans and manually triggered applies

## Architecture

```text
GitHub Actions -- OIDC --> AWS IAM deployment role
                              |
                              v
                           Terraform
                              |
                 +------------+------------+
                 |                         |
             Staging VPC               Production VPC
                 |                         |
             EKS cluster               EKS cluster
                 |                         |
                 +-- Managed node groups --+
                 +-- IRSA roles -----------+
                 +-- EBS CSI driver -------+
                 +-- Helm controllers -----+
                              |
                            Argo CD
                              |
                     Sliders GitOps repository
                              |
              Application workloads, databases, monitoring
```

Each environment uses public and private subnets in `eu-west-1a`, `eu-west-1b`, and `eu-west-1c`. Worker nodes use the private subnets. The current configuration uses one NAT gateway per environment to control cost.

## Repository structure

```text
.
|-- .github/workflows/terraform.yaml
|-- environments
|   |-- staging
|   |   |-- backend.tf
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- terraform.tfvars
|   `-- production
|       |-- backend.tf
|       |-- main.tf
|       |-- variables.tf
|       `-- terraform.tfvars
`-- modules
    |-- vpc
    |-- eks
    |-- iam_irsa
    |-- eks_addons
    |-- helm_bootstraps
    `-- argocd
```

| Module | Responsibility |
| --- | --- |
| `vpc` | Subnets, routing, NAT, DNS configuration, and load balancer discovery tags |
| `eks` | Kubernetes control plane, access entries, managed nodes, CoreDNS, kube-proxy, and VPC CNI |
| `iam_irsa` | IAM roles and policies bound to controller service accounts |
| `eks_addons` | EBS CSI managed add-on and its IAM role association |
| `helm_bootstraps` | AWS Load Balancer Controller and External Secrets Operator |
| `argocd` | Argo CD Helm release |

The EBS add-on depends on the EKS and IAM modules so its cluster, nodes, role, and policy attachments are created first. Helm bootstrap includes a short delay after installing the load balancer controller to allow its webhook to start.

## Environment configuration

These are the values currently declared in the repository, rather than a report of live cluster capacity:

| Setting | Staging | Production |
| --- | --- | --- |
| Region | `eu-west-1` | `eu-west-1` |
| Cluster | `sliders-staging-cluster` | `sliders-production-cluster` |
| VPC CIDR | `10.0.0.0/16` | `10.1.0.0/16` |
| Instance type | `t3.medium` | `m5.large` |
| Minimum / desired / maximum nodes | `3 / 4 / 5` | `3 / 3 / 10` |
| Kubernetes version | `1.37` | `1.37` |
| EBS CSI add-on version | `v1.66.0-eksbuild.1` | `v1.66.0-eksbuild.1` |

Each environment uses its own `terraform.tfvars` and an S3 state key under `env/<environment>/terraform.tfstate`. Backend configuration enables encryption and uses the existing DynamoDB locking table. The state bucket and locking table must exist before initialization; this repository does not provision them.

## Deployment workflow

The workflow in `.github/workflows/terraform.yaml` has two paths:

1. **Plan:** relevant pushes to `main` and pull requests targeting `main` initialize, validate, and plan both environments through a matrix job.
2. **Apply:** a manual workflow dispatch applies only the selected environment, using `terraform apply -input=false -auto-approve`.

The apply job calculates a fresh plan; it does not apply a saved artifact from the earlier plan job. Review the changes and plan output before triggering it. Staging should be verified before dispatching an apply for production.

The workflow pins Terraform to `1.9.0` and assumes an AWS role through GitHub OIDC. AWS access keys are not embedded in the workflow.

## Adapting the configuration

Before deploying into another account or repository, configure:

- An S3 state bucket and DynamoDB lock table, then update both `backend.tf` files
- The GitHub OIDC provider and IAM deployment role, including trust scoped to your repository
- The deployment role ARN and region in the GitHub Actions workflow
- The administrator principal in `modules/eks/main.tf`
- The Secrets Manager ARN scope in `modules/iam_irsa/main.tf`
- Environment names, cluster versions, instance types, subnet CIDRs, and capacity bounds in each environment's `terraform.tfvars`
- Compatible Helm chart and add-on versions for the target Kubernetes version

The AWS account identifiers in this repository refer to my deployment environment. Replace them with your own configuration when adapting the infrastructure.

## Local validation

From the repository root:

```bash
terraform fmt -check -recursive
terraform -chdir=environments/staging init -backend=false
terraform -chdir=environments/staging validate
terraform -chdir=environments/production init -backend=false
terraform -chdir=environments/production validate
```

Backend initialization is disabled for these configuration checks. Planning against deployed infrastructure requires normal backend initialization and AWS access. Deployment is handled through the GitHub Actions workflow.

Commit Terraform source and provider lock files. Keep state, credentials, and local plan artifacts out of version control.

## Connecting infrastructure to GitOps

Terraform installs Argo CD; it does not create the Sliders Argo CD Application resources. After infrastructure provisioning, bootstrap the applications from the companion GitOps repository:

```bash
aws eks update-kubeconfig --region eu-west-1 --name sliders-staging-cluster
kubectl config current-context
kubectl apply -f argocd/
```

Run the last command from the GitOps repository. Use the corresponding cluster name when targeting another environment.

Terraform owns the EBS driver and its IAM permissions. Argo CD owns the `gp3` StorageClass, database PVCs, ExternalSecret resources, and monitoring application. This keeps infrastructure and workload configuration in their respective repositories.

## Operational verification

After a pipeline apply, check the target cluster:

```bash
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get pods -n kube-system
kubectl get csidriver ebs.csi.aws.com
kubectl get pods -n external-secrets
kubectl get pods -n argocd
```

After GitOps bootstrap, verify that database PVCs bind, ExternalSecrets synchronize, and workload pods become ready. A successful Terraform apply establishes resource provisioning; application startup and end-to-end behavior require separate checks.

## Engineering decisions and roadmap

- **Environment reuse:** shared modules provide one implementation with independent environment inputs and state.
- **Storage provisioning:** the EBS CSI driver and its IAM role are managed together. Volume placement must be considered alongside node capacity when scheduling stateful workloads.
- **Capacity management:** managed node groups currently span multiple zones. Cluster Autoscaler and zone-specific scaling groups are planned; configuring minimum and maximum sizes alone does not install a Kubernetes node autoscaler.
- **Availability:** the single NAT gateway per environment and the Argo CD configuration with Redis HA disabled are explicit cost and availability tradeoffs. Production resilience needs a separate review.
- **Compatibility:** Argo CD and other Helm releases remain explicitly versioned. An Argo CD upgrade to address the observed Kubernetes status-schema comparison error remains follow-up work.
- **Pipeline evolution:** saved-plan promotion, environment approval gates, and explicit formatting checks are potential improvements to the current workflow.


