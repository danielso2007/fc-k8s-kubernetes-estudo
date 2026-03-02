- [**Deployment no Kubernetes**](#deployment-no-kubernetes)
- [**1️⃣ O que é um Deployment**](#1️⃣-o-que-é-um-deployment)
- [**2️⃣ Papel Arquitetural**](#2️⃣-papel-arquitetural)
- [**3️⃣ YAML do Deployment**](#3️⃣-yaml-do-deployment)
  - [**📄 `deployment.yml`**](#-deploymentyml)
- [**4️⃣ Explicação Detalhada**](#4️⃣-explicação-detalhada)
  - [**apiVersion: apps/v1**](#apiversion-appsv1)
  - [**kind: Deployment**](#kind-deployment)
  - [**metadata**](#metadata)
  - [**spec.replicas**](#specreplicas)
  - [**spec.selector**](#specselector)
  - [**spec.strategy**](#specstrategy)
    - [**RollingUpdate**](#rollingupdate)
  - [**template**](#template)
  - [**resources**](#resources)
- [**5️⃣ Criar Deployment**](#5️⃣-criar-deployment)
- [**6️⃣ Verificar**](#6️⃣-verificar)
- [**7️⃣ Inspecionar**](#7️⃣-inspecionar)
- [**8️⃣ Escalar Deployment**](#8️⃣-escalar-deployment)
  - [ReplicaSet ajusta número de Pods](#replicaset-ajusta-número-de-pods)
- [**9️⃣ Atualizar imagem (Rolling Update)**](#9️⃣-atualizar-imagem-rolling-update)
- [**🔟 Histórico e Rollback**](#-histórico-e-rollback)
- [**1️⃣1️⃣ Fluxo Interno Completo**](#1️⃣1️⃣-fluxo-interno-completo)
- [**1️⃣2️⃣ OwnerReferences**](#1️⃣2️⃣-ownerreferences)
- [**1️⃣3️⃣ Diferença Deployment vs ReplicaSet**](#1️⃣3️⃣-diferença-deployment-vs-replicaset)
- [**📌 Conceito Fundamental**](#-conceito-fundamental)
- [**🎯 Resumo Técnico**](#-resumo-técnico)


# **Deployment no Kubernetes**

Base: Kubernetes  
Doc oficial: [https://kubernetes.io/docs/concepts/workloads/controllers/deployment/](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

---

# **1️⃣ O que é um Deployment**

Deployment é um **controller de alto nível** que:

* Gerencia ReplicaSets  
* Faz rolling update  
* Permite rollback  
* Garante número desejado de réplicas

Ele não cria Pods diretamente.  
Fluxo interno:
```
Deployment → ReplicaSet → Pods  
```
---

# **2️⃣ Papel Arquitetural**

O Deployment implementa:

* Controle declarativo de versão  
* Estratégia de atualização  
* Histórico de revisões

Internamente existe o **Deployment Controller**, que observa mudanças e cria/atualiza ReplicaSets.

---

# **3️⃣ YAML do Deployment**

## **📄 `deployment.yml`**
```yaml
apiVersion: apps/v1  
kind: Deployment

metadata:  
 name: hello-k8s  
 labels:  
   app: hello-k8s

spec:  
 replicas: 3

 selector:  
   matchLabels:  
     app: hello-k8s

 strategy:  
   type: RollingUpdate  
   rollingUpdate:  
     maxUnavailable: 1  
     maxSurge: 1

 template:  
   metadata:  
     labels:  
       app: hello-k8s  
   spec:  
     containers:  
       \- name: hello-k8s  
         image: hello-k8s:latest  
         imagePullPolicy: IfNotPresent  
         ports:  
           \- containerPort: 8080  
         resources:  
           requests:  
             memory: "128Mi"  
             cpu: "100m"  
           limits:  
             memory: "256Mi"  
             cpu: "500m"
```
---

# **4️⃣ Explicação Detalhada**

---

## **apiVersion: apps/v1**

Deployments pertencem ao API group `apps`.

---

## **kind: Deployment**

Define controlador de alto nível.

---

## **metadata**

Identificação única no namespace.

Labels servem para:

* Organização  
* Seleção por Services  
* Métricas

---

## **spec.replicas**
```yaml
replicas: 3
```
Estado desejado:

Quero 3 Pods ativos.

O Deployment cria um ReplicaSet com essa configuração.

---

## **spec.selector**
```yaml
selector:  
 matchLabels:  
   app: hello-k8s
```
Define quais Pods pertencem ao Deployment.

⚠️ Deve coincidir com o template.

---

## **spec.strategy**
```yaml
type: RollingUpdate
```
Define como atualizar Pods.

### **RollingUpdate**
```yaml
maxUnavailable: 1  
maxSurge: 1
```
Significa:

* Pode ficar 1 Pod indisponível  
* Pode criar 1 Pod extra temporariamente

Se replicas=3:

Durante update:  
```
mínimo disponível = 2  
máximo temporário = 4  
```
---

## **template**

Define o modelo do Pod.

Deployment gera um ReplicaSet usando esse template.

Se você mudar a imagem:
```yaml
image: hello-k8s:v2
```
Ele cria um novo ReplicaSet.

---

## **resources**

Scheduler usa `requests` para decidir node.

Kubelet impõe `limits` via cgroups.

---

# **5️⃣ Criar Deployment**
```bash
kubectl apply -f deployment-hello.yml  
```
---

# **6️⃣ Verificar**

Listar Deployments:
```bash
kubectl get deployments
```
Listar ReplicaSets:
```bash
kubectl get rs
```
Listar Pods:
```bash
kubectl get pods  
```
---

# **7️⃣ Inspecionar**
```bash
kubectl describe deployment hello-k8s
```
Mostra:

* Strategy  
* Replicas desejadas  
* ReplicaSet ativo  
* Eventos

---

# **8️⃣ Escalar Deployment**
```bash
kubectl scale deployment hello-k8s --replicas=5
```
O que acontece:

Deployment atualiza spec.replicas  
   ↓  
ReplicaSet ajusta número de Pods  
---

# **9️⃣ Atualizar imagem (Rolling Update)**
```bash
kubectl set image deployment/hello-k8s hello-k8s=hello-k8s:v2
```
Fluxo interno:
```
Deployment detecta mudança  
   ↓  
Cria novo ReplicaSet  
   ↓  
Aumenta novo RS (maxSurge)  
   ↓  
Reduz antigo RS (maxUnavailable)  
   ↓  
Quando concluído → RS antigo escala para 0
```
Ver rollout:
```bash
kubectl rollout status deployment hello-k8s  
```
---

# **🔟 Histórico e Rollback**

Ver histórico:
```bash
kubectl rollout history deployment hello-k8s
```
Rollback:
```bash
kubectl rollout undo deployment hello-k8s
```
O Deployment reativa ReplicaSet anterior.

---

# **1️⃣1️⃣ Fluxo Interno Completo**
```
kubectl apply  
   ↓  
API Server valida  
   ↓  
Persistência no etcd  
   ↓  
Deployment Controller detecta mudança  
   ↓  
Cria/atualiza ReplicaSet  
   ↓  
ReplicaSet cria Pods  
   ↓  
Scheduler agenda  
   ↓  
kubelet executa containers  
```
---

# **1️⃣2️⃣ OwnerReferences**

Hierarquia:
```
Deployment  
  └── ReplicaSet  
          └── Pods
```
Se deletar Deployment:
```bash
kubectl delete deployment hello-k8s
```
Garbage Collector remove ReplicaSets e Pods.

---

# **1️⃣3️⃣ Diferença Deployment vs ReplicaSet**

| ReplicaSet | Deployment |
| ----- | ----- |
| Mantém cardinalidade | Mantém versão \+ rollout |
| Sem histórico | Histórico de revisões |
| Sem rollback | Rollback automático |
| Baixo nível | Alto nível |

---

# **📌 Conceito Fundamental**

Deployment é:

> Um controlador declarativo que gerencia ReplicaSets versionados para garantir rollout controlado e histórico de versões.

---

# **🎯 Resumo Técnico**

| Campo | Função |
| ----- | ----- |
| replicas | Quantidade desejada |
| selector | Identificação dos Pods |
| strategy | Política de atualização |
| template | Modelo de Pod |
| resources | Scheduling \+ limites |

