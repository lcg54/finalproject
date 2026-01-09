# Local Development Setup

## 1. Install Docker

- Windows / macOS
  - Docker Desktop 설치 : https://www.docker.com/products/docker-desktop
- Linux
  - Docker Engine & Docker Compose Plugin 설치 : https://docs.docker.com/engine/install/

---

## 2. Clone & Configure

```bash
git clone https://github.com/lcg54/finalproject.git
cd finalproject
cp .env.development.example .env
```

- `.env`에서 다음 변수를 설정하세요.
  - MySQL password
  - Django SECRET_KEY

---

## 3. Build & Run

```bash
docker compose up -d --build
```

- 최초 실행 시 시간이 다소 소요될 수 있습니다.

---

## 4. Create Django Admin Account

```bash
docker compose exec admin python manage.py createsuperuser
```

- Django Admin에 접속하기 위해 필요합니다.

---

## 5. Connection Port

- Frontend      : http://localhost:8888
- Django Admin  : http://localhost:8888/admin

---

## 6. Stop / Restart

```bash
docker compose down     # stop containers
docker compose up -d    # restart without rebuild
```