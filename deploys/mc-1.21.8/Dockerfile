# FROM amazoncorretto:21-al2023

# # Install essential tools and update system libraries for VS Code Server compatibility
# RUN yum update -y && \
#     yum install -y tar gzip curl wget procps glibc && \
#     yum clean all

# Changed it to get VS Code attached to the container
FROM debian:bullseye

# Install prerequisites
RUN apt-get update && apt-get install -y wget gnupg

# Add Amazon Corretto repository and install Java 21
RUN wget -O - https://apt.corretto.aws/corretto.key | apt-key add - && \
    echo "deb https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list && \
    apt-get update && \
    apt-get install -y java-21-amazon-corretto-jdk

# Install essential tools for VS Code Server
RUN apt-get install -y tar gzip curl wget procps

COPY server /server

WORKDIR /server

RUN mv server-jars/paper*.jar server-jars/server.jar

ENV SERVER_JAR='/server/server-jars/server.jar'

ENV SERVER_PLUGINS="/server/server-plugins/*.jar"

RUN chmod 777 entrypoint.sh

CMD [ "sh", "entrypoint.sh" ]

# For debugging comment entry point and uncomment sleep
# CMD ["sleep", "infinity"] 