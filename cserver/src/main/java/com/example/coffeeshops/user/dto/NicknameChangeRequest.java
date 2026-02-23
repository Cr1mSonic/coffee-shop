package com.example.coffeeshops.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class NicknameChangeRequest {
    @NotBlank(message = "Никнейм обязателен")
    @Size(min = 2, max = 50, message = "Никнейм должен быть от 2 до 50 символов")
    private String nickname;

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
}
