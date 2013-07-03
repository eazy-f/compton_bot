-module(cbot_srv).

-behaviour(gen_server).

-export([start_link/2]).
-export([init/1, terminate/2, handle_info/2]).

-record(state, { game_server, name, state :: login | game } ).

start_link(Hostname, Port) ->
    gen_server:start_link(?MODULE, { Hostname, Port }, []).

init({ Hostname, Port }) ->
    io:format("connecting to ~s:~b~n", [Hostname, Port]),
    {ok, Sock} = gen_tcp:connect(Hostname, Port, [ binary, { packet, 0 } ]),
    { ok, #state{ game_server = Sock, state = login } }.

handle_info( {tcp, Socket, Data}, #state{game_server = Socket} = State)
  when State#state.state == login ->
    io:format("recv:~w~n", [Data]),
    Name = "nigga",
    ok = gen_tcp:send(Socket, hello_msg(Name)),
    { noreply, State#state{ name = Name, state = game } };
handle_info( {tcp, Socket, Data}, #state{game_server = Socket} = State)
  when State#state.state == game ->
    io:format("recv:~w~n", [Data]),
    ok = gen_tcp:send(Socket, make_turn()),
    { noreply, State }.

terminate(_, _) ->
    ok.

hello_msg(Name) ->
    mochijson2:encode({ struct, [ { "name", Name } ] }).

make_turn() ->
    mochijson2:encode({ struct, [ { "optionNumber", 0 } ] }).
