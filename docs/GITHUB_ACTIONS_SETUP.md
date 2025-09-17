# GitHub Actions 자동 배포 설정 가이드

## 1. GitHub Secrets 설정

### 1.1 GitHub 저장소에서 Secrets 설정
1. GitHub 저장소 페이지로 이동
2. **Settings** 탭 클릭
3. 좌측 메뉴에서 **Secrets and variables** → **Actions** 클릭
4. **New repository secret** 버튼 클릭

### 1.2 필요한 Secrets 추가

#### EC2_HOST
- **Name**: `EC2_HOST`
- **Secret**: `54.180.125.120`

#### EC2_SSH_KEY
- **Name**: `EC2_SSH_KEY`
- **Secret**: SSH 개인키 내용 (전체 내용 복사)

SSH 키 내용 확인 방법:
```bash
cat ~/Downloads/RIDE-EBOT-KR\ \(1\).pem
```

## 2. 자동 배포 워크플로우

### 2.1 워크플로우 파일 위치
- `.github/workflows/deploy.yml`

### 2.2 배포 트리거
- `main` 브랜치에 push할 때마다 자동 배포
- Pull Request 생성 시에도 빌드 테스트

### 2.3 배포 과정
1. **코드 체크아웃**: GitHub에서 최신 코드 다운로드
2. **Java 17 설정**: JDK 17 환경 구성
3. **Maven 캐시**: 의존성 캐싱으로 빌드 속도 향상
4. **애플리케이션 빌드**: Maven으로 JAR 파일 생성
5. **EC2 배포**: SSH로 서버에 접속하여 배포

## 3. 배포 명령어

### 3.1 수동 배포 (개발 중)
```bash
# 로컬에서 변경사항 커밋 및 푸시
git add .
git commit -m "새로운 기능 추가"
git push origin main
```

### 3.2 배포 상태 확인
1. GitHub 저장소 → **Actions** 탭
2. 최근 워크플로우 실행 상태 확인
3. 실패 시 로그 확인 및 문제 해결

## 4. 서버 관리 명령어

### 4.1 서비스 상태 확인
```bash
ssh -i ~/Downloads/RIDE-EBOT-KR\ \(1\).pem ubuntu@54.180.125.120 "sudo systemctl status accident-factory"
```

### 4.2 서비스 재시작
```bash
ssh -i ~/Downloads/RIDE-EBOT-KR\ \(1\).pem ubuntu@54.180.125.120 "sudo systemctl restart accident-factory"
```

### 4.3 로그 확인
```bash
ssh -i ~/Downloads/RIDE-EBOT-KR\ \(1\).pem ubuntu@54.180.125.120 "sudo journalctl -u accident-factory -f"
```

## 5. 환경별 설정

### 5.1 개발 환경 (로컬)
- `application.yml`: 기본 설정
- 포트: 8080
- 로그 레벨: DEBUG

### 5.2 프로덕션 환경 (EC2)
- `application-prod.yml`: 프로덕션 설정
- 포트: 8080
- 로그 레벨: INFO
- 데이터베이스: EC2 MySQL

## 6. 트러블슈팅

### 6.1 배포 실패 시
1. **GitHub Actions 로그 확인**
   - Actions 탭에서 실패한 워크플로우 클릭
   - 상세 로그에서 오류 원인 파악

2. **일반적인 오류**
   - SSH 연결 실패: EC2_SSH_KEY 확인
   - 빌드 실패: Maven 의존성 문제
   - 서비스 시작 실패: 포트 충돌 또는 설정 오류

### 6.2 서비스 문제 해결
```bash
# 서비스 중지
sudo systemctl stop accident-factory

# 수동으로 애플리케이션 실행 (디버깅용)
cd /home/ubuntu/MT-MAP/backend
java -jar target/accident-factory-0.0.1-SNAPSHOT.jar

# 서비스 재시작
sudo systemctl start accident-factory
```

## 7. 보안 고려사항

### 7.1 SSH 키 관리
- SSH 개인키는 절대 공개하지 않음
- GitHub Secrets에 안전하게 저장
- 정기적인 키 로테이션 권장

### 7.2 환경 변수
- 민감한 정보는 환경 변수로 관리
- 데이터베이스 비밀번호 등은 별도 관리

## 8. 모니터링

### 8.1 애플리케이션 상태 확인
```bash
# 헬스체크
curl http://54.180.125.120:8080/api/health

# 서비스 상태
sudo systemctl status accident-factory
```

### 8.2 로그 모니터링
```bash
# 실시간 로그
sudo journalctl -u accident-factory -f

# 최근 로그
sudo journalctl -u accident-factory --since "1 hour ago"
```

## 9. 배포 체크리스트

### 9.1 배포 전 확인사항
- [ ] 코드가 정상적으로 컴파일되는지 확인
- [ ] 테스트가 통과하는지 확인
- [ ] 데이터베이스 마이그레이션이 필요한지 확인
- [ ] 환경 변수 설정이 올바른지 확인

### 9.2 배포 후 확인사항
- [ ] 애플리케이션이 정상적으로 시작되었는지 확인
- [ ] API 엔드포인트가 정상 작동하는지 확인
- [ ] 데이터베이스 연결이 정상인지 확인
- [ ] 로그에 오류가 없는지 확인

이제 GitHub에 코드를 푸시하면 자동으로 EC2 서버에 배포됩니다! 🚀
