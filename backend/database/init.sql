-- 카카오맵 사고공장 데이터베이스 초기화 스크립트

-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS accident_factory 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 데이터베이스 사용
USE accident_factory;

-- 사용자 생성 (로컬 개발용)
CREATE USER IF NOT EXISTS 'accident_user'@'localhost' IDENTIFIED BY 'accident_password';
GRANT ALL PRIVILEGES ON accident_factory.* TO 'accident_user'@'localhost';
FLUSH PRIVILEGES;

-- 사고 정보 테이블
CREATE TABLE IF NOT EXISTS accidents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    latitude DECIMAL(10, 8) NOT NULL COMMENT '위도',
    longitude DECIMAL(11, 8) NOT NULL COMMENT '경도',
    address VARCHAR(255) NOT NULL COMMENT '주소',
    accident_type VARCHAR(50) NOT NULL COMMENT '사고 유형',
    severity VARCHAR(20) NOT NULL COMMENT '심각도 (경미/중상/치명)',
    description TEXT COMMENT '사고 상세 설명',
    accident_date DATETIME NOT NULL COMMENT '사고 발생 일시',
    weather_condition VARCHAR(50) COMMENT '날씨 조건',
    road_condition VARCHAR(50) COMMENT '도로 조건',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_location (latitude, longitude),
    INDEX idx_accident_date (accident_date),
    INDEX idx_accident_type (accident_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'USER' COMMENT 'USER, ADMIN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 댓글 테이블
CREATE TABLE IF NOT EXISTS comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    accident_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (accident_id) REFERENCES accidents(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_accident_id (accident_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 샘플 데이터 삽입
INSERT INTO accidents (latitude, longitude, address, accident_type, severity, description, accident_date, weather_condition, road_condition) VALUES
(37.5665, 126.9780, '서울특별시 중구 세종대로 110', '교통사고', '경미', '신호등 앞에서 추돌사고 발생', '2024-01-15 14:30:00', '맑음', '건조'),
(37.5512, 126.9882, '서울특별시 용산구 이태원로 200', '교통사고', '중상', '횡단보도에서 보행자 사고', '2024-01-16 09:15:00', '흐림', '젖음'),
(37.5172, 127.0473, '서울특별시 강남구 테헤란로 152', '교통사고', '치명', '고속도로 진입로에서 추돌사고', '2024-01-17 18:45:00', '비', '젖음');

INSERT INTO users (username, email, password, role) VALUES
('admin', 'admin@kakaomap.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'ADMIN'),
('user1', 'user1@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'USER');
