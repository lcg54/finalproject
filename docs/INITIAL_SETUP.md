# Initial Setup on Ubuntu Server (SSH)

## 1. Install Docker & Docker Compose

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
- Restart the session to apply Docker privileges.

---

## 2. Prepare App to Run

```bash
git clone https://github.com/lcg54/finalproject.git
cd finalproject
cp .env.development.example .env
vi .env
```
- Set your MySQL password and Django secret key.

---

## 3. Build & Run (About 5 minutes)

```bash
docker compose up -d --build
```
---

## 4. Create Django Admin Account (via Docker)

```bash
docker compose exec admin python manage.py createsuperuser
```
---

## 5. Connection Port

- Frontend      : http://<server-ip>:8888
- Django Admin  : http://<server-ip>:8888/admin

※ If Docker and browser are running on the same machine, `localhost` can be used instead of `<server-ip>`.

---

## 6. Stop / Restart

```bash
docker compose down     # stop containers
docker compose up -d    # restart without rebuild
```