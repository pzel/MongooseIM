-module(mod_tcp_feed).
%% @doc Pipes all XMPP stanzas to kafka

-behavior(gen_mod).
-export([start/2, stop/1]).
-export([forward_stanza/4]).

-include("mongoose.hrl").
-include("jlib.hrl").
-include("ejabberd_c2s.hrl").

-define(WALLAROO_ENDPOINT, "WALLAROO_TCP_HOSTPORT").
-define(CLIENT, mod_kafka_feed_client).


start(Host, Opts) ->
    start_client(),
    ejabberd_hooks:add(hooks(Host)).

stop(Host) ->
    ejabberd_hooks:delete(hooks(Host)).

hooks(Host) ->
    [{user_send_packet, Host, ?MODULE, forward_stanza, 1}].

-spec forward_stanza(Acc :: map(), From :: jid:jid(),
                     To :: jid:jid(),
                     Packet :: exml:element()) -> map().
forward_stanza(Acc, From, _To, #xmlel{} = Stanza) ->
    BinStanza = exml:to_binary(Stanza),
    BinJid = jid:to_binary(From),
    Event = make_event(BinJid, BinStanza, erlang:system_time(1000)),
    try
        gen_tcp:send(ensure_client(), Event),
        Acc
    catch
        _ -> ?ERROR_MSG("Failed sending message", [Event]),
             Acc
    end.

start_client() ->
    case os:getenv(?WALLAROO_ENDPOINT) of
        false -> error("env var " ++ ?WALLAROO_ENDPOINT ++ " not set");
        HostPort ->
            [Host, Port] = binary:split(l2b(HostPort), <<":">>),
            {ok, Pid} = gen_tcp:connect(b2l(Host), list_to_integer(b2l(Port)), []),
            true = erlang:register(?CLIENT, Pid),
            Pid
    end.

ensure_client() ->
    case whereis(?CLIENT) of
        undefined -> start_client();
        Pid -> Pid
    end.

make_event(BinFrom, BinStanza, POSIXMilliseconds)
  when is_binary(BinFrom), is_binary(BinStanza),
       is_number(POSIXMilliseconds) ->
    Bin = jiffy:encode(#{<<"from">> => BinFrom,
                         <<"stanza">> => BinStanza,
                         <<"ts">> => POSIXMilliseconds}),
    Size = byte_size(Bin),
    <<Size:32, Bin/binary>>.


l2b(L) -> list_to_binary(L).
b2l(B) -> binary_to_list(B).
