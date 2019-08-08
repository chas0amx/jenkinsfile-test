## Full example usage Jenkins(Docker in Docker) and "Configuration as Code" plugin to use Jenkinsfile
Jenkins(from docker) use jCasC plugin create first pipeline with:
  - trigger job every minute
  - get sources from remote SCM
  - apply Jenkinsfile with steps:
      - build nginx from source inside the container
      - create a production ready container with nginx from previous step and some static html page from repository
      - run this container on the same(run via -v /var/run/docker.sock:/var/run/docker.sock) instance
      - test if it is running successfully and responding (curl) - rollback if it is not
 
 Used Env Variables:
    ```ENV JENKINS_USER admin```
    ```ENV JENKINS_PASS admin```
 
###To run on local-develop environment:

- Install docker on instance
- Git clone this repository
- Init local(develop) git repo for Jenkins pipeline
    - `make git-init`
    - `make git-daemon`
- Check your local ip address (instance where docker will be running)
    - `make check-ip-for-develop `
- Build docker image
    - `make jenkins-build`
- Run jenkins
    - `make jenkins-run`

Jenkins will with JCasC (Configuration as Code plugin) and
create seed pipelene (src.jenkins/jcasc.yaml:57).

Job will trigger your local(develop) repository every minute and apply Jenkinsfile

- Make changes and push this sources to your local(develop) repo
    `git ci -am 'first commit'`   
    `git push git://$(hostname -I | cut -d' ' -f1)/test master`
    
    - You are able to trigger jenkins job manually
        `curl http://$(hostname -I | cut -d' ' -f1):8080/job/Nginx_Builder/build?token=mytoken`    
- Open browser with last pipeline output
    `xdg-open http://$(hostname -I | cut -d' ' -f1):8080/job/Nginx_Builder/lastBuild/console`
- Open browser with work stable release
    `xdg-open http://$(hostname -I | cut -d' ' -f1)`

For test stages from Jenkinsfile:
    - Make changes into landing page ;):
    
        `echo 'WeLcOmE Nginx Builder ];-() ' >  index.html`
                 
        `git ci -am 'test pipeline'`
           
        `git push git://$(hostname -I | cut -d' ' -f1)/test master`
        
        `xdg-open http://$(hostname -I | cut -d' ' -f1):8080/job/Nginx_Builder/lastBuild/console`
        
        `curl http://$(hostname -I | cut -d' ' -f1):8080/job/Nginx_Builder/build?token=mytoken`
    
    - Restore page:
    
        `echo -n 'Welcome Nginx Builder' >  index.html`
        
        `git ci -am 'test pipeline2'`
                   
        `git push git://$(hostname -I | cut -d' ' -f1)/test master`
        
        `xdg-open http://$(hostname -I | cut -d' ' -f1):8080/job/Nginx_Builder/lastBuild/console`
        
        `curl http://$(hostname -I | cut -d' ' -f1):8080/job/Nginx_Builder/build?token=mytoken`
    