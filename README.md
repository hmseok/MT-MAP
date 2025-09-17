# 카카오맵 사고공장

카카오맵을 활용한 교통사고 정보 수집 및 관리 시스템

## 프로젝트 구조

```
카카오맵 사고공장/
├── backend/          # Spring Boot 백엔드
│   ├── src/
│   ├── database/     # 데이터베이스 스크립트
│   └── pom.xml
├── frontend/         # React 프론트엔드 (별도 폴더)
└── README.md
```

## 기술 스택

### 백엔드
- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **Spring Security**
- **MySQL 8.0**
- **Maven**

### 프론트엔드 (예정)
- **React 18**
- **TypeScript**
- **Kakao Map API**

### 인프라
- **AWS EC2**
- **가비아 도메인**
- **GitHub**

## 개발환경 설정

### 1. 백엔드 실행

```bash
# 프로젝트 디렉토리로 이동
cd backend

# Maven으로 의존성 설치 및 실행
./mvnw spring-boot:run
```

### 2. 데이터베이스 설정

```bash
# MySQL 설치 (macOS)
brew install mysql
brew services start mysql

# 데이터베이스 초기화
mysql -u root -p < database/init.sql
```

### 3. API 테스트

```bash
# 헬스체크
curl http://localhost:8080/api/health
```

## 배포 환경

### EC2 서버 설정
- Ubuntu 22.04 LTS
- Java 17
- MySQL 8.0
- Nginx (리버스 프록시)

### 도메인 설정
- 가비아 도메인 연결
- SSL 인증서 적용

## API 문서

### 기본 엔드포인트
- `GET /api/health` - 서버 상태 확인

## 개발 가이드

### 백엔드 개발
1. Spring Boot 애플리케이션 구조를 따릅니다
2. RESTful API 설계 원칙을 준수합니다
3. JPA를 사용한 데이터베이스 연동
4. Spring Security를 통한 인증/인가

### 데이터베이스
- MySQL 8.0 사용
- UTF-8 인코딩
- JPA를 통한 ORM 매핑

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
