# fschk

List persistence items on macOS.

This app is an attempt to wrap things written by 
[Csaba Fitzi](https://twitter.com/theevilbit) in 
[Beyond good ol' LaunchAgents](https://theevilbit.github.io/beyond/).

## Done

- [x] Launch
- [x] LSLoginItems
- [x] StartupItems
- [ ] Paths

## Installation

```sh
$ make
$ sudo make install
```
or
```sh
$ brew tap x13a/tap
$ brew install x13a/tap/fschk
```

## Usage

```text
USAGE: fschk [--version]

OPTIONS:
  --version               Print version and exit
  -h, --help              Show help information.
```

## Example

```sh
~
❯ [sudo] fschk
Launch (6)
----------

path: /Library/LaunchDaemons/com.docker.vmnetd.plist
prog: /Library/PrivilegedHelperTools/com.docker.vmnetd
args: ["/Library/PrivilegedHelperTools/com.docker.vmnetd"]
...
```
