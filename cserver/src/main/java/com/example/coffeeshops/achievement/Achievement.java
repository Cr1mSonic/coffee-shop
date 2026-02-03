package com.example.coffeeshops.achievement;

public class Achievement {
    private String title;
    private String description;
    private String icon;
    private boolean unlocked;

    public Achievement(String title, String description, String icon, boolean unlocked) {
        this.title = title;
        this.description = description;
        this.icon = icon;
        this.unlocked = unlocked;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public boolean isUnlocked() {
        return unlocked;
    }

    public void setUnlocked(boolean unlocked) {
        this.unlocked = unlocked;
    }
}
