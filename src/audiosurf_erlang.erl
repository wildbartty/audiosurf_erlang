-module(audiosurf_erlang).

-export([]).

-compile(export_all).

dumpty() ->
    {ok, Ret} = file:read_file("engine/Support/Dumpty.cgr"),
    Ret.

hinter() ->
    {ok, Ret} = file:read_file("engine/Support/Hinter.cgr"),
    Ret.

friendmanager() ->
    {ok, Ret} = file:read_file("engine/Support/FriendManager.cgr"),
    Ret.

ninja() ->
    {ok, Ret} = file:read_file("engine/Actors/NinjasLittleHelper.cgr"),
    Ret.    

parse(Binary) ->
    First = parse_tag(Binary),
    continue_tag(First).

debug_parse(<<"CHES", _Rest/binary>> = Binary) ->
    parse_tag(Binary);
debug_parse(Binary) ->
    parse_tag(Binary).

parse_tag(Binary) ->
    <<Name:4/binary,Size0:32/little, Rest/binary>> = Binary,
    IsEmpty = check_empty(Size0),
    if IsEmpty ->
            Data = <<>>,
            Size = 0,
            <<_:4/binary, Tail/binary>> = Binary;
       true ->
            Size = Size0,
            <<Data:Size/binary, Tail/binary>> = Rest
    end,
    {Name, Size, Data, Tail}.

check_empty(Size) ->
    Bin = binary:encode_unsigned(Size),
    if byte_size(Bin) == 4 -> 
            <<_:24, A:8>> = Bin,
            A > 0;
       true ->
            false
    end.

continue_tag({Tag, Size, Data, <<>>}) ->
    [{Tag, Size,  Data}];
continue_tag({Tag, Size, Data, Rest}) ->
    [{Tag, Size, Data} | continue_tag(debug_parse(Rest))].

xor_binary(Binary) ->
    Calc = fun(X) ->
                   X bxor 4
           end,
    List = binary:bin_to_list(Binary),
    Xored = lists:map(Calc, List),
    binary:list_to_bin(Xored).
