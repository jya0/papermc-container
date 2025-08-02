FROM amazoncorretto:21

COPY server /server

WORKDIR /server

RUN mv server-jars/paper*.jar server-jars/server.jar

ENV SERVER_JAR='/server/server-jars/server.jar'

ENV SERVER_PLUGINS="/server/server-plugins/*.jar"

RUN chmod 777 entrypoint.sh

CMD [ "sh", "entrypoint.sh" ]

# For debugging comment entry point and uncomment sleep
# CMD ["sleep", "infinity"] 