FROM argoproj/argocd:latest

USER root

RUN apt-get update && \
    apt-get install -y \
        curl \
        python3-pip && \
    apt-get clean && \
    pip3 install pipenv

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn
RUN yarn global add npm cdk8s-cli

USER argocd
