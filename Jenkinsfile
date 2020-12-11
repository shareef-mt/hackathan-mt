pipeline {
    environment {
        VERSION = "latest"
        PROJECT = "app_repo"
        IMAGE = "$PROJECT:$VERSION"
        ECRURL = "https://683294139580.dkr.ecr.us-east-1.amazonaws.com/app_repo"
        ECRCRED = "ecr:us-east-1:aws_ecr_cred"
    }
       
    agent any
    tools {
        maven 'maven'
	terraform 'terraform'
    }
	
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}/bin/mvn"
                '''
            }
        }
       
        stage('SCM Checkout') {
            steps {
            // Get source code from Gitlab repository
                checkout([$class: 'GitSCM', branches: [[name: '*/dev']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: '']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github_cred', url: 'https://github.com/shareef-mt/sample-java.git']]])
            }
        }
       
        stage('Mvn Package') {
            steps {
                sh 'mvn -B -DskipTests clean package -e'
            }
        }
		
        stage('Aws Ecr Repo Creation') {
            steps {
                dir("ecr/") {
                    script {
                        sh 'pwd'
                        sh 'terraform init'
                        sh 'terraform plan'
                        sh 'terraform apply --auto-approve'
                           
                    }
                }
            }
        }
       
        stage('Docker Image Build') {
            steps {
            sh '''
                    pwd
                    echo "PATH = ${PATH}"
                    echo "PATH = ${IMAGE}"
                '''
                script {
                    sh 'docker version '
                    docker.build('$IMAGE')
                }
            }
        }
		
        stage('Scanning & Pushing Docker Image into Aws Repo') {
            steps {
                script {
                    docker.withRegistry(ECRURL, ECRCRED)
                        {
                            sh 'aws ecr put-image-scanning-configuration --repository-name app_repo --image-scanning-configuration scanOnPush=true --region us-east-1'
                            docker.image(IMAGE).push()
                 
                        }
                }
            }
        }
       
        stage('Deploy Aws Ecr image into Aws Ecs') {
            steps {
                dir("ecs/") {
                    script {
                        sh '''
                            terraform init
                            terraform plan
                            terraform apply --auto-approve
       
                           '''
                    }
                }
            }
        }
       
    }  
    }
