#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use AnyEvent::Twitter;
use AnyEvent::Twitter::Plugin::Yammer;
use Config::Pit;
use Data::Dumper;

my $consumer_tokens = pit_get(
    "consumer.yammer.com",
    require => {
        consumer_key    => 'my consumer key',
        consumer_secret => 'my consumer secret',
    }
);
my $access_tokens = pit_get(
    "access.yammer.com",
    require => {
        access_token        => 'my access token',
        access_token_secret => 'my access token secret',
    }
);

my $ua = AnyEvent::Twitter->new(
    consumer_key        => $consumer_tokens->{consumer_key},
    consumer_secret     => $consumer_tokens->{consumer_secret},
    access_token        => $access_tokens->{access_token},
    access_token_secret => $access_tokens->{access_token_secret},
);

print Dumper %AnyEvent::Twitter::PATH;

my $cv = AE::cv;

$cv->begin;
$ua->request(
    method  => 'POST',
    url     => 'https://www.yammer.com/api/v1/messages.json',
    params  => { body => '日本語テスト第２弾' },
    sub {
        print Dumper \@_;
        $cv->end;
    }
);
$cv->recv;

