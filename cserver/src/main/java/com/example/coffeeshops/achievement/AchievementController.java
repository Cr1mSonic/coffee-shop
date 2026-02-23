package com.example.coffeeshops.achievement;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;


@RestController
public class AchievementController {

    @GetMapping("/api/achievements")
    public List<Achievement> getAchievements() {
        return List.of(
                new Achievement("Кофейный новичок", "Оставь первый отзыв о кофейне.", "☕", false),
                new Achievement("Городской дегустатор", "Посети 5 разных кофеен.", "🌆", false),
                new Achievement("Комментатор", "Напиши 10 комментариев.", "💬", false),
                new Achievement("Мастер вкуса", "Средний рейтинг выше 4.5.", "⭐", false)
        );
    }
}
