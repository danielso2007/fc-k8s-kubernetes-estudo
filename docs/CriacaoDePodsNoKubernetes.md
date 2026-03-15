- [**Criação de Pods no Kubernetes**](#criação-de-pods-no-kubernetes)
- [**1️⃣ O que é um Pod (internamente)**](#1️⃣-o-que-é-um-pod-internamente)
- [**2️⃣ Criando um Pod com YAML**](#2️⃣-criando-um-pod-com-yaml)
  - [**📄 `pod-hello.yml`**](#-pod-helloyml)
- [**3️⃣ Explicação detalhada**](#3️⃣-explicação-detalhada)
  - [**apiVersion: v1**](#apiversion-v1)
  - [**kind: Pod**](#kind-pod)
  - [**metadata**](#metadata)
  - [**spec**](#spec)
  - [**containers**](#containers)
  - [**imagePullPolicy**](#imagepullpolicy)
  - [**containerPort**](#containerport)
  - [**resources**](#resources)
- [**4️⃣ Criar o Pod**](#4️⃣-criar-o-pod)
- [**5️⃣ Verificar**](#5️⃣-verificar)
- [**6️⃣ Testar acesso**](#6️⃣-testar-acesso)
- [**7️⃣ Ciclo de vida do Pod**](#7️⃣-ciclo-de-vida-do-pod)
- [**8️⃣ Fluxo interno de criação**](#8️⃣-fluxo-interno-de-criação)
- [**9️⃣ Excluir Pod**](#9️⃣-excluir-pod)
- [**🔎 Resumo Técnico**](#-resumo-técnico)

# **Criação de Pods no Kubernetes**

Base: Kubernetes  
Conceito oficial: [https://kubernetes.io/docs/concepts/workloads/pods/](https://kubernetes.io/docs/concepts/workloads/pods/)

---

# **1️⃣ O que é um Pod (internamente)**

Pod é a **menor unidade implantável** no Kubernetes.

Ele encapsula:

* 1 ou mais containers  
* IP próprio  
* Volume compartilhado  
* Network namespace  
* IPC namespace

Internamente:
```
PodSpec → API Server → etcd → Scheduler → Node → kubelet → container runtime  
```
---

# **2️⃣ Criando um Pod com YAML**

## **📄 `pod-hello.yml`**
```yaml
apiVersion: v1  
kind: Pod

metadata:  
 name: hello-k8s  
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

# **3️⃣ Explicação detalhada**

## **apiVersion: v1**

Pods pertencem ao core API group.

---

## **kind: Pod**

Define o tipo do recurso.

---

## **metadata**
```yaml
metadata:  
 name: hello-k8s  
 labels:  
   app: hello-k8s
```
* `name` → identificador único no namespace.  
* `labels` → chave-valor para seleção (Services, etc).

---

## **spec**

Define o estado desejado do Pod.

---

## **containers**

Lista de containers no Pod.
```yaml
image: hello-k8s:latest
```
⚠️ Se estiver usando `kind`, a imagem precisa estar disponível no cluster.

Para carregar imagem local no kind:
```bash
kind load docker-image hello-k8s:latest --name lab-cluster
```
---

## **imagePullPolicy**

* Always  
* IfNotPresent  
* Never

Para ambiente local → `IfNotPresent`.

---

## **containerPort**

Exposição informativa.  
Não abre porta automaticamente.

---

## **resources**

Scheduler usa:
```yaml
requests
```
Para decidir onde alocar.

O kubelet impõe:
```yaml
limits
```
via cgroups.

---

# **4️⃣ Criar o Pod**
```yaml
kubectl apply -f pod-hello.yml
```
---

# **5️⃣ Verificar**
```bash
kubectl get pods
```
Detalhado:
```bash
kubectl describe pod hello-k8s
```
Logs:
```bash
kubectl logs hello-k8s
```
Entrar no container:
```bash
kubectl exec -it hello-k8s -- sh
```
---

# **6️⃣ Testar acesso**

Port-forward:
```bash
kubectl port-forward pod/hello-k8s 8080:8080
```
Acessar:
```
http://localhost:8080/hello-k8s/v1/hello
```
---

# **7️⃣ Ciclo de vida do Pod**

Fases:
```
Pending → Running → Succeeded | Failed
```
Eventos:
```bash
kubectl get events
```
---

# **8️⃣ Fluxo interno de criação**
```
kubectl apply  
   ↓  
API Server valida  
   ↓  
Persistência no etcd  
   ↓  
Scheduler escolhe node  
   ↓  
kubelet cria container  
   ↓  
Status atualizado
```
---

# **9️⃣ Excluir Pod**
```bash
kubectl delete pod hello-k8s
```
⚠️ Observação importante:

Pod criado diretamente **não é auto-recuperável**.

Se morrer, não será recriado.

Para produção → usar Deployment.

---

# **🔎 Resumo Técnico**

| Campo | Função |
| ----- | ----- |
| metadata | Identificação |
| spec | Estado desejado |
| containers | Definição runtime |
| resources | Scheduling \+ cgroups |
| labels | Seleção e organização |

