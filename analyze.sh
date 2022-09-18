#!/usr/bin/env bash

set -eux
cd `dirname $0`

################################################################################
echo "# Analyze"
################################################################################

. /tmp/prepared_env
. ./torb/webapp/env.sh

mkdir -p ${result_dir}

#sudo journalctl --since="${prepared_time}" | gzip -9c > "${data_dir}/journal.log.gz"

# alp
ALPM="/,/initialize,/api/users,/api/users/\d,/api/actions/login,/api/actions/logout,/api/events,/api/events/\d,/api/events/\d/actions/reserve,/api/events/\d/sheets/[A-Za-z]+/\d/reservation,/admin/,/admin/api/actions/login,/admin/api/actions/logout,/admin/api/events,/admin/api/events,/admin/api/events/\d,/admin/api/events/\d/actions/edit,/admin/api/reports/events/\d/sales,/admin/api/reports/sales"
OUTFORMT=count,1xx,2xx,3xx,4xx,5xx,method,uri,min,max,sum,avg,p95,min_body,max_body,avg_body
alp ltsv --file=${nginx_access_log} \
  --nosave-pos \
  --sort sum \
  --reverse \
  --output ${OUTFORMT} \
  --format markdown \
  --matching-groups ${ALPM}  \
  --query-string \
  > ${result_dir}/alp.md

# mysqlowquery
#sudo mysqldumpslow -s t ${mysql_slow_log} > ${result_dir}/mysqld-slow.txt

pt-query-digest --explain "h=${DB_HOST},u=${DB_USER},p=${DB_PASS},D=${DB_DATABASE}" ${mysql_slow_log} \
  > ${result_dir}/pt-query-digest.txt
