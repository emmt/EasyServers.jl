module TestingEasyServers

using Test
using Sockets
using EasyServers
using Base: IOError

# a simple echo callback
function echo(sock::TCPSocket)
    req = readline(sock, keep=false)
    println(sock, "ok: ", req)
    req == "quit" ? :quit : :continue
end

const SendError = (VERSION < v"1.1" ? ArgumentError : IOError)

tryconnect(port::Integer; kwds...) =
    tryconnect(Sockets.localhost, port; kwds...)

function tryconnect(addr, port::Integer; secs::Real=5.0, verb::Bool=false)
    tmax = max(Float64(secs), 0.0)
    Δt = 0.001
    tsum = 0.0
    while true
        sock = try
            connect(addr, port)
        catch ex
            isa(ex, IOError) || rethrow(ex)
            nothing
        end
        if sock === nothing && tsum < tmax
            verb && println(
                stderr, "connection failed, $(tmax - tsum) seconds remaining")
            sleep(min(Δt, tmax - tsum))
            tsum += Δt # do not add actual delay to avoid rounding errors
            Δt *= 2
        else
            return sock
        end
    end
end

@testset "Simple server" begin
    # Create the server ourself but with an automatic port number.
    port, server = listenany(0)
    @async runserver(server, echo)
    sock = tryconnect(port; secs=10.0)
    @test isa(sock, TCPSocket)
    println(sock, "hello")
    @test readline(sock; keep=false) == "ok: hello"
    @test isopen(sock)
    println(sock, "quit")
    @test readline(sock; keep=false) == "ok: quit"
    @test readline(sock; keep=false) == ""
    @test_throws SendError println(sock, "are you there?")
    @test isopen(server) == false

    # Resuse the same port number.
    @async runserver(port, echo)
    sock = tryconnect(port; secs=10.0)
    @test isa(sock, TCPSocket)
    println(sock, "hello")
    @test readline(sock; keep=false) == "ok: hello"
    @test isopen(sock)
    println(sock, "quit")
    @test readline(sock; keep=false) == "ok: quit"
    @test readline(sock; keep=false) == ""
    @test_throws SendError println(sock, "are you there?")
end

end # module
