package com.example.coffeeshops.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class PasswordChangeRequest {
    @NotBlank(message = "Пароль обязателен")
    @Size(min = 6, max = 64, message = "Пароль должен быть от 6 до 64 символов")
    private String password;

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
