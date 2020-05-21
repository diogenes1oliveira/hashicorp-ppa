# hashicorp-ppa

PPA for Hashicorp applications, such as Vagrant and Terraform

No Hashicorp code is hosted here: the package simply downloads the binary
from Hashicorp's website at install time.

The PPA is available at [diogenes1oliveira/hashicorp-ppa](https://launchpad.net/~diogenes1oliveira/+archive/ubuntu/hashicorp-ppa).

<table>
  <tr>
    <td><a href="https://www.terraform.io"><img src="icons/terraform.png" width=270></a></td>
    <td><a href="https://www.packer.io/"><img src="icons/packer.png" width=270></a></td>
    <td><a href="https://www.vagrantup.com/"><img src="icons/vagrant.png" width=270></a></td>
    <td><a href="https://www.vaultproject.io"><img src="icons/vault.png" width=270></a></td>
  </tr>
</table>

## Install

If you're using Ubuntu, install it via PPA with:

``` sh
$ add-apt-repository ppa:diogenes1oliveira/hashicorp-ppa
$ apt update
$ apt install terraform
$ apt install vagrant
```

## Deploying new packages

### Generating the source package files

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

Finally, generate the source package files with:

``` sh
$ make generate
```

This will create the package referencing your Git username and email.

### Building and deploying the package

First build the Docker image for the container in which all the builds
will be executed:

``` sh
$ make docker/build
```

Test the generated package with:

``` sh
$ bats *.bats
```

Then build up the source package, informing your GPG key passphrase:

``` sh
$ make build
```

Finally, send the package to Launchpad with:

``` sh
$ make deploy
```
