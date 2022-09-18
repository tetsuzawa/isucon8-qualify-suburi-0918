#!/usr/bin/env bash

set -eux
cd `dirname $0`

################################################################################
echo "# Prepare"
################################################################################

# ====== env ======
cat > /tmp/prepared_env <<EOF
prepared_time="`date +'%Y-%m-%d %H:%M:%S'`"
app_log="/var/log/app/app.log"
nginx_access_log="/var/log/nginx/access_log.ltsv"
nginx_error_log="/var/log/nginx/error.log"
mysql_slow_log="/var/log/mysql/mysqld-slow.log"
mysql_error_log="/var/log/mysql/error.log"
result_dir="/home/isucon/result"
EOF

. /tmp/prepared_env
. ./torb/webapp/env.sh


# ====== go ======
make -C torb/webapp/go build
sudo systemctl restart torb.go

# ====== nginx ======
sudo cp ${nginx_access_log} ${nginx_access_log}.prev
sudo truncate -s 0 ${nginx_access_log}
sudo cp ${nginx_error_log} ${nginx_error_log}.prev
sudo truncate -s 0 ${nginx_error_log}
sudo nginx -t
sudo systemctl restart nginx

# ====== mysql ======
sudo cp etc/my.cnf /etc/my.cnf
sudo cp -r etc/my.cnf.d /etc/my.cnf.d
sudo cp ${mysql_slow_log} ${mysql_slow_log}.prev
sudo truncate -s 0 ${mysql_slow_log}
sudo cp ${mysql_error_log} ${mysql_error_log}.prev
sudo truncate -s 0 ${mysql_error_log}
sudo systemctl restart mariadb


# slow log
MYSQL="mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASS} ${DB_DATABASE}"
${MYSQL} -e "set global slow_query_log_file = '${mysql_slow_log}'; set global long_query_time = 0; set global slow_query_log = ON;"

echo "OK"

