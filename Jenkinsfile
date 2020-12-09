#!groovy
@Library('eqx-shared-libraries')

String version
String awsRegion = "us-east-1"
String appName = "hypergate-assessment"
String dockerFilePath = "."
String TASK_FAMILY = "assessment"
#String projectFile = "pom.xml"
String env = env.BRANCH_NAME
String ecrRepo =  ""
String awsAccount= "520009515406"



pipeline {
    agent none

    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        disableConcurrentBuilds()
        timeout(time: 6, unit: 'HOURS')
        ansiColor('xterm')
    }

    stages {
        stage('Spot Poc Version Build') {
            agent { label 'linux' }
            tools {
                maven 'maven-3.5.0'
            }
            steps {
                script {
                    version = VersionNumber(
                        versionNumberString: '1.1.${BUILD_NUMBER, X}',
                        skipFailedBuilds:    false)
                    currentBuild.displayName = version
                    println "Pipeline Version='${version}'"
                }
                dir("${WORKSPACE}") {
                      withCredentials([usernamePassword(credentialsId: 'coaching-maven', passwordVariable: 'PASSWORD_VAR', usernameVariable: 'USERNAME_VAR')])    {
                           sh "find . -type f -name pom.xml | xargs sed -i 's/0.0.0/'${version}'/g'"
		                   mavenBuild(version, appName, env, projectFile)
                        }
                   }
               }
           }

//		stage('Spot Poc Code Analytics') {
//            when {
//                anyOf { branch 'DOPS-2931' }
//            }
//            agent { label 'linux-maven' }
//            tools {
//               maven 'maven-3.5.0'
//            }
//            environment{
//               SONAR_SCANNER_OPTS="-Xmx512m"
//            }
//            steps {
//                dir("${WORKSPACE}") {
//                   unstash name: "${appName}-build-output-${env}"
//                   withSonarQubeEnv('Sonarqube') {
//                      withCredentials([usernamePassword(credentialsId: 'coaching-maven', passwordVariable: 'PASSWORD_VAR', usernameVariable: 'USERNAME_VAR')])    {
//                           sh "mvn clean test org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=false"
//		                   sh "mvn -e -B sonar:sonar -Dsonar.java.source=1.8 -Dsonar.host.url='https://coachingsonar.equinoxfitness.com'"
//                        }
//                    }
//                 }
//            }
//        }

        stage('Spot Poc Build') {
            when {
                anyOf { branch 'DOPS-2931' }
            }
            agent { label 'linux-docker' }
            steps{
                script {
                   dockerBuildArgs = ['version':"${version}"]
                }
                dockerBuildMultiAccount(appName, env, version, ecrRepo, awsAccount, awsRegion, dockerBuildArgs)
            }
        }

        stage('Spot Poc Deploy') {
            when {
                anyOf { branch 'DOPS-2931' }
            }
            agent { label 'linux-terraform' }
            environment{
                PATH = "$PATH:~/.tfenv"
            }
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/DOPS-2931']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: '']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'eq00svc-buildmaster-bitbucket-api-key', url: 'https://bitbucket.org/equinoxfitness/coaching-terraform']]])
                writeFile file: "coaching-hypergate/assessment/spot/terraform.tfvars", text: """
spot_poc_hypergate_assessment_version = "${version}"
"""
                sh "chmod +x terraform-run.sh"
                sh "./terraform-run.sh -e coaching-hypergate/assessment/spot"
            }
        }
    }
}
