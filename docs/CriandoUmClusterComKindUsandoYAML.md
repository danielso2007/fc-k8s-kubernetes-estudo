# **Criando um cluster com kind usando YAML**

Projeto: kind  
Baseado em: Kubernetes  
Spec do cluster: [https://kind.sigs.k8s.io/docs/user/configuration/](https://kind.sigs.k8s.io/docs/user/configuration/)

---

# **1️⃣ Arquivo `kind.yml`**

Crie o arquivo:
```yaml
\# kind.yml  
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

name: lab-cluster

networking:
  ipFamily: ipv4
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443

nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 8080
        protocol: TCP
  - role: worker
  - role: worker
  - role: worker
```
---

# **2️⃣ Explicação detalhada do YAML**

## **kind: Cluster**

Define que o objeto é um cluster kind.

---

## **apiVersion: kind.x-k8s.io/v1alpha4**

Versão da API do kind.  
`v1alpha4` é a versão estável atual da spec.

---

## **name: lab-cluster**

Nome lógico do cluster.

Impacto:

* Nome do contexto no kubeconfig → `kind-lab-cluster`  
* Prefixo dos containers Docker

---

## **networking**
```yaml
networking:  
 ipFamily: ipv4  
 apiServerAddress: "127.0.0.1"  
 apiServerPort: 6443
```
### **ipFamily**

Define stack de IP usada no cluster.

* ipv4  
* ipv6  
* dual

### **apiServerAddress**

IP do host onde a API ficará exposta.

### **apiServerPort**

Porta do kube-apiserver no host.

Resultado:
```
https://127.0.0.1:6443  
```
---

## **nodes**

Define topologia do cluster.

---

### **Control-plane**
```yaml
- role: control-plane
```
Cria container Docker contendo:
```
kube-apiserver  
etcd  
scheduler  
controller-manager  
kubelet  
containerd  
```
---

### **extraPortMappings**
```yaml
extraPortMappings:  
 - containerPort: 30080  
   hostPort: 8080  
   protocol: TCP
```
Mapeamento de porta:
```
Host:8080 → NodeContainer:30080
```
Usado para expor NodePort localmente.

Sem isso:

* NodePort ficaria acessível apenas dentro da rede Docker.

---

### **Workers**
```yaml
- role: worker  
- role: worker
- role: worker
```
Criam 3 nós workers.

Total do cluster:

* 1 control-plane  
* 3 workers

---

# **3️⃣ Criar o cluster**
```bash
kind create cluster --config ./k8s/kind.yml
```
### **O que acontece internamente:**

1. kind lê YAML  
2. Cria containers Docker (1 control-plane \+ 2 workers)  
3. Executa kubeadm init dentro do control-plane  
4. Workers fazem join automático  
5. Gera kubeconfig  
6. Atualiza `~/.kube/config`

---

# **4️⃣ Verificar cluster**
```bash
kubectl cluster-info  
kubectl get nodes -o wide
```
Saída esperada:
```
NAME                         STATUS   ROLES           VERSION  
lab-cluster-control-plane    Ready    control-plane   v1.xx.x  
lab-cluster-worker           Ready    \<none\>  
lab-cluster-worker2          Ready    \<none\>  
```
---

# **5️⃣ Ver containers Docker**
```bash
docker ps
```
Você verá:
```
lab-cluster-control-plane  
lab-cluster-worker  
lab-cluster-worker2
```
Cada container é um “node”.

---

# **6️⃣ Testar NodePort**

Depois de criar um Service NodePort:
```yaml
spec:  
 type: NodePort  
 ports:  
   - port: 80  
     targetPort: 8080  
     nodePort: 30080
```
Você poderá acessar:
```
http://localhost:8080
```
Porque foi mapeado no `extraPortMappings`.

---

# **7️⃣ Remover cluster**
```bash
kind delete cluster --name lab-cluster
```
Remove:

* Containers Docker  
* Rede  
* Contexto

---

# **8️⃣ Arquitetura resultante**
```
Ubuntu Host  
└── Docker  
     ├── lab-cluster-control-plane  
     ├── lab-cluster-worker  
     └── lab-cluster-worker2
```
Rede interna Docker conecta todos os nodes.

---

# **🔎 Observações técnicas importantes**

* O CNI padrão no kind é baseado em bridge Docker.  
* O cluster é single control-plane (não HA).  
* etcd roda dentro do container control-plane.  
* Não é ambiente de produção.  
* Ideal para estudo de:  
  * Deployments  
  * Services  
  * HPA  
  * RBAC  
  * Troubleshooting

---

[Voltar](README.md)
