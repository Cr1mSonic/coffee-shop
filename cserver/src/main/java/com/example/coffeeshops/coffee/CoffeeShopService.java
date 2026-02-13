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

    public CoffeeShop createShop(CoffeeShop shop) {
        return repository.save(shop);
    }

    public boolean deleteShop(Long id) {
        if (!repository.existsById(id)) {
            return false;
        }
        repository.deleteById(id);
        return true;
    }
}
