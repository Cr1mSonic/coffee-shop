package com.example.coffeeshops.ai;

import com.example.coffeeshops.ai.AiService;
import com.example.coffeeshops.ai.ChatRequest;
import com.example.coffeeshops.ai.ChatResponse;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/ai")
public class AiController {

    private final AiService aiService;

    public AiController(AiService aiService) {
        this.aiService = aiService;
    }

    @PostMapping("/chat")
    public ChatResponse chat(@RequestBody ChatRequest request) {
        return aiService.getChatResponse(request);
    }
}
