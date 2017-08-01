# Gerrit installer for Debian/Ubuntu

[Gerrit](https://www.gerritcodereview.com/) code review installer package for 
Debian and Ubuntu.

## Getting Started

Please read the [README.Debian](debian/README.Debian) for package-specific 
functionality.

### Installation

#### Installing from PPA
```
add-apt-repository ppa:rjozwik/gerrit
apt update
apt install gerrit
```

#### Installing from *.deb

1. Go to the [Releases](../../releases) tab and download latest DEB package.

2. Install dependencies
```
apt install wget openssh-client openjdk-8-jre-headless
```

3. Install Gerrit
```
dpkg --install gerrit_XXX_all.deb
```

### Configuration

Edit `/etc/gerrit/gerrit.config` to change Gerrit daemon configuration. There 
is also `/etc/default/gerrit` for settings related to the init script.

### Startup

There is an init script provided as `/etc/init.d/gerrit`. Run it without 
arguments for usage instructions.

