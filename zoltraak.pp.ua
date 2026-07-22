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
