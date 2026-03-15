# **Configuração no Kubernetes (ConfigMap e Variáveis de Ambiente)**

Base: Kubernetes  
Doc oficial: [https://kubernetes.io/docs/concepts/configuration/configmap/](https://kubernetes.io/docs/concepts/configuration/configmap/)

---

# **1️⃣ Problema que ConfigMap resolve**

Separar:
```
Código ≠ Configuração
```
Sem ConfigMap:

* Variáveis ficam hardcoded  
* Rebuild de imagem para cada ambiente

Com ConfigMap:

* Configuração externa  
* Mutável  
* Independente da imagem

---

# **2️⃣ O que é um ConfigMap**

É um objeto da API que armazena:

* Pares chave/valor  
* Arquivos  
* Configuração textual

Ele pode ser consumido por:

* Variáveis de ambiente  
* Volume montado  
* Argumentos de container

---

# **3️⃣ Criando ConfigMap (YAML)**

## **📄 `configmap.yml`**
```yaml
apiVersion: v1  
kind: ConfigMap

metadata:  
 name: hello-k8s-config  
 labels:  
   app: hello-k8s

data:  
 APP_MESSAGE: "Hello World from ConfigMap"  
 APP_ENV: "dev"
```
---

# **4️⃣ Criando Deployment usando ConfigMap**

## **📄 `deployment-config.yml`**
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

         env:  
           - name: APP_MESSAGE  
             valueFrom:  
               configMapKeyRef:  
                 name: hello-k8s-config  
                 key: APP_MESSAGE

           - name: APP_ENV  
             valueFrom:  
               configMapKeyRef:  
                 name: hello-k8s-config  
                 key: APP_ENV  
```
---

# **5️⃣ Explicação Detalhada**

---

## **ConfigMap**
```yaml
data:  
 APP_MESSAGE: "Hello World from ConfigMap"
```
Armazena pares chave/valor.

Internamente:
```
API Server → etcd  
```

---

## **Deployment → env → valueFrom**
```yaml
valueFrom:  
 configMapKeyRef:
```
Significa:

> Puxe valor da chave X do ConfigMap Y.

No runtime:
```
kubelet resolve ConfigMap  
Injeta variável no container  
```
---

# **6️⃣ Aplicando os recursos**
```bash
kubectl apply -f configmap.yml
kubectl apply -f deployment-config.yml
```
---

# **7️⃣ Verificar ConfigMap**
```bash
kubectl get configmap  
kubectl describe configmap hello-k8s-config  
```

---

# **8️⃣ Verificar variáveis dentro do Pod**
```bash
kubectl exec -it <pod> -- printenv | grep APP
```
Saída esperada:
```
APP_MESSAGE=Hello World from ConfigMap  
APP_ENV=dev  
```
---

# **9️⃣ Atualizando ConfigMap**
```bash
kubectl edit configmap hello-k8s-config
```
⚠️ Observação importante:

Se usar como variável de ambiente:
```
Container NÃO atualiza automaticamente.
```
Você precisa reiniciar pods:
```bash
kubectl rollout restart deployment hello-k8s  
```
---

# **🔟 ConfigMap como Volume**

Alternativa:
```yaml
volumeMounts:  
 - name: config-volume  
   mountPath: /config

volumes:  
 - name: config-volume  
   configMap:  
     name: hello-k8s-config
```
Nesse caso:
```
Arquivo é atualizado dinamicamente
```
Sem reiniciar container (dependendo da aplicação).

---

# **1️⃣1️⃣ Criando ConfigMap via CLI**
```bash
kubectl create configmap hello-k8s-config \ 
 --from-literal=APP_MESSAGE="Hello World" \ 
 --from-literal=APP_ENV="dev"
```
Ou a partir de arquivo:
```bash
kubectl create configmap hello-k8s-config \ 
 --from-file=application.properties  
```
---

# **1️⃣2️⃣ Fluxo Interno**
```
kubectl apply  
     ↓  
API Server valida  
     ↓  
Persistido no etcd  
     ↓  
Deployment referencia ConfigMap  
     ↓  
kubelet injeta valor no container  
```
---

# **1️⃣3️⃣ Diferença ConfigMap vs Secret**

| ConfigMap | Secret |
| ----- | ----- |
| Texto claro | Base64 |
| Configuração | Dados sensíveis |
| Não criptografado por padrão | Pode usar encryption at rest |

---

# **1️⃣4️⃣ Boas práticas**

* Nunca versionar segredo no Git  
* Separar config por ambiente  
* Usar namespace para isolamento  
* Versionar ConfigMap via Helm

---

# **1️⃣5️⃣ Estrutura Final**
```
Cluster  
├── ConfigMap  
├── Deployment  
│      └── Pods  
│           └── Variáveis injetadas  
└── Service  
```
---

# **🎯 Conceito Fundamental**

ConfigMap é:

Um mecanismo declarativo para externalizar configuração da aplicação sem rebuild de imagem.

---

# **📌 Resumo Técnico**

| Elemento | Função |
| ----- | ----- |
| ConfigMap | Armazena config |
| env.valueFrom | Injeta variável |
| volumeMount | Monta arquivo |
| rollout restart | Atualiza Pods |

