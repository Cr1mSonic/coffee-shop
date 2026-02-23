package com.example.coffeeshops.coffee.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

public class CoffeeShopRateRequest {

    @NotNull(message = "Рейтинг обязателен")
    @DecimalMin(value = "1.0", message = "Рейтинг должен быть не ниже 1.0")
    @DecimalMax(value = "5.0", message = "Рейтинг должен быть не выше 5.0")
    private Double rating;

    public Double getRating() {
        return rating;
    }

    public void setRating(Double rating) {
        this.rating = rating;
    }
}
