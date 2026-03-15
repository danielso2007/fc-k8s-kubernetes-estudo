- [📖 Guia de Referência: Menu de Ações](#-guia-de-referência-menu-de-ações)
  - [💡 Como utilizar](#-como-utilizar)
  - [🏗️ Cluster \& Deploy](#️-cluster--deploy)
    - [1) `up-cluster.sh`](#1-up-clustersh)
    - [2) `reset-cluster.sh`](#2-reset-clustersh)
    - [3) `build-api-java-exemplo.sh`](#3-build-api-java-exemplosh)
    - [4) `redeploy.sh`](#4-redeploysh)
  - [📊 Monitoramento](#-monitoramento)
    - [5) `watch-pods.sh`](#5-watch-podssh)
    - [6) `logs-pods.sh`](#6-logs-podssh)
    - [7) `monitor-hpa.sh`](#7-monitor-hpash)
    - [8) `apiservices-list-chech.sh`](#8-apiservices-list-chechsh)
  - [🔍 Acesso \& Debug](#-acesso--debug)
    - [9) `port-forward-pod.sh`](#9-port-forward-podsh)
    - [10) `access-pod.sh`](#10-access-podsh)
    - [11) `describe-pod.sh`](#11-describe-podsh)
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


# 📖 Guia de Referência: Menu de Ações

O arquivo menu.sh centraliza a gestão da aplicação hello-k8s. Abaixo estão as descrições de cada comando disponível:

## 💡 Como utilizar
1. Certifique-se de que está na raiz do projeto.
2. Execute `./menu.sh`.
3. Digite o número da opção desejada e siga as instruções na tela.

## 🏗️ Cluster & Deploy
Gerenciamento da infraestrutura e publicação da aplicação.

### 1) `up-cluster.sh`
- Cria o cluster Kind (caso não exista) utilizando o arquivo de configuração.
- Builda a imagem Docker e a carrega no cluster (Exemplo API Java Spring-boot).
- Aplica os manifestos YAML e aguarda o rollout.

### 2) `reset-cluster.sh`
- Destrói o cluster.

### 3) `build-api-java-exemplo.sh`
- Para criar a API de exemplo.
- Gerencia a versão no pom.xml (incremento de Patch ou Minor).
- Compila a imagem Docker atualizada e injeta no Kind.

### 4) `redeploy.sh`
- Força o Kubernetes a reiniciar os Pods existentes (rollout restart).
- Aplica novas configurações sem deletar o cluster.

## 📊 Monitoramento
Acompanhamento de saúde, escalonamento e logs.

### 5) `watch-pods.sh`
- Exibe em tempo real o status de cada Pod (Running, Terminating, Pending).

### 6) `logs-pods.sh`
- Inicia o Stern para exibir logs coloridos de todas as réplicas simultaneamente.

### 7) `monitor-hpa.sh`
- Monitora o consumo de CPU/Memória e dispara alertas visuais se os limites forem atingidos.

### 8) `apiservices-list-chech.sh`
- Valida se os serviços internos da API do Kubernetes estão operacionais.

## 🔍 Acesso & Debug
Interação direta com os containers para diagnóstico.

### 9) `port-forward-pod.sh`
- Mapeia a porta do Pod para o seu localhost, permitindo testar a API via navegador ou Postman.

### 10) `access-pod.sh`
- Permite escolher uma réplica específica e abrir um terminal interativo (sh) dentro do container.

### 11) `describe-pod.sh`
- Exibe os eventos detalhados do Kubernetes para entender por que um Pod falhou ao iniciar.


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
