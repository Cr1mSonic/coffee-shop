package com.example.coffeeshops.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // 🟢 Регистрация
    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody User user) {
        Map<String, Object> response = new HashMap<>();

        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            response.put("success", false);
            response.put("message", "Пользователь уже существует");
        } else {
            userRepository.save(user);
            response.put("success", true);
            response.put("message", "Регистрация успешна");
        }

        return response;
    }

    // 🟢 Вход
    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody User user) {
        Map<String, Object> response = new HashMap<>();

        return userRepository.findByEmail(user.getEmail())
                .filter(u -> u.getPassword().equals(user.getPassword()))
                .map(u -> {
                    response.put("success", true);
                    response.put("message", "Вход выполнен");
                    return response;
                })
                .orElseGet(() -> {
                    response.put("success", false);
                    response.put("message", "Неверный email или пароль");
                    return response;
                });
    }
}
