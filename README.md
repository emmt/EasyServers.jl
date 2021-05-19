# Simple TCP/IP server in Julia

This package is to facilitate running TCP/IP servers in [Julia][julia-url] code.


## Usage

To use the `EasyServers` package, call:

```julia
using EasyServers
```

which provides the method `runserver`.  To run a server accepting connections
on socket `srv` with function `f` to handle client connections, call:

```julia
runserver(srv, f)
```

This will accept connections from all clients and manage to have `f(sock)`
repeatedly called by an asynchronous task to process requests from any socket
`sock` connected to a client.

The call `f(sock)` shall return a symbolic result, in particular: `:continue`
to continue processing client requests or `:quit` if the server is asked to
quit.  If anything else than `:continue` is returned, the client connection is
closed if not yet done.  If `:quit` is returned, the server and all client
connections are closed and the `runserver` function returns.  All these
connections are also closed in case of exception.

The server socket may be automatically created if `runserver` is called as:

```julia
runserver([addr=ip"127.0.0.1",] port, f; kwds...)
```

with `addr` and `port` the address and port number to be listened by the server
and `kwds...` the keywords to pass to the `Sockets.listen` method.


To run several servers in parallel (asynchronously), call `runserver` with the
`@async` macro:

```julia
@async runserver(args...; kwds...)
```


## Installation

`EasyServers` is not yet an [offical Julia
package](https://pkg.julialang.org/) but its installation can be as easy as:

```julia
… pkg> add https://github.com/emmt/EasyServers.jl
```

where `… pkg>` stands for the package manager prompt (the ellipsis `…` denotes
your current environment).  To start Julia's package manager, launch Julia and,
at the [REPL of
Julia](https://docs.julialang.org/en/stable/manual/interacting-with-julia/),
hit the `]` key; you should get the above `… pkg>` prompt.  To revert to
Julia's REPL, just hit the `Backspace` key at the `… pkg>` prompt.

To install `EasyServers` in a Julia script, write:

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/emmt/EasyServers.jl",
                    rev="master"));
```

This also works from the Julia REPL.

In any cases, you may use the URL `git@github.com:emmt/EasyServers.jl` if you
want to use `ssh` instead of HTTPS.


[doc-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[doc-dev-url]: https://emmt.github.io/EasyServers.jl/dev

[license-url]: ./LICENSE.md
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat

[travis-img]: https://travis-ci.org/emmt/EasyServers.jl.svg?branch=master
[travis-url]: https://travis-ci.org/emmt/EasyServers.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/github/emmt/EasyServers.jl?branch=master
[appveyor-url]: https://ci.appveyor.com/project/emmt/EasyServers-jl/branch/master

[coveralls-img]: https://coveralls.io/repos/github/emmt/EasyServers.jl/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/emmt/EasyServers.jl?branch=master

[codecov-img]: https://codecov.io/gh/emmt/EasyServers.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/emmt/EasyServers.jl

[fitsio-url]: https://github.com/JuliaAstro/FITSIO.jl
[fitsio-url]: https://github.com/JuliaAstro/CFITSIO.jl
[julia-url]: http://julialang.org/
[libcfitsio-url]: http://heasarc.gsfc.nasa.gov/fitsio/