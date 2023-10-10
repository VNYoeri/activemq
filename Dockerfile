FROM eclipse-temurin:11-jdk
CMD ["BASH"]
RUN apt-get update
RUN apt-get install -y --no-install-recommends ca-certificates curl netbase wget && rm -rf /var/lib/apt/lists/*
RUN set -ex; if ! command -v gpg > /dev/null; then apt-get update; apt-get install -y --no-install-recommends gnupg dirmngr ; rm -rf /var/lib/apt/lists/*; fi
RUN apt-get update && apt-get install -y --no-install-recommends bzip2 unzip xz-utils && rm -rf /var/lib/apt/lists/*
RUN { echo '#!/bin/sh'; echo 'set -e'; echo; echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home
RUN ln -svT $JAVA_HOME /docker-java-home
ENV JAVA_HOME=/docker-java-home
ENV LANG=C.UTF-8
ENV ACTIVEMQ_VERSION=5.15.11
ENV ACTIVEMQ=apache-activemq-5.15.11
ENV ACTIVEMQ_HOME=/opt/activemq
ENV SHA512_VAL=a3ca1a839ddb87eaf7468db1f130a1fe79be6423acc6b059ac2998d3d359b8cc369a45b62322bf29bb031e702113e4d1ac44ee43457a28e7bf22687aa107a37f
ENV ACTIVEMQ_SUNJMX_START="-Djava.rmi.server.hostname=0.0.0.0 \
-Dcom.sun.management.jmxremote.port=1616 \
-Dcom.sun.management.jmxremote.rmi.port=1616 \
-Dcom.sun.management.jmxremote.local.only=false \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false"
RUN curl "https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz" -o $ACTIVEMQ-bin.tar.gz # buildkit
RUN if [ "$SHA512_VAL" != "$(sha512sum $ACTIVEMQ-bin.tar.gz | awk '{print($1)}')" ]; then echo "sha512 values doesn't match! exiting." && exit 1; fi; # buildkit
RUN tar xzf $ACTIVEMQ-bin.tar.gz -C /opt && ln -s /opt/$ACTIVEMQ $ACTIVEMQ_HOME && useradd -r -M -d $ACTIVEMQ_HOME activemq && chown -R activemq:activemq /opt/$ACTIVEMQ && chown -h activemq:activemq $ACTIVEMQ_HOME && rm $ACTIVEMQ-bin.tar.gz # buildkit
RUN echo $(cd $ACTIVEMQ && ls -l)
RUN sed -i -e"" "s/127.0.0.1/0.0.0.0/g" $ACTIVEMQ_HOME/conf/jetty.xml # buildkit
ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161 ACTIVEMQ_JMX=1099 JMX_RMI=1616
WORKDIR $ACTIVEMQ_HOME
EXPOSE 1883:$ACTIVEMQ_MQTT
EXPOSE 5672:$ACTIVEMQ_AMQP
EXPOSE 61613:$ACTIVEMQ_STOMP
EXPOSE 61614:$ACTIVEMQ_WS
EXPOSE 61616:$ACTIVEMQ_TCP
EXPOSE 8161:$ACTIVEMQ_UI
EXPOSE 1099:$ACTIVEMQ_JMX
EXPOSE 1616:$JMX_RMI
CMD ["/bin/sh","-c","bin/activemq console"]