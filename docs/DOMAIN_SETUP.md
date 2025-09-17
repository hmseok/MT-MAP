# 가비아 도메인 연결 가이드

## 1. 가비아 도메인 구매 및 설정

### 1.1 도메인 구매
1. 가비아 홈페이지 접속 (https://www.gabia.com)
2. 원하는 도메인명 검색 및 구매
3. 예시: `kakaomap-accident.com`, `accident-factory.kr`

### 1.2 도메인 관리 페이지 접속
1. 가비아 로그인 후 "나의 서비스" → "도메인 관리" 접속
2. 구매한 도메인 선택

## 2. DNS 설정

### 2.1 네임서버 확인
도메인 관리 페이지에서 현재 네임서버 확인:
- 가비아 기본 네임서버: `ns1.gabia.co.kr`, `ns2.gabia.co.kr`
- 또는 AWS Route 53 사용 시: `ns-xxx.awsdns-xx.com`

### 2.2 DNS 레코드 설정

#### A 레코드 설정 (IPv4)
```
타입: A
호스트: @ (루트 도메인)
값: EC2 퍼블릭 IP 주소
TTL: 3600

타입: A
호스트: www
값: EC2 퍼블릭 IP 주소
TTL: 3600
```

#### CNAME 레코드 설정 (선택사항)
```
타입: CNAME
호스트: api
값: your-domain.com
TTL: 3600
```

### 2.3 가비아 DNS 설정 방법
1. 도메인 관리 페이지에서 "DNS 관리" 클릭
2. "DNS 레코드 관리" 선택
3. 위의 A 레코드 정보 입력
4. 설정 저장

## 3. AWS Route 53 사용 (권장)

### 3.1 Route 53 호스팅 영역 생성
1. AWS 콘솔 → Route 53 → "호스팅 영역" → "호스팅 영역 생성"
2. 도메인명 입력 (예: kakaomap-accident.com)
3. 퍼블릭 호스팅 영역으로 생성

### 3.2 네임서버 변경
1. Route 53에서 생성된 호스팅 영역의 네임서버 확인
2. 가비아 도메인 관리에서 네임서버를 Route 53 네임서버로 변경

### 3.3 A 레코드 생성
```bash
# Route 53에서 A 레코드 생성
타입: A
이름: (비워둠 - 루트 도메인)
값: EC2 퍼블릭 IP
TTL: 300

타입: A
이름: www
값: EC2 퍼블릭 IP
TTL: 300
```

## 4. 도메인 연결 확인

### 4.1 DNS 전파 확인
```bash
# nslookup으로 DNS 확인
nslookup your-domain.com

# dig 명령어로 상세 확인
dig your-domain.com

# 온라인 DNS 체크 도구 사용
# https://www.whatsmydns.net/
```

### 4.2 연결 테스트
```bash
# 도메인으로 서버 접속 테스트
curl -I http://your-domain.com/api/health

# HTTPS 연결 테스트 (SSL 설정 후)
curl -I https://your-domain.com/api/health
```

## 5. SSL 인증서 설정

### 5.1 Let's Encrypt 인증서 발급
```bash
# EC2 서버에서 실행
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### 5.2 Nginx SSL 설정 확인
```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# HTTP에서 HTTPS로 리다이렉트
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

## 6. 서브도메인 설정

### 6.1 API 서브도메인
```
타입: A
호스트: api
값: EC2 퍼블릭 IP
TTL: 3600
```

### 6.2 관리자 서브도메인
```
타입: A
호스트: admin
값: EC2 퍼블릭 IP
TTL: 3600
```

## 7. 도메인 관리 체크리스트

### 7.1 기본 설정
- [ ] 도메인 구매 완료
- [ ] DNS 레코드 설정 완료
- [ ] 네임서버 변경 완료 (Route 53 사용 시)
- [ ] DNS 전파 확인 완료

### 7.2 보안 설정
- [ ] SSL 인증서 발급 완료
- [ ] HTTPS 리다이렉트 설정 완료
- [ ] 보안 헤더 설정 완료

### 7.3 모니터링
- [ ] 도메인 만료일 확인
- [ ] SSL 인증서 만료일 확인
- [ ] 자동 갱신 설정 완료

## 8. 트러블슈팅

### 8.1 DNS 전파 지연
- DNS 변경 후 최대 48시간 소요
- TTL 값을 낮게 설정하여 빠른 전파 가능

### 8.2 SSL 인증서 발급 실패
```bash
# 도메인 소유권 확인
sudo certbot certonly --manual -d your-domain.com

# Nginx 설정 확인
sudo nginx -t
```

### 8.3 도메인 연결 안됨
1. DNS 레코드 확인
2. EC2 보안 그룹 설정 확인
3. Nginx 설정 확인
4. 방화벽 설정 확인

## 9. 성능 최적화

### 9.1 CDN 설정 (CloudFront)
1. AWS CloudFront 배포 생성
2. Origin을 EC2 서버로 설정
3. 도메인을 CloudFront 배포로 연결

### 9.2 캐싱 설정
```nginx
# 정적 파일 캐싱
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 10. 비용 최적화

### 10.1 도메인 비용
- .com 도메인: 연간 약 15,000원
- .kr 도메인: 연간 약 20,000원

### 10.2 SSL 인증서
- Let's Encrypt: 무료
- 상용 인증서: 연간 50,000원 ~ 500,000원

### 10.3 Route 53 비용
- 호스팅 영역: 월 $0.50
- 쿼리: 100만 건당 $0.40
