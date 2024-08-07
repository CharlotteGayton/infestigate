FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        dotnet-runtime-8.0 \
        dotnet-sdk-8.0 \
        python3 \
        python3-pip \
        software-properties-common \
        wget && \
    apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN . /etc/os-release && \
    wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        powershell && \
    apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN pip install pandas

RUN dotnet tool install --global covenant && \
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.50.1

# This has the effect of pre-populating the trivy cache with the latest vulnerability data,
# although this will likely be out of date by the time the container is run.
ARG TRIVY_CACHE_UPDATE=false
RUN trivy sbom foo.json  || true

WORKDIR /app

COPY analysing_vulnerability_data/scripts/analysing_data.py .
COPY --chmod=+x entrypoint.ps1 .

# These provide well-known mount points for the input and output directories
VOLUME [ "/input" ]
VOLUME [ "/output" ]

ENTRYPOINT [ "pwsh", "-f", "/app/entrypoint.ps1" ]

# Default usage assumes the above volume mount conventions and analysing SBOMs in Covenant's native file format
CMD [ "-SbomPath", "/input", "-OutputPath", "/output", "-ConvertToSpdx" ]