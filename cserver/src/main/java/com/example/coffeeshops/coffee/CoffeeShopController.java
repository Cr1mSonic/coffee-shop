package com.example.coffeeshops.coffee;

import com.example.coffeeshops.coffee.dto.CoffeeShopCreateRequest;
import com.example.coffeeshops.coffee.dto.CoffeeShopRateRequest;
import com.example.coffeeshops.user.User;
import com.example.coffeeshops.user.UserRepository;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.springframework.http.HttpStatus.FORBIDDEN;
import static org.springframework.http.HttpStatus.NOT_FOUND;
import static org.springframework.http.HttpStatus.UNAUTHORIZED;

@RestController
@RequestMapping("/api/coffee-shops")
@CrossOrigin(origins = "*") // ⚠️ Разрешаем Flutter подключаться
public class CoffeeShopController {

    private final CoffeeShopService service;
    private final UserRepository userRepository;

    public CoffeeShopController(CoffeeShopService service, UserRepository userRepository) {
        this.service = service;
        this.userRepository = userRepository;
    }

    @GetMapping
    public List<CoffeeShop> getAll() {
        return service.getAllShops();
    }

    @PostMapping
    public Map<String, Object> create(
            @RequestParam String adminEmail,
            @Valid @RequestBody CoffeeShopCreateRequest request
    ) {
        if (!isAdmin(adminEmail)) {
            throw new ResponseStatusException(FORBIDDEN, "Доступ запрещен");
        }

        CoffeeShop shop = new CoffeeShop(
                request.getName(),
                request.getAddress(),
                request.getLat(),
                request.getLng(),
                request.getRating()
        );
        CoffeeShop saved = service.createShop(shop);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("coffeeShop", saved);
        return response;
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(
            @PathVariable Long id,
            @RequestParam String adminEmail
    ) {
        if (!isAdmin(adminEmail)) {
            throw new ResponseStatusException(FORBIDDEN, "Доступ запрещен");
        }

        boolean deleted = service.deleteShop(id);
        if (!deleted) {
            throw new ResponseStatusException(NOT_FOUND, "Кофейня не найдена");
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Кофейня удалена");
        return response;
    }

    @PostMapping("/{id}/rate")
    public Map<String, Object> rateCoffeeShop(
            @PathVariable Long id,
            @RequestParam String userEmail,
            @Valid @RequestBody CoffeeShopRateRequest request
    ) {
        if (!userRepository.existsByEmail(userEmail)) {
            throw new ResponseStatusException(UNAUTHORIZED, "Пользователь не найден");
        }

        CoffeeShop updated = service.rateShop(id, request.getRating())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Кофейня не найдена"));

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("coffeeShop", updated);
        return response;
    }

    private boolean isAdmin(String email) {
        Optional<User> user = userRepository.findByEmail(email);
        return user.map(u -> "ADMIN".equals(u.getRole())).orElse(false);
    }
}
