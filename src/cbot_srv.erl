-module(cbot_srv).

-behaviour(gen_server).

-export([start_link/3]).
-export([init/1, terminate/2, handle_info/2]).

-record(state, {
    host,
    port,
    name,
    sock,
    state :: disconnected | login | game
}).

start_link(Hostname, Port, Name) ->
    gen_server:start_link(?MODULE, { Hostname, Port, Name }, []).

init({ Hostname, Port, Name }) ->
    self() ! connect,
    { ok, #state{
              state = disconnected,
              host = Hostname,
              port = Port,
              name = Name
    }}.

handle_info( connect, #state{ host = Hostname, port = Port } = State )
  when State#state.state == disconnected ->
    Opts = [ binary, { packet, line }, {buffer, ( 1024 * 1024 ) } ],
    {ok, Sock} = gen_tcp:connect(Hostname, Port, Opts),
    { noreply, State#state{ sock = Sock, state = login } };

handle_info( {tcp, Socket, _Data}, #state{ sock = Socket, name = Name } = State)
  when State#state.state == login ->
    ok = gen_tcp:send(Socket, hello_msg(Name)),
    { noreply, State#state{ name = Name, state = game } };

handle_info( {tcp, Socket, Data}, #state{sock = Socket} = State)
  when State#state.state == game ->
    case make_turn(Data, State#state.name) of
        { reply, Reply } ->
            ok = gen_tcp:send(Socket, Reply);
        _ ->
            ok
    end,
    { noreply, State };

handle_info( {tcp_closed, Socket}, #state{sock = Socket} = State) ->
    self() ! connect,
    { noreply, State#state{ state = disconnected } }.

terminate(_, _) ->
    ok.

hello_msg(Name) ->
    mochijson2:encode({ struct, [ { "name", Name } ] }).

make_turn(GameState, Me) ->
    { struct, State } = mochijson2:decode(GameState),
    case proplists:get_value(<<"activePlayer">>, State) of
        Me ->
            Cmd = mochijson2:encode({ struct, [ { "optionNumber", 0 } ] }),
            { reply, Cmd };
        _ ->
            noreply
    end.
