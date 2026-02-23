package com.example.coffeeshops.coffee.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class CoffeeShopCreateRequest {
    @NotBlank(message = "Название обязательно")
    @Size(max = 120, message = "Название слишком длинное")
    private String name;

    @NotBlank(message = "Адрес обязателен")
    @Size(max = 200, message = "Адрес слишком длинный")
    private String address;

    @NotNull(message = "Широта обязательна")
    @Min(value = -90, message = "Широта должна быть в диапазоне [-90; 90]")
    @Max(value = 90, message = "Широта должна быть в диапазоне [-90; 90]")
    private Double lat;

    @NotNull(message = "Долгота обязательна")
    @Min(value = -180, message = "Долгота должна быть в диапазоне [-180; 180]")
    @Max(value = 180, message = "Долгота должна быть в диапазоне [-180; 180]")
    private Double lng;

    @NotNull(message = "Рейтинг обязателен")
    @Min(value = 0, message = "Рейтинг должен быть от 0 до 5")
    @Max(value = 5, message = "Рейтинг должен быть от 0 до 5")
    private Double rating;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Double getLat() {
        return lat;
    }

    public void setLat(Double lat) {
        this.lat = lat;
    }

    public Double getLng() {
        return lng;
    }

    public void setLng(Double lng) {
        this.lng = lng;
    }

    public Double getRating() {
        return rating;
    }

    public void setRating(Double rating) {
        this.rating = rating;
    }
}
