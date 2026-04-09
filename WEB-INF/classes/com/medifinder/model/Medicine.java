package com.medifinder.model;

public class Medicine {

    private String id;
    private String name;
    private String price;
    private String stock;
    private String distance;
    private String rating;
    private String pharmacyEmail;
    private String pharmacyName;
    private String tabletsPerStrip;
    private String stripInfo;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPrice() {
        return price;
    }

    public void setPrice(String price) {
        this.price = price;
    }

    public String getStock() {
        return stock;
    }

    public void setStock(String stock) {
        this.stock = stock;
    }

    public String getDistance() {
        return distance;
    }

    public void setDistance(String distance) {
        this.distance = distance;
    }

    public String getRating() {
        return rating;
    }

    public void setRating(String rating) {
        this.rating = rating;
    }

    public String getPharmacyEmail() {
        return pharmacyEmail;
    }

    public void setPharmacyEmail(String pharmacyEmail) {
        this.pharmacyEmail = pharmacyEmail;
    }

    public String getPharmacyName() {
        return pharmacyName;
    }

    public void setPharmacyName(String pharmacyName) {
        this.pharmacyName = pharmacyName;
    }

    public String getTabletsPerStrip() {
        return tabletsPerStrip;
    }

    public void setTabletsPerStrip(String tabletsPerStrip) {
        this.tabletsPerStrip = tabletsPerStrip;
    }

    public String getStripInfo() {
        return stripInfo;
    }

    public void setStripInfo(String stripInfo) {
        this.stripInfo = stripInfo;
    }
}
