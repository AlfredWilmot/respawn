# A DDS CLI tool for diagnosing DDS networks
# https://github.com/eclipse-cyclonedds/cyclonedds-python?tab=readme-ov-file#command-line-tooling

FROM python:3.10-alpine3.22
RUN <<EOF
apk update
pip install --upgrade pip
pip install cyclonedds=="0.10.5"
EOF
ENTRYPOINT ["cyclonedds"]
