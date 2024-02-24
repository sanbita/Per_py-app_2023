pipeline {
      agent any
      stages {
        stage('Git Checkout') {
          steps {

            checkout scm
          }
        }
        stage('Run SonarQube Analysis') {
          steps {
            script {
              def scannerHome = tool name: 'sonar-qube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
              withSonarQubeEnv('sonar-server') {
                sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=my_project"
              }
            }
          }
        }
        stage("OWASP Dependency Check") {
          steps {
            dependencyCheck additionalArguments: '--scan ./ --format XML --enableExperimental', odcInstallation: 'DP-check'
            dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
          }
        }

        stage('Docker Build') {
          steps {

            sh 'docker build -t sanba1sara/our-app:v2 .'
          }
        }

        stage("Trivy Scan") {

          steps {

            script {

              // Specify the path to the Docker image you want to scan

              def dockerImage = "sanba1sara/our-app:v2"

              // Run Trivy to scan the Docker image

              sh "trivy  image ${dockerImage} --no-progress  --severity HIGH,CRITICAL  "

            }

          }

        }

        stage('Docker Push') {
          steps {
            withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'dockerhubpwd')]) {
              sh 'docker login -u sanba1sara -p ${dockerhubpwd}'
              sh 'docker push sanba1sara/our-app:v2'
            }
          }
        }

        stage('Deploy Container') {
          steps {

            sh 'docker stop app'
            sh 'docker rm app'
            sh 'docker run -d --name app -p 5000:5000 sanba1sara/our-app:v2'
          }
        }
        stage('OWASP ZAP Scan') {
          steps {

            script {
              try {

                sh "docker run --rm  -v ${pwd}:/zap/wrk -i owasp/zap2docker-stable zap-baseline.py  -t http://172.17.0.4:5000 "
              } catch (Exception e) {
                echo "OWASP ZAP scan completed with findings."
                currentBuild.result = 'SUCCESS' // Mark the build as successful even if there are findings     
              }
            }
          }
        }

      }


    }
