# Infestigate

Update secrets in workflow

## Container-based Usage

The container is designed to be run as if it were a typical CLI tool and uses convention-based volume mounts to handle inputs and outputs.

### Building
Build the container image:
```
docker build -t infestigate .
```


### Running with defaults
The container's default settings assume you have an SBOM in [Covenant's](https://github.com/patriksvensson/covenant) native format.

Use the following to run the container where you have a Covenant-formatted SBOM in your current working directory.

Running from bash:
```bash
docker run -it -v "$PWD:/input" -v "$PWD/infestigate-output:/output" infestigate
```

Running from PowerShell:
```powershell
docker run -it -v "$($PWD):/input" -v "$($PWD)/infestigate-output:/output" infestigate
```

## Running with custom parameters

The [PowerShell script](./entrypoint.ps1) that acts as the container's entrypoint, supports the following [positional parameters](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/types-of-cmdlet-parameters?view=powershell-7.4#positional-and-named-parameters):

| Position | Parameter Name | Type | Default Value | Description |
|----------|----------------|------|---------------|-------------|
| 0        | SbomPath | /input | string | Path to either a single SBOM file or a directory containing 1 or more SBOM files |
| 1        | OutputPath | /input | string |Path where all outputs will be stored |
| 2        | ConvertToSpdx | false | switch | When specified, the SBOM file is assumed to be in Covenant's native format and will be converted to SPDX format (as required by [Trivy](https://github.com/aquasecurity/trivy)) |

If you already have an SBOM in [SPDX](https://spdx.dev/learn/overview/) format in your current working directory, you should run the container as shown below:

Running from bash:
```bash
docker run -it -v "$PWD:/input" -v "$PWD/infestigate-output:/output" infestigate /input /output
```

Running from PowerShell:
```powershell
docker run -it -v "$($PWD):/input" -v "$($PWD)/infestigate-output:/output" infestigate /input /output
```
