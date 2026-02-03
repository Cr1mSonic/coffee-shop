package com.example.coffeeshops.coffee;

import org.springframework.stereotype.Service;
import java.util.List;


@Service
public class CoffeeShopService {

    private final CoffeeShopRepository repository;

    public CoffeeShopService(CoffeeShopRepository repository) {
        this.repository = repository;
    }

    public List<CoffeeShop> getAllShops() {
        return repository.findAll();
    }
}
