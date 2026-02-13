package com.example.coffeeshops.coffee;

import com.example.coffeeshops.user.User;
import com.example.coffeeshops.user.UserRepository;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

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
            @RequestBody CoffeeShop shop
    ) {
        Map<String, Object> response = new HashMap<>();

        if (!isAdmin(adminEmail)) {
            response.put("success", false);
            response.put("message", "Р”РѕСЃС‚СѓРї Р·Р°РїСЂРµС‰С‘РЅ");
            return response;
        }

        CoffeeShop saved = service.createShop(shop);
        response.put("success", true);
        response.put("coffeeShop", saved);
        return response;
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(
            @PathVariable Long id,
            @RequestParam String adminEmail
    ) {
        Map<String, Object> response = new HashMap<>();

        if (!isAdmin(adminEmail)) {
            response.put("success", false);
            response.put("message", "Р”РѕСЃС‚СѓРї Р·Р°РїСЂРµС‰С‘РЅ");
            return response;
        }

        boolean deleted = service.deleteShop(id);
        response.put("success", deleted);
        if (!deleted) {
            response.put("message", "РљРѕС„РµР№РЅСЏ РЅРµ РЅР°Р№РґРµРЅР°");
        }
        return response;
    }

    private boolean isAdmin(String email) {
        Optional<User> user = userRepository.findByEmail(email);
        return user.map(u -> "ADMIN".equals(u.getRole())).orElse(false);
    }
}
