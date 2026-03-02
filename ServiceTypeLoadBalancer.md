# **Service Type: LoadBalancer**

Base: Kubernetes  
Documentação: [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)

---

# **1️⃣ O que é um LoadBalancer**

`type: LoadBalancer` é um Service que:

* Cria um ClusterIP  
* Cria um NodePort automaticamente  
* Solicita um Load Balancer externo ao provedor

Arquitetura lógica:
```
Cliente Externo  
     ↓  
Load Balancer (Cloud)  
     ↓  
NodePort  
     ↓  
ClusterIP  
     ↓  
Pods
```
⚠️ Importante:

Em ambientes locais (kind, minikube), não existe provedor cloud.  
Logo:
```
EXTERNAL-IP ficará como <pending>
```
A menos que você use MetalLB.

---

# **2️⃣ YAML Completo (Deployment \+ LoadBalancer)**

## **📄 `loadbalancer.yml`**
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

---  
apiVersion: v1  
kind: Service  
metadata:  
 name: hello-k8s  
 labels:  
   app: hello-k8s  
spec:  
 type: LoadBalancer  
 selector:  
   app: hello-k8s  
 ports:  
   - protocol: TCP  
     port: 80  
     targetPort: 8080
```
---

# **3️⃣ Explicação Detalhada**

---

## **Deployment**

Mesma lógica já estudada:
```
Deployment → ReplicaSet → Pods
```
`replicas: 3` → 3 Pods ativos.

---

## **Service type: LoadBalancer**
```yaml
type: LoadBalancer
```
Isso faz 3 coisas automaticamente:

1️⃣ Cria ClusterIP  
2️⃣ Cria NodePort  
3️⃣ Solicita LoadBalancer externo

Você pode confirmar:
```bash
kubectl get svc hello-k8s
```
Saída típica (local):
```
TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)  
LoadBalancer   10.96.45.22    <pending>     80:32451/TCP
```
Observe:
```
80:32451
```
32451 é o NodePort criado automaticamente.

---

# **4️⃣ Criar os recursos**
```bash
kubectl apply -f loadbalancer.yml  
```

---

# **5️⃣ Verificar status**
```bash
kubectl get deployment  
kubectl get pods -o wide  
kubectl get svc  
kubectl get endpoints  
```
---

# **6️⃣ Como funciona em Cloud (EKS/GKE/AKS)**

Quando você cria LoadBalancer:
```
Service Controller  
     ↓  
Cloud Controller Manager  
     ↓  
API da Cloud  
     ↓  
Provisiona Load Balancer real  
     ↓  
Atribui EXTERNAL-IP
```
Depois:
```bash
kubectl get svc
```
Mostraria:
```
EXTERNAL-IP   34.123.45.67
```
Acesso externo:
```
http://34.123.45.67/hello  
```

---

# **7️⃣ Como funciona no kind (ambiente local)**

No kind:

* Não existe Cloud Controller Manager real  
* EXTERNAL-IP ficará `<pending>`

Você pode acessar via NodePort:
```bash
kubectl get svc hello-k8s
```
Identifique:
```
PORT(S): 80:32451/TCP
```
Descubra IP do node:
```bash
kubectl get nodes -o wide
```
Teste:
```bash
curl http://<NODE-IP>:32451/hello
```
⚠️ Em kind, precisa de `extraPortMappings` ou port-forward.
```bash
kubectl port-forward pod/hello-k8s 8080:80
```
---

# **8️⃣ Fluxo Interno Completo**
```
Service criado  
    ↓  
API Server registra  
    ↓  
Service Controller cria NodePort  
    ↓  
EndpointSlice associa Pods  
    ↓  
kube-proxy cria regras iptables  
    ↓  
Tráfego começa a rotear
```
Se estiver em cloud:
```
Cloud Controller cria Load Balancer externo  
```

---

# **9️⃣ Diferença entre ClusterIP, NodePort e LoadBalancer**

| Tipo | Exposição |
| ----- | ----- |
| ClusterIP | Interno |
| NodePort | Porta do Node |
| LoadBalancer | IP externo real |
| Ingress | Roteamento HTTP L7 |

---

# **🔟 Teste prático de balanceamento**

Execute várias vezes:
```bash
curl http://localhost:PORTA/hello
```
Se modificar o controller para retornar hostname, verá alternância entre pods.

---

# **1️⃣1️⃣ Conceitos Importantes**

LoadBalancer:

* É abstração L4  
* Balanceia TCP  
* Não faz roteamento por path  
* Não substitui Ingress

---

# **1️⃣2️⃣ MetalLB (para ambiente local)**

Se quiser LoadBalancer real no kind:

Use:

MetalLB

Ele simula provisionamento externo.

---

# **🎯 Resumo Técnico**

| Componente | Função |
| ----- | ----- |
| Deployment | Garante Pods |
| Service LB | Exposição externa |
| NodePort | Porta intermediária |
| EndpointSlice | Backend dinâmico |
| kube-proxy | Regras de roteamento |
| Cloud Controller | Provisiona LB real |

---

# **📌 Estado atual no seu laboratório**

No kind:

* LoadBalancer cria NodePort  
* EXTERNAL-IP ficará pending  
* Use port-forward ou extraPortMappings

---

