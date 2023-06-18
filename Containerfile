##Choose a base image
#
FROM registry.access.redhat.com/ubi8/ubi:8.7

##Variables - To create non-root user
#
ARG USERNAME=sftpclient
ARG USER_UID=1001
ARG USER_GID=$USER_UID

##Set user context for setting up the image
#
USER root

##Install pre-requisites
#
RUN yum install -y openssh-clients less unzip && \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && ./aws/install && mkdir -p /staging && rm -f awscliv2.zip && \
        groupadd --gid $USER_GID $USERNAME && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
        yum remove -y unzip && yum clean all

##Copy the shell script files to the image
#
COPY scripts/ /scripts

##Assign right permissions on folders
RUN chown -R $USER_UID:$USER_GID /staging && \
        chown -R $USER_UID:$USER_GID /scripts && \
        chmod 755 /scripts/sftpjob.sh

##Change user context to run as non-root
USER 1001

##Default command to execute when container starts
#
CMD /scripts/sftpjob.sh
