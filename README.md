# Docker-handbrake




## Notes

https://hub.docker.com/r/jlesage/handbrake

this might be more suitable:  https://github.com/jongillies/docker-handbrake-cli

``` shell
mkdir -p /mnt/nas/docker/handbrake

sudo docker service create \
  --name handbrake \
  --publish published=5800,target=5800,protocol=tcp,mode=ingress \
  --mount type=bind,src=/mnt/nas/docker/handbrake,dst=/config:rw \
  --mount type=bind,src=/mnt/nas/media/jobs/watch,dst=/watch:rw \
  --mount type=bind,src=/mnt/nas/media/jobs/output,dst=/output:rw \
  --mount type=bind,src=/mnt/nas/media/jobs/storage,dst=/storage:ro \
  --env AUTOMATED_CONVERSION_PRESET="Very Fast 1080p30" \
  --replicas=1 \
  jlesage/handbrake
```




`docker build https://github.com/shepner/Docker-handbrake.git`
