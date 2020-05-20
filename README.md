# hashicorp-ppa

PPA for Hashicorp applications, such as Vagrant and Terraform

## Usage

First export the environment variables with the `$PACKAGE` and `$VERSION` you
want to build the package for:

``` sh
$ export PACKAGE=terraform
$ export VERSION=0.12.24
```

You may also change the architecture and base URL of the packages. The default
values are shown below:

``` sh
$ export BASE_URL=https://releases.hashicorp.com
$ export ARCH=linux_amd64
```

Be sure to import Hashicorp's PGP key in https://www.hashicorp.com/security.
Then download and verify the checksum with:

``` sh
$ make fetch
```

A file will be created with the parameters in the `build/` directory:

``` sh
$ cat build/terraform_0.12.24.vars
# BASE_URL=https://releases.hashicorp.com
# ARCH=linux_amd64
# PACKAGE=terraform
# VERSION=0.12.24
# CHECKSUM=602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11
```

Finally, create the source package files with:

``` sh
$ make build
```
