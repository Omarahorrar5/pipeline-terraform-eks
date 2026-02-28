# pipeline-terraform-eks

End-to-end CI/CD pipeline deploying a containerized Node.js application on AWS EKS using Terraform, Docker, and GitLab CI.

## Pipeline Architecture

<p align="center">
  <img src="./eks pipeline.png" alt="CI/CD & DevSecOps Pipeline" width="800"/>
</p>

## Flow

```
git push
    ↓
GitLab CI — 3 stages
    ↓
Stage 1: Terraform → reads state from S3 → provisions EKS cluster if not exists
    ↓
Stage 2: Docker → builds image → pushes to DockerHub
    ↓
Stage 3: kubectl → deploys to EKS → 3 pods running
    ↓
AWS LoadBalancer → public URL → app live
```

## Stack

- **Node.js** — Express REST API
- **Docker** — containerized application
- **Kubernetes (EKS)** — managed cluster with 2 worker nodes (t3.small)
- **Terraform** — AWS infrastructure as code with S3 remote state
- **GitLab CI** — automated 3-stage pipeline
- **AWS** — EKS, VPC, subnets, IAM roles, LoadBalancer, S3

## Project Structure

```
pipeline-terraform-eks/
├── app/
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── outputs.tf
├── .gitlab-ci.yml
├── eks_pipeline.png
└── README.md
```

## Infrastructure (Terraform)

Terraform provisions:
- VPC with 2 public subnets across 2 availability zones
- Internet gateway and route tables
- Security group
- IAM roles for EKS control plane and worker nodes
- EKS cluster with managed node group (2 nodes, scales 1-3)

State is stored remotely in AWS S3.

## Pipeline Stages

| Stage | Trigger | What It Does |
|---|---|---|
| infra | always | terraform init → plan → apply |
| build | always | docker build → push to DockerHub |
| deploy | always | kubectl apply → rollout restart |

## Kubernetes

- Deployment with 3 replicas
- Service type LoadBalancer — AWS provisions a public load balancer automatically
- Image pulled from DockerHub on every deploy

## API Endpoints

| Endpoint | Description |
|---|---|
| `GET /` | Returns app info |
| `GET /health` | Health check for Kubernetes probes |

---

## Testing

### Connect to the cluster
```bash
aws eks update-kubeconfig --name express-cluster --region us-east-1
```

### Check nodes
```bash
kubectl get nodes
```

### Check pods
```bash
kubectl get pods
```

### Check service and get public URL
```bash
kubectl get svc
```

### Test the app
```bash
curl http://EXTERNAL-IP
```

Expected response:
```json
{
  "message": "Hello from Node.js App!",
  "version": "1.0.0",
  "environment": "development"
}
```

### Check deployment details
```bash
kubectl describe deployment express-deployment
```

### Check pod logs
```bash
kubectl logs -l app=express
```

### Check Terraform state
```bash
aws s3 ls s3://omar-terraform-state-eks
```