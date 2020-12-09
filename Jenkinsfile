pipeline {
    environment {
        VERSION = "latest"
        PROJECT = "workshop"
        IMAGE = "$PROJECT:$VERSION"
        ECRURL = 'https://683294139580.dkr.ecr.ap-south-1.amazonaws.com/workshop'
        ECRCRED = "ecr:ap-south-1:c8880065-79a9-4e1b-b329-aafbb2ce4f00"
    }
       
    agent any
    tools {
        maven 'maven'
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
                checkout([$class: 'GitSCM', branches: [[name: '*/dev']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: '']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github_cred', url: 'https://github.com/shareef-mt/hackathan-mt.git']]])
            }
        }
       
        stage('Mvn Package') {
            steps {
                sh 'mvn -B -DskipTests clean package -e'
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
        
		stage('Aws Ecr Repo Creation') {
			steps {
				dir("ecr/") {
					script {
						sh  '''
								terraform init
								terraform plan
								terraform apply
							'''
					}
				}
			}
		}
        stage('Scanning & Pushing Docker Image into Aws Repo') {
            steps {
                script {
                    docker.withRegistry(ECRURL, ECRCRED)
                        {
                            sh 'aws ecr put-image-scanning-configuration --repository-name workshop --image-scanning-configuration scanOnPush=true --region ap-south-1'
                            docker.image(IMAGE).push()
                 
                        }
                }
            }
        }
       
        stage('Deploy Aws Ecr image into Aws EKS') {
            steps {
                dir("ecs") {
                    script {
                        sh '''
							terraform init
							terraform plan
							terraform apply
       
                           '''
                    }
                }
            }
        }
       
    }  
    }
