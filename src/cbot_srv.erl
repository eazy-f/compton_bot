-module(cbot_srv).

-behaviour(gen_server).

-export([start_link/3]).
-export([init/1, terminate/2, handle_info/2]).

-record(state, { game_server, name, state :: login | game } ).

start_link(Hostname, Port, Name) ->
    gen_server:start_link(?MODULE, [Hostname, Port, Name], []).

init([ Hostname, Port, Name ]) ->
    Opts = [ binary, { packet, line }, {buffer, ( 1024 * 1024 ) } ],
    {ok, Sock} = gen_tcp:connect(Hostname, Port, Opts),
    { ok, #state{ game_server = Sock, state = login, name = Name } }.

handle_info( {tcp, Socket, _Data}, #state{game_server = Socket} = State)
  when State#state.state == login ->
    ok = gen_tcp:send(Socket, hello_msg(State#state.name)),
    { noreply, State#state{ state = game } };

handle_info( {tcp, Socket, Data}, #state{game_server = Socket} = State)
  when State#state.state == game ->
    case make_turn(Data, State#state.name) of
        { reply, Reply } ->
            ok = gen_tcp:send(Socket, Reply);
        _ ->
            ok
    end,
    { noreply, State };

handle_info( {tcp_closed, Socket}, #state{game_server = Socket} = State) ->
    { stop, normal, State }.

terminate(_, _) ->
    ok.

hello_msg(Name) ->
    mochijson2:encode({ struct, [ { "name", Name } ] }).

make_turn(GameState, Me) ->
    { struct, State } = mochijson2:decode(GameState),
    case proplists:get_value(<<"activePlayer">>, State) of
        Me ->
            Num = length(proplists:get_value(<<"options">>, State)) - 1,
            Cmd = mochijson2:encode({ struct, [ { "optionNumber", Num } ] }),
            { reply, Cmd };
        _ ->
            noreply
    end.
