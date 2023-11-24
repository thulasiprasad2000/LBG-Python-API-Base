pipeline {
    agent any
    environment {
        PORT = "8000"
        MYSQL_ROOT_PASSWORD = credentials("MYSQL_ROOT_PASSWORD")
    }
    stages {
        stage('Build') {
            steps {
                sh '''
                docker build -t thulasiprasad2000/lbg:${BUILD_NUMBER} --build-arg PORT=${PORT} .
                docker tag thulasiprasad2000/lbg:${BUILD_NUMBER} thulasiprasad2000/lbg:latest
                docker build -t thulasiprasad2000/lbg-mysql:${BUILD_NUMBER} db
                docker tag thulasiprasad2000/lbg-mysql:${BUILD_NUMBER} thulasiprasad2000/lbg-mysql:latest
                docker push thulasiprasad2000/lbg:${BUILD_NUMBER}
                docker push thulasiprasad2000/lbg:latest
                docker push thulasiprasad2000/lbg-mysql:${BUILD_NUMBER}
                docker push thulasiprasad2000/lbg-mysql:latest
                docker rmi thulasiprasad2000/lbg:${BUILD_NUMBER}
                docker rmi thulasiprasad2000/lbg:latest
                docker rmi thulasiprasad2000/lbg-mysql:${BUILD_NUMBER}
                docker rmi thulasiprasad2000/lbg-mysql:latest
                '''
           }
        }
        stage("generate nginx.conf") {
            steps {
                sh '''
                cat - > nginx.conf <<EOF
                events {}
                http {
                    server {
                        listen 80;
                        location / {
                            proxy_pass http://lbg-api:${PORT};
                        }
                    }
                }
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                scp nginx.conf jenkins@thulasi-deploy:/home/jenkins/nginx.conf
                ssh jenkins@thulasi-deploy <<EOF
                export PORT=${PORT}
                export VERSION=${BUILD_NUMBER}
                export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
                docker stop lbg-api && echo "stopped" || echo "not running"
                docker rm lbg-api && echo "removed" || echo "already removed"
                docker stop nginx && echo "stopped" || echo "not running"
                docker rm nginx && echo "removed" || echo "already removed"
                docker stop mysql && echo "stopped" || echo "not running"
                docker rm mysql && echo "removed" || echo "already removed"
                docker network inspect proj && echo "network exists" || docker network create proj
                docker volume inspect proj-vol && echo "volume exists" || docker volume create proj-vol
                docker pull thulasiprasad2000/lbg
                docker pull thulasiprasad2000/lbg-mysql
                docker run -d -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} --network proj --name mysql -v proj-vol:/var/lib/mysql thulasiprasad2000/lbg-mysql
                docker run -d -e PORT=${PORT} -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} --name lbg-api --network proj thulasiprasad2000/lbg
                docker run -d -p 80:80 --name nginx --network proj --mount type=bind,source=/home/jenkins/nginx.conf,target=/etc/nginx/nginx.conf nginx:alpine
                '''
            }
        }
    }
}
