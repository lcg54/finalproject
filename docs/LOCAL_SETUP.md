# 1. Install Docker & Docker Compose

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker ubuntu
exit
```
→ SSH 재접속 (docker 권한 적용)


# 2. Prepare App to Run

```bash
git clone https://github.com/lcg54/finalproject.git
cd finalproject
cp .env.development.example .env
vi .env
```
→ MySQL 비밀번호 & Django 시크릿키 수정


# 3. Run (About 5 to 10 minutes)

```bash
docker compose up -d --build
```

# 4. Create Admin Account (Local)

```bash
docker compose exec admin python manage.py createsuperuser
```

# 5. Connection Port

- Frontend      : http://localhost:8888
- Django Admin  : http://localhost:8888/admin


# 6. Stop / Restart

```bash
docker compose down     # stop containers
docker compose up -d    # restart without rebuild
```