package com.example.coffeeshops.coffee;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;


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

    public Optional<CoffeeShop> rateShop(Long id, double newRating) {
        return repository.findById(id).map(shop -> {
            // Minimal averaging strategy without extra schema fields.
            double updated = (shop.getRating() + newRating) / 2.0;
            shop.setRating(updated);
            return repository.save(shop);
        });
    }
}
