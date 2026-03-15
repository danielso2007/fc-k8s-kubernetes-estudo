- [**Services no Kubernetes**](#services-no-kubernetes)
- [**1️⃣ O que é um Service**](#1️⃣-o-que-é-um-service)
- [**2️⃣ Problema que ele resolve**](#2️⃣-problema-que-ele-resolve)
- [**3️⃣ Tipos de Service**](#3️⃣-tipos-de-service)
- [**4️⃣ Como funciona internamente**](#4️⃣-como-funciona-internamente)
- [**5️⃣ YAML do Service (ClusterIP)**](#5️⃣-yaml-do-service-clusterip)
  - [**📄 `service.yml`**](#-serviceyml)
- [**6️⃣ Explicação detalhada**](#6️⃣-explicação-detalhada)
  - [**apiVersion: v1**](#apiversion-v1)
  - [**kind: Service**](#kind-service)
  - [**metadata.name**](#metadataname)
  - [**spec.type**](#spectype)
  - [**spec.selector**](#specselector)
  - [**spec.ports**](#specports)
- [**7️⃣ Criar o Service**](#7️⃣-criar-o-service)
- [**8️⃣ Verificar**](#8️⃣-verificar)
- [**9️⃣ Ver endpoints**](#9️⃣-ver-endpoints)
- [**🔟 Testar dentro do cluster**](#-testar-dentro-do-cluster)
- [**1️⃣1️⃣ Expor externamente (NodePort)**](#1️⃣1️⃣-expor-externamente-nodeport)
- [**1️⃣2️⃣ Fluxo Interno Completo**](#1️⃣2️⃣-fluxo-interno-completo)
- [**1️⃣3️⃣ Relação com Deployment**](#1️⃣3️⃣-relação-com-deployment)
- [**1️⃣4️⃣ Atualização dinâmica**](#1️⃣4️⃣-atualização-dinâmica)
- [**1️⃣5️⃣ Conceitos avançados**](#1️⃣5️⃣-conceitos-avançados)
    - [**Headless Service**](#headless-service)
- [**📌 Resumo Técnico**](#-resumo-técnico)
- [**🎯 Conceito Fundamental**](#-conceito-fundamental)


# **Services no Kubernetes**

Base: Kubernetes  
Doc oficial: [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)

---

# **1️⃣ O que é um Service**

Service é um recurso que fornece:

* IP estável  
* DNS interno  
* Load balancing  
* Descoberta de serviço

⚠️ Pods são efêmeros.  
Service resolve isso criando um **endpoint lógico estável**.

---

# **2️⃣ Problema que ele resolve**

Sem Service:
```
Pod A → IP muda → Cliente perde conexão
```
Com Service:
```
Cliente → Service IP → kube-proxy → Pod disponível  
```
---

# **3️⃣ Tipos de Service**

| Tipo | Uso |
| ----- | ----- |
| ClusterIP | Comunicação interna |
| NodePort | Exposição via porta do node |
| LoadBalancer | Exposição externa (cloud) |
| Headless | Sem ClusterIP |

---

# **4️⃣ Como funciona internamente**

Service cria:

1. Um ClusterIP virtual  
2. Um objeto Endpoints (ou EndpointSlice)  
3. Regras no kube-proxy (iptables ou IPVS)

Fluxo:
```
Cliente → ClusterIP → kube-proxy → Pod backend  
```
---

# **5️⃣ YAML do Service (ClusterIP)**

## **📄 `service.yml`**
```yaml
apiVersion: v1  
kind: Service

metadata:  
 name: hello-k8s  
 labels:  
   app: hello-k8s

spec:  
 type: ClusterIP

 selector:  
   app: hello-k8s

 ports:  
   - protocol: TCP  
     port: 80  
     targetPort: 8080
```
---

# **6️⃣ Explicação detalhada**

---

## **apiVersion: v1**

Service pertence ao core API group.

---

## **kind: Service**

Define recurso de rede.

---

## **metadata.name**

Nome DNS interno:
```
hello-k8s.default.svc.cluster.local  
```
---

## **spec.type**
```yaml
type: ClusterIP
```
Cria IP virtual acessível somente dentro do cluster.

---

## **spec.selector**
```yaml
selector:  
 app: hello-k8s
```
Seleciona Pods com label:
```yaml
labels:  
 app: hello-k8s
```
⚠️ Sem labels compatíveis → Service não roteia tráfego.

---

## **spec.ports**
```yaml
port: 80  
targetPort: 8080
```
* `port` → Porta exposta pelo Service  
* `targetPort` → Porta do container  
* `protocol` → TCP/UDP

---

# **7️⃣ Criar o Service**
```bash
kubectl apply -f service.yml  
```
---

# **8️⃣ Verificar**

Listar Services:
```bash
kubectl get svc
```
Exemplo saída:
```
NAME         TYPE        CLUSTER-IP     PORT(S)  
hello-k8s    ClusterIP   10.96.45.22    80/TCP  
```

---

# **9️⃣ Ver endpoints**
```bash
kubectl get endpoints hello-k8s
```
Mostra IPs dos Pods backend.

Internamente criado automaticamente.

---

# **🔟 Testar dentro do cluster**

Use port-forward:
```bash
kubectl port-forward svc/hello-k8s 8080:80
```
Acessar:
```
http://localhost:8080/hello
```

Criar Pod temporário:
```bash
kubectl run test --rm -it --image=busybox -- sh
```
Dentro dele:
```bash
wget -qO- http://hello-k8s
```
DNS resolve automaticamente.

---

# **1️⃣1️⃣ Expor externamente (NodePort)**

Se quiser acesso externo:
```yaml
spec:  
 type: NodePort  
 ports:  
   - port: 80  
     targetPort: 8080  
     nodePort: 30080
```
Criar:
```bash
kubectl apply -f service.yml
```
Ip do node:
```bash
kubectl get nodes -o wide
```
Acessar:
```
http://<node-ip>:30080
```
Se estiver usando kind com port mapping:
```
http://localhost:8080
```
---

# **1️⃣2️⃣ Fluxo Interno Completo**
```
Service criado  
   ↓  
API Server registra  
   ↓  
EndpointSlice Controller associa Pods  
   ↓  
kube-proxy atualiza regras iptables  
   ↓  
ClusterIP começa a rotear tráfego  
```
---

# **1️⃣3️⃣ Relação com Deployment**
```
Estrutura final:

Deployment  
  ↓  
ReplicaSet  
  ↓  
Pods (label: app=hello-k8s)  
  ↑  
Service (selector: app=hello-k8s)
```
Service nunca aponta para Deployment diretamente.  
Ele aponta para Pods via labels.

---

# **1️⃣4️⃣ Atualização dinâmica**

Se um Pod morrer:
```
ReplicaSet cria novo Pod  
EndpointSlice atualiza automaticamente  
Service passa a rotear para novo Pod
```
Nenhuma mudança no cliente.

---

# **1️⃣5️⃣ Conceitos avançados**

### **Headless Service**
```
clusterIP: None
```
Sem load balancing → DNS retorna múltiplos IPs.

Usado com StatefulSet.

---

# **📌 Resumo Técnico**

| Campo | Função |
| ----- | ----- |
| selector | Define backend |
| port | Porta do Service |
| targetPort | Porta do container |
| type | Modelo de exposição |
| ClusterIP | IP virtual interno |

---

# **🎯 Conceito Fundamental**

Service é:

Uma abstração de rede que fornece endpoint estável e balanceamento para Pods dinâmicos.

