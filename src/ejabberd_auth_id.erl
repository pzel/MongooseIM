-module(ejabberd_auth_id).

%% External exports
-behaviour(ejabberd_gen_auth).
-export([start/1,
         stop/1,
         set_password/3,
         authorize/1,
         try_register/3,
         dirty_get_registered_users/0,
         get_vh_registered_users/1,
         get_vh_registered_users/2,
         get_vh_registered_users_number/1,
         get_vh_registered_users_number/2,
         get_password/2,
         get_password_s/2,
         does_user_exist/2,
         remove_user/2,
         remove_user/3,
         store_type/1
        ]).

-export([scram_passwords/0]).

%% Internal
-export([check_password/3,
         check_password/5]).

-include("mongoose.hrl").
-include("scram.hrl").

start(_) -> ok.
stop(_) -> ok.
update_reg_users_counter_table(_Server) -> ok.
store_type(_Server) -> ok.
authorize(Creds) ->
    ejabberd_auth:authorize_with_check_password(?MODULE, Creds).
check_password(LUser, _LServer, Password) ->
    LUser == Password.
check_password(LUser, _LServer, Password, _Digest, _DigestGen) ->
    LUser == Password.
set_password(_LUser, _LServer, _Password) -> ok.
try_register(_LUser, _LServer, _Password) -> ok.
dirty_get_registered_users() -> [].
get_vh_registered_users(_LServer) -> [].
get_vh_registered_users(_,_) -> [].
get_vh_registered_users_number(_) -> 0.
get_vh_registered_users_number(_,_) -> 0.
get_password(LUser, _LServer) -> LUser.
get_password_s(LUser, _LServer) -> LUser.
does_user_exist(_LUser, _LServer) -> true.
remove_user(_LUser, _LServer) -> ok.
remove_user(_LUser, _LServer, _Password) -> ok.
delete_scram_password(_US, _LServer, _Password, _Scram) -> ok.
delete_password(_US, _LServer) -> ok.
scram_passwords() -> ok.
