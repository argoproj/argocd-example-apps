node {
    stage('SCM checkout') {
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/radtac-craft/argocd-example-apps.git']]])
    }

    stage('Start argocd') {
        withKubeConfig(credentialsId: 'aws-eksctl-kubeconfig', serverUrl: '') {
            // sh 'kubectl get all'
            sh 'kubectl port-forward svc/argocd-server -n argocd 8080:443&'
            // sh 'argocd login 127.0.0.1:8080'
            sh 'argocd login 127.0.0.1:8080 --config /Users/mac/.argocd/config --insecure --username admin --password admin'
            sh 'argocd app list'
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
