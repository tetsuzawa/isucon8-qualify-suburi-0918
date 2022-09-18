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
ALPM="/api/admin/tenants/add,/api/admin/tenants/billing,/api/organizer/players,/api/organizer/players/add,/api/organizer/player/[a-zA-Z0-9]+/disqualified,/api/organizer/competitions/add,/api/organizer/competition/[a-zA-Z0-9]+/finish,/api/organizer/competition/[a-zA-Z0-9]+/score,/api/organizer/billing,/api/organizer/competitions,/api/player/player/[a-zA-Z0-9]+,/api/player/competition/[a-zA-Z0-9]+/ranking,/api/player/competitions,/api/me,/initialize"
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
