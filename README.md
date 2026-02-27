# devops-pipeline-aws

End-to-end CI/CD pipeline deploying a containerized Node.js application on AWS using Terraform, Ansible, Docker, Kubernetes, and GitLab CI.

## Architecture
```
git push → GitLab CI → Build Docker Image → Push to DockerHub
                     → Ansible → SSH into EC2 → kubectl apply → App Live
```

## Stack

- **Node.js** — Express REST API
- **Docker** — containerized application
- **Kubernetes** — 3-replica deployment on Minikube
- **Terraform** — AWS infrastructure (VPC, subnet, security group, EC2)
- **Ansible** — server configuration (Docker, Minikube, kubectl)
- **GitLab CI** — automated build and deploy pipeline
- **AWS EC2** — t3.small instance (2 vCPU / 2GB RAM)

## Pipeline Stages

| Stage | What It Does |
|---|---|
| Build | Builds Docker image and pushes to DockerHub |
| Deploy | Runs Ansible playbook, applies Kubernetes manifests |

## Infrastructure

Terraform provisions:
- Custom VPC and public subnet
- Internet gateway and route table
- Security group
- EC2 instance (Ubuntu 24.04)

Ansible configures:
- Docker
- Minikube
- kubectl

## Run Locally
```bash
cd app
npm install
node index.js
```

## Endpoints

- `GET /` — returns app info
- `GET /health` — health check for Kubernetes probes