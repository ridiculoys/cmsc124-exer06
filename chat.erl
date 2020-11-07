-module(chat).
-compile(export_all).


init_chat() ->
	Name = io:get_line("Enter your name: "),
	register(user1, spawn(chat, user1, [Name])).


user1(OwnName) ->
	receive
		{user2, User2_Pid, FromUser, Msg} ->
			case Msg == "bye" of
				true ->
					io:format("Your partner disconnected. ~n");
				false ->
					io:format("~p: ~p~n", [FromUser], [Msg]),
					Str = io:read("You: "),
					User2_Pid ! {user1, OwnName, Str},
					% f(Str),
					user1(OwnName)
			end
	end.

init_chat2(User1_Node) ->
	Name = io:get_line("Enter your name: "),
	spawn(chat, user2, [Name, User1_Node]).

user2(OwnName, User1_Node) ->
	io:format("I am here. ~n"),
	Str1 = io:get_line("You: "),
	io:format("I am now here. ~n"),
 	User1_Node ! {user2, self(), OwnName, Str1},
	receive
		{user1, FromUser, Msg} ->
			case Msg == "bye" of
				true -> 
					io:format("Your partner disconnected. ~n");
				false ->
					io:format("~p: ~p~n", [FromUser], [Msg]),
				 	% f(Str),
				 	user2(OwnName, User1_Node)
			end
	end.