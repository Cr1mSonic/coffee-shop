package com.example.coffeeshops.user;

import com.example.coffeeshops.user.dto.AuthRequest;
import com.example.coffeeshops.user.dto.NicknameChangeRequest;
import com.example.coffeeshops.user.dto.PasswordChangeRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.HashMap;
import java.util.Map;

import static org.springframework.http.HttpStatus.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserController(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // 🟢 Регистрация
    @PostMapping("/register")
    public Map<String, Object> register(@Valid @RequestBody AuthRequest request) {
        Map<String, Object> response = new HashMap<>();

        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new ResponseStatusException(CONFLICT, "Пользователь уже существует");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole("admin@admin.com".equals(request.getEmail()) ? "ADMIN" : "USER");
        userRepository.save(user);

        response.put("success", true);
        response.put("message", "Регистрация успешна");
        response.put("role", user.getRole());
        return response;
    }

    // 🟢 Вход
    @PostMapping("/login")
    public Map<String, Object> login(@Valid @RequestBody AuthRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResponseStatusException(UNAUTHORIZED, "Неверный email или пароль"));

        // Backward compatibility: old accounts may still have plain text passwords.
        if (passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            // ok
        } else if (request.getPassword().equals(user.getPassword())) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
            userRepository.save(user);
        } else {
            throw new ResponseStatusException(UNAUTHORIZED, "Неверный email или пароль");
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Вход выполнен");
        response.put("email", user.getEmail());
        response.put("role", user.getRole());
        return response;
    }

    // 🔄 Восстановление пароля (базовый сценарий по email)
    @PostMapping("/forgot-password")
    public Map<String, Object> forgotPassword(@Valid @RequestBody AuthRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Пользователь не найден"));

        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userRepository.save(user);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Пароль успешно обновлен");
        return response;
    }

    // 🟢 Получить профиль
    @GetMapping("/user/{email}")
    public Map<String, Object> getUser(@PathVariable String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Пользователь не найден"));

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("email", user.getEmail());
        response.put("nickname", user.getEmail()); // пока ник = email
        response.put("avatar", user.getAvatar());
        return response;
    }

    // 🔐 Смена пароля
    @PutMapping("/user/{email}/password")
    public Map<String, Object> changePassword(
            @PathVariable String email,
            @Valid @RequestBody PasswordChangeRequest body) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Пользователь не найден"));

        user.setPassword(passwordEncoder.encode(body.getPassword()));
        userRepository.save(user);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Пароль обновлен");
        return response;
    }

    // ✍️ Смена никнейма (пока без поля в БД)
    @PutMapping("/user/{email}/nickname")
    public Map<String, Object> changeNickname(
            @PathVariable String email,
            @Valid @RequestBody NicknameChangeRequest body) {
        if (userRepository.findByEmail(email).isEmpty()) {
            throw new ResponseStatusException(NOT_FOUND, "Пользователь не найден");
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Никнейм обновлен");
        return response;
    }

    // 🖼️ Смена аватара
    @PutMapping("/user/{email}/avatar")
    public Map<String, Object> changeAvatar(
            @PathVariable String email,
            @RequestBody Map<String, String> body) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Пользователь не найден"));

        String avatar = body.get("avatar");
        if (avatar == null || avatar.isBlank()) {
            throw new ResponseStatusException(BAD_REQUEST, "Аватар не передан");
        }

        user.setAvatar(avatar);
        userRepository.save(user);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Аватар обновлен");
        return response;
    }
}
