# 데이터베이스 설정 가이드

## MySQL 설치 및 설정

### 1. MySQL 설치 (macOS)
```bash
# Homebrew를 사용한 MySQL 설치
brew install mysql

# MySQL 서비스 시작
brew services start mysql

# MySQL 보안 설정
mysql_secure_installation
```

### 2. 데이터베이스 초기화
```bash
# MySQL에 접속
mysql -u root -p

# 초기화 스크립트 실행
source /path/to/backend/database/init.sql
```

### 3. 연결 정보 설정
`src/main/resources/application.yml` 파일에서 데이터베이스 연결 정보를 수정하세요:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/accident_factory?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: accident_user  # 또는 root
    password: accident_password  # 실제 비밀번호로 변경
```

### 4. 테스트
Spring Boot 애플리케이션을 실행한 후 다음 URL로 접속하여 확인:
- http://localhost:8080/api/health

## 데이터베이스 구조

### accidents 테이블
- 사고 정보를 저장하는 메인 테이블
- 위치 정보 (위도, 경도), 사고 유형, 심각도 등 포함

### users 테이블
- 사용자 정보를 저장하는 테이블
- 인증 및 권한 관리용

### comments 테이블
- 사고에 대한 댓글을 저장하는 테이블
- accidents와 users 테이블과 외래키 관계
