use inc::Module::Install;
name 'Statim';
all_from 'lib/Statim.pm';

requires 'Switch';
requires 'AnyEvent';
requires 'IO::Socket::INET';
requires 'Config::JSON';
requires 'Redis';
requires 'Scalar::Util';
requires 'Class::Data::Inheritable';
requires 'List::Util'; 
requires 'List::MoreUtils';
requires 'DateTime';

requires 'Test::More';
requires 'Test::Exception';
requires 'Test::Vars';
requires 'Test::TCP';

WriteAll;
