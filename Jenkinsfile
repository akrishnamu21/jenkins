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
        stage('terraform destroy') {
            steps {
                sh '/usr/local/bin/terraform destroy -no-color -auto-approve ./jenkins'
            }
        }
        
       /*stage('git clone') {
            steps {
                sh 'sudo rm -r *; git clone https://github.com/akrishnamu21/jenkins.git'
            }
        }
        stage('tfsvars create'){
            steps {
                sh 'sudo cp /home/smadmin/vars.tf /var/lib/jenkins/workspace/new/jenkins/'
            }
        }
        stage('terraform init') {
            steps {
                //sh 'terraform init -input=false /var/lib/jenkins/workspace/new/jenkins/;'
                sh '/usr/local/bin/terraform init -input=false ./jenkins'
            }
        }
        stage('terraform plan') {
            steps {
                //sh 'sudo ls /var/lib/jenkins/workspace/new/jenkins/; sudo terraform plan -out=tfplan -input=false/var/lib/jenkins/workspace/new/jenkins/; '
                sh '/usr/local/bin/terraform plan -out=tfplan -input=false ./jenkins'
            }
            
        }
        stage('terraform apply') {
            steps {
                //sh 'cd /var/lib/jenkins/workspace/new/jenkins/; terraform apply -input=false tfplan'
                 sh '/usr/local/bin/terraform apply -no-color -auto-approve ./jenkins'
            }
        }
        
        stage('terraform ended') {
            steps {
                sh 'echo "Ended....!!"'
            }
        } */ 
    }
}
