# ConnectIQ Builder

ConnectIQ Builder is a Docker image that can be used to test and build ConnectIQ applications.

The image contains ConnectIQ SDK version `7.1.1` and all the device files retrieved on `2024-06-11`.

## --- NOTE: UNDER DEVELOPMENT - DO NOT USE! ---

## Usage

The image requires to bind the code of your application to a folder in the container and to set the working directory of the container to the same folder.

The Docker command has the following optional parameters:

- --device=DEVICE_ID: the id of one device supported by your application, as listed in your `manifest.xml` file, that will be used to run the tests. If you don't specify a device id, it will default to `fenix7`.
- --certificate-path=CERT_PATH: the path of the certificate that will be used to compile the application relatively to the folder of your application. If you don't provide one, a temporary certificate will be generated automatically.
- --type-check-level=LEVEL: the type check level to use when building the application. By default `Strict` type checking is used but you can change this by using any of the values described [here](https://developer.garmin.com/connect-iq/monkey-c/monkey-types/): 0 = Silent | 1 = Gradual | 2 = Informative | 3 = Strict [default].

The simplest command is the following:

```
docker run -v /path/to/your/app:/app -w /app ghcr.io/matco/connectiq-tester:latest
```

The flag `-v` binds the folder containing your application to the `app` folder in the container. The flag `-w` tells the container to work in this repository (it is the working directory). It is required that the working directory matches the path where you bound your application in the container. With this command, a temporary certificate will be created, and the application will be tested using a Fenix 7.

### Note on deprecated positional arguments

In previous versions positional arguments were used to specify the device and the certificate path. Device was first and certificate path was second. You can still use the docker command with positional arguments but you will receive a warning. In some future version this will be removed and the above described named arguments will be used. If you are using positional arguments, you are advised to change them.

## Examples

If you want to specify a difference device, just run:

```
docker run -v /path/to/your/app:/app -w /app ghcr.io/matco/connectiq-tester:latest --device=venu2
```

In this case, the application will be tested using a Venu 2.

To specify your own certificate, just run:

```
docker run -v /path/to/your/app:/app -w /app ghcr.io/matco/connectiq-tester:latest --device=venu2 --certificate-path=certificate/key.der
```

In this case, the application will be tested using a Venu 2 and the certificate used to compile the application will be `/path/to/your/app/certificate/key.der`.

To relax the type checking when building the application, just run:

```
docker run -v /path/to/your/app:/app -w /app ghcr.io/matco/connectiq-tester:latest --type-check-level=2
```

This will run the compiler with type checking set to Informative, whilst using the default device and an auto-generated certificate.

## Notes

```bash
# Build and publish
docker build --tag adibacsi/connectiq-app-builder:latest .
docker push adibacsi/connectiq-app-builder:latest

# Run in interactive mode
docker run --rm -it adibacsi/connectiq-app-builder:latest

# Run the tester command
docker run --rm -v /mnt/Code/Garmin/iHIIT:/_build_ -w /_build_ adibacsi/connectiq-app-builder:latest /connectiq/bin/tester.sh --device=fr235 --type-check-level=2

```

regarding storing certificates in github: https://josh-ops.com/posts/storing-certificates-as-github-secrets/

## Copyright

All the resources contained in the archive `devices.tar.gz` are the property of Garmin. These resources have been fetched from the Garmin website and have been included in this repository to facilitate the creation of the Docker image.
