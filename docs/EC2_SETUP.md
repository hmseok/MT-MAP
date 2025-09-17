# AWS EC2 서버 설정 가이드

## 1. EC2 인스턴스 생성

### 1.1 인스턴스 설정
- **AMI**: Ubuntu Server 22.04 LTS
- **인스턴스 타입**: t3.medium (2 vCPU, 4GB RAM)
- **스토리지**: 20GB GP3
- **보안 그룹**: 
  - SSH (22) - 본인 IP만 허용
  - HTTP (80) - 0.0.0.0/0
  - HTTPS (443) - 0.0.0.0/0
  - Custom TCP (8080) - 0.0.0.0/0 (Spring Boot)

### 1.2 키 페어 생성
- RSA 키 페어 생성
- .pem 파일을 안전한 곳에 저장

## 2. 서버 초기 설정

### 2.1 서버 접속
```bash
# 키 파일 권한 설정
chmod 400 your-key.pem

# 서버 접속
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### 2.2 시스템 업데이트
```bash
sudo apt update && sudo apt upgrade -y
```

### 2.3 필수 패키지 설치
```bash
# Java 17 설치
sudo apt install openjdk-17-jdk -y

# Maven 설치
sudo apt install maven -y

# MySQL 설치
sudo apt install mysql-server -y

# Nginx 설치
sudo apt install nginx -y

# Git 설치
sudo apt install git -y

# UFW 방화벽 설정
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw allow 8080
sudo ufw --force enable
```

## 3. MySQL 설정

### 3.1 MySQL 보안 설정
```bash
sudo mysql_secure_installation
```

### 3.2 데이터베이스 생성
```bash
sudo mysql -u root -p

# MySQL 콘솔에서 실행
CREATE DATABASE accident_factory CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'accident_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON accident_factory.* TO 'accident_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## 4. 애플리케이션 배포

### 4.1 프로젝트 클론
```bash
cd /home/ubuntu
git clone https://github.com/your-username/your-repo.git
cd your-repo/backend
```

### 4.2 애플리케이션 빌드
```bash
# Maven으로 JAR 파일 생성
./mvnw clean package -DskipTests

# 또는
mvn clean package -DskipTests
```

### 4.3 시스템 서비스 등록
```bash
sudo nano /etc/systemd/system/accident-factory.service
```

서비스 파일 내용:
```ini
[Unit]
Description=Accident Factory Spring Boot Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/your-repo/backend
ExecStart=/usr/bin/java -jar target/accident-factory-0.0.1-SNAPSHOT.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 4.4 서비스 시작
```bash
sudo systemctl daemon-reload
sudo systemctl enable accident-factory
sudo systemctl start accident-factory
sudo systemctl status accident-factory
```

## 5. Nginx 설정

### 5.1 Nginx 설정 파일 생성
```bash
sudo nano /etc/nginx/sites-available/accident-factory
```

설정 파일 내용:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5.2 사이트 활성화
```bash
sudo ln -s /etc/nginx/sites-available/accident-factory /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## 6. SSL 인증서 설정 (Let's Encrypt)

### 6.1 Certbot 설치
```bash
sudo apt install certbot python3-certbot-nginx -y
```

### 6.2 SSL 인증서 발급
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### 6.3 자동 갱신 설정
```bash
sudo crontab -e

# 다음 줄 추가
0 12 * * * /usr/bin/certbot renew --quiet
```

## 7. 모니터링 및 로그

### 7.1 애플리케이션 로그 확인
```bash
sudo journalctl -u accident-factory -f
```

### 7.2 Nginx 로그 확인
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 8. 자동 배포 설정 (선택사항)

### 8.1 GitHub Actions 워크플로우
`.github/workflows/deploy.yml` 파일 생성:

```yaml
name: Deploy to EC2

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ubuntu
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          cd /home/ubuntu/your-repo
          git pull origin main
          cd backend
          ./mvnw clean package -DskipTests
          sudo systemctl restart accident-factory
```

## 9. 보안 체크리스트

- [ ] SSH 키 기반 인증만 사용
- [ ] 불필요한 포트 차단
- [ ] 정기적인 시스템 업데이트
- [ ] 데이터베이스 비밀번호 강화
- [ ] SSL 인증서 적용
- [ ] 로그 모니터링 설정
- [ ] 백업 정책 수립

## 10. 트러블슈팅

### 10.1 애플리케이션이 시작되지 않는 경우
```bash
sudo journalctl -u accident-factory --no-pager
```

### 10.2 포트 충돌 확인
```bash
sudo netstat -tlnp | grep :8080
```

### 10.3 디스크 공간 확인
```bash
df -h
```

### 10.4 메모리 사용량 확인
```bash
free -h
```
