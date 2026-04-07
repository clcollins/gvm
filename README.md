# gvm — Go Version Manager

GVM provides an interface to manage Go versions.

> **Note:** This is a fork of [moovweb/gvm](https://github.com/moovweb/gvm), which was abandoned in August 2023 (last commit: 2023-08-14). The upstream repository has had no maintenance, review activity, or response to pull requests since then. This fork is independently maintained by [Chris Collins](https://github.com/clcollins).
>
> Originally created by Josh Bussdieker while working at [Moovweb](https://www.moovweb.com), and previously maintained by [Benjamin Knigge](https://github.com/BenKnigge).

Pull requests and other contributions are welcome.

Features
========
* Install/Uninstall Go versions with `gvm install [tag]` where tag is "go1.22.5", "go1.23rc1", or "tip"
* List added/removed files in GOROOT with `gvm diff`
* Manage GOPATHs with `gvm pkgset [create/use/delete] [name]`. Use `--local` as `name` to manage repository under local path (`/path/to/repo/.gvm_local`).
* List latest release tags with `gvm listall`. Use `--all` to list weekly as well.
* Cache a clean copy of the latest Go source for multiple version installs.
* Link project directories into GOPATH

Installing
==========

To install:

1.  Install [Bison](https://www.gnu.org/software/bison/) (only needed if building Go from source):

    ```
    sudo apt-get install bison
    ```

1.  Install gvm:

    ```
    bash < <(curl -s -S -L https://raw.githubusercontent.com/clcollins/gvm/main/binscripts/gvm-installer)
    ```

Or if you are using zsh just change `bash` with `zsh`

Installing Go
=============

The quickest way to install a Go version is with the `--prefer-binary` flag, which downloads a precompiled binary from go.dev and only falls back to source compilation if no binary is available for your platform:

    gvm install go1.22.5 --prefer-binary
    gvm use go1.22.5 [--default]

Once this is done Go will be in the path and ready to use. $GOROOT and $GOPATH are set automatically.

Additional options can be specified when installing Go:

    Usage: gvm install [version] [options]
        -s,  --source=SOURCE      Install Go from specified source.
        -n,  --name=NAME          Override the default name for this version.
        -pb, --with-protobuf      Install Go protocol buffers.
        -b,  --with-build-tools   Install package build tools.
        -B,  --binary             Only install from binary.
             --prefer-binary      Attempt a binary install, falling back to source.
        -h,  --help               Display this message.

### Compiling Go from Source

Go 1.5+ removed the C compilers from the toolchain and [replaced][compiler_note] them with one written in Go. This means you need an existing Go installation to compile from source. Each Go version requires a recent-enough bootstrap compiler (typically within the last two major releases).

The simplest bootstrap path:

```
gvm install go1.17.13 -B
gvm use go1.17.13
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.22.5
```

### A Note on ARMv6 and ARMv7 architectures (32 bit)
Binary versions for ARMv6 architecture are available [starting from Go 1.6](https://go.dev/dl/#go1.6). So, it is necessary to bootstrap with an existing binary version, then it will be possible compiling other versions. For instance, to bootstrap a setup, version `1.21.0` may be used:

```
gvm install go1.21.0 -B
gvm use go1.21.0
```

And then, compile any other version (including older ones):

```
gvm install go1.22.5
```

[compiler_note]: https://docs.google.com/document/d/1OaatvGhEAq7VseQ9kkavxKNAfepWy2yhPUBs96FGV28/edit

List Go Versions
================
To list all installed Go versions (The current version is prefixed with "=>"):

    gvm list

To list all Go versions available for download:

    gvm listall

Uninstalling
============
To completely remove gvm and all installed Go versions and packages:

    gvm implode

If that doesn't work see the troubleshooting steps at the bottom of this page.

Mac OS X Requirements
====================
 * Install Xcode Command Line Tools from the App Store.

```
xcode-select --install
```

Linux Requirements
==================

Debian/Ubuntu
==================
    sudo apt-get install curl git make binutils bison gcc build-essential

Redhat/Centos/Fedora
==================

    sudo dnf install curl git make bison gcc glibc-devel

FreeBSD Requirements
====================

    sudo pkg_add -r bash
    sudo pkg_add -r git

Vendoring Native Code and Dependencies
==================================================
GVM supports vendoring package set-specific native code and related
dependencies, which is useful if you need to qualify a new configuration
or version of one of these dependencies against a last-known-good version
in an isolated manner.  Such behavior is critical to maintaining good release
engineering and production environment hygiene.

As a convenience matter, GVM will furnish the following environment variables to
aid in this manner if you want to decouple your work from what the operating
system provides:

1. ``${GVM_OVERLAY_PREFIX}`` functions in a manner akin to a root directory
  hierarchy suitable for auto{conf,make,tools} where it could be passed in
  to ``./configure --prefix=${GVM_OVERLAY_PREFIX}`` and not conflict with any
  existing operating system artifacts and hermetically be used by your
  workspace.  This is suitable to use with ``C{PP,XX}FLAGS and LDFLAGS``, but you will have
  to manage these yourself, since each tool that uses them is different.

2. ``${PATH}`` includes ``${GVM_OVERLAY_PREFIX}/bin`` so that any tools you
  manually install will reside there, available for you.

3. ``${LD_LIBRARY_PATH}`` includes ``${GVM_OVERLAY_PREFIX}/lib`` so that any
  runtime library searching can be fulfilled there on FreeBSD and Linux.

4. ``${DYLD_LIBRARY_PATH}`` includes ``${GVM_OVERLAY_PREFIX}/lib`` so that any
  runtime library searching can be fulfilled there on Mac OS X.

5. ``${PKG_CONFIG_PATH}`` includes ``${GVM_OVERLAY_PREFIX}/lib/pkgconfig`` so
  that ``pkg-config`` can automatically resolve any vendored dependencies.

Recipe for success:

    gvm use go1.22
    gvm pkgset use current-known-good
    # Let's assume that this includes some C headers and native libraries, which
    # Go's CGO facility wraps for us.  Let's assume that these native
    # dependencies are at version V.
    gvm pkgset create trial-next-version
    # Let's assume that V+1 has come along and you want to safely trial it in
    # your workspace.
    gvm pkgset use trial-next-version
    # Do your work here replicating current-known-good from above, but install
    # V+1 into ${GVM_OVERLAY_PREFIX}.

See examples/native for a working example.

Troubleshooting
===============
Sometimes especially during upgrades the state of gvm's files can get mixed up. This is mostly true for upgrade from older version than 0.0.8. Changes are slowing down and a LTR is imminent. But for now `rm -rf ~/.gvm` will always remove gvm. Stay tuned!
