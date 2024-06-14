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

The test script has the main objective of running the tests defined in your applicastion and reporting back if these test were run successfully.
To be able to run the test, your application will be first compiled with `monkeyc` then attaching the simulator, it will run all tests using the `monkeydo`
command.

The script has the following optional parameters:

- `--device=DEVICE_ID`: the id of one device supported by your application, as listed in your `manifest.xml` file, that will be used to run the tests. If you don't specify a device id, it will default to `fenix7`.
- `--type-check-level=LEVEL`: the type check level to use when building the application. By default `Strict` type checking is used but you can change this by using any of the values described [here](https://developer.garmin.com/connect-iq/monkey-c/monkey-types/): 0 = Silent | 1 = Gradual | 2 = Informative | 3 = Strict [default].
- `--certificate=CERTIFICATE`: [!!! NOT YET AVAILABLE !!!] the certificate that will be used to compile the application. The certificate needs to be passed in a base64 encoded format. On a Linux box it is as simple as running `base64 /path/to/my/cert`, and pasting the output in this parameter. If you don't provide one, a temporary certificate will be generated automatically.

## Usage: The build script (/scripts/build.sh)

NOT AVAILABLE! I still have to write this. The idea is to create a project release by compiling the application for all devices and making the package ready for being uploaded to the ConnectIQ store.

## Notes

- Document explaining how to store certificates in github: https://josh-ops.com/posts/storing-certificates-as-github-secrets/

## Contributions

Yes, please.

## Credits

This repo is a fork of the [matco/connectiq-tester](https://github.com/matco/connectiq-tester) repo.

## Copyright

All the resources contained in the archive `devices.tar.gz` are the property of Garmin. These resources have been fetched from the Garmin website and have been included in this repository to facilitate the creation of the Docker image.
