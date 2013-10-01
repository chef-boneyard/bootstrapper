# BOOTSTRAPPER

Bootstrapper is an in-progress replacement for Chef's `knife bootstrap`.
It's capable of bootstrapping a host using omnibus packages and running
chef-client on it, however, input validation and error messaging are
minimal. This means that when things go wrong, you may need to read the
code to understand why. If you're uncomfortable with this, you should
probably avoid using it for now.

## Using It

`bootstrapper` is only available via git for now. To install it:

1. git clone
2. bundle install

`bootstrapper` currently does not read any bootstrap definitions by
default (this will change). To see the options available in the default
bootstrap from your git clone:

    bundle exec bin/bootstrap -f lib/bootstrapper/bootstraps/default.rb -h # lists all known boostrap commands
    bundle exec bin/bootstrap -f lib/bootstrapper/bootstraps/default.rb omnibus-unix -h # shows options for omnibus-unix bootstrap


Note that `bootstrapper` is a standalone CLI program. Though it is
intended to be used with Chef, it does not read any standard Chef
configuration files. The only mechanism to set default values is in a
bootstrap definition file. Since this file is pure ruby code, you can
hack in some logic to set the default values if you need to. This
limitation may change in the future.


## Design

### Defining a Bootstrap

The primary interface to _bootstrapper_ is a bootstrap definition file.
This file specifies which components are used to bootstrap a host, and
configures default settings for each component.

A node is bootstrapped by three cooperating components:

#### Transport

Transport is an implementation of some remote command protocol. For Unix
systems, this typically means SSH.

#### Config Generator

The config generator is responsible for generating any credentials and
configuration needed to run Chef on the remote machine.

The default `chef_client` config generator communicates with your Chef
server to create a client identity and node object before the bootstrap
runs, so use of the validator client is avoided.

#### Installer

The installer gets Chef installed on the remote box. The default
installer uses the `install.sh` script to install an Omnibus package.
This may change in the future.

### Command Line

Each bootstrap definition is compiled into a subcommand of the
`bootstrap` command. For example, the default bootstrap definition in
this source tree is named "omnibus_unix", so it is invoked by running
(caveat: all bootstrap files must be loaded explicitly for now, see
above):

    bootstrapper omnibus-unix [options]

Each component declares a set of options that it supports. When a
bootstrap is compiled into a subcommand, support for each option is
added to the CLI, so that any option can be set on a per-invocation
basis.

## Goals

`knife bootstrap` exists and works, so why this?

* Bootstrap nodes without using the validator: By moving client and node
creation up front (before SSH-ing in and running the installer),
authentication issues and naming conflicts are found quickly and can be
resolved ahead of time, automatically. In addition, server-side auditing
is on the roadmap for Chef server, so it's better to use everyone's real
identity than rely on the more-or-less anonymous validator.
* Use SCP to install configuration: The current bootstrap passes all
data in via a single bash command, which means sensitive data is visible
in the argv of the bootstrap process. Bootstrapper, by, contrast, uses
SCP to copy credentials to the remote node.
* Modular design: The current boostrap relies on templated shell scripts
for customization. This results in a ton of copy-pasta'd code, since the
entire bootstrap process must be performed by the resulting script, even
though most users simply wish to customize the install process. By
separating config generation, installation, and SSH session handling,
each piece of functionality can be re-used or customized in isolation.

## License:
Apache 2 License.

