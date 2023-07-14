ARG IMAGE=ubuntu:22.04
FROM node:latest as npm
WORKDIR /v4l2web	
COPY . /v4l2web

RUN npm install -g npm && make vuejs/dist

FROM $IMAGE as builder
WORKDIR /v4l2web	
COPY --from=npm /v4l2web .

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates g++ autoconf automake libtool xz-utils cmake make pkg-config git libjpeg-dev libssl-dev \
    && make install && apt-get clean && rm -rf /var/lib/apt/lists/

FROM $IMAGE
LABEL maintainer michel.promonet@free.fr
COPY --from=builder /usr/bin/ /usr/bin/
COPY --from=builder /usr/share/v4l2camera/ /usr/share/v4l2camera/

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates libjpeg-dev libssl-dev libasound2-dev && rm -rf /var/lib/apt/lists/

ENTRYPOINT [ "/usr/bin/v4l2camera" ]
CMD [ "-p", "/usr/share/v4l2camera" ]
