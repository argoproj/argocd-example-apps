node {
    stage('Start argocd') {
        withKubeConfig(credentialsId: 'aws-eksctl-kubeconfig', serverUrl: '') {
            withCredentials([usernamePassword(credentialsId: 'argocd-devops-lab', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {

            sh"""
            kubectl port-forward svc/argocd-server -n argocd 8080:443&
            sh 'argocd login 127.0.0.1:8080 --insecure --username $USERNAME --password $PASSWORD'            
            argocd app list
            """
            }
        }       
    }
    
    stage('Create app') {
        withKubeConfig(credentialsId: 'aws-eksctl-kubeconfig', serverUrl: '') {
            sh """
            argocd app create prod-kustomize-guestbook \
            --repo https://github.com/radtac-craft/argocd-example-apps.git \
            --path kustomize-guestbook/overlays/prod \
            --dest-server https://kubernetes.default.svc \
            --dest-namespace prod-kustomize-guestbook
            """
            sh 'argocd app sync prod-kustomize-guestbook'
            sh 'argocd app wait prod-kustomize-guestbook --sync'
        }
    }       
        
    stage('Verify app') {
        withKubeConfig(credentialsId: 'aws-eksctl-kubeconfig', serverUrl: '') {
            sh 'argocd app list'
        }               
    }
}
