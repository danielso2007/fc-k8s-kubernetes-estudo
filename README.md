- [**Kubernetes**](#kubernetes)
  - [**Definição**](#definição)
  - [**Problema que ele resolve**](#problema-que-ele-resolve)
  - [**Conceito central: Estado Desejado (Desired State)**](#conceito-central-estado-desejado-desired-state)
  - [**Arquitetura**](#arquitetura)
    - [**1. Control Plane**](#1-control-plane)
    - [**2. Worker Nodes**](#2-worker-nodes)
  - [**Unidade Básica: Pod**](#unidade-básica-pod)
  - [**Principais Abstrações**](#principais-abstrações)
  - [**Modelo Operacional**](#modelo-operacional)
  - [**Resumo Técnico**](#resumo-técnico)
- [Estrutura Fundamental do Kubernetes](#estrutura-fundamental-do-kubernetes)
- [Como instalar o kubectl e kind](#como-instalar-o-kubectl-e-kind)
- [Criando um cluster com kind usando YAML](#criando-um-cluster-com-kind-usando-yaml)
- [Criação de Pods no Kubernetes](#criação-de-pods-no-kubernetes)
- [ReplicaSet no Kubernetes](#replicaset-no-kubernetes)
- [Deployment no Kubernetes](#deployment-no-kubernetes)
- [Services no Kubernetes](#services-no-kubernetes)
- [kubectl proxy](#kubectl-proxy)
- [Service Type: LoadBalancer](#service-type-loadbalancer)
- [Configuração no Kubernetes (ConfigMap e Variáveis de Ambiente)](#configuração-no-kubernetes-configmap-e-variáveis-de-ambiente)
- [ConfigMap como Volume (Deep Dive)](#configmap-como-volume-deep-dive)
- [Resources, Metrics Server e HPA no Kubernetes (com kind)](#resources-metrics-server-e-hpa-no-kubernetes-com-kind)

# **Kubernetes**

## **Definição**

O **Kubernetes (K8s)** é uma plataforma open-source de **orquestração de containers** projetada para automatizar o deploy, escalabilidade, gerenciamento e operação de aplicações containerizadas.

Projeto mantido pela Cloud Native Computing Foundation  
Projeto original: Kubernetes  
Documentação oficial: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)

---

## **Problema que ele resolve**

Containers (ex: Docker) isolam aplicações e suas dependências, mas não resolvem:

* Orquestração multi-host  
* Escalabilidade horizontal automática  
* Auto-healing  
* Service discovery  
* Balanceamento de carga interno  
* Atualizações sem downtime  
* Gestão declarativa de configuração

Kubernetes fornece esses mecanismos via controle distribuído baseado em reconciliação de estado.

---

## **Conceito central: Estado Desejado (Desired State)**

Kubernetes funciona com **modelo declarativo**.

Você define o estado desejado (ex: 3 réplicas rodando) e o sistema garante convergência contínua para esse estado.

Fluxo interno:
```
kubectl apply → API Server → etcd → Controllers → Scheduler → Kubelet → Container Runtime  
```
---

## **Arquitetura**

### **1\. Control Plane**

Responsável pelo gerenciamento global do cluster:

* **kube-apiserver** → Interface REST central  
* **etcd** → Armazenamento consistente (Raft)  
* **kube-scheduler** → Decisão de alocação de Pods  
* **kube-controller-manager** → Controladores de reconciliação

Referência:  
[https://kubernetes.io/docs/concepts/architecture/](https://kubernetes.io/docs/concepts/architecture/)

---

### **2\. Worker Nodes**

Executam as cargas de trabalho:

* **kubelet** → Agente que aplica o estado desejado  
* **kube-proxy** → Gerenciamento de rede  
* **Container Runtime** → ex: containerd

---

## **Unidade Básica: Pod**

O **Pod** é a menor unidade implantável no Kubernetes.

Características:

* Compartilha IP  
* Compartilha namespace de rede  
* Pode conter múltiplos containers  
* Compartilha volumes

Exemplo:

apiVersion: v1  
kind: Pod  
metadata:  
 name: app  
spec:  
 containers:  
   - name: nginx  
     image: nginx:latest  
---

## **Principais Abstrações**

| Recurso | Função |
| ----- | ----- |
| Pod | Unidade mínima |
| ReplicaSet | Garante número fixo de réplicas |
| Deployment | Gerencia rollout e rollback |
| Service | Exposição e load balancing |
| ConfigMap | Configuração externa |
| Secret | Dados sensíveis |
| Namespace | Isolamento lógico |
| Ingress | Roteamento HTTP |

Referência:  
[https://kubernetes.io/docs/concepts/overview/working-with-objects/](https://kubernetes.io/docs/concepts/overview/working-with-objects/)

---

## **Modelo Operacional**

Kubernetes implementa o padrão **Controller \+ Reconciliação**:

Estado atual ≠ Estado desejado → Controller atua → Convergência

Isso permite:

* Auto-healing  
* Escalabilidade automática  
* Resiliência  
* Atualizações progressivas

---

## **Resumo Técnico**

Kubernetes é um **sistema distribuído de controle declarativo**, baseado em:

* API REST central  
* Persistência consistente (etcd)  
* Controllers idempotentes  
* Scheduler inteligente  
* Runtime de containers

Ele abstrai infraestrutura e fornece uma camada padrão para execução de aplicações cloud-native.

---

# Estrutura Fundamental do Kubernetes

[Estrutura Fundamental do Kubernetes](docs/EstruturaFundamentalKubernetes.md)

---

# Como instalar o kubectl e kind

[Como instalar o kubectl e kind](docs/InstalandokindUbuntu.md)

---

# Criando um cluster com kind usando YAML

[Criando um cluster com kind usando YAML](docs/CriandoUmClusterComKindUsandoYAML.md)

---

# Criação de Pods no Kubernetes

[Criação de Pods no Kubernetes](docs/CriacaoDePodsNoKubernetes.md)

---

# ReplicaSet no Kubernetes

[ReplicaSet no Kubernetes](docs/ReplicaSetNoKubernetes.md)

---

# Deployment no Kubernetes

[Deployment no Kubernetes](docs/DeploymentNoKubernetes.md)

---

# Services no Kubernetes

[Services no Kubernetes](docs/ServicesNoKubernetes.md)

---

# kubectl proxy

[kubectl proxy](docs/kubectlProxy.md)

---

# Service Type: LoadBalancer

[Service Type: LoadBalancer](docs/ServiceTypeLoadBalancer.md)

---

# Configuração no Kubernetes (ConfigMap e Variáveis de Ambiente)

[Configuração no Kubernetes (ConfigMap e Variáveis de Ambiente)](docs/ConfiguracaoNoKubernetes.md)

---

# ConfigMap como Volume (Deep Dive)

[ConfigMap como Volume (Deep Dive)](docs/ConfigMapComoVolume.md)

---

# Resources, Metrics Server e HPA no Kubernetes (com kind)

[Resources, Metrics Server e HPA no Kubernetes (com kind)](docs/ConfigMapComoVolume.md)
