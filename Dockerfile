FROM ubuntu:latest
RUN apt-get -y update; apt-get -y install curl jq
WORKDIR /scripts
COPY remove_images.sh .
# RUN chmod +x /scripts/remove_images.sh
# CMD ["bash", "/scripts/remove_images.sh", "registry.knap.dev", "projects/rost_today", "auto-hub", "BoBbn#gom", "5"]
ENTRYPOINT [ "bash", "/scripts/remove_images.sh" ]
CMD [ "registry.knap.dev", "projects/rost_today", "auto-hub", "BoBbn#gom", "2" ]