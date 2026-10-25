pipeline {
    // run on the SSH agent labelled "podman"
    agent { label 'podman' }

    // Check github for new commits every 2 minutes
    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        REGISTRY = 'registry.assign.nsteiman.300.ops:5000'
        IMAGE    = "${REGISTRY}/bind-secondary"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Tag = build number + short commit SHA
                    env.TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 7)}"
                }
                sh 'podman build -t "$IMAGE:$TAG" .'
            }
        }

        stage('Test') {
            steps {
                // Image must contain a valid BIND configuration
                sh 'podman run --rm "$IMAGE:$TAG" named-checkconf'
            }
        }

        stage('Scan') {
            steps {
                // CVE scan with Trivy before pushing.
                sh '''
                    podman save -o image.tar "$IMAGE:$TAG"
                    trivy image --input image.tar \
                        --scanners vuln \
                        --severity HIGH,CRITICAL \
                        --exit-code 0 \
                        --no-progress \
                        --format table \
                        --output trivy-report.txt
                    cat trivy-report.txt
                    rm -f image.tar
                '''
                archiveArtifacts artifacts: 'trivy-report.txt', fingerprint: true
            }
        }

        stage('Push') {
            steps {
                // Registry login comes from Jenkins Creds
                withCredentials([usernamePassword(credentialsId: 'registry-creds',
                                                  usernameVariable: 'REG_USER',
                                                  passwordVariable: 'REG_PASS')]) {
                    sh '''
                        echo "$REG_PASS" | podman login "$REGISTRY" -u "$REG_USER" --password-stdin
                        podman push "$IMAGE:$TAG"
                        podman tag "$IMAGE:$TAG" "$IMAGE:latest"
                        podman push "$IMAGE:latest"
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'podman logout "$REGISTRY" || true'
        }
    }
}
