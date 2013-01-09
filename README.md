# BOOTSTRAPPER

Bootstrapper is an in-progress replacement for Chef's `knife bootstrap`.
As of now, it can install chef on a remote box using ssh password auth,
though most of the features/options of `knife bootstrap` are not wired in.

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

## Using It

Use of this code is only recommended for users with experience writing
knife plugins, on a test/development basis only.

Knife currently supports only a single user plugins directory (more
plugins can be installed as rubygems, though this code is not ready for
that kind of release). To install the `knife strap` command, clone this
repo to `~/.chef/plugins/bootstrapper`, then create a stub plugin in
`~/.chef/plugins/knife/strap.rb`:

    load File.expand_path("../../bootstrapper/bin/strap.rb", __FILE__)

## License:
Apache 2 License.

