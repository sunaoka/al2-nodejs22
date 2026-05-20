# syntax=docker/dockerfile:1
# check=error=true
ARG PLATFORM
FROM --platform=$PLATFORM public.ecr.aws/amazonlinux/amazonlinux:2 AS base

RUN <<EOT sh -ex
  yum -y update

  amazon-linux-extras install python3.8

  yum install -y \
      gcc10 \
      gcc10-c++ \
      openssl-devel \
      rpm-build
EOT

FROM base

CMD ["rpmbuild", "-ba", "--clean", "/root/rpmbuild/SPECS/nodejs.spec"]
