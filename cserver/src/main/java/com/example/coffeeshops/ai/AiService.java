package com.example.coffeeshops.ai;

import com.example.coffeeshops.coffee.CoffeeShop;
import com.example.coffeeshops.coffee.CoffeeShopRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.JsonNode;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.*;


@Service
public class AiService {
    private final CoffeeShopRepository coffeeShopRepository;

    public AiService(CoffeeShopRepository coffeeShopRepository) {
        this.coffeeShopRepository = coffeeShopRepository;
    }

    @Value("${spring.ai.openai.api-key}")
    private String apiKey;

    @Value("${spring.ai.openai.chat.options.model:gpt-4o-mini}")
    private String primaryModel;

    @Value("${app.ai.models:}")
    private String modelsProperty;

    @Value("${app.ai.api-url:https://api.openai.com/v1/chat/completions}")
    private String apiUrl;

    @Value("${app.ai.openrouter.site-url:http://localhost}")
    private String openRouterSiteUrl;

    @Value("${app.ai.openrouter.app-title:CoffeeApp}")
    private String openRouterAppTitle;

    @Value("${app.ai.max-output-tokens:120}")
    private int maxOutputTokens;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public ChatResponse getChatResponse(ChatRequest request) {
        try {
            if (request == null || request.getMessage() == null || request.getMessage().isBlank()) {
                return new ChatResponse("Ошибка: пустой запрос.");
            }

            if (apiKey == null || apiKey.isBlank()) {
                return new ChatResponse("Ошибка: API ключ не настроен");
            }

            List<String> models = buildModelList();

            String lastError = "Не удалось получить ответ от AI";

            for (String model : models) {
                Map<String, Object> payload = new HashMap<>();
                payload.put("model", model);
                payload.put("temperature", 0.2);
                payload.put("max_tokens", maxOutputTokens);
                payload.put("messages", List.of(
                        Map.of("role", "system", "content", buildSystemPrompt()),
                        Map.of("role", "user", "content", request.getMessage())
                ));

                String json = objectMapper.writeValueAsString(payload);

                HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
                        .uri(URI.create(apiUrl))
                        .header("Content-Type", "application/json")
                        .header("Authorization", "Bearer " + apiKey);

                if (apiUrl.contains("openrouter.ai")) {
                    requestBuilder
                            .header("HTTP-Referer", openRouterSiteUrl)
                            .header("X-Title", openRouterAppTitle);
                }

                HttpRequest httpRequest = requestBuilder
                        .POST(HttpRequest.BodyPublishers.ofString(json))
                        .build();

                HttpResponse<String> response = HttpClient.newHttpClient()
                        .send(httpRequest, HttpResponse.BodyHandlers.ofString());

                JsonNode root = objectMapper.readTree(response.body());

                if (response.statusCode() >= 400) {
                    String errorMessage = root.path("error").path("message").asText();
                    if (errorMessage == null || errorMessage.isBlank()) {
                        errorMessage = "Ошибка AI API (HTTP " + response.statusCode() + ")";
                    }
                    lastError = errorMessage;
                    continue;
                }

                JsonNode choices = root.path("choices");
                if (!choices.isArray() || choices.isEmpty()) {
                    String errorMessage = root.path("error").path("message").asText();
                    lastError = (errorMessage == null || errorMessage.isBlank())
                            ? "Некорректный ответ AI API"
                            : errorMessage;
                    continue;
                }

                String content = extractContent(choices.get(0));
                if (content == null || content.isBlank()) {
                    lastError = "AI вернул пустой ответ";
                    continue;
                }

                return new ChatResponse(content.trim());
            }

            return new ChatResponse("Ошибка: " + lastError);

        } catch (Exception e) {
            return new ChatResponse("Ошибка: " + e.getMessage());
        }
    }

    private List<String> buildModelList() {
        List<String> configured = Arrays.stream(modelsProperty.split(","))
                .map(String::trim)
                .filter(s -> !s.isBlank())
                .toList();

        if (!configured.isEmpty()) {
            return configured;
        }

        return List.of(primaryModel);
    }

    private String extractContent(JsonNode choice) {
        JsonNode message = choice.path("message");
        JsonNode contentNode = message.path("content");

        if (contentNode.isTextual()) {
            return contentNode.asText();
        }

        if (contentNode.isArray()) {
            for (JsonNode part : contentNode) {
                String text = part.path("text").asText();
                if (text != null && !text.isBlank()) {
                    return text;
                }
            }
        }

        String directText = choice.path("text").asText();
        if (directText != null && !directText.isBlank()) {
            return directText;
        }

        return "";
    }

    private String buildSystemPrompt() {
        List<CoffeeShop> shops = coffeeShopRepository.findAll();
        String shopsText;

        if (shops.isEmpty()) {
            shopsText = "Список кофеен в базе пуст.";
        } else {
            shopsText = shops.stream()
                    .limit(30)
                    .map(s -> String.format("- %s | %s | рейтинг %.1f", s.getName(), s.getAddress(), s.getRating()))
                    .reduce((a, b) -> a + "\n" + b)
                    .orElse("Список кофеен в базе пуст.");
        }

        return """
                Ты бариста-ассистент приложения Coffee Radar.
                Правила:
                1) Отвечай на любые темы вежливо и по делу.
                2) Всегда отвечай кратко: 1-3 предложения, без длинных списков.
                3) В конце каждого ответа добавляй короткое дружелюбное предложение поговорить про кофе.
                4) Если спрашивают про кофейни, используй только данные из списка ниже.

                Кофейни из базы:
                %s
                """.formatted(shopsText);
    }
}
