pipeline {
  agent any
  stages {
      stage('Check out') {
      agent any
      steps {
        checkout scm
            }
        }
    stage('Deploy to Helm') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-qas-labs', passwordVariable: 'gitpass', usernameVariable: 'gituser')]) {
          sh "git clone https://$gituser:$gitpass@github.com/byangtri/argocd-example-apps.git"
           sh "sudo git config --system user.email 'b.yang@ext.tricentis.com'"
           sh "sudo git config --system user.name 'brandon'"
           dir("argocd-example-apps") {
            sh "cd helm-guestbook && sed -i 's+0.1+0.2+g' values.yaml"
            sh "git commit -am 'Publish new version' && git push || echo 'update version'"
           }
        }
       }
     }
   }
 }