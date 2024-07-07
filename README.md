# ConnectIQ Builder

ConnectIQ Builder is a Docker image that can be used to test and build ConnectIQ applications.

## Description

The docker image is always published in the [package repository](https://github.com/adamjakab/connectiq-builder/pkgs/container/connectiq-builder) and it can be pulled from the Github Container Repository (ghcr.io):

```bash
docker pull ghcr.io/adamjakab/connectiq-builder:latest
```

The image contains:

- the ConnectIQ SDK version `7.1.1`
- the device files retrieved on `2024-06-11`
- the scripts directory allowing you to build and test your ConnectIQ app

## Usage

The generic usage of the container with any of the below described scripts is as follows:

**docker run -v `[local app path]`:`[container app path]` -w `[container app path]` ghcr.io/adamjakab/connectiq-builder:latest `[script to run]` `[script parameters]`**

The `-v` flag binds the folder containing your application to the folder in the container. So, `[local app path]` needs to be substituted with the path of your ConnectIQ application and `[container app path]` can be any path where the same ConnectIQ application will be available inside the container.

The `-w` flag sets the working directory of the container and it must be pointing to the same folder which was chosen above: `[container app path]`

The `[script to run]` and the `[script parameters]` parameters are described in detail below for each script. Putting this all together, an example of how your command will look like:

```bash
docker run -v /code/my_app:/app -w /app ghcr.io/adamjakab/connectiq-builder:latest /scripts/info.sh
```

## Usage: The info script (/scripts/info.sh)

This script has no paramater and being the default script, it can be run even without specifying it in the `[script to run]` option.
It will return some basic information about the container and about the application itself. This script is mostly used for debugging.

Example:

```bash
docker run -v /code/my_app:/app -w /app ghcr.io/adamjakab/connectiq-builder:latest /scripts/info.sh
# or
docker run -v /code/my_app:/app -w /app ghcr.io/adamjakab/connectiq-builder:latest
```

## Usage: The test script (/scripts/test.sh)

The test script has the main objective of running the tests defined in your application and reporting back if these test were run successfully.
To be able to run the test, your application will be first compiled with `monkeyc` then attaching the simulator, it will run all tests using the `monkeydo`
command.

The script has the following optional parameters:

- `--device=DEVICE_ID`: the id of one of the devices supported by your application (as listed in your `manifest.xml` file). If you don't specify a device id, it will default to `fr235`.
- `--devices=DEVICE_ID_LIST`: a comma separated list of device ids. If you pass this parameter the single `--device` parametrer will be ignored. This parameter is only used when running the test script. This parameter was introduced to optimize testing and intesd of firing up a container for each device, it is possible to execute tests for all deviced using a single container.
- `--type-check-level=LEVEL`: the type check level to use when building the application. By default `Informative` type checking is used but you can change this by using any of the values described [here](https://developer.garmin.com/connect-iq/monkey-c/monkey-types/): 0 = Silent | 1 = Gradual | 2 = Informative [default] | 3 = Strict.
- `--certificate-path=PATH`: The path of the certificate in the container. If you don't provide one, a temporary certificate will be generated automatically.

## Usage: The build script (/scripts/package.sh)

The package script will package your application into a single file ready to be uploaded to ConnectIQ Store.
The script will run the `monkeyc` compiler with the `--package-app` and the `--release` options.

The script has the same parameters as the test script with the following notes:

- `--certificate-path=PATH`: This is a required parameter here. Hint: you can use additional `-v` or `--volume` parameters on the `docker run` command to mount a specific folder where you keep your certificate.
- `--package-name=NAME`: This optional parameter allows you to define how the package should be named (the file name). If you don't define it, your package will be called `package.iq`.

## Developers

When working locally, you will first want to build / rebuild the docker image:

```bash
docker build --tag adamjakab/connectiq-builder:latest .
```

and then run any of the scripts by someting similar to this:

```bash
docker run --rm -v /mnt/secrets/ConnectIQ/certs:/certificate -v /mnt/code/Garmin/myApp:/_build_ -w /_build_ adamjakab/connectiq-builder:latest /scripts/package.sh --type-check-level=2 --certificate-path=/certificate/my_developer_key --package-name=myApp_v1.2.3.iq
```

## Supported SDKs

- 7.2.1
- 7.2.0
- 7.1.1
- 7.1.0
- 6.4.2

## Contributions

Yes, please.

## Credits

This repo is a fork of the [matco/connectiq-tester](https://github.com/matco/connectiq-tester) repo.

## Copyright

All the resources contained in the archive `devices.tar.gz` are the property of Garmin. These resources have been fetched from the Garmin website and have been included in this repository to facilitate the creation of the Docker image.
