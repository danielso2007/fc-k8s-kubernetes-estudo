# **kubectl proxy**

Base: kubectl  
Relacionado a: Kubernetes  
Doc: [https://kubernetes.io/docs/tasks/extend-kubernetes/http-proxy-access-api/](https://kubernetes.io/docs/tasks/extend-kubernetes/http-proxy-access-api/)

---

# **1️⃣ O que é o `kubectl proxy`**

`kubectl proxy` cria um **proxy HTTP local** para o Kubernetes API Server.

Ele:

* Abre uma porta local (default 8001\)  
* Encaminha requisições HTTP para o API Server  
* Usa automaticamente seu kubeconfig  
* Autentica usando suas credenciais

Ele NÃO expõe aplicações.  
Ele expõe a **API do cluster**.

---

# **2️⃣ Arquitetura**

Sem proxy:
```
curl → API Server (https, TLS, auth obrigatória)
```
Com proxy:
```
curl → localhost:8001 → kubectl proxy → API Server
```
Fluxo real:
```
Client HTTP  
   ↓  
localhost:8001  
   ↓  
kubectl proxy  
   ↓  
kube-apiserver (TLS \+ auth)  
   ↓  
etcd / controllers
```
---

# **3️⃣ Como iniciar**
```bash
kubectl proxy
```
Saída:
```
Starting to serve on 127.0.0.1:8001
```
Agora a API está acessível em:
```
http://localhost:8001  
```
---

# **4️⃣ Testando acesso à API**

Listar namespaces via HTTP:
```bash
curl http://localhost:8001/api/v1/namespaces
```
Listar pods:
```bash
curl http://localhost:8001/api/v1/namespaces/default/pods
```
Isso retorna JSON bruto da API.

---

# **5️⃣ Acessar Dashboard (quando instalado)**

Se houver Dashboard:
```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```
O proxy resolve autenticação automaticamente.

---

# **6️⃣ Flags importantes**

### **Mudar porta**
```bash
kubectl proxy \--port=9000  
```

---

### **Permitir acesso externo (cuidado)**
```bash
kubectl proxy \--address=0.0.0.0 \--accept-hosts='^.\*$'
```
⚠️ Isso expõe a API localmente para rede externa.

---

### **Filtrar caminhos**
```bash
kubectl proxy \--accept-paths='^/api/.\*'  
```
---

# **7️⃣ Diferença entre kubectl proxy e port-forward**

| kubectl proxy | kubectl port-forward |
| ----- | ----- |
| Acessa API Server | Acessa Pod/Service |
| Proxy HTTP | Túnel TCP |
| Não expõe app | Expõe app |
| Usa kubeconfig | Usa conexão SPDY |

---

# **8️⃣ Exemplo prático no seu cluster**

Suba o proxy:
```bash
kubectl proxy
```
Abra outro terminal:

Listar Services:
```bash
curl http://localhost:8001/api/v1/namespaces/default/services
```
Ver Deployment:
```bash
curl http://localhost:8001/apis/apps/v1/namespaces/default/deployments/hello-k8s  
```

---

# **9️⃣ Como funciona internamente**

`kubectl proxy`:

1. Lê kubeconfig  
2. Abre servidor HTTP local  
3. Converte requisição HTTP simples  
4. Encaminha para API Server via TLS  
5. Retorna resposta ao cliente

Ele remove necessidade de:

* TLS manual  
* Token manual  
* Certificados client-side

---

# **🔟 Segurança**

Por padrão:
```
127.0.0.1 only
```
Isso evita exposição da API.

Nunca use:
```bash
--address=0.0.0.0
```
em ambientes não controlados.

---

# **1️⃣1️⃣ Ver recursos disponíveis**

Descobrir API groups:
```bash
curl http://localhost:8001/apis
```
Descobrir core:
```bash
curl http://localhost:8001/api
```
Isso mostra a estrutura da API REST do Kubernetes.

---

# **1️⃣2️⃣ Relação com API REST**

Exemplo real equivalente:
```bash
kubectl get pods
```
Internamente vira:
```http
GET /api/v1/namespaces/default/pods
```
via API Server.

---

# **1️⃣3️⃣ Quando usar**

Use `kubectl proxy` quando quiser:

* Explorar API manualmente  
* Testar integrações REST  
* Depurar recursos  
* Usar Dashboard  
* Testar chamadas programáticas

Não use para expor aplicação.

---

# **📌 Conceito Fundamental**

`kubectl proxy` é:

Um reverse proxy HTTP autenticado para o Kubernetes API Server.

Ele facilita acesso à API sem lidar com TLS e credenciais manualmente.

---

# **🎯 Resumo Técnico**

| Característica | kubectl proxy |
| ----- | ----- |
| Protocolo | HTTP |
| Destino | API Server |
| Autenticação | Automática (kubeconfig) |
| Exposição de app | ❌ |
| Uso principal | Debug e acesso API |

