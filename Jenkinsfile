pipeline {
    agent any

    environment {
        APP_NAME = 'devops-lab1-cicd'
        STUDENT  = 'Fayyaz Ahmad'
        VENV     = "${WORKSPACE}/.venv"
        ARTIFACT = "devops-lab1-cicd-${BUILD_NUMBER}.tar.gz"
        APP_PORT = '8000'
    }

    options {
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        skipStagesAfterUnstable()
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                sh '''
                    echo "Build #${BUILD_NUMBER} | ${APP_NAME} | ${STUDENT}"
                    git log --oneline -5
                '''
            }
        }

        stage('Setup Environment') {
            steps {
                sh '''
                    python3 -m venv "$VENV"
                    . "$VENV/bin/activate"
                    pip install --upgrade pip --quiet
                    pip install -r requirements.txt --quiet
                    pip list
                '''
            }
        }

        stage('Lint') {
            steps {
                sh '''
                    . "$VENV/bin/activate"
                    mkdir -p reports
                    flake8 app tests --max-line-length=100 \
                        --output-file=reports/flake8.txt --tee
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    . "$VENV/bin/activate"
                    pytest -v --junitxml=reports/junit.xml
                '''
            }
            post {
                always {
                    junit 'reports/junit.xml'
                }
            }
        }

        stage('Build Artifact') {
            steps {
                sh '''
                    tar -czf "$ARTIFACT" app requirements.txt scripts
                    ls -lh "$ARTIFACT"
                    sha256sum "$ARTIFACT" > "${ARTIFACT}.sha256"
                '''
                archiveArtifacts artifacts: "${ARTIFACT}*", fingerprint: true
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    expression { env.GIT_BRANCH ==~ /(origin\/)?main/ }
                }
            }
            steps {
                sh '''
                    chmod +x scripts/deploy.sh
                    ./scripts/deploy.sh "$(pwd)/$ARTIFACT"
                '''
            }
        }

        stage('Smoke Test') {
            when {
                anyOf {
                    branch 'main'
                    expression { env.GIT_BRANCH ==~ /(origin\/)?main/ }
                }
            }
            steps {
                sh '''
                    sleep 5
                    curl -fsS "http://localhost:${APP_PORT}/health"
                    echo
                    curl -fsS "http://localhost:${APP_PORT}/"
                '''
            }
        }
    }

    post {
        success {
            echo "SUCCESS: build #${BUILD_NUMBER} deployed and verified by ${STUDENT}."
        }
        failure {
            echo "FAILED: build #${BUILD_NUMBER} - inspect the first red stage."
        }
        always {
            sh 'rm -rf "$VENV"'
        }
    }
}
