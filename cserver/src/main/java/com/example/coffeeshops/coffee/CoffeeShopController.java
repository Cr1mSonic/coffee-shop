package com.example.coffeeshops.coffee;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/coffee-shops")
@CrossOrigin(origins = "*") // ⚠️ Разрешаем Flutter подключаться
public class CoffeeShopController {

    private final CoffeeShopService service;

    public CoffeeShopController(CoffeeShopService service) {
        this.service = service;
    }

    @GetMapping
    public List<CoffeeShop> getAll() {
        return service.getAllShops();
    }
}
