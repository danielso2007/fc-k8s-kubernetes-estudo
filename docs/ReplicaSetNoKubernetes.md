- [**ReplicaSet no Kubernetes**](#replicaset-no-kubernetes)
- [**1️⃣ O que é um ReplicaSet**](#1️⃣-o-que-é-um-replicaset)
- [**2️⃣ Diferença entre Pod e ReplicaSet**](#2️⃣-diferença-entre-pod-e-replicaset)
- [**3️⃣ YAML do ReplicaSet**](#3️⃣-yaml-do-replicaset)
  - [**📄 `replicaset.yml`**](#-replicasetyml)
- [**4️⃣ Explicação detalhada do YAML**](#4️⃣-explicação-detalhada-do-yaml)
  - [**apiVersion: apps/v1**](#apiversion-appsv1)
  - [**kind: ReplicaSet**](#kind-replicaset)
  - [**metadata**](#metadata)
  - [**spec.replicas**](#specreplicas)
  - [**spec.selector**](#specselector)
  - [**spec.template**](#spectemplate)
  - [**containers**](#containers)
  - [**resources**](#resources)
- [**5️⃣ Criar o ReplicaSet**](#5️⃣-criar-o-replicaset)
- [**6️⃣ Verificar**](#6️⃣-verificar)
- [**7️⃣ Inspecionar**](#7️⃣-inspecionar)
- [**8️⃣ Escalar manualmente**](#8️⃣-escalar-manualmente)
- [**9️⃣ Auto-healing**](#9️⃣-auto-healing)
- [**🔟 Fluxo interno**](#-fluxo-interno)
- [**1️⃣1️⃣ Deletar ReplicaSet**](#1️⃣1️⃣-deletar-replicaset)
- [**1️⃣2️⃣ OwnerReference**](#1️⃣2️⃣-ownerreference)
- [**1️⃣3️⃣ Limitações do ReplicaSet**](#1️⃣3️⃣-limitações-do-replicaset)
- [**📌 Resumo Técnico**](#-resumo-técnico)
- [**🎯 Conceito chave**](#-conceito-chave)


# **ReplicaSet no Kubernetes**

Base: Kubernetes  
Doc oficial: [https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

---

# **1️⃣ O que é um ReplicaSet**

ReplicaSet é um **controller** responsável por:

Garantir que N réplicas de um Pod estejam sempre rodando.

Ele implementa um **loop de reconciliação**:
```
desired replicas ≠ current replicas → cria ou remove Pods
```
⚠️ ReplicaSet não faz rollout inteligente (isso é papel do Deployment).

---

# **2️⃣ Diferença entre Pod e ReplicaSet**

| Pod direto | ReplicaSet |
| ----- | ----- |
| Não se auto-recupera | Auto-healing |
| Não escala automaticamente | Mantém número fixo |
| Isolado | Gerencia múltiplos Pods |

---

# **3️⃣ YAML do ReplicaSet**

## **📄 `replicaset.yml`**
```yaml
apiVersion: apps/v1  
kind: ReplicaSet

metadata:  
 name: hello-k8s  
 labels:  
   app: hello-k8s

spec:  
 replicas: 3

 selector:  
   matchLabels:  
     app: hello-k8s

 template:  
   metadata:  
     labels:  
       app: hello-k8s  
   spec:  
     containers:  
       - name: hello-k8s  
         image: hello-k8s:latest  
         imagePullPolicy: IfNotPresent  
         ports:  
           - containerPort: 8080  
         resources:  
           requests:  
             memory: "128Mi"  
             cpu: "100m"  
           limits:  
             memory: "256Mi"  
             cpu: "500m"
```
---

# **4️⃣ Explicação detalhada do YAML**

---

## **apiVersion: apps/v1**

ReplicaSet pertence ao API Group `apps`.

---

## **kind: ReplicaSet**

Define que o recurso é um controller.

---

## **metadata**
```yaml
metadata:  
 name: hello-k8s
```
Nome único no namespace.

Labels servem para organização e seleção.

---

## **spec.replicas**
```yaml
replicas: 3
```
Define o estado desejado:

Quero 3 Pods rodando.

---

## **spec.selector**
```yaml
selector:  
 matchLabels:  
   app: hello-k8s
```
Regra usada para identificar quais Pods pertencem ao ReplicaSet.

⚠️ Deve ser idêntico às labels do template.

Se não coincidir → erro de validação.

---

## **spec.template**

Define o **modelo do Pod** que será criado.

Equivale a um PodSpec embutido.
```yaml
template:  
 metadata:  
   labels:  
     app: hello-k8s
```
Essas labels são essenciais para o selector funcionar.

---

## **containers**

Mesma estrutura de um Pod.
```yaml
image: hello-k8s:latest
```
Se estiver usando kind:
```bash
kind load docker-image hello-k8s:latest --name lab-cluster
```
---

## **resources**

Scheduler usa `requests`.

Kubelet aplica `limits` via cgroups.

---

# **5️⃣ Criar o ReplicaSet**
```bash
kubectl apply -f replicaset.yml  
```
---

# **6️⃣ Verificar**

Listar ReplicaSets:
```bash
kubectl get rs
```
Listar Pods criados:
```bash
kubectl get pods
```
Saída esperada:
```
hello-k8s-xxxxx   Running  
hello-k8s-yyyyy   Running  
hello-k8s-zzzzz   Running
```
---

# **7️⃣ Inspecionar**
```bash
kubectl describe rs hello-k8s
```
Mostra:

* Desired replicas  
* Current replicas  
* Events

---

# **8️⃣ Escalar manualmente**
```bash
kubectl scale rs hello-k8s --replicas=5
```
O que acontece:
```
replicas=5 → controller cria 2 novos Pods
```
Verificar:
```bash
kubectl get pods  
```
---

# **9️⃣ Auto-healing**

Delete um Pod:
```bash
kubectl delete pod <nome-do-pod>
```
Observe:
```bash
kubectl get pods
```
ReplicaSet detecta que:
```
current=2 desired=3
```
Cria automaticamente novo Pod.

---

# **🔟 Fluxo interno**
```
kubectl apply  
   ↓  
API Server valida  
   ↓  
Persistência no etcd  
   ↓  
ReplicaSet Controller observa mudança  
   ↓  
Compara selector vs Pods existentes  
   ↓  
Cria/Remove Pods  
   ↓  
Scheduler agenda  
   ↓  
kubelet executa  
```
---

# **1️⃣1️⃣ Deletar ReplicaSet**
```bash
kubectl delete rs hello-k8s
```
Por padrão:

* ReplicaSet é removido  
* Pods também são removidos (ownerReference)

---

# **1️⃣2️⃣ OwnerReference**

Pods criados terão:
```yaml
ownerReferences:  
 - kind: ReplicaSet
```
Isso cria relação hierárquica.

Garbage Collector remove Pods quando RS é removido.

---

# **1️⃣3️⃣ Limitações do ReplicaSet**

* Não faz rolling update  
* Não gerencia versão  
* Não faz rollback

Por isso usamos Deployment em produção.

---

# **📌 Resumo Técnico**

| Campo | Função |
| ----- | ----- |
| replicas | Estado desejado |
| selector | Seleção de Pods |
| template | Modelo de criação |
| resources | Scheduling + limites |
| labels | Associação lógica |

---

# **🎯 Conceito chave**

ReplicaSet é:

> Um controlador idempotente que garante cardinalidade fixa de Pods com base em um label selector.

