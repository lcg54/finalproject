# Local Development Setup

## For the First Run

### 1. Install Docker

- Windows / macOS
  - Docker Desktop 설치 : https://www.docker.com/products/docker-desktop
- Linux
  - Docker Engine & Docker Compose Plugin 설치 : https://docs.docker.com/engine/install/

---

### 2. Clone & Configure

```bash
git clone https://github.com/lcg54/finalproject.git
cd finalproject\frontend
npm install
npm run build
cd ..
cp .env.development.example .env
```

- `.env`에서 다음 변수를 실제 값으로 설정하세요. (`.env`는 보안상 Git에 커밋되지 않습니다.)
  - MySQL root password
  - Redis password
  - Django SECRET_KEY
  - Spring 및 Django Jwt Secret

- Windows hosts 파일에 다음 항목을 추가하세요. (관리자 권한)
  - 127.0.0.1 admin.localhost

---

### 3. Build & Run

```bash
docker compose up -d --build
docker compose exec admin python manage.py migrate --noinput
docker compose exec admin python manage.py collectstatic --noinput
docker compose restart gateway
docker compose exec admin python manage.py createsuperuser
```

- Django Admin에 접속하기 위해 관리자 계정 생성이 필요합니다.
  - 사용자 이름
  - 이메일
  - 비밀번호

---

### 4. Stop

```bash
docker compose down
```

## After the First Run

### 1. Run

```bash
docker compose up -d
```

---

### 2. Update Database Schema

```bash
docker compose exec admin python manage.py makemigrations
docker compose exec admin python manage.py migrate
```

- Django model을 추가/수정/제거한 경우 수행하세요.

---

### 3. Stop & Reset DB

```bash
docker compose down -v
```

- 이후 **3. Build & Run**을 다시 수행하세요.

## Connection Port

- Frontend      : http://localhost:8888
- Django Admin  : http://admin.localhost:8888