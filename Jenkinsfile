pipeline {
    agent {
        node {
            label 'master'
        }
    }

    stages {

        stage('terraform started') {
            steps {
                sh 'echo "Started...!" '
            }
        }
        stage('git clone') {
            steps {
                sh 'rm -r *; git clone https://github.com/akrishnamu21/jenkins.git'
            }
        }
        stage('tfsvars create'){
            steps {
                sh 'sudo cp /home/smadmin/vars.tf /var/lib/jenkins/workspace/new/jenkins/'
            }
        }
        stage('terraform init') {
            steps {
                sh '/home/smadminr/terraform init /var/lib/jenkins/workspace/new/jenkins/'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'ls /var/lib/jenkins/workspace/new/jenkins/; /home/smadmin/terraform plan /var/lib/jenkins/workspace/new/jenkins/'
            }
        }
        stage('terraform ended') {
            steps {
                sh 'echo "Ended....!!"'
            }
        }

        
    }
}
