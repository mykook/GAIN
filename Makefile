.PHONY: rel deps all compile clean disclean test rel relclean run

all: compile

compile:
	./rebar compile

deps:
	./rebar get-deps

clean:
	./rebar clean

distclean: clean relclean
	./rebar delete-deps

test:
	./rebar skip_deps=true eunit

rel: compile
	./rebar compile generate

relclean:
	rm -fr rel/dataminerl

run:
	rel/dataminerl/erts-5.8.2/bin/erl -pa ebin