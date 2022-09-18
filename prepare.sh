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
# sudo truncate -s 0 ${mysql_slow_log}
# sudo truncate -s 0 ${mysql_error_log}
# sudo systemctl restart mysql

# slow log
#MYSQL="mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DBNAME}"
#${MYSQL} -e "set global slow_query_log_file = '${mysql_slow_log}'; set global long_query_time = 0; set global slow_query_log = ON;"

echo "OK"

