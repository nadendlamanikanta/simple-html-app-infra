pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Install Terraform') {
            steps {
                sh '''
                sudo apt-get update -y
                sudo apt-get install -y wget unzip
                wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
                unzip terraform_1.0.0_linux_amd64.zip
                sudo mv terraform /usr/local/bin/
                terraform -v
                '''
            }
        }
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/nadendlamanikanta/simple-html-app-infra.git', branch: 'main'
            }
        }
        stage('Terraform Init') {
            steps {
                dir('aws-infra') {
                    withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}"]) {
                        script {
                            def output = sh(script: 'terraform init', returnStatus: true)
                            if (output != 0) {
                                error("Terraform Init failed")
                            }
                        }
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('aws-infra') {
                    withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}"]) {
                        script {
                            def output = sh(script: 'terraform apply -auto-approve -lock=false', returnStatus: true)
                            if (output != 0) {
                                error("Terraform Apply failed")
                            } else {
                                env.WEB_SERVER_IP = sh(script: 'terraform output -raw web_server_public_ip', returnStdout: true).trim()
                            }
                        }
                    }
                }
            }
        }
        stage('Build') {
            steps {
                dir('html') {
                    sh '''
                    mkdir -p html
                    echo "<html><body><h1>Hello, World</h1></body></html>" > html/index.html
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                sshagent(['aws-ec2-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@${WEB_SERVER_IP} "sudo mkdir -p /var/www/html && sudo chown -R ubuntu:ubuntu /var/www/html"
                    scp -o StrictHostKeyChecking=no -r html/* ubuntu@${WEB_SERVER_IP}:/var/www/html/
                    ssh -o StrictHostKeyChecking=no ubuntu@${WEB_SERVER_IP} "ls -l /var/www/html && if [ -f /var/www/html/index.html ]; then echo 'Deployment successful'; else echo 'Deployment failed'; exit 1; fi"
                    '''
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}


