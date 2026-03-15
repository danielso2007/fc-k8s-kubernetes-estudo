# **ConfigMap como Volume (Deep Dive)**

Base: Kubernetes  
Doc oficial: [https://kubernetes.io/docs/concepts/configuration/configmap/](https://kubernetes.io/docs/concepts/configuration/configmap/)

---

# **📌 Quando usar ConfigMap como Volume**

Use volume quando:

* Aplicação lê arquivo (ex: `.properties`, `.yaml`)  
* Precisa atualizar config sem rebuild  
* Precisa múltiplas chaves como arquivos

Diferente de `env`, aqui o conteúdo vira **arquivo real no filesystem do container**.

---

# **1️⃣ Exemplo Simples (cada chave vira um arquivo)**

## **📄 ConfigMap**
```yaml
apiVersion: v1  
kind: ConfigMap  
metadata:  
 name: hello-k8s-config  
data:  
 application.properties: |  
   app.message=Hello from file  
   app.env=dev  
 log.level: "INFO"  
```
---

## **📄 Deployment usando volume**
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
         volumeMounts:  
           - name: config-volume  
             mountPath: /config  
     volumes:  
       - name: config-volume  
         configMap:  
           name: hello-k8s-config  
```
---

# **🔎 O que acontece**

Dentro do container:
```
/config/application.properties  
/config/log.level
```
Cada chave do ConfigMap vira um arquivo.

Verifique:
```bash
kubectl exec -it <pod> -- ls /config
kubectl exec -it <pod> -- cat /config/application.properties
```
---

# **2️⃣ Atualização dinâmica**

Se você editar:
```bash
kubectl edit configmap hello-k8s-config
```
O Kubernetes:

Atualiza conteúdo do volume automaticamente

⚠️ Mas:

* Atualização não é instantânea (leva alguns segundos)  
* Aplicação precisa reler arquivo  
* Variáveis de ambiente NÃO atualizam automaticamente

---

# **3️⃣ Exemplo com subPath (montar arquivo específico)**

Montar apenas 1 arquivo:
```yaml
volumeMounts:  
 - name: config-volume  
   mountPath: /app/application.properties  
   subPath: application.properties

volumes:  
 - name: config-volume  
   configMap:  
     name: hello-k8s-config  
```
---

# **🔎 Diferença importante**

Sem `subPath`:
```
/config/<arquivos>
```
Com `subPath`:
```
/app/application.properties
```
⚠️ Com `subPath`, atualizações NÃO são refletidas dinamicamente.

---

# **4️⃣ Exemplo com items (mapear chaves específicas)**
```yaml
volumes:  
 - name: config-volume  
   configMap:  
     name: hello-k8s-config  
     items:  
       - key: application.properties  
         path: app.properties
```
Resultado:
```
/config/app.properties  
```
---

# **5️⃣ Definir permissões**
```yaml
volumes:  
 - name: config-volume  
   configMap:  
     name: hello-k8s-config  
     defaultMode: 0444
```
Permissões padrão são 0644\.

---

# **6️⃣ Criar ConfigMap via CLI com arquivo**

Arquivo local:
```
application.properties
```
Criar:
```bash
kubectl create configmap hello-k8s-config \  
 --from-file=application.properties
```
Isso gera:
```
key = nome do arquivo  
value = conteúdo  
```
---

# **7️⃣ Estrutura interna do volume**

Internamente Kubernetes cria:
```
/var/lib/kubelet/pods/\<uid\>/volumes/kubernetes.io\~configmap/
```
Usa mecanismo de:
```
Projected volume  
Atomic symlink swap
```
Por isso atualização é quase instantânea.

---

# **8️⃣ Fluxo Interno**
```
kubectl apply configmap  
     ↓  
API Server atualiza etcd  
     ↓  
kubelet detecta mudança  
     ↓  
Recria conteúdo do volume  
     ↓  
Container enxerga novo arquivo  
```
---

# **9️⃣ Spring Boot \+ ConfigMap Volume**

Se usar:
```yaml
spring.config.additional-location=file:/config/
```
Spring passa a ler automaticamente arquivos do volume.

---

# **🔟 Comparação: env vs volume**

| Característica | env | volume |
| ----- | ----- | ----- |
| Atualiza automático | ❌ | ✅ |
| Fácil acesso | ✅ | ✅ |
| Ideal para arquivo grande | ❌ | ✅ |
| Necessita restart | Sim | Não necessariamente |

---

# **1️⃣1️⃣ Erros comuns**

### **ConfigMap não encontrado**
```
MountVolume.SetUp failed
```
Verifique namespace.

---

### **Arquivo não atualiza**

Se estiver usando `subPath`, isso é esperado.

---

# **1️⃣2️⃣ Melhor prática**

* Config pequena → env  
* Config estruturada → volume  
* Dados sensíveis → Secret  
* Produção → versionar via Helm

