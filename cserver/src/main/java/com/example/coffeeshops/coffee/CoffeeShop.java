package com.example.coffeeshops.coffee;

import jakarta.persistence.*;

@Entity
public class CoffeeShop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private double lat;
    private double lng;
    private double rating;

    public CoffeeShop() {}

    public CoffeeShop(String name, double lat, double lng, double rating) {
        this.name = name;
        this.lat = lat;
        this.lng = lng;
        this.rating = rating;
    }

    // ✅ Геттеры и сеттеры
    public Long getId() { return id; }
    public String getName() { return name; }
    public double getLat() { return lat; }
    public double getLng() { return lng; }
    public double getRating() { return rating; }

    public void setId(Long id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setLat(double lat) { this.lat = lat; }
    public void setLng(double lng) { this.lng = lng; }
    public void setRating(double rating) { this.rating = rating; }
}
