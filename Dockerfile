FROM frolvlad/alpine-java:jdk8-full as build

ENV TRON_PATH=/opt/tron

USER root

WORKDIR ${TRON_PATH}

# installs dependencies packages
RUN apk update \
    && apk -U upgrade \
    && apk add --no-cache --update bash curl wget \
        tar tzdata iputils unzip findutils git gettext gdb lsof patch \
        libcurl libxml2 libxslt openssl-dev zlib-dev \
        make automake gcc g++ binutils-gold linux-headers paxctl libgcc libstdc++ \
        python gnupg ncurses-libs ca-certificates \
    && update-ca-certificates --fresh \
    && rm -rf /var/cache/apk/*

# adds tron user and fix tron folder's permission
RUN	adduser -S tron -u 1000 -G root \
    && chown -R tron:root ${TRON_PATH}

USER tron

# builds tron-full-node
ENV TRON_VERSION=3.6.0
ENV TRON_SOURCE_URL=https://github.com/tronprotocol/java-tron/archive/Odyssey-v${TRON_VERSION}.tar.gz
ENV TRON_SOURCE_PATH=${TRON_PATH}/java-tron-Odyssey-v${TRON_VERSION}/
RUN curl -L -O ${TRON_SOURCE_URL} \
    && tar -xzvf Odyssey-v${TRON_VERSION}.tar.gz \
    && cd java-tron-Odyssey-v${TRON_VERSION}/ \
    && ./gradlew clean build -x test
    
# moves distribution binaries to WORKDIR
# and cleans downloaded tar and source
RUN mv ${TRON_SOURCE_PATH}build/libs/FullNode.jar ${TRON_PATH}/ \
    && mv ${TRON_SOURCE_PATH}/build/libs/SolidityNode.jar ${TRON_PATH}/ \
    && cd ${TRON_PATH} && rm -rf ${TRON_SOURCE_PATH} \
    && rm -f Odyssey-v${TRON_VERSION}.tar.gz

FROM frolvlad/alpine-java:jdk8-full as runtime

ENV TRON_PATH=/opt/tron

WORKDIR ${TRON_PATH}

USER root

# installs dependencies packages
RUN apk update \
    && apk -U upgrade \
    && apk add --no-cache --update libstdc++ curl ca-certificates \
    && update-ca-certificates --fresh \
    && rm -rf /var/cache/apk/*

# adds tron user and fix tron folder's permission
RUN	adduser -S tron -u 1000 -G root \
    && chown -R tron:root ${TRON_PATH}

USER tron

COPY --from=build --chown=tron:root ${TRON_PATH}/FullNode.jar ${TRON_PATH}/SolidityNode.jar ${TRON_PATH}/

COPY --chown=tron:root start.sh ./
RUN	chmod +x ${TRON_PATH}/start.sh \
    && curl -LO https://raw.githubusercontent.com/tronprotocol/tron-deployment/master/main_net_config.conf

ENTRYPOINT [ "sh" ]
CMD [ "start.sh" ]
