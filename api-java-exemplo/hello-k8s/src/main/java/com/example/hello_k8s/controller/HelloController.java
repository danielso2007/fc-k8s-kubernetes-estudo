package com.example.hello_k8s.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

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
        return ResponseEntity.ok("ok");
    }

    @Operation(
        summary = "Retorna saudação padrão", 
        description = "Retorna um objeto JSON com a mensagem clássica de Hello World"
    )
    @ApiResponse(responseCode = "200", description = "Mensagem retornada com sucesso")
    @GetMapping("/v1/hello")
    public ResponseEntity<Map<String, String>> hello() {
        return ResponseEntity.ok(Map.of("message", "Hello World"));
    }
}