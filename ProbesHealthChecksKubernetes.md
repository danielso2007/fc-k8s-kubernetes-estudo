- [**Probes, Health Checks, Liveness, Readiness e StartupProbe no Kubernetes**](#probes-health-checks-liveness-readiness-e-startupprobe-no-kubernetes)
- [**Tipos de Probes**](#tipos-de-probes)
- [**Liveness Probe**](#liveness-probe)
  - [**Conceito**](#conceito)
- [**YAML de Liveness Probe**](#yaml-de-liveness-probe)
- [**Readiness Probe**](#readiness-probe)
  - [**Conceito**](#conceito-1)
- [**YAML de Readiness Probe**](#yaml-de-readiness-probe)
- [**Startup Probe**](#startup-probe)
  - [**Conceito**](#conceito-2)
- [**YAML de Startup Probe**](#yaml-de-startup-probe)
- [**Exemplo completo no seu Deployment**](#exemplo-completo-no-seu-deployment)
- [**Tipos de execução de Probes**](#tipos-de-execução-de-probes)
  - [**HTTP**](#http)
  - [**TCP**](#tcp)
  - [**Exec**](#exec)
- [**Comandos kubectl para trabalhar com probes**](#comandos-kubectl-para-trabalhar-com-probes)
  - [**Ver pods**](#ver-pods)
  - [**Ver detalhes do Pod**](#ver-detalhes-do-pod)
  - [**Ver logs**](#ver-logs)
  - [**Ver eventos do cluster**](#ver-eventos-do-cluster)
  - [**Ver pods com status**](#ver-pods-com-status)
  - [**Ver endpoint do service**](#ver-endpoint-do-service)
- [**Testar manualmente o endpoint de health**](#testar-manualmente-o-endpoint-de-health)
- [**Boas práticas**](#boas-práticas)
- [**Referências**](#referências)


# **Probes, Health Checks, Liveness, Readiness e StartupProbe no Kubernetes**

No Kubernetes, **probes** são mecanismos que permitem ao cluster verificar o **estado de saúde de um container dentro de um Pod**.

Essas verificações são executadas pelo **kubelet**, que roda em cada **node do cluster**.

O objetivo é permitir que o Kubernetes tome decisões automáticas como:

* reiniciar containers travados  
* remover Pods do balanceamento de carga  
* aguardar aplicações finalizarem o processo de inicialização  
* evitar enviar tráfego para aplicações que ainda não estão prontas

No seu caso, os Pods são criados a partir do **Deployment `hello-k8s`**, que possui **3 réplicas**.

Arquitetura:
```
Deployment
    ↓  
ReplicaSet
    ↓
Pods (3)
    ↓
Container hello-k8s
```
O **kubelet executa probes periodicamente dentro do container**.

Documentação oficial:  
[https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)

---

# **Tipos de Probes**

Existem três tipos de probes no Kubernetes:

| Probe | Função |
| ----- | ----- |
| livenessProbe | verifica se o container ainda está funcionando |
| readinessProbe | verifica se o container pode receber tráfego |
| startupProbe | verifica se a aplicação terminou de iniciar |

Fluxo típico de execução:
```
Container inicia
      ↓
startupProbe
      ↓
readinessProbe
      ↓
Pod entra no Service
      ↓  
livenessProbe monitora continuamente
```
---

# **Liveness Probe**

## **Conceito**

A **liveness probe** verifica se o container ainda está **vivo e funcionando**.

Se falhar repetidamente:
```bash
kubelet reinicia o container
```
Fluxo:
```
container travado
        ↓  
livenessProbe falha
        ↓
kubelet detecta falha
        ↓
container restart
```
---

# **YAML de Liveness Probe**

Exemplo adaptado para sua aplicação (porta 8080):
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8080
  initialDelaySeconds: 20
  periodSeconds: 10
  timeoutSeconds: 2
  failureThreshold: 3
```
Significado:

| Campo | Função |
| ----- | ----- |
| initialDelaySeconds | tempo antes da primeira execução |
| periodSeconds | intervalo entre execuções |
| timeoutSeconds | tempo máximo de resposta |
| failureThreshold | número de falhas antes de reiniciar |

---

# **Readiness Probe**

## **Conceito**

A **readiness probe** determina se o container está **pronto para receber tráfego**.

Se falhar:

* o container continua rodando  
* o Pod é removido do **Service**

Fluxo de rede:
```
Service
   ↓
EndpointSlice
   ↓
Pods READY
```
Se a readiness falhar:
```
Pod removido do EndpointSlice
      ↓
Service não envia tráfego

```
Isso é essencial para evitar enviar requisições para aplicações que ainda estão iniciando.

---

# **YAML de Readiness Probe**
```yaml
readinessProbe:
  httpGet:
    path: /actuator/health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 2
  failureThreshold: 3
```
---

# **Startup Probe**

## **Conceito**

A **startup probe** é usada para aplicações que demoram para iniciar.

Muito comum em:

* aplicações Java  
* aplicações que executam migrations  
* aplicações que carregam grandes volumes de dados

Enquanto a startup probe não passar:
```
livenessProbe não executa
```
Fluxo:
```
Container inicia
        ↓
startupProbe executa
        ↓
se passar → habilita livenessProbe
```
---

# **YAML de Startup Probe**
```yaml
startupProbe:
  httpGet:
    path: /actuator/health
    port: 8080
  failureThreshold: 30
  periodSeconds: 5
```
Cálculo do tempo máximo de inicialização:
```nginx
failureThreshold × periodSeconds
30 × 5 = 150 segundos
```
A aplicação pode levar até **150 segundos para iniciar**.

---

# **Exemplo completo no seu Deployment**

Baseado no seu YAML:
```yaml
containers:
  - name: hello-k8s
    image: hello-k8s:latest
    imagePullPolicy: IfNotPresent

    ports:
      - containerPort: 8080

    startupProbe:
      httpGet:
        path: /actuator/health
        port: 8080
      failureThreshold: 30
      periodSeconds: 5

    readinessProbe:
      httpGet:
        path: /actuator/health
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5

    livenessProbe:
      httpGet:
        path: /actuator/health
        port: 8080
      initialDelaySeconds: 20
      periodSeconds: 10
```
---

# **Tipos de execução de Probes**

O Kubernetes suporta três métodos.

## **HTTP**
```yaml
httpGet:
  path: /health
  port: 8080

```
Usado para aplicações web.

---

## **TCP**

Verifica apenas se a porta está aberta.
```yaml
tcpSocket:
  port: 8080
```
---

## **Exec**

Executa um comando dentro do container.
```yaml
exec:
  command:
    - cat
    - /tmp/healthy
```
Se retornar **exit code 0**, a probe é considerada bem sucedida.

---

# **Comandos kubectl para trabalhar com probes**

## **Ver pods**
```bash
kubectl get pods
```
Exemplo:
```bash
hello-k8s-8467dbd9fb-7x7zq   1/1 Running
```
---

## **Ver detalhes do Pod**
```bash
kubectl describe pod <pod>
```
Exemplo:
```bash
kubectl describe pod hello-k8s-8467dbd9fb-7x7zq
```
Na seção **Events** aparecem mensagens como:
```bash
Liveness probe failed
Readiness probe failed
Container restarted
```
---

## **Ver logs**
```bash
kubectl logs <pod>
```
Exemplo:
```bash
kubectl logs hello-k8s-8467dbd9fb-7x7zq
```
---

## **Ver eventos do cluster**
```bash
kubectl get events
```
Ordenado por tempo:
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```
---

## **Ver pods com status**
```bash
kubectl get pods -o wide
```
Isso mostra também:

* node  
* IP  
* status

---

## **Ver endpoint do service**
```bash
kubectl get endpointslices
```
Isso mostra quais Pods estão **READY**.

---

# **Testar manualmente o endpoint de health**

Entrar no pod:
```bash
kubectl exec -it <pod> -- sh
```
Testar:
```bash
curl localhost:8080/actuator/health
```
---

# **Boas práticas**

1. separar endpoints de health  
2. usar startupProbe em aplicações Java  
3. readiness antes de liveness  
4. evitar probes muito agressivas  
5. definir corretamente initialDelaySeconds

---

# **Referências**

Kubernetes Probes  
https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/\#container-probes

Configuring Liveness, Readiness and Startup Probes  
[https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

Spring Boot Actuator  
[https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)

