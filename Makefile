.DEFAULT_GOAL := help
# print description
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

jenkins: clean-previouse-installation dc-stop jenkins-build jenkins-run

LOCAL_IP := $(shell hostname -I | cut -d' ' -f1)
JENKINS_URL := "http://$(LOCAL_IP):8080"
URL_FOR_CHECK := "http://$(LOCAL_IP)"
## Escaped for replacing in jcasc file
REMOTE_REPO_URL := "git:\/\/$(LOCAL_IP)\/test\/"
LOCAL_JENKINS_HOME_DIR := /var/www/jenkins_test

check-ip-for-develop:
	echo $(LOCAL_IP)

clean-previouse-installation:
	sudo rm -rf $(LOCAL_JENKINS_HOME_DIR); \
	mkdir $(LOCAL_JENKINS_HOME_DIR)

jenkins-run:
	docker run --rm --interactive --tty \
		-p 8080:8080 \
		-p 50000:50000 \
		--user $(id -u):$(id -g) \
		--name jenkins-as-service \
		-v $(LOCAL_JENKINS_HOME_DIR):/var/jenkins_home \
		-v /var/run/docker.sock:/var/run/docker.sock \
		jenkins-as-service/jenkins

jenkins-build:
	cd ./src.jenkins/;\
	docker build \
	--build-arg DEVELOP_IP=$(LOCAL_IP) \
	--build-arg REMOTE_REPO_URL=$(REMOTE_REPO_URL) \
	--build-arg URL_FOR_CHECK=$(URL_FOR_CHECK) \
	--build-arg JENKINS_URL=$(JENKINS_URL) \
	-t jenkins-as-service/jenkins -f Dockerfile .

dc-images-dung:
	docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi

dc-containers-dung:
	docker ps -q -f status=exited | xargs --no-run-if-empty docker rm

dc-untaged-rm:
	docker images -a | grep "<none>" | awk "{print \$3}" |  xargs --no-run-if-empty docker rmi -f

dc-stop:
	docker kill jenkins-as-service 2>/dev/null; true

dc-console:
	docker exec -it jenkins-as-service bash

git-push:
	git ci -am 'test'; git push; curl http://$(LOCAL_IP):8080/job/Nginx_Builder/build?token=mytoken

git-init:
	git init --bare /tmp/git/test/

git-daemon:
	git daemon --reuseaddr --enable=receive-pack --enable=upload-archive --verbose --export-all --base-path=/tmp/git/




