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
            if ("admin@admin.com".equals(user.getEmail())) {
                user.setRole("ADMIN");
            } else {
                user.setRole("USER");
            }
            userRepository.save(user);
            response.put("success", true);
            response.put("message", "Регистрация успешна");
            response.put("role", user.getRole());
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
                    response.put("email", u.getEmail());
                    response.put("role", u.getRole());
                    return response;
                })
                .orElseGet(() -> {
                    response.put("success", false);
                    response.put("message", "Неверный email или пароль");
                    return response;
                });
     }

    // 🟢 Получить профиль
    @GetMapping("/user/{email}")
    public Map<String, Object> getUser(@PathVariable String email) {
        Map<String, Object> response = new HashMap<>();

        return userRepository.findByEmail(email)
                .map(u -> {
                    response.put("success", true);
                    response.put("email", u.getEmail());
                    response.put("nickname", u.getEmail()); // пока ник = email
                    response.put("avatar", null); // аватар позже
                    return response;
                })
                .orElseGet(() -> {
                    response.put("success", false);
                    response.put("message", "Пользователь не найден");
                    return response;
                });
    }

    // 🔐 Смена пароля
    @PutMapping("/user/{email}/password")
    public Map<String, Object> changePassword(
            @PathVariable String email,
            @RequestBody Map<String, String> body) {

        Map<String, Object> response = new HashMap<>();

        return userRepository.findByEmail(email)
                .map(u -> {
                    u.setPassword(body.get("password"));
                    userRepository.save(u);
                    response.put("success", true);
                    return response;
                })
                .orElseGet(() -> {
                    response.put("success", false);
                    response.put("message", "Пользователь не найден");
                    return response;
                });
    }

    // ✍️ Смена никнейма (пока без поля в БД)
    @PutMapping("/user/{email}/nickname")
    public Map<String, Object> changeNickname(
            @PathVariable String email,
            @RequestBody Map<String, String> body) {

        Map<String, Object> response = new HashMap<>();

        if (userRepository.findByEmail(email).isPresent()) {
            response.put("success", true);
        } else {
            response.put("success", false);
            response.put("message", "Пользователь не найден");
        }

        return response;
    }

    // 🖼️ Аватар (заглушка)
    @PutMapping("/user/{email}/avatar")
    public Map<String, Object> changeAvatar(
            @PathVariable String email,
            @RequestBody Map<String, String> body) {

        Map<String, Object> response = new HashMap<>();

        if (userRepository.findByEmail(email).isPresent()) {
            response.put("success", true);
        } else {
            response.put("success", false);
            response.put("message", "Пользователь не найден");
        }

        return response;
    }
}
