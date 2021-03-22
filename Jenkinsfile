pipeline {
  agent any
  stages {
      stage('Check out') {
      agent any
      steps {
        checkout scm
            }
        }
    stage('Deploy to Helm Chart') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-qas-labs', passwordVariable: 'gitpass', usernameVariable: 'gituser')]) {
          sh "git clone https://$gituser:$gitpass@github.com/byangtri/argocd-example-apps.git"
           sh "git config --global user.email 'b.yang@ext.tricentis.com'"
           sh "git config --global user.name 'brandon'"
           dir("argocd-example-apps") {
            sh "cd helm-guestbook && sed -i 's+0.1+0.2+g' values.yaml"
            sh "git commit -am 'Publish new version' && git push || echo 'update version'"
           }
        }
       }
     }
   }
 }