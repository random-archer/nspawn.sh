#!/bin/bash

#
# common functions
#

# project folder
proj=$(cd ${BASH_SOURCE%/*}/../.. && pwd)

# installer command
pacrun="pacman --needed --noconfirm --noprogressbar"

# container image
system_image="randomarcher/archlinux:latest"

# container identity
instance_name="tester"

# test prerequisites
package_list=(
   sudo
   rsync
   netcat
   bind-tools
)

# fetch image
docker_pull() {
   docker pull $system_image
}

# launch instance
docker_inst() {
    docker run \
       --privileged \
       --rm --tty --detach \
       --env JENKINS_HOME=/tmp \
       --volume /var/lib/machines:/var/lib/machines:rw \
       --volume /var/lib/nspawn.sh:/var/lib/nspawn.sh:rw \
       --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
       --volume /tmp:/tmp:rw \
       --volume $proj:$proj:rw \
       --name $instance_name \
       $system_image
}

# invoke command
docker_exec() {
   docker exec $instance_name "$@"
}

# terminate instance
docker_kill() {
   docker kill $instance_name
}

# show instance console
docker_logs() {
   docker logs $instance_name
}

# verify system service is started
sysd_is_active() {
   local "$@" # unit
   local active=$(docker_exec systemctl is-active $unit)
   [[ $active == active* ]] # ignore tail '\r' from docker 
}

# await system service is running
sysd_wait_active() {
   local "$@" # unit
   while true ; do
      if sysd_is_active ; then
         echo "ready: $unit"
         break
      else
         echo "await: $unit"
         sleep 1
      fi 
   done
}

# show system services
sysd_report_status() {
   docker_exec systemctl status --no-pager $@
}
