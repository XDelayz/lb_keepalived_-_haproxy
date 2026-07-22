Для тестування та налаштування балансування трафіку нам треба 4 vm з Ubuntu 22.04 на яких ми встановимо та налаштуємо:

Keepalived - який матиме наступний virtual_ipaddress 10.10.10.154 для відмовостійкості та переключення на резервний сервер у випадку падіння першого.
Haproxy - для балансування трафіку між двома nginx серверами з однаковою конфігурацією.

список vm:
haproxy-0 - налаштуємо Keepalived та Haproxy
haproxy-1 - налаштуємо Keepalived та Haproxy
nginx-0 - розгорнемо та запустимо тестовий docker контейнер
nginx-1 - розгорнемо та запустимо тестовий docker контейнер

Після створення серверів почнемо з налаштування haproxy-0:
для початку треба отримати SSL-сертифікат для домену у мене це (zoltraak.pp.ua), щоб випустити тестовий контейнер з HTTPS
перед отриманням має бути DNS запис типу А - на адресу сервера

apt update
apt install certbot -y
sudo certbot certonly \
  --standalone \
  -d zoltraak.pp.ua

sudo mkdir -p /etc/haproxy/certs

sudo bash -c '
cat \
/etc/letsencrypt/live/zoltraak.pp.ua/fullchain.pem \
/etc/letsencrypt/live/zoltraak.pp.ua/privkey.pem \
> /etc/haproxy/certs/zoltraak.pp.ua.pem'

sudo chmod 600 /etc/haproxy/certs/zoltraak.pp.ua.pem

Після отримання сертифікату можемо розпочинати налаштування haproxy-0:
apt update
apt install haproxy -y

видаляємо стандартний файл
rm /etc/haproxy/haproxy.cfg

зробимо свою конфігурацію
nano /etc/haproxy/haproxy.cfg

копіюємо вміст з файлу поточного git-репозиторію haproxy.cfg 

перевірка конфігурації на правильність і запуск:
haproxy -c -f /etc/haproxy/haproxy.cfg
systemctl restart haproxy
systemctl enable haproxy
systemctl status haproxy

налаштуємо keepalived:
apt update
apt install keepalived -y
nano /etc/keepalived/keepalived.conf

копіюємо вміст з файлу поточного git-репозиторію haproxy-0 - keepalived.conf
перевірка конфігурації
keepalived -t

запускаєм
systemctl enable keepalived
systemctl restart keepalived
systemctl status keepalived

На рівні віртуалізації потрібно відкрити буде 80 та 443 порти на віртуальну адресу
virtual_ipaddress 10.10.10.154


тепер заходимо на haproxy-1
при налаштувані haproxy повторуємо конфігурацію
а ось при налаштувані keepalived
у файл nano /etc/keepalived/keepalived.conf
копіюємо вміст з файлу поточного git-репозиторію саме для haproxy-1 - keepalived.conf


для тестування балансування запускати будемо тестовий Docker-контейнер podinfo.png

Почнемо з вм nginx-0

Додамо офіційний репозиторій Docker

sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

створимо файл та додамо в нього конфігурацію з файлу nginx-0 - compose.yaml

nano compose.yaml

запускаємо docker compose up -d
перевірка запуску контейнера docker ps

заходимо на nginx-1 
ставимо докер і створюємо файл 
nginx-1 - compose.yaml і вставляємо вміст з репозиторію для nginx-1

для тесту відмовостійкості можна на nginx-1 виключити контейнер командою
docker stop podinfo
потім запускаємо docker start podinfo






