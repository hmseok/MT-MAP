package com.kakaomap.accidentfactory.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "카카오맵 사고공장 API 서버가 정상적으로 실행 중입니다.");
        response.put("timestamp", System.currentTimeMillis());
        return response;
    }
}
