package com.example.hello_k8s.controller;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

@Slf4j
@RestController
@Tag(name = "Hello API", description = "Endpoints de saudação e verificação de status")
public class HelloController {

    private final MeterRegistry registry;
    private final Counter cpuStressCounter;
    private static final List<byte[]> memoryLoad = new ArrayList<>();

    public HelloController(MeterRegistry registry) {
        this.registry = registry;

        // Contador: Quantas vezes o endpoint de CPU foi chamado
        this.cpuStressCounter = Counter.builder("api.stress.cpu.calls")
                .description("Total de chamadas ao stress de CPU")
                .register(registry);

        // Gauge: Mede o tamanho da lista de memória em tempo real
        Gauge.builder("api.stress.memory.objects", memoryLoad, List::size)
                .description("Quantidade de blocos de 10MB alocados na lista")
                .register(registry);
    }

    @Operation(summary = "Check de disponibilidade", description = "Endpoint simples para verificar se a API está respondendo na raiz")
    @ApiResponse(responseCode = "200", description = "API está online")
    @GetMapping("/v1/")
    public ResponseEntity<String> healthCheck() {
        log.info("Chamada recebida no endpoint de Health Check");
        return ResponseEntity.ok("ok");
    }

    @Operation(summary = "Retorna saudação padrão", description = "Retorna um objeto JSON com a mensagem clássica de Hello World")
    @ApiResponse(responseCode = "200", description = "Mensagem retornada com sucesso")
    @GetMapping("/v1/hello")
    public ResponseEntity<Map<String, String>> hello() {
        log.info("Chamada recebida no endpoint /v1/hello");
        return ResponseEntity.ok(Map.of("message", "Hello World"));
    }

    @Operation(summary = "Lista variáveis de ambiente", description = "Retorna todas as variáveis de ambiente do sistema onde o container está rodando")
    @ApiResponse(responseCode = "200", description = "Lista de variáveis retornada com sucesso")
    @GetMapping("/v1/env")
    public ResponseEntity<Map<String, String>> getEnvironmentVariables() {
        log.info("Chamada recebida no endpoint /v1/env para listar variáveis");

        // Usamos TreeMap para manter as chaves em ordem alfabética, facilitando a
        // leitura
        Map<String, String> envVars = new TreeMap<>(System.getenv());

        return ResponseEntity.ok(envVars);
    }

    @Operation(summary = "Busca credenciais do MongoDB", description = "Retorna especificamente as variáveis de usuário e senha do MongoDB configuradas no ambiente")
    @ApiResponse(responseCode = "200", description = "Credenciais retornadas com sucesso")
    @GetMapping("/v1/secrets")
    public ResponseEntity<Map<String, String>> getMongoSecrets() {
        log.info("Chamada recebida para buscar credenciais do MongoDB");

        Map<String, String> mongoSecrets = new TreeMap<>();

        // Busca as variáveis específicas do sistema
        String user = System.getenv("DB_USER_MONGO");
        String pass = System.getenv("DB_PASSWORD_MONGO");

        // Adiciona ao mapa apenas se não forem nulas (opcional)
        mongoSecrets.put("DB_USER_MONGO", user != null ? user : "NOT_SET");
        mongoSecrets.put("DB_PASSWORD_MONGO", pass != null ? pass : "NOT_SET");

        return ResponseEntity.ok(mongoSecrets);
    }

    @Operation(summary = "Força a falha da aplicação", description = "Gera um erro fatal que encerra a JVM em 5 segundos, forçando o restart do Pod pelo Kubernetes")
    @ApiResponse(responseCode = "200", description = "Falha agendada com sucesso")
    @GetMapping("/v1/crash")
    public ResponseEntity<String> forceCrash() {
        log.error("⚠️ ALERTA: Comando de crash recebido! O Pod será encerrado em 5 segundos...");

        // Criamos uma Thread separada para não travar a resposta HTTP
        new Thread(() -> {
            try {
                Thread.sleep(5000); // Aguarda 5 segundos
                log.error("💥 Crash iminente. Encerrando JVM...");
                System.exit(1); // Finaliza o processo com erro, forçando o K8s a reiniciar
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }).start();

        return ResponseEntity.ok("O container será reiniciado em 5 segundos. Tchau!");
    }

    @Operation(summary = "Simula consumo de CPU")
    @GetMapping("/v1/stress-cpu")
    public ResponseEntity<String> stressCpu() {
        cpuStressCounter.increment(); // Incrementa a métrica no Micrometer
        log.info("🔥 Iniciando carga de CPU...");
        long result = calculateFibonacci(50);
        return ResponseEntity.ok("Cálculo de CPU finalizado. Resultado: " + result);
    }

    @Operation(summary = "Simula consumo de Memória")
    @GetMapping("/v1/stress-memory")
    public ResponseEntity<String> stressMemory() {
        byte[] block = new byte[200 * 1024 * 1024]; // 200MB
        memoryLoad.add(block);

        // Podemos registrar um evento específico ou apenas deixar o Gauge monitorar a
        // lista
        registry.counter("api.stress.memory.allocated.total").increment();

        long totalMemory = Runtime.getRuntime().totalMemory() / 1024 / 1024;
        log.info("💾 Bloco adicionado. Itens na lista: {}", memoryLoad.size());

        return ResponseEntity.ok("200MB adicionados. Itens ativos: " + memoryLoad.size());
    }

    @Operation(summary = "Limpa o consumo de Memória")
    @GetMapping("/v1/clear-memory")
    public ResponseEntity<String> clearMemory() {
        memoryLoad.clear();
        System.gc();
        log.info("扫 Memória liberada via Micrometer.");
        return ResponseEntity.ok("Métricas resetadas e memória limpa!");
    }

    private long calculateFibonacci(int n) {
        if (n <= 1)
            return n;
        return calculateFibonacci(n - 1) + calculateFibonacci(n - 2);
    }
}
