FROM debian:buster-slim as kustomize

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN curl --silent --location https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz | tar xz -C /tmp \
    && mv /tmp/kubeval /usr/local/bin \
    && chmod +x /usr/local/bin

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
   && chmod +x ./kubectl \
   && mv ./kubectl /usr/local/bin/kubectl

# Install kustomize
# kubectl still ships w/ kustomize v2.0.3 (https://github.com/kubernetes/kubectl/blob/master/Godeps/Godeps.json) which
# is _slightly_ outdated. More recent kustomize releases are incompatible though
# c.f. https://github.com/kubernetes-sigs/kustomize/issues/1342
# and https://github.com/kubernetes-sigs/kustomize/issues/1500
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v2.0.3/kustomize_2.0.3_linux_amd64 -o /usr/local/bin/kustomize \
    && chmod +x /usr/local/bin/kustomize

COPY ./scripts/kustomize-overlays.sh .
RUN chmod u+x /kustomize-overlays.sh

WORKDIR /test/
RUN mkdir manifests


FROM kustomize AS deployment

ENTRYPOINT [ "/kustomize-overlays.sh", "/test/manifests", "checkimage" ]

FROM kustomize AS cibuild

COPY ./scripts/kustomize-projects.sh /
RUN chmod u+x /kustomize-projects.sh

ENTRYPOINT [ "/kustomize-projects.sh", "/test/manifests" ]
