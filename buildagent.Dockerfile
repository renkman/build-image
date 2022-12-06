FROM golang:1.19-buster

ENV AWS_DEFAULT_REGION=eu-central-1 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
       curl \
       unzip \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install jsonnet
ENV GO111MODULE="on"
RUN go install github.com/google/go-jsonnet/cmd/jsonnet@latest \
    && go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest \
    && go install github.com/brancz/gojsontoyaml@latest \
    && rm -rf $GOPATH/{src,pkg}

# Install awscli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip


# Install eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.122.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.22.2/bin/linux/amd64/kubectl \
   && chmod +x ./kubectl \
   && mv ./kubectl /usr/local/bin/kubectl

# Install kustomize
# kubectl still ships w/ kustomize v2.0.3 (https://github.com/kubernetes/kubectl/blob/master/Godeps/Godeps.json) which
# is _slightly_ outdated. More recent kustomize releases are incompatible though
# c.f. https://github.com/kubernetes-sigs/kustomize/issues/1342
# and https://github.com/kubernetes-sigs/kustomize/issues/1500
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v2.0.3/kustomize_2.0.3_linux_amd64 -o /usr/local/bin/kustomize \
    && chmod +x /usr/local/bin/kustomize

# Install aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x ./aws-iam-authenticator \
    && mv ./aws-iam-authenticator /usr/local/bin/

# Install helm
RUN curl --silent --location https://get.helm.sh/helm-v3.2.0-linux-amd64.tar.gz | tar xvz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin
