# GitHub 저장소 설정 가이드

## 1. GitHub 저장소 생성

### 1.1 새 저장소 생성
1. GitHub 홈페이지 접속 (https://github.com)
2. "New repository" 클릭
3. 저장소 정보 입력:
   - Repository name: `kakaomap-accident-factory`
   - Description: `카카오맵을 활용한 교통사고 정보 수집 및 관리 시스템`
   - Visibility: Public 또는 Private 선택
   - Initialize with README: 체크 해제 (이미 로컬에 있음)

### 1.2 저장소 연결
```bash
# 로컬 저장소에 원격 저장소 추가
cd "/Users/hominseok/MyProject/카카오맵 사고공장"
git remote add origin https://github.com/your-username/kakaomap-accident-factory.git

# 기본 브랜치를 main으로 변경
git branch -M main

# 원격 저장소에 푸시
git push -u origin main
```

## 2. 브랜치 전략 설정

### 2.1 브랜치 구조
```
main (프로덕션)
├── develop (개발)
├── feature/기능명 (기능 개발)
├── hotfix/버그명 (긴급 수정)
└── release/버전명 (릴리즈)
```

### 2.2 브랜치 생성 및 전환
```bash
# develop 브랜치 생성
git checkout -b develop
git push -u origin develop

# feature 브랜치 생성 예시
git checkout -b feature/user-authentication
git push -u origin feature/user-authentication
```

## 3. GitHub Actions 설정

### 3.1 CI/CD 워크플로우 생성
`.github/workflows/ci.yml` 파일 생성:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Cache Maven dependencies
      uses: actions/cache@v3
      with:
        path: ~/.m2
        key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
        restore-keys: ${{ runner.os }}-m2
    
    - name: Run tests
      run: ./mvnw test
    
    - name: Build application
      run: ./mvnw clean package -DskipTests
    
    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: jar-file
        path: backend/target/*.jar
```

### 3.2 배포 워크플로우 생성
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
    - uses: actions/checkout@v3
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ubuntu
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          cd /home/ubuntu/kakaomap-accident-factory
          git pull origin main
          cd backend
          ./mvnw clean package -DskipTests
          sudo systemctl restart accident-factory
```

## 4. GitHub Secrets 설정

### 4.1 필요한 Secrets
1. **EC2_HOST**: EC2 퍼블릭 IP 주소
2. **EC2_SSH_KEY**: EC2 접속용 SSH 개인키
3. **DB_PASSWORD**: 데이터베이스 비밀번호
4. **JWT_SECRET**: JWT 토큰 시크릿 키

### 4.2 Secrets 추가 방법
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. Name과 Secret 값 입력

## 5. 이슈 및 프로젝트 관리

### 5.1 이슈 템플릿 생성
`.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug report
about: 버그 리포트
title: '[BUG] '
labels: bug
assignees: ''
---

**버그 설명**
버그에 대한 명확하고 간결한 설명

**재현 단계**
1. '...'로 이동
2. '...' 클릭
3. '...'까지 스크롤
4. 오류 확인

**예상 동작**
예상했던 동작 설명

**스크린샷**
해당하는 경우 스크린샷 추가

**환경:**
 - OS: [e.g. macOS]
 - 브라우저: [e.g. chrome, safari]
 - 버전: [e.g. 22]
```

### 5.2 풀 리퀘스트 템플릿 생성
`.github/pull_request_template.md`:

```markdown
## 변경 사항
- [ ] 새로운 기능 추가
- [ ] 버그 수정
- [ ] 문서 업데이트
- [ ] 리팩토링

## 설명
변경 사항에 대한 자세한 설명

## 테스트
- [ ] 로컬에서 테스트 완료
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과

## 체크리스트
- [ ] 코드 리뷰 요청
- [ ] 문서 업데이트
- [ ] 테스트 케이스 추가
```

## 6. 코드 품질 관리

### 6.1 CodeQL 분석 설정
`.github/workflows/codeql.yml`:

```yaml
name: "CodeQL"

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'java' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
```

### 6.2 Dependabot 설정
`.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "maven"
    directory: "/backend"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

## 7. 릴리즈 관리

### 7.1 릴리즈 노트 템플릿
`.github/release_template.md`:

```markdown
## 🚀 새로운 기능
- 

## 🐛 버그 수정
- 

## 🔧 개선 사항
- 

## 📚 문서 업데이트
- 

## ⚠️ 주의사항
- 
```

### 7.2 태그 생성 및 릴리즈
```bash
# 태그 생성
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub에서 릴리즈 생성
# Releases → Create a new release → 태그 선택 → 릴리즈 노트 작성
```

## 8. 협업 가이드

### 8.1 커밋 메시지 규칙
```
<type>(<scope>): <subject>

<body>

<footer>
```

타입:
- feat: 새로운 기능
- fix: 버그 수정
- docs: 문서 변경
- style: 코드 포맷팅
- refactor: 리팩토링
- test: 테스트 추가/수정
- chore: 빌드 프로세스 또는 보조 도구 변경

### 8.2 코드 리뷰 체크리스트
- [ ] 코드가 요구사항을 충족하는가?
- [ ] 코드가 읽기 쉽고 이해하기 쉬운가?
- [ ] 적절한 주석이 있는가?
- [ ] 테스트가 포함되어 있는가?
- [ ] 보안 취약점이 없는가?

## 9. 백업 및 복구

### 9.1 저장소 백업
```bash
# 전체 저장소 클론
git clone --mirror https://github.com/your-username/kakaomap-accident-factory.git

# 백업 저장소 생성
git remote add backup https://github.com/your-username/kakaomap-accident-factory-backup.git
git push backup --mirror
```

### 9.2 데이터베이스 백업
```bash
# EC2에서 데이터베이스 백업
mysqldump -u accident_user -p accident_factory > backup_$(date +%Y%m%d).sql

# GitHub에 백업 파일 업로드 (선택사항)
git add backup_*.sql
git commit -m "Add database backup"
git push origin main
```

## 10. 모니터링 및 알림

### 10.1 GitHub 알림 설정
1. Settings → Notifications
2. 원하는 알림 방식 선택:
   - Email
   - Web
   - Mobile

### 10.2 상태 배지 추가
README.md에 추가:
```markdown
![CI](https://github.com/your-username/kakaomap-accident-factory/workflows/CI/badge.svg)
![Deploy](https://github.com/your-username/kakaomap-accident-factory/workflows/Deploy/badge.svg)
```
