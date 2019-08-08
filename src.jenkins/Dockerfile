FROM jenkins/jenkins:lts-alpine
USER root
RUN apk update && apk add docker

USER jenkins
# install jenkins plugins
RUN /usr/local/bin/install-plugins.sh configuration-as-code
RUN /usr/local/bin/install-plugins.sh matrix-auth
RUN /usr/local/bin/install-plugins.sh git
RUN /usr/local/bin/install-plugins.sh job-dsl
RUN /usr/local/bin/install-plugins.sh workflow-job
RUN /usr/local/bin/install-plugins.sh workflow-aggregator
RUN /usr/local/bin/install-plugins.sh authorize-project
RUN /usr/local/bin/install-plugins.sh docker-workflow

ARG REMOTE_REPO_URL
ARG DEVELOP_IP

ENV JENKINS_USER admin
ENV JENKINS_PASS admin

ARG URL_FOR_CHECK
ENV URL_FOR_CHECK=${URL_FOR_CHECK}

ARG CASC_JENKINS_CONFIG=/tmp/jcasc.yaml
ENV CASC_JENKINS_CONFIG=${CASC_JENKINS_CONFIG}

ARG JENKINS_URL
ENV JENKINS_URL=${JENKINS_URL}

ENV JENKINS_HOME /var/jenkins_home

COPY --chown=jenkins jcasc.yaml ${CASC_JENKINS_CONFIG}
RUN sed -i 's/REMOTE_REPO_URL/'${REMOTE_REPO_URL}'/g' ${CASC_JENKINS_CONFIG}

# allows to skip Jenkins setup wizard
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"

