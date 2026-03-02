package com.example.hello_k8s.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.TreeMap;

@Slf4j
@RestController
@Tag(name = "Hello API", description = "Endpoints de saudação e verificação de status")
public class HelloController {

    @Operation(
        summary = "Check de disponibilidade", 
        description = "Endpoint simples para verificar se a API está respondendo na raiz"
    )
    @ApiResponse(responseCode = "200", description = "API está online")
    @GetMapping("/v1/")
    public ResponseEntity<String> healthCheck() {
        log.info("Chamada recebida no endpoint de Health Check");
        return ResponseEntity.ok("ok");
    }

    @Operation(
        summary = "Retorna saudação padrão", 
        description = "Retorna um objeto JSON com a mensagem clássica de Hello World"
    )
    @ApiResponse(responseCode = "200", description = "Mensagem retornada com sucesso")
    @GetMapping("/v1/hello")
    public ResponseEntity<Map<String, String>> hello() {
        log.info("Chamada recebida no endpoint /v1/hello");
        return ResponseEntity.ok(Map.of("message", "Hello World"));
    }

    @Operation(
        summary = "Lista variáveis de ambiente", 
        description = "Retorna todas as variáveis de ambiente do sistema onde o container está rodando"
    )
    @ApiResponse(responseCode = "200", description = "Lista de variáveis retornada com sucesso")
    @GetMapping("/v1/env")
    public ResponseEntity<Map<String, String>> getEnvironmentVariables() {
        log.info("Chamada recebida no endpoint /v1/env para listar variáveis");
        
        // Usamos TreeMap para manter as chaves em ordem alfabética, facilitando a leitura
        Map<String, String> envVars = new TreeMap<>(System.getenv());
        
        return ResponseEntity.ok(envVars);
    }
}
