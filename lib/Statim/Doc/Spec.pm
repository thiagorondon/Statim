=encoding utf-8

=head1 NAME

Statim - Protocol Specification.

=head1 ABSTRACT

This document specifies a standart interface to store and get information about
stats in a statim-server, and how to send the requests from a statim-client. The main 
reason of this interface is to offer a design to promote the portability and reduce 
the effort to make web applications to manage stats of your data.

=head1 TERMINOLOGY

=over 4

=item Collection-key

Is the name to identified the collection that represent a grouping of data, and the
propose of this collection is to map and reduce information about your things, and
with this way we make a circular buffer with the data we have.

=item Schema

You need to setup a schema of the collection, and say about the type of the fields
that collection you have, and the period of use to group the data.

=back

=head1 SPECIFICATION

Clients of statim communicate with server throught TCP connections,  clients connect to 
that port, send commands to the server, read responses, and eventually close the connection.

There is no need to send any command to end the session. A client may just close the
connection at any moment it no longer needs it. 

The just one kind of data sent in the statim protocol, text line, that are used for
commands from clients and responses from server.

Text lines are always terminanted by \r\n. 

=head1 Server configuration

The server have to be pre-configured schema.


	{ 
	  "collection1" : {
	  	"period" : "84600",
		"fields" : {
			"foo" : "count",
			"bar" : "enum",
			"jaz" : "enum"
		},
	  }
	}

=head1 Commands

A command line always starts with the name of the command, followd by parameters
(if any) delimited by ':' (colon). Command names are lower-case and are case-sensitive.

There are three types of commands.

=head2 Storage commands

Ask the server to store some data identified by a collection key. The client sends
a command line, and then a data struct; after that the client expects one line of
response, which will indicate success or failure.

=head3 add

# add [collection-key] [parameters]

	# example
	add collection1 ts:1234567890 foo:1 bar:jaz
	OK

=head2 Retrieval commands

Ask the server to retrieve data corresponding a collection key. The client sends a 
command line, which includes the collection key and the type of view ; after that
the server finds it sends to the cliente one response line with information about
the item.

=head3 get [collection-key] [enum|ts] 

	# example
	get collection bar foo
	OK 1

	get collection bar ts:123456780 foo
	OK 1

    get collection bar ts:123456780-1234567890 foo
    OK 1

=head2 Other commands

Commands with no arguments.

=head3 version

Version string of this server.

=head3 quit

Upon receiving this command, the server closes the connection. However, the
client may also simply close the connection when it no longer needs it,
without issuing this command.

=head1 Error strings

Each command sent by a client may be answered with an error string from the server.
These erro strings come in three types:

=over 4

=item "ERROR\r\n"
  
means the client sent a nonexistente command name.

=item "CLIENT_ERROR <error>\r\n"

means some sort of client error in the input line, i.e. the input doesn't conform to
the protocol in some way. <error> is a human-readable error string.

=item "SERVER_ERROR <error>\r\n"

means some sort of server error preventes the server from carrying out the command.
<error> is a human-readable error string.

=back

=head1 THANKS

=over 4

=item * memcached

=item * redis

=back

=cut 
