# DevOps Challenge Containerized Flask App with CI/CD

This project implements a small web service using Python Flask. The goal was to build and containerize the app, create Terraform infrastructure for a possible cloud deployment, and set up a CI/CD pipeline that validates the container inside a local Kubernetes cluster (kind) using GitHub Actions.

# Service Overview

The app exposes two simple endpoints:

- "/health" returns a JSON health check: "{ "status": "OK" }"
- "/" returns a static string: "Hello  Devops This is a assignment test"

Code is located under "app/".


# Docker Image

The Dockerfile uses a multi-stage build with "python:3.11-slim". The container runs as a non-root user and is optimized, Tested locally with:

'''
docker build -t devops-challenge ./app
docker run -p 8080:8080 devops-challenge
'''

# CICD pipeline

The pipeline is defined in the repo location at ".github/workflows/pipeline.yml". It's set up to take care of the full build and verify flow:

Installs dependencies and runs basic tests using pytest

Runs linting with flake8 to keep the code clean

Builds the Docker image for the app

Spins up a local Kubernetes cluster using kind

Deploys the image to the cluster using a simple Pod manifest

Port forwards to make the app reachable on localhost:8080

Curls the /health endpoint with retries to make sure the container is actually running and responding

Captures the response from the root endpoint and saves it as screenshot.png

Uploads the screenshot as an artifact so it is easy to review

This setup gives a full validation of the container in a live Kubernetes environment.


# kubernetes Manifest
A single Pod definition is used, located at manifests/pod.yaml. The pod includes a readiness probe using the /health endpoint.

No service or ingress is required for this use case, since traffic is accessed via port forward during CI.

# IAC Terraform 
Terraform config is located under the iac/ directory.

Even though this project uses a local kind cluster for deployment, the Terraform code is included to show how the app could be deployed to Google Cloud Run if needed.

The configuration defines:

A Docker Artifact Registry repository (for hosting container images)

A service account with minimal permissions for Cloud Run deployment

A basic Cloud Run service that points to a container image

In this  cuerrent devops challenge setup, I didn’t apply the Terraform, I just make sure the code is clean and valid.

The CI pipeline runs the following Terraform steps:

terraform init

terraform fmt -check

terraform validate

terraform plan (output only, no apply)

This proves the infrastructure code is correct and ready to use.

# Monitoring / Observability

The app includes a /health endpoint which acts as a basic readiness check, I used it in the pipeline to verify that the container is up and responding.

To add better visibility, I integrated prometheus_flask_exporter. This automatically exposes a /metrics endpoint that Prometheus can scrape. It gives useful data like:

Number of requests per route

Request durations (latency buckets)

HTTP status code counts

This would be enough to plug into a basic Grafana dashboard if the app was deployed to a real cluster.

If this were running in production, we can also  also set up:

Alerts for slow responses or failed health checks (via Prometheus + Alertmanager)

Dashboards for traffic, latency, and error rate

Log aggregation using something like Stackdriver, Loki, or Elasticsearch

Right now logs just go to stdout/stderr, which works fine for CI. For real use, we would format logs as JSON and ship them to a centralized log system.

# Instructions to test locally

- Docker
To build and run the container locally 
docker build -t devops-challenge ./app
docker run -p 8080:8080 devops-challenge

To check that the service is responding
curl http://localhost:8080/
# Hello  Devops This is a assignment test

curl http://localhost:8080/health
# {"status": "OK"}

curl http://localhost:8080/metrics
# Prometheus metrics output

- Python App (without Docker)
cd app
pip install -r requirements.txt
python app.py

curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/metrics

- Terraform (IAC)
cd iac
terraform init
terraform fmt -check
terraform validate
cp terraform.tfvars.example terraform.tfvars
terraform plan -out=planfile -lock=false



