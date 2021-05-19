module EasyServers

export
    runserver

using Sockets
using Sockets: TCPServer, TCPSocket
using Base: IOError

"""
    runserver(srv, f)

runs TCP server socket `srv` with function `f` to handle client connections.

The server accepts connections from clients and manages to have `f(sock)`
repeatedly called by an asynchronous task to process requests from any socket
`sock` connected to a client.  The call `f(sock)` shall return a symbolic
result, in particular: `:continue` to continue processing client requests or
`:quit` if the server is asked to quit.  If anything else than `:continue` is
returned, the client connection is closed if not yet done.  If `:quit` is
returned, the server and all client connections are closed and the `runserver`
function returns.  All these connections are also closed in case of exception.

The server socket may be automatically created if `runserver` is called as:

     runserver([addr=ip"127.0.0.1",] port, f; kwds...)

with `addr` and `port` the address and port number to be listened by the server
and `kwds...` the keywords to pass to the `Sockets.listen` method.

"""
function runserver(server::TCPServer, callback::Function)
    # The server is eventually closed to quit and make `tryaccept` returns
    # `nothing`.  A `try/catch` block with a `finally` clause is needed to
    # handle exceptions and make sure that all clients and the server are
    # properly closed on return.
    clients = Set{TCPSocket}()
    try
        while true
            sock = tryaccept(server)
            sock === nothing && break
            @async begin
                push!(clients, sock)
                while isopen(sock)
                    status = callback(sock)
                    if status !== :continue
                        # Close server connection to quit.
                        status === :quit && closeifopen(server)
                        break
                    end
                end
                closeifopen(pop!(clients, sock))
            end
        end
    catch ex
        rethrow(ex)
    finally
        closeifopen(server)
        closeall!(clients)
    end
    nothing
end

runserver(port::Integer, args...; kwds...) =
    runserver(Sockets.localhost, port, args...; kwds...)

runserver(addr, port::Integer, args...; kwds...) =
    runserver(listen(addr, port), args...; kwds...)

"""
    sock = tryaccept(server)

attempts to accept a client connection on the given server.  On success, the
result is a socket connection to the client.  If the server connection has been
closed or is closed while waiting for a client, `nothing` is returned.

"""
function tryaccept(server::TCPServer)
    try
        accept(server)
    catch ex
        isopen(server) && rethrow(ex)
        nothing
    end
end

"""
    closeifopen(x)

closes `x` unless it has been closed.

"""
closeifopen(x) = isopen(x) && close(x)

"""
    closeall!(coll)

pops all items from collection `coll` closing them unless already closed.

"""
function closeall!(collection)
    while !isempty(collection)
        closeifopen(pop!(collection))
    end
    nothing
end

end # module
