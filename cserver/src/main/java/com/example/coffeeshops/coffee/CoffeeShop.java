package com.example.coffeeshops.coffee;

import jakarta.persistence.*;

@Entity
@Table(name = "coffee_shop")
public class CoffeeShop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String address;
    private double lat;
    private double lng;
    private double rating;

    public CoffeeShop() {}

    public CoffeeShop(String name, String address, double lat, double lng, double rating) {
        this.name = name;
        this.address = address;
        this.lat = lat;
        this.lng = lng;
        this.rating = rating;
    }

    // ✅ Геттеры и сеттеры
    public Long getId() { return id; }
    public String getName() { return name; }
    public String getAddress() { return address; }
    public double getLat() { return lat; }
    public double getLng() { return lng; }
    public double getRating() { return rating; }

    public void setId(Long id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setAddress(String address) { this.address = address; }
    public void setLat(double lat) { this.lat = lat; }
    public void setLng(double lng) { this.lng = lng; }
    public void setRating(double rating) { this.rating = rating; }
}
