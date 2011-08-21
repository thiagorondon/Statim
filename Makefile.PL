use inc::Module::Install;
name 'Statim';
all_from 'lib/Statim.pm';

requires 'Switch';
requires 'AnyEvent';
requires 'IO::Socket::INET';
requires 'Config::JSON';
requires 'Redis';

WriteAll;
