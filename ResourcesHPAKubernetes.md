- [Resources, Metrics Server e HPA no Kubernetes (com kind)](#resources-metrics-server-e-hpa-no-kubernetes-com-kind)
- [Resources no Deployment](#resources-no-deployment)
  - [Requests](#requests)
  - [Limits](#limits)
    - [CPU](#cpu)
    - [Memória](#memória)
- [Unidades de CPU](#unidades-de-cpu)
- [QoS Classes](#qos-classes)
- [Instalando Metrics Server no kind](#instalando-metrics-server-no-kind)
- [Ajuste necessário para kind](#ajuste-necessário-para-kind)
- [Verificar se metrics-server está funcionando](#verificar-se-metrics-server-está-funcionando)
- [Testar métricas](#testar-métricas)
- [Horizontal Pod Autoscaler (HPA)](#horizontal-pod-autoscaler-hpa)
- [YAML completo de HPA](#yaml-completo-de-hpa)
- [Criar HPA](#criar-hpa)
- [Verificar HPA](#verificar-hpa)
- [Ver detalhes](#ver-detalhes)
- [Fluxo de autoscaling](#fluxo-de-autoscaling)
- [Testar HPA gerando carga](#testar-hpa-gerando-carga)
- [Usando o Fortio para testes](#usando-o-fortio-para-testes)
- [Boas práticas](#boas-práticas)
- [Referências](#referências)


# Resources, Metrics Server e HPA no Kubernetes (com kind)

Para utilizar **HPA (Horizontal Pod Autoscaler)** é necessário que o
cluster possua um sistema de métricas.\
No Kubernetes isso é feito normalmente pelo **metrics-server**.

Arquitetura:

    Application Pods
           ↓
    kubelet coleta métricas
           ↓
    metrics-server
           ↓
    Kubernetes API (metrics.k8s.io)
           ↓
    HPA Controller
           ↓
    Deployment escala Pods

Referência:\
https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/

------------------------------------------------------------------------

# Resources no Deployment

No seu Deployment você já definiu **requests** e **limits**.

``` yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

## Requests

Quantidade **mínima garantida** para o container.

O **kube-scheduler** usa esse valor para decidir em qual node o Pod será
executado.

Exemplo:

    Node possui 4 CPU
    Pod request = 100m

Resultado:

    4000m / 100m = até 40 Pods

------------------------------------------------------------------------

## Limits

Define o **máximo de recursos que o container pode usar**.

Se ultrapassar:

### CPU

O container sofre **throttling**.

### Memória

O container pode ser **OOMKilled**.

------------------------------------------------------------------------

# Unidades de CPU

CPU no Kubernetes usa **millicores**.

  Valor   Significado
  ------- -------------
  1000m   1 CPU
  500m    0.5 CPU
  100m    0.1 CPU

Exemplo:

``` yaml
cpu: 250m
```

Significa:

    0.25 CPU

Referência:\
https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu

------------------------------------------------------------------------

# QoS Classes

Dependendo da configuração de resources, o Kubernetes define a **QoS
Class** do Pod.

  Classe       Condição
  ------------ --------------------
  Guaranteed   requests = limits
  Burstable    requests \< limits
  BestEffort   nenhum resource

Seu Deployment é:

    Burstable

------------------------------------------------------------------------

# Instalando Metrics Server no kind

O **kind** não instala o metrics-server automaticamente.

Instalação padrão:

``` bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
Referência:\
https://github.com/kubernetes-sigs/metrics-server

------------------------------------------------------------------------

# Ajuste necessário para kind

Como o kind usa certificados internos, é necessário adicionar a flag:

    --kubelet-insecure-tls

Editar o deployment:

``` bash
kubectl edit deployment metrics-server -n kube-system
```

Adicionar em `args`:

``` yaml
- --kubelet-insecure-tls
```

Exemplo:

``` yaml
containers:
- name: metrics-server
  args:
    - --cert-dir=/tmp
    - --secure-port=10250
    - --kubelet-insecure-tls
```

------------------------------------------------------------------------

# Verificar se metrics-server está funcionando

``` bash
kubectl get pods -n kube-system
```

Exemplo:

    metrics-server-6c8fdbf6d7-abcde   Running

------------------------------------------------------------------------

# Testar métricas

Com metrics-server instalado:

``` bash
kubectl top nodes
```

Exemplo:

    NAME                        CPU(cores)   MEMORY(bytes)
    lab-cluster-control-plane   120m         500Mi

Ver pods:

``` bash
kubectl top pods
```

Exemplo:

    NAME               CPU(cores)   MEMORY(bytes)
    hello-k8s-abcde    70m          140Mi

Referência:\
https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/

------------------------------------------------------------------------

# Horizontal Pod Autoscaler (HPA)

O **HPA** ajusta automaticamente o número de Pods baseado em métricas.

Normalmente utiliza:

-   CPU
-   memória
-   métricas customizadas

Arquitetura:

    metrics-server
          ↓
    HPA Controller
          ↓
    Deployment
          ↓
    ReplicaSet
          ↓
    Pods

Referência:\
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

------------------------------------------------------------------------

# YAML completo de HPA

Exemplo para seu Deployment `hello-k8s`.

``` yaml
apiVersion: autoscaling/v2 # Versão da API que permite múltiplas métricas
kind: HorizontalPodAutoscaler # Tipo do recurso para escalonamento horizontal

metadata: # Metadados de identificação
  name: hello-k8s-hpa # Nome do rastreador HPA

spec: # Especificações de funcionamento
  scaleTargetRef: # Referência do que será escalado
    apiVersion: apps/v1 # API do recurso alvo
    kind: Deployment # Tipo do alvo (Deployment)
    name: hello-k8s # Nome do Deployment que será vigiado

  minReplicas: 2 # Mínimo de instâncias mantidas vivas
  maxReplicas: 10 # Máximo de instâncias (aumentei para dar margem)

  metrics: # Lista de métricas (o HPA avaliará todas)
  - type: Resource # Primeira métrica: Recurso de sistema
    resource:
      name: cpu # Monitoramento de processamento
      target:
        type: Utilization # Baseado em porcentagem
        averageUtilization: 60 # Escala se a média de CPU passar de 60%
  
  - type: Resource # Segunda métrica: Recurso de sistema
    resource:
      name: memory # Monitoramento de memória RAM
      target:
        type: Utilization # Baseado em porcentagem
        averageUtilization: 70 # Escala se a média de Memória passar de 70%
```

Significado:

  Campo                Função
  -------------------- ----------------
  minReplicas          mínimo de pods
  maxReplicas          máximo de pods
  averageUtilization   target de CPU

------------------------------------------------------------------------

# Criar HPA

Aplicar YAML:

``` bash
kubectl apply -f hpa.yaml
```

Ou criar via CLI:

``` bash
kubectl autoscale deployment hello-k8s   --cpu-percent=60   --min=3   --max=10
```

------------------------------------------------------------------------

# Verificar HPA

``` bash
kubectl get hpa
```

Exemplo:

    NAME            REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS
    hello-k8s-hpa   Deployment/hello-k8s   40%/60%   3         10        3

------------------------------------------------------------------------

# Ver detalhes

``` bash
kubectl describe hpa hello-k8s-hpa
```

Mostra:

-   métricas atuais
-   scaling decisions
-   eventos

------------------------------------------------------------------------

# Fluxo de autoscaling

    Client envia requisições
            ↓
    Pods usam CPU
            ↓
    metrics-server coleta métricas
            ↓
    HPA calcula scaling
            ↓
    Deployment aumenta replicas

------------------------------------------------------------------------

# Testar HPA gerando carga

Esse comando é o "canivete suíço" para testar redes e carga dentro do cluster. Basicamente, ele cria um Pod temporário para você rodar comandos manualmente.

Aqui está o que cada parte faz:
- `kubectl run load-generator`: Cria um novo Pod chamado `load-generator`.
- `-it`: Abre um terminal Interativo com o Pod (você entra "dentro" dele).
- `--rm`: Remove o Pod automaticamente assim que você sair dele (ótimo para não deixar lixo no cluster).
- `--image=busybox`: Usa a imagem `busybox`, que é super leve e já vem com ferramentas como `wget`, `ping` e `nslookup`.
- `-- /bin/sh`: Executa o shell do Linux dentro do container para você digitar seus comandos.

Criar pod para gerar tráfego:

``` bash
kubectl run load-generator -it --rm   --image=busybox   -- /bin/sh
```

Executar loop:

``` bash
while true; do wget -q -O- http://hello-k8s/hello-k8s/v1/env; done
```

Observar scaling:

``` bash
kubectl get pods -w
```

# Usando o Fortio para testes

O Fortio é uma das ferramentas favoritas da comunidade Kubernetes (usada inclusive pelo Istio) porque ele consegue manter uma carga constante de requisições por segundo (TPS) e gera relatórios detalhados de latência.

Diferente do `wget`, o Fortio permite que você controle exatamente a intensidade do "ataque".

1. Rodando o Fortio via kubectl
Você pode rodar um Pod temporário já com o comando de stress. O comando abaixo envia 20 requisições por segundo (`-qps 20`) durante 1 minuto (`-t 1m`):

```bash
kubectl run fortio -it --rm --image=fortio/fortio -- load -qps 20 -t 1m -c 8 http://hello-k8s/hello-k8s/v1/env
```
O que significam os parâmetros:
- `load`: Comando do Fortio para gerar carga.
- `-qps 20`: Queries Per Second. Define a velocidade (20 disparos por segundo).
- `-t 1m`: Duração do teste (1 minuto). Use 0 para rodar infinitamente.
- `-c 8`: Conexões simultâneas (8 threads paralelas).
- `http://...`: O endpoint da sua API.

2. Por que usar o Fortio para testar o seu HPA?
Como você está monitorando CPU e Memória, o Fortio é excelente porque ele não "engasga" o seu próprio terminal. Você pode aumentar o `-c` (concorrência) para forçar o uso de CPU:
- Para forçar CPU: Aumente as conexões simultâneas (`-c 32` ou mais).
- Para ver estabilidade: Use um QPS fixo e observe se a latência sobe quando o Kubernetes está criando novos Pods.

3. Versão com Interface Gráfica (Web UI)
O Fortio tem uma interface incrível que gera gráficos de histograma. Você pode rodá-lo como um serviço temporário no cluster:

1. Inicie o servidor do Fortio:

```bash
kubectl run fortio-server --image=fortio/fortio -- server
```
Faça um port-forward para acessar no seu navegador:

```bash
kubectl port-forward pod/fortio-server 8080:8080
```

Acesse `http://localhost:8080/fortio/` no seu browser. Lá você pode preencher os campos e ver o gráfico de performance em tempo real.

------------------------------------------------------------------------

# Boas práticas

1.  sempre definir **requests de CPU**
2.  usar **CPU para HPA**
3.  evitar limits muito baixos
4.  definir **minReplicas \>= 2**
5.  monitorar métricas constantemente

------------------------------------------------------------------------

# Referências

Resource Management\
https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

Horizontal Pod Autoscaler\
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

Metrics Server\
https://github.com/kubernetes-sigs/metrics-server

Resource Metrics Pipeline\
https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/
