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
                sh 'sudo rm -r *;sudo git clone https://github.com/akrishnamu21/jenkins.git'
            }
        }
        stage('tfsvars create'){
            steps {
                sh 'sudo cp /home/smadmin/vars.tf ./jenkins/'
            }
        }
        stage('terraform init') {
            steps {
                sh 'sudo /home/smadminr/terraform init ./jenkins'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'ls ./jenkins; sudo /home/smadmin/terraform plan ./jenkins'
            }
        }
        stage('terraform ended') {
            steps {
                sh 'echo "Ended....!!"'
            }
        }

        
    }
}
