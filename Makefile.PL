use inc::Module::Install;
use Module::Install::AuthorTests;

name 'AnyEvent-Twitter-Plugin-Yammer';
all_from 'lib/AnyEvent/Twitter/Plugin/Yammer.pm';

# requires '';
# requires 'Exporter' => 5.63; # use Exporter 'import';
# requires 'Plack' =>  0.9949;



tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
# test_requires 'Test::Requires';
author_tests('xt');
WriteAll;
