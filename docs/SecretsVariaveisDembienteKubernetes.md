# **Secrets e Variáveis de Ambiente no Kubernetes**

Base: Kubernetes  
Documentação: [https://kubernetes.io/docs/concepts/configuration/secret/](https://kubernetes.io/docs/concepts/configuration/secret/)

---

# **1️⃣ O que são Secrets**

`Secret` é um objeto da API usado para armazenar **dados sensíveis**, por exemplo:

* senhas  
* tokens  
* chaves de API  
* certificados TLS  
* credenciais de banco

Eles são semelhantes ao `ConfigMap`, porém destinados a **informações confidenciais**.

---

# **2️⃣ Diferença entre ConfigMap e Secret**

| ConfigMap | Secret |
| ----- | ----- |
| Configuração | Dados sensíveis |
| Texto normal | Base64 |
| Não criptografado por padrão | Pode usar encryption-at-rest |
| Ex: URL | Ex: senha |

⚠️ Importante:

Base64 **não é criptografia**.

---

# **3️⃣ Estrutura de um Secret**

## **📄 `secret.yml`**
```yaml
apiVersion: v1  
kind: Secret

metadata:  
 name: hello-k8s-secret

type: Opaque

data:  
 DB_USER: YWRtaW4=  
 DB_PASSWORD: c2VjcmV0  
```
---

# **🔎 Explicação**

## **type: Opaque**

Tipo padrão de secret.

Outros tipos:

| Tipo | Uso |
| ----- | ----- |
| Opaque | genérico |
| kubernetes.io/tls | certificados TLS |
| kubernetes.io/dockerconfigjson | login de registry |
| kubernetes.io/service-account-token | token interno |

---

## **data**

Valores precisam estar em **base64**.

Exemplo:
```bash
echo -n "admin" | base64
```
Resultado:
```bash
YWRtaW4=  
```
---

# **4️⃣ Criar Secret via CLI**

Mais fácil que YAML.
```bash
kubectl create secret generic hello-k8s-secret \  
 --from-literal=DB_USER=admin \  
 --from-literal=DB_PASSWORD=secret  
 ```
---

# **5️⃣ Ver Secrets**
```bash
kubectl get secrets
```
Detalhado:
```bash
kubectl describe secret hello-k8s-secret
```
Ver YAML:
```
kubectl get secret hello-k8s-secret -o yaml
```
---

# **6️⃣ Usar Secret como variável de ambiente**

## **📄 Deployment**
```yaml
apiVersion: apps/v1  
kind: Deployment

metadata:  
 name: hello-k8s

spec:  
 replicas: 2

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
         ports:  
           - containerPort: 8080

         env:  
           - name: DB_USER  
             valueFrom:  
               secretKeyRef:  
                 name: hello-k8s-secret  
                 key: DB_USER

           - name: DB_PASSWORD  
             valueFrom:  
               secretKeyRef:  
                 name: hello-k8s-secret  
                 key: DB_PASSWORD  
```
---

# **🔎 O que acontece**

No runtime:
```
Secret → kubelet → variável de ambiente → container
```
Dentro do container:
```bash
printenv DB_USER
```
Resultado:
```
admin  
```
---

# **7️⃣ Usar Secret como Volume**

## **📄 Deployment**
```yaml
volumeMounts:  
 - name: secret-volume  
   mountPath: /secrets  
   readOnly: true

volumes:  
 - name: secret-volume  
   secret:  
     secretName: hello-k8s-secret
```
Dentro do container:
```bash
/secrets/DB_USER  
/secrets/DB_PASSWORD
```
Verificar:
```bash
kubectl exec -it \<pod\> -- ls /secrets  
```
---

# **8️⃣ Criar Secret a partir de arquivo**

Arquivo:
```
password.txt
```
Criar:
```bash
kubectl create secret generic db-password \  
 --from-file=password.txt  
```
---

# **9️⃣ Fluxo interno**
```
kubectl apply secret  
       ↓  
API Server valida  
       ↓  
Persistido no etcd  
       ↓  
Pod referencia secret  
       ↓  
kubelet injeta valor no container
```
---

# **🔟 Segurança Interna**

Secrets ficam:
```
etcd
```
Se encryption-at-rest não estiver ativado:
```
armazenados em texto base64
```
Clusters de produção devem usar:
```
EncryptionConfiguration  
```
---

# **1️⃣1️⃣ Exemplo completo (Secret + Deployment + Service)**
```yaml
apiVersion: v1  
kind: Secret  
metadata:  
 name: hello-k8s-secret  
type: Opaque  
data:  
 API_KEY: MTIzNDU=

---  
apiVersion: apps/v1  
kind: Deployment  
metadata:  
 name: hello-k8s  
spec:  
 replicas: 2  
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
         env:  
           - name: API_KEY  
             valueFrom:  
               secretKeyRef:  
                 name: hello-k8s-secret  
                 key: API_KEY

---  
apiVersion: v1  
kind: Service  
metadata:  
 name: hello-k8s  
spec:  
 selector:  
   app: hello-k8s  
 ports:  
   - port: 80  
     targetPort: 8080  
```
---

# **1️⃣2️⃣ Boas práticas**

* Nunca commitar secrets no Git  
* Use namespace para isolamento  
* Use RBAC para controlar acesso  
* Use vault externo (Hashicorp Vault, AWS Secrets Manager)

---

# **1️⃣3️⃣ Erros comuns**

### **Secret não encontrado**
```
CreateContainerConfigError
```
Verificar:
```bash
kubectl describe pod \<pod\>  
```
---

### **chave errada**
```
key not found in secret  
```
---

# **🎯 Conceito fundamental**

Secret é:

> Um objeto Kubernetes projetado para armazenar dados sensíveis e fornecê-los aos containers de forma controlada.

---

# **📌 Resumo técnico**

| Método | Uso |
| ----- | ----- |
| env | variável ambiente |
| volume | arquivo |
| CLI create | rápido |
| YAML | declarativo |

