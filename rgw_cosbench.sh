#!/bin/bash

POOL="default.rgw.buckets.data"
COS_BASE="../cosbench/"
COS_CLI="${COS_BASE}/cli.sh"
COS_CONF="${COS_BASE}/my-workload/"
DRY_RUN="true"

function cleanup_data_pool {
  local tmp_file="/tmp/xxxyyzz"
  rados -p $POOL ls > $tmp_file
  i=0
  STEP=20
  while read o
  do
    {
      rados -p $POOL rm $o
    } &
    ((i=($i+1)%$STEP))
    if [ $i -eq 0 ]; then
      wait
    fi
  done < $tmp_file
}

function wait_until_0_active()
{
  while true
  do
    bash ${COS_CLI} info anonymous:cosbench@192.168.2.22:19088 2>/dev/null
    num_active=$(bash ${COS_CLI} info anonymous:cosbench@192.168.2.22:19088 2>/dev/null | grep active | awk '{printf $2}')
    if [ $num_active == "0" ];then
      echo "cosbench task finished"
      return
    fi
    sleep 60
  done
}

##### main #####

tests=`ls ${COS_CONF}`
for test in $tests
do
  echo ">>> bench for $test"
  [ $DRY_RUN != "true" ] && bash ${COS_CLI} submit ${COS_CONF}/$test
  wait_until_0_active
  cleanup_data_pool
  echo ">>> bench for $test done"
done

for test in $tests
do
  echo ">>> def bench for $test"
  [ $DRY_RUN != "true" ] && bash ${COS_CLI} submit ${COS_CONF}/$test
  wait_until_0_active
  cleanup_data_pool
  echo ">>> def bench for $test done"
done

