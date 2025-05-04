

```markdown
# ⚙️ Geth RPC Cluster on Kubernetes

A production-ready, hardened Ethereum Geth RPC cluster with integrated observability (Prometheus, Grafana, Loki), Redis caching, system tuning (`sysctl`), and auto-scaling support on AKS (Azure Kubernetes Service).

---

## 📁 Project Structure

```

geth-rpc-cluster/
├── docker/geth/                 # Dockerfile for hardened Geth image
├── exporters/node-exporter/    # Prometheus Node Exporter Kubernetes manifests
├── grafana-dashboards/         # Custom Grafana dashboards for Geth
├── k8s/                         # Kubernetes manifests organized by component
│   ├── geth/
│   ├── hpa/
│   ├── ingress/
│   ├── monitoring/             # Prometheus, Grafana, Loki, Alerts
│   ├── redis/
│   └── sysctl/
├── terraform/                  # Terraform for provisioning AKS and related infra
├── README.md                   # 📘 You're here

````

---

## 🛠️ 1. Build Hardened Geth Docker Image

Navigate to the Dockerfile directory:

```bash
cd docker/geth
````

Build the image:

```bash
docker build -t hardened-geth:latest .
```

You can push this image to your container registry (e.g., ACR or DockerHub) for AKS deployment.

---

## ☁️ 2. Provision AKS Using Terraform

Navigate to the Terraform folder:

```bash
cd terraform
```

Update variables as needed (e.g., cluster name, location, node size) and apply:

```bash
terraform init
terraform plan
terraform apply
```

This will provision:

* Azure Kubernetes Service (AKS)
* Azure Container Registry (ACR)
* Required RBAC and networking components

---

## 📦 3. Install Prometheus Operator with Helm

### Add Helm repo and update:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Create monitoring namespace:

```bash
kubectl create namespace monitoring
```

### Install Prometheus stack:

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring
```

This installs:

* Prometheus
* Grafana
* Prometheus Operator (with CRDs like `PrometheusRule`)
* Alertmanager

---

## 📈 4. Apply Kubernetes Manifests

Apply manifests in the following order:

### A. System Tuning (Kernel Parameters)

```bash
kubectl apply -f k8s/sysctl/daemonset.yaml
```

### B. Redis for RPC Caching

```bash
kubectl apply -f k8s/redis/deployment.yaml
kubectl apply -f k8s/redis/service.yaml
```

### C. Geth Node

```bash
kubectl apply -f k8s/geth/
```

### D. Node Exporter

```bash
kubectl apply -f exporters/node-exporter/deployment.yaml
kubectl apply -f exporters/node-exporter/service.yaml
```

### E. Monitoring Components (Prometheus/Grafana/Loki)

```bash
kubectl apply -f k8s/monitoring/prometheus.yaml
kubectl apply -f k8s/monitoring/grafana.yaml
kubectl apply -f k8s/monitoring/loki.yaml
```

### F. Alert Rules

```bash
kubectl apply -f k8s/monitoring/alert-rule.yaml
```

Ensure Prometheus Operator is installed before this step.

### G. Ingress + HPA (Optional)

```bash
kubectl apply -f k8s/ingress/
kubectl apply -f k8s/hpa/
```

---

## 📊 5. Load Grafana Dashboards

Import the JSON dashboards manually or via ConfigMap:

```bash
cd grafana-dashboards
```

Upload:

* `rpc-performance.json`
* `node-health.json`

Or create ConfigMaps and mount them into Grafana.

---

## ✅ Validation

* `kubectl get pods -A` → All pods should be running
* `kubectl get prometheusrules -n monitoring` → Check alert rules
* Visit Grafana (default: `http://<node-ip>:3000`) and log in with default credentials (`admin/admin`)

---

## 🔐 Security Tips

* Harden Ingress with TLS + ModSecurity
* Use sealed secrets or Azure Key Vault for sensitive data
* Configure rate-limiting and IP whitelisting in Ingress
* Use Azure-managed identity for secure resource access

---

## 📬 Contact

For feedback or improvements, raise an issue or reach out to the maintainer.

---

## 📄 License

MIT © 2025

```

---

Would you like me to generate this as a downloadable `README.md` file?
```
