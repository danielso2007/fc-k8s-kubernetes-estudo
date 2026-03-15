# **Estrutura Fundamental do Kubernetes**

Baseado em: Kubernetes  
Documentação oficial: [https://kubernetes.io/docs/concepts/](https://kubernetes.io/docs/concepts/)

---

# **1️⃣ Namespaces**

## **O que são**

Namespaces são **partições lógicas dentro do cluster**.

Eles isolam:

* Recursos  
* Políticas  
* Quotas  
* RBAC

Não isolam infraestrutura física.

---

## **Objetivo**

Multi-tenant lógico.

Exemplo:
```bash
kubectl create namespace dev  
kubectl create namespace prod  
```
---

## **Funcionamento interno**

Todos os objetos namespaced possuem:
```yaml
metadata:  
 namespace: dev
```
No `etcd`, o namespace compõe a chave do objeto.

---

## **Namespaces padrão**

* default  
* kube-system  
* kube-public  
* kube-node-lease

---

# **2️⃣ Nodes**

## **O que são**

Nodes são máquinas (VM ou físicas) que executam Pods.

---

## **Componentes do node**

* kubelet  
* container runtime (containerd)  
* kube-proxy

---

## **Registro**

Quando o kubelet inicia:
```
kubelet → API Server → registra Node
```
---

## **Scheduler**

O scheduler seleciona node com base em:

* Recursos (CPU/mem)  
* Taints / tolerations  
* Node selectors  
* Affinity rules

---

# **3️⃣ Workloads**

Workloads são controladores que gerenciam Pods.

---

## **Principais tipos**

| Recurso | Finalidade |
| ----- | ----- |
| Deployment | Apps stateless |
| ReplicaSet | Garante número de réplicas |
| StatefulSet | Apps stateful |
| DaemonSet | 1 Pod por node |
| Job | Execução batch |
| CronJob | Execução agendada |

---

## **Modelo interno**

Workloads implementam:
```
Desired State → ReplicaSet → Pods
```
Controllers rodam loops de reconciliação contínuos.

---

# **4️⃣ Network**

Modelo de rede do Kubernetes:

> Todo Pod pode se comunicar com qualquer outro Pod sem NAT.

---

## **Componentes**

### **Pod Network**

Cada Pod recebe IP único.

### **Service**

Abstração de load balancing.

Tipos:

* ClusterIP  
* NodePort  
* LoadBalancer

---

## **DNS**

CoreDNS cria entradas:
```
service.namespace.svc.cluster.local
```
---

## **CNI**

Kubernetes usa plugin CNI (Container Network Interface).

Exemplos:

* Calico  
* Flannel  
* Cilium

---

# **5️⃣ Storage**

Pods são efêmeros.

Storage é abstraído via:

* Volume  
* PersistentVolume (PV)  
* PersistentVolumeClaim (PVC)  
* StorageClass

---

## **Fluxo**
```
PVC → StorageClass → Provisionador → PV
```
Provisionamento pode ser:

* Estático  
* Dinâmico

---

## **Tipos comuns**

* emptyDir  
* hostPath  
* NFS  
* Block storage (cloud)

---

# **6️⃣ Configuration**

Separação entre código e configuração.

---

## **ConfigMap**

Dados não sensíveis:
```yaml
data:  
 app.properties: value  
```
---

## **Secret**

Base64 encoded.

Pode ser montado como:

* Variável de ambiente  
* Volume

---

## **Boas práticas**

* Não embutir config na imagem  
* Integrar com Vault externo

---

# **7️⃣ Custom Resources (CRDs)**

Extensibilidade nativa.

Permitem criar novos tipos de objetos.

---

## **Funcionamento**

1. Registrar CRD  
2. API Server passa a reconhecer novo tipo  
3. Criar controller customizado (Operator)

---

## **Exemplo**
```yaml
apiVersion: stable.example.com/v1  
kind: Database  
```
---

## **Modelo**
```
CRD → API Extension → Controller → Reconciliação
```
Base para Operators.

---

# **8️⃣ Helm Releases**

Projeto: Helm

Helm é o **gerenciador de pacotes do Kubernetes**.

---

## **Conceitos**

* Chart → pacote templated  
* Release → instância instalada do chart

---

## **Fluxo**
```bash
helm install app ./chart
```
Internamente:

1. Renderiza templates  
2. Gera YAML final  
3. Executa kubectl apply  
4. Registra release no cluster

---

## **Armazenamento**

Helm armazena releases como:

* Secrets  
* ConfigMaps

---

## **Recursos**

* Versionamento  
* Rollback  
* Values.yaml  
* Templating Go

---

# **Arquitetura Conceitual Consolidada**
```
Cluster  
├── Namespaces  
│    ├── Workloads  
│    ├── Services  
│    ├── ConfigMaps  
│    ├── Secrets  
│    └── PVCs  
│  
├── Nodes  
│    └── Pods  
│  
├── Network (CNI \+ Services \+ DNS)  
├── Storage (PV / PVC / StorageClass)  
├── API Extensions (CRDs)  
└── Package Layer (Helm)  
```
---

# **Resumo Técnico Estrutural**

| Camada | Função |
| ----- | ----- |
| Namespace | Isolamento lógico |
| Node | Execução física |
| Workloads | Orquestração de Pods |
| Network | Comunicação |
| Storage | Persistência |
| Configuration | Parametrização |
| CRDs | Extensão da API |
| Helm | Empacotamento e versionamento |

