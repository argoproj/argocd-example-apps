node {
   timestamps{
     properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '3', numToKeepStr: '7'))])

    stage('Start argocd') {
        withKubeConfig(credentialsId: 'aws-eksctl-kubeconfig', serverUrl: '') {
            withCredentials([usernamePassword(credentialsId: 'argocd-devops-lab', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
//               sh"""
               sh 'kubectl port-forward svc/argocd-server -n argocd 8080:443&'
               sh 'argocd logout 127.0.0.1:8080'
//               sh 'echo $PASSWORD'
//               sh"""
//               echo $PASSWORD
//               """
               sh 'argocd login 127.0.0.1:8080 --insecure --username $USERNAME --password $PASSWORD'
               sh 'argocd app list'
//               """
            }
     }       
    }   

      stage('Create app') {
        withKubeConfig(credentialsId: 'aws-eksctl-kubeconfig', serverUrl: '') {
            sh """
            argocd app create ${env.BRANCH_NAME}-kustomize-guestbook \
            --repo https://github.com/radtac-craft/argocd-example-apps.git \
            --path kustomize-guestbook/overlays/${env.BRANCH_NAME} \
            --dest-server https://kubernetes.default.svc \
            --dest-namespace ${env.BRANCH_NAME}-kustomize-guestbook
            """
            sh 'argocd app sync $BRANCH_NAME-kustomize-guestbook'
            sh 'argocd app wait $BRANCH_NAME-kustomize-guestbook --sync'
        }
    }       
        
    stage('Verify app') {
        withKubeConfig(credentialsId: 'aws-eksctl-kubeconfig', serverUrl: '') {
            sh 'argocd app list'
        }               
    }
}
}