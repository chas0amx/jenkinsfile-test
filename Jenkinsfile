// Initialize a LinkedHashMap / object to share between stages
def pipelineContext = [:]

pipeline {
    agent any

    environment {
        // @TODO: use variable
        NGINX_BUILD_ARG = "-f ./nginx.build/Dockerfile ."
        DOCKER_NGINX_IMAGE_TAG = "my-app-nginx:build"
        IMAGE_BUILD_ID = "my-app:build-${env.BUILD_ID}"
        IMAGE_STABLE_TAG = "my-app:stable"
        IMAGE_CANDIDATE_NAME = "release4test"
        // @TODO: do not use variable from Dockerfile
        URL_FOR_CHECK = "${env.URL_FOR_CHECK}"
    }

    stages {
        stage('Build nginx from source inside the container') {
             steps {
                 echo "Check base nginx image exists"
                 script {
                    def ret = sh(script: "#!/bin/bash\n" +
                        "docker images -q " + "${env.DOCKER_NGINX_IMAGE_TAG}" ,
                      returnStdout: true)

                    if (ret) {
                        echo 'Local base nginx image (' + "${env.DOCKER_NGINX_IMAGE_TAG}" + ') already exists' 
                    } else {
                        echo 'Build local base nginx image'
                        dockerImage = docker.build("${env.DOCKER_NGINX_IMAGE_TAG}",  "${NGINX_BUILD_ARG}")
                    }
                }
            }
        }

        stage('Create a production ready container') {
          steps {
              script {
                  dockerImage = docker.build("${env.IMAGE_BUILD_ID}", ' -f Dockerfile .')
                  pipelineContext.dockerImage = dockerImage
              }
          }
        }
        
        stage('Run this container on the same instance') {
            steps {
                script  {
                  sh 'docker ps -q -f name=' + "${env.IMAGE_CANDIDATE_NAME}" + ' | xargs --no-run-if-empty docker rm -f'
                }
                script  {
                 // sh 'docker ps -q -f name=' + "${env.IMAGE_STABLE_TAG}" + ' | xargs --no-run-if-empty docker rm -f'
                 sh 'docker ps -a | awk \'{ print $1,$2 }\' | grep '+"${env.IMAGE_STABLE_TAG}"+' | awk \'{print $1 }\' | xargs -I {} docker rm -f {}'
                  
                }
                script  {
                  pipelineContext.dockerContainer = pipelineContext.dockerImage.run('--name=' + "${env.IMAGE_CANDIDATE_NAME}" + ' -p80:80')
                }
            }
        }

        stage('Test if it is running successfully and responding'){
            steps {
                    script {
                        sleep(time:3, unit:"SECONDS");

                        def STATUSCODE = sh script: 'curl --silent --output /dev/stderr --write-out "%{http_code}" ' + "${env.URL_FOR_CHECK}", returnStdout: true
                        echo 'Status code: ' + STATUSCODE
                        
                        def CONTENT = sh script: 'curl --silent ' + "${env.URL_FOR_CHECK}", returnStdout: true
                        String trimmedString = CONTENT.trim()
                        echo 'Content: ' + trimmedString

                        // do rollback
                        if ( (STATUSCODE != '200' || STATUSCODE != '201') && trimmedString != 'Welcome Nginx Builder' ) {
                            echo 'Do rollback'
                            // remove failed release
                            if (pipelineContext && pipelineContext.dockerContainer) {
                                pipelineContext.dockerContainer.stop()
                            }
                             // run previouse stable release
                            sh(script: "#!/bin/bash\n" + "docker run -d --rm -p80:80 ${env.IMAGE_STABLE_TAG} ", returnStdout: true)
                        }
                        else {
                            echo 'Create new stable version'
                            sh(script: "#!/bin/bash\n" +
                                "docker tag " +
                                 "${env.IMAGE_BUILD_ID}" + " " + "${env.IMAGE_STABLE_TAG}" ,
                            returnStdout: true)
                        }
                    }
            }
        }
//
//         stage('Dangling Containers') {
//             steps{
//                 sh '''docker ps -q -f status=exited | xargs --no-run-if-empty docker rm'''
//             }
//         }
//
//         stage('Dangling Images') {
//             steps{
//                 sh '''docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi'''
//             }
//         }
    }// stages

    post {
        always {
            echo 'Finish: ' + "${env.URL_FOR_CHECK}"
        }
    }
}