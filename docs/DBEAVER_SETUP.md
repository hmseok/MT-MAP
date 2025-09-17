# DBeaver에서 EC2 MySQL 연결 설정 가이드

## 1. DBeaver 설치

### 1.1 DBeaver Community Edition 다운로드
- [DBeaver 공식 사이트](https://dbeaver.io/download/)에서 Community Edition 다운로드
- macOS용 DMG 파일 다운로드 후 설치

### 1.2 MySQL 드라이버 확인
- DBeaver는 기본적으로 MySQL 드라이버를 포함하고 있습니다
- 만약 드라이버가 없다면: Database → Driver Manager → MySQL → Download/Update

## 2. EC2 MySQL 연결 설정

### 2.1 새 데이터베이스 연결 생성
1. DBeaver 실행
2. 상단 메뉴에서 **Database** → **New Database Connection** 클릭
3. 또는 `Ctrl+Shift+N` (Windows/Linux) / `Cmd+Shift+N` (macOS) 단축키 사용

### 2.2 MySQL 선택
1. 데이터베이스 목록에서 **MySQL** 선택
2. **Next** 클릭

### 2.3 연결 정보 입력

#### 기본 연결 설정
```
Server Host: 54.180.125.120
Port: 3306
Database: accident_factory
Username: accident_user
Password: accident_password123
```

#### 고급 설정 (선택사항)
- **Connection timeout**: 30초
- **Keep-alive interval**: 0초
- **Use SSL**: 체크 해제 (개발 환경)
- **Allow Public Key Retrieval**: 체크 (MySQL 8.0 필수)

### 2.4 연결 테스트
1. **Test Connection** 버튼 클릭
2. 성공 메시지가 나타나면 **OK** 클릭
3. 연결 이름을 `EC2-Accident-Factory`로 설정
4. **Finish** 클릭

## 3. 연결 문제 해결

### 3.1 연결 실패 시 확인사항

#### EC2 보안 그룹 확인
- AWS EC2 콘솔에서 보안 그룹 확인
- MySQL/Aurora (3306) 포트가 열려있는지 확인
- 소스를 `0.0.0.0/0` 또는 본인 IP로 설정

#### MySQL 서비스 상태 확인
```bash
# EC2 서버에서 실행
sudo systemctl status mysql
sudo systemctl start mysql  # 서비스가 중지된 경우
```

#### MySQL 사용자 권한 확인
```bash
# EC2 서버에서 실행
sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User='accident_user';"
```

### 3.2 방화벽 설정 (필요한 경우)
```bash
# EC2 서버에서 실행
sudo ufw allow 3306
sudo ufw status
```

## 4. 데이터베이스 초기화

### 4.1 테이블 생성
DBeaver에서 연결 후 다음 SQL을 실행:

```sql
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
```

### 4.2 샘플 데이터 삽입
```sql
-- 샘플 사고 데이터
INSERT INTO accidents (latitude, longitude, address, accident_type, severity, description, accident_date, weather_condition, road_condition) VALUES
(37.5665, 126.9780, '서울특별시 중구 세종대로 110', '교통사고', '경미', '신호등 앞에서 추돌사고 발생', '2024-01-15 14:30:00', '맑음', '건조'),
(37.5512, 126.9882, '서울특별시 용산구 이태원로 200', '교통사고', '중상', '횡단보도에서 보행자 사고', '2024-01-16 09:15:00', '흐림', '젖음'),
(37.5172, 127.0473, '서울특별시 강남구 테헤란로 152', '교통사고', '치명', '고속도로 진입로에서 추돌사고', '2024-01-17 18:45:00', '비', '젖음');

-- 샘플 사용자 데이터
INSERT INTO users (username, email, password, role) VALUES
('admin', 'admin@kakaomap.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'ADMIN'),
('user1', 'user1@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'USER');
```

## 5. DBeaver 사용 팁

### 5.1 SQL 편집기 사용
- `Ctrl+Enter`: SQL 실행
- `Ctrl+Shift+Enter`: SQL 실행 및 결과 표시
- `Ctrl+Space`: 자동완성

### 5.2 데이터베이스 탐색
- 좌측 Database Navigator에서 테이블 구조 확인
- 테이블 우클릭 → **View Data**로 데이터 조회
- 테이블 우클릭 → **Generate SQL** → **INSERT**로 데이터 삽입 SQL 생성

### 5.3 연결 관리
- 연결 우클릭 → **Edit Connection**으로 설정 수정
- 연결 우클릭 → **Test Connection**으로 연결 상태 확인
- 연결 우클릭 → **Disconnect**로 연결 해제

## 6. 보안 고려사항

### 6.1 프로덕션 환경
- SSL 연결 사용
- 강력한 비밀번호 설정
- IP 화이트리스트 적용
- 정기적인 비밀번호 변경

### 6.2 개발 환경
- 로컬 네트워크에서만 접근 허용
- 개발용 별도 사용자 계정 사용
- 민감한 데이터 제외

## 7. 트러블슈팅

### 7.1 연결 타임아웃
```
Error: Communications link failure
```
**해결방법:**
- EC2 보안 그룹에서 3306 포트 열기
- MySQL 서비스 상태 확인
- 네트워크 연결 확인

### 7.2 인증 실패
```
Error: Access denied for user 'accident_user'@'your-ip'
```
**해결방법:**
- 사용자 권한 확인
- 비밀번호 확인
- 호스트 설정 확인

### 7.3 데이터베이스 없음
```
Error: Unknown database 'accident_factory'
```
**해결방법:**
- 데이터베이스 생성 확인
- 데이터베이스 이름 확인
- 권한 확인

### 7.4 Public Key Retrieval 오류
```
Error: Public Key Retrieval is not allowed
```
**해결방법:**
- DBeaver 연결 설정에서 **Allow Public Key Retrieval** 체크
- 또는 연결 URL에 `allowPublicKeyRetrieval=true` 추가

## 8. 연결 정보 요약

```
서버 정보:
- 호스트: 54.180.125.120
- 포트: 3306
- 데이터베이스: accident_factory
- 사용자명: accident_user
- 비밀번호: accident_password123
- 인코딩: UTF-8
- 타임존: UTC
```

이제 DBeaver에서 EC2 서버의 MySQL 데이터베이스에 연결할 수 있습니다! 🎉
