# ⚙️ Ethereum Node Cluster on Kubernetes

A production-ready Ethereum node cluster with **Geth** (Execution Layer) and **Prysm** (Consensus Layer) on Azure Kubernetes Service (AKS). Includes integrated observability (Prometheus, Grafana, Loki), Redis caching, system tuning (`sysctl`), and auto-scaling support.

---

## 📁 Project Structure

ethereum-node-cluster/├── docker/geth/                 # Dockerfile for hardened Geth image├── exporters/node-exporter/    # Prometheus Node Exporter Kubernetes manifests├── grafana-dashboards/         # Custom Grafana dashboards for Geth and Prysm├── k8s/                        # Kubernetes manifests organized by component│   ├── geth/                   # Geth StatefulSet, Service, PVC│   ├── prysm/                  # Prysm StatefulSet, Service│   ├── hpa/                    # Horizontal Pod Autoscaler for Geth│   ├── ingress/                # NGINX Ingress for Geth RPC│   ├── monitoring/             # Prometheus, Grafana, Loki, Alerts│   ├── redis/                  # Redis for caching│   └── sysctl/                 # System tuning DaemonSet├── terraform/                  # Terraform for provisioning AKS and infra├── README.md                   # 📘 You're here

---

## 🛠️ 1. Build Hardened Geth Docker Image

Navigate to the Dockerfile directory:

```bash
cd docker/geth

Build the image:
docker build -t hardened-geth:latest .

Push to your container registry (e.g., Azure Container Registry or DockerHub):
docker tag hardened-geth:latest <registry>/hardened-geth:latest
docker push <registry>/hardened-geth:latest


☁️ 2. Provision AKS Using Terraform
Navigate to the Terraform folder:
cd terraform

Update variables (e.g., cluster name, location, node size) and apply:
terraform init
terraform plan
terraform apply

This provisions:

Azure Kubernetes Service (AKS)
Required RBAC and networking components


📦 3. Install Prometheus Operator with Helm
Add Helm repository and update:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

Create monitoring namespace:
kubectl create namespace monitoring

Install Prometheus stack:
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring

This installs:

Prometheus
Grafana
Prometheus Operator (with CRDs like PrometheusRule)
Alertmanager


🔑 4. Create JWT Secret for Geth-Prysm Connection
Generate a JWT secret for Engine API authentication:
openssl rand -hex 32 > jwt.hex
base64 jwt.hex > jwt.b64

Create a Kubernetes Secret:
kubectl create -f k8s/prysm/jwt-secret.yaml

Example jwt-secret.yaml:
apiVersion: v1
kind: Secret
metadata:
  name: jwt-secret
  namespace: default
type: Opaque
data:
  jwt.hex: <base64-encoded-jwt-hex>


📈 5. Apply Kubernetes Manifests
Apply manifests in the following order:
A. System Tuning (Kernel Parameters)
kubectl apply -f k8s/sysctl/daemonset.yaml

B. Redis for RPC Caching
kubectl apply -f k8s/redis/deployment.yaml
kubectl apply -f k8s/redis/service.yaml

C. Geth Node (Execution Layer)
kubectl apply -f k8s/geth/

D. Prysm Node (Consensus Layer)
kubectl apply -f k8s/prysm/

E. Node Exporter
kubectl apply -f exporters/node-exporter/deployment.yaml
kubectl apply -f exporters/node-exporter/service.yaml

F. Monitoring Components (Prometheus/Grafana/Loki)
kubectl apply -f k8s/monitoring/prometheus.yaml
kubectl apply -f k8s/monitoring/grafana.yaml
kubectl apply -f k8s/monitoring/loki.yaml
kubectl apply -f k8s/monitoring/prometheus-config.yaml

G. Alert Rules
kubectl apply -f k8s/monitoring/alert-rule.yaml

Ensure Prometheus Operator is installed before this step.
H. Ingress + HPA (Optional)
kubectl apply -f k8s/ingress/
kubectl apply -f k8s/hpa/


📊 6. Load Grafana Dashboards
Import JSON dashboards manually or via ConfigMap:
cd grafana-dashboards

Upload:

rpc-performance.json (Geth RPC metrics)
node-health.json (Geth node health)


Alternatively, create ConfigMaps and mount them into Grafana.

✅ 7. Validation

Check pod status:
kubectl get pods -A

All pods should be Running.

Verify alert rules:
kubectl get prometheusrules -n monitoring


Access Grafana:

Port-forward or use Ingress:kubectl port-forward svc/grafana 3000:3000 -n monitoring


Open http://localhost:3000 and log in (default: admin/admin).
Check Geth and Prysm dashboards.


Check Geth-Prysm connection:

Geth logs:kubectl logs -l app=geth -n default

Look for Served engine_exchangeTransitionConfigurationV1 or block imports.
Prysm logs:kubectl logs -l app=prysm -n default


📄 License
MIT © 2025```
