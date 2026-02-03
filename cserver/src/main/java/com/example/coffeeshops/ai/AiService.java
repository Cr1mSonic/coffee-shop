package com.example.coffeeshops.ai;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.*;


@Service
public class AiService {

    @Value("${spring.ai.openai.api-key}")
    private String apiKey;

    private static final String API_URL = "https://openrouter.ai/api/v1/chat/completions";

    private final ObjectMapper objectMapper = new ObjectMapper();

    public ChatResponse getChatResponse(ChatRequest request) {
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("model", "gpt-3.5-turbo"); 
            payload.put("messages", List.of(
                    Map.of("role", "system", "content", "Ты — виртуальный бариста, отвечай про кофе."),
                    Map.of("role", "user", "content", request.getMessage())
            ));

            String json = objectMapper.writeValueAsString(payload);

            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL))
                    .header("Content-Type", "application/json")

                    .header("Authorization", "Bearer " + apiKey)
                    .header("HTTP-Referer", "http://localhost")
                    .header("X-Title", "CoffeeApp")

                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpResponse<String> response = HttpClient.newHttpClient()
                    .send(httpRequest, HttpResponse.BodyHandlers.ofString());

            String content = objectMapper.readTree(response.body())
                    .path("choices").get(0).path("message").path("content").asText();

            return new ChatResponse(content);

        } catch (Exception e) {
            return new ChatResponse("Ошибка: " + e.getMessage());
        }
    }
}
