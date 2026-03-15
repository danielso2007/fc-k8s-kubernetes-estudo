- [**kubectl e kind**](#kubectl-e-kind)
- [**kubectl**](#kubectl)
  - [**O que é**](#o-que-é)
  - [**Como funciona internamente**](#como-funciona-internamente)
  - [**Arquivo kubeconfig**](#arquivo-kubeconfig)
  - [**Principais comandos**](#principais-comandos)
  - [**Conceito importante**](#conceito-importante)
- [**kind**](#kind)
  - [**O que é**](#o-que-é-1)
  - [**Como funciona internamente**](#como-funciona-internamente-1)
  - [**Fluxo de criação**](#fluxo-de-criação)
  - [**Arquitetura simplificada**](#arquitetura-simplificada)
- [**Diferença Fundamental**](#diferença-fundamental)
  - [**Relação entre eles**](#relação-entre-eles)
- [**Resumo Técnico**](#resumo-técnico)
- [**Instalando o kind no Ubuntu (para estudo de Kubernetes)**](#instalando-o-kind-no-ubuntu-para-estudo-de-kubernetes)
- [**1 Pré-requisitos**](#1-pré-requisitos)
  - [**1.1 Container Runtime**](#11-container-runtime)
  - [**1.2 kubectl**](#12-kubectl)
- [**2 Instalar o kind**](#2-instalar-o-kind)
- [**3 Criar Cluster**](#3-criar-cluster)
- [**4 Criar Cluster Multi-Node (Recomendado para estudo)**](#4-criar-cluster-multi-node-recomendado-para-estudo)
- [**5 Como o kind funciona internamente**](#5-como-o-kind-funciona-internamente)
- [**6 Remover Cluster**](#6-remover-cluster)
- [**7 Versão do Kubernetes**](#7-versão-do-kubernetes)
- [**Comparação com outras opções**](#comparação-com-outras-opções)
- [**Recomendação para estudo**](#recomendação-para-estudo)


# **kubectl e kind**

---

# **kubectl**

Projeto: kubectl  
Parte do ecossistema: Kubernetes  
Documentação: [https://kubernetes.io/docs/reference/kubectl/](https://kubernetes.io/docs/reference/kubectl/)

## **O que é**

`kubectl` é o **cliente CLI oficial do Kubernetes**.

Ele é apenas um **client HTTP REST** que interage com o **kube-apiserver**.

---

## **Como funciona internamente**
```
kubectl → REST API → kube-apiserver → etcd → controllers
```
Fluxo ao aplicar um manifesto:
```bash
kubectl apply -f deployment.yaml
```
1. Converte YAML → JSON  
2. Autentica via kubeconfig  
3. Envia requisição HTTP para API Server  
4. API valida e persiste no etcd  
5. Controllers iniciam reconciliação

---

## **Arquivo kubeconfig**

Local padrão:
```bash
\~/.kube/config
```
Contém:

* cluster (endpoint)  
* credentials (cert/token)  
* context (cluster \+ user \+ namespace)

Exemplo:
```yaml
apiVersion: v1  
clusters:  
- cluster:  
   server: https://127.0.0.1:6443  
 name: kind-lab  
contexts:  
- context:  
   cluster: kind-lab  
   user: kind-user  
```
---

## **Principais comandos**
```bash
kubectl get pods  
kubectl describe pod \<name\>  
kubectl logs \<pod\>  
kubectl exec -it \<pod\> -- bash  
kubectl apply -f file.yaml  
kubectl delete -f file.yaml  
```
---

## **Conceito importante**

`kubectl` **não executa containers**  
Ele apenas **interage com a API do cluster**.

---

# **kind**

Projeto: kind  
Documentação: [https://kind.sigs.k8s.io/](https://kind.sigs.k8s.io/)

---

## **O que é**

`kind` (Kubernetes IN Docker) é uma ferramenta que:

Cria clusters Kubernetes rodando dentro de containers Docker.

Ele é usado principalmente para:

* Estudo  
* Testes locais  
* CI pipelines

---

## **Como funciona internamente**

Cada node do cluster é um container Docker rodando uma imagem:
```
kindest/node:\<versão\>
```
Dentro do container:
```
kubelet  
containerd  
kube-apiserver (control-plane)  
etcd  
scheduler  
controller-manager  
```
---

## **Fluxo de criação**
```bash
kind create cluster
```
O kind:

1. Cria containers Docker  
2. Inicializa cluster com kubeadm interno  
3. Gera kubeconfig automaticamente  
4. Configura kubectl para usar o cluster

---

## **Arquitetura simplificada**
```
Ubuntu Host  
└── Docker  
     ├── Container (control-plane)  
     ├── Container (worker)  
     └── Container (worker)  
```
---

# **Diferença Fundamental**

| Ferramenta | Papel |
| ----- | ----- |
| kubectl | Cliente que conversa com cluster |
| kind | Ferramenta que cria o cluster |

---

## **Relação entre eles**

kind cria cluster  
kubectl opera cluster  

---

# **Resumo Técnico**

* `kubectl` → CLI oficial, cliente REST do Kubernetes  
* `kind` → Provisionador local de cluster usando Docker  
* Ambos são independentes  
* `kubectl` pode operar qualquer cluster (kind, kubeadm, cloud)

---

# **Instalando o kind no Ubuntu (para estudo de Kubernetes)**

O **kind (Kubernetes IN Docker)** cria clusters Kubernetes usando containers Docker como nós.

Projeto: kind  
Documentação oficial: [https://kind.sigs.k8s.io/](https://kind.sigs.k8s.io/)

---

# **1 Pré-requisitos**

## **1.1 Container Runtime**

O kind usa Docker.

Instale o Docker:
```bash
sudo apt update  
sudo apt install -y docker.io
```
Habilite e inicie:
```bash
sudo systemctl enable docker  
sudo systemctl start docker
```
Adicione seu usuário ao grupo docker (evita sudo):
```bash
sudo usermod -aG docker $USER  
newgrp docker
```
Teste:
```bash
docker run hello-world  
```
---

## **1.2 kubectl**

Cliente oficial do Kubernetes.
```bash
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  
chmod \+x kubectl  
sudo mv kubectl /usr/local/bin/
```
Verifique:
```bash
kubectl version --client
```
Referência:  
[https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)

---

# **2 Instalar o kind**

Instalação binária direta:
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64  
chmod \+x kind  
sudo mv kind /usr/local/bin/
```
Verifique:
```bash
kind version  
```
---

# **3 Criar Cluster**

Criação padrão (1 control-plane):
```bash
kind create cluster --name lab
```
Verifique:
```bash
kubectl cluster-info  
kubectl get nodes
```
Você verá algo como:
```
NAME                 STATUS   ROLES           AGE  
lab-control-plane    Ready    control-plane   1m  
```
---

# **4 Criar Cluster Multi-Node (Recomendado para estudo)**

Arquivo `cluster.yaml`:
```yaml
kind: Cluster  
apiVersion: kind.x-k8s.io/v1alpha4  
nodes:  
 - role: control-plane  
 - role: worker  
 - role: worker
```
Criar:
```bash
kind create cluster --config cluster.yaml --name lab
```
Verificar:
```bash
kubectl get nodes -o wide  
```
---

# **5 Como o kind funciona internamente**

Arquitetura simplificada:
```
Docker Container (Node)  
├── kubelet  
├── containerd  
├── kube-apiserver  
├── etcd
```
Cada node é um container Docker rodando uma imagem oficial:

kindest/node:\<k8s-version\>

Verifique:
```bash
docker ps  
```
---

# **6 Remover Cluster**
```bash
kind delete cluster --name lab  
```
---

# **7 Versão do Kubernetes**

Criar cluster com versão específica:
```bash
kind create cluster --image kindest/node:v1.29.2
```
Lista de versões:  
[https://hub.docker.com/r/kindest/node](https://hub.docker.com/r/kindest/node)

---

# **Comparação com outras opções**

| Ferramenta | Característica |
| ----- | ----- |
| kind | Roda dentro do Docker |
| minikube | VM ou container |
| k3s | Kubernetes leve |
| MicroK8s | Snap, mais integrado |

---

# **Recomendação para estudo**

Para seu ambiente Ubuntu:

* kind \+ kubectl  
* Cluster multi-node  
* Habilitar métricas depois (metrics-server)  
* Testar Deployments \+ Services \+ Ingress

---

[Voltar](README.md)
