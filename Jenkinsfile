@NonCPS
def cancelPreviousBuilds() {
    def jobName = env.JOB_NAME
    def buildNumber = env.BUILD_NUMBER.toInteger()
    def currentJob = Jenkins.instance.getItemByFullName(jobName)

    for (def build : currentJob.builds) {
        def listener = build.getListener()
        def exec = build.getExecutor()
        if (build.isBuilding() && build.number.toInteger() < buildNumber && exec != null) {
            exec.interrupt(
                Result.ABORTED,
                new CauseOfInterruption.UserInterruption("Aborted by #${currentBuild.number}")
            )
            println("Aborted previously running build #${build.number}")
        }
    }
}

pipeline {
    agent any
    environment {
        DOCKER_BUILDKIT = '1'
    }
    stages {
        stage('Init') {
            steps {
                script {
                    cancelPreviousBuilds()
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    withVault([vaultSecrets: [[path: 'Datawords/internal', secretValues: [
                        [vaultKey: 'HARBOR-DOMAIN', envVar: 'HARBOR_DOMAIN'],
                    ]]]]) {
                        sh """
                        docker build -t ${HARBOR_DOMAIN}/datawords/promtail:vpc -f dockerfile --target vpc .
                        docker build -t ${HARBOR_DOMAIN}/datawords/promtail:public -f dockerfile --target public .
                        """
                    }
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    withVault([vaultSecrets: [[path: 'Datawords/internal', secretValues: [
                        [vaultKey: 'HARBOR-SERVER-INTERNAL-ADDRESS', envVar: 'HARBOR_ADDRESS'],
                        [vaultKey: 'HARBOR-USERNAME', envVar: 'HARBOR_USERNAME'],
                        [vaultKey: 'HARBOR-SECRET', envVar: 'HARBOR_SECRET'],
                        [vaultKey: 'HARBOR-DOMAIN', envVar: 'HARBOR_DOMAIN'],
                    ]]]]) {
                        sh """
                        docker login -u '${HARBOR_USERNAME}' -p '${HARBOR_SECRET}' ${HARBOR_DOMAIN}
                        docker push ${HARBOR_DOMAIN}/datawords/promtail:vpc
                        docker push ${HARBOR_DOMAIN}/datawords/promtail:public
                        """
                    }
                }
            }
        }
    }
}
