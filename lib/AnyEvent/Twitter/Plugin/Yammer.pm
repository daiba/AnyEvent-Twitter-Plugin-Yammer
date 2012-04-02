package AnyEvent::Twitter::Plugin::Yammer;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.01';
use AnyEvent::HTTP;
use Carp;

my %my_PATH = (
    site          => 'https://yammer.com',
    authorize     => "https://www.yammer.com/oauth/authorize",
    request_token => "https://www.yammer.com/oauth/request_token",
    access_token  => "https://www.yammer.com/oauth/access_token",
    authenticate  => "",
);

sub import {
    my $class = shift;
    *AnyEvent::Twitter::PATH    = %my_PATH;
    *AnyEvent::Twitter::request = \&my_request;
}


sub my_request {
    my $cb = pop;
    my ( $self, %opt ) = @_;

    ( $opt{api} || $opt{url} )
      or Carp::croak "'api' or 'url' option is required";

    my $url = $opt{url};

    ref $cb eq 'CODE'
      or Carp::croak "callback coderef is required";

    $opt{params} ||= {};
    ref $opt{params} eq 'HASH'
      or Carp::croak "parameters must be hashref.";

    $opt{method} = uc $opt{method};
    $opt{method} =~ /^(?:GET|POST)$/
      or Carp::croak "'method' option should be GET or POST";

    my $req = $self->_make_oauth_request(
        class           => 'Net::OAuth::ProtectedResourceRequest',
        request_url     => $url,
        request_method  => $opt{method},
        extra_params    => $opt{params},
        consumer_key    => $self->{consumer_key},
        consumer_secret => $self->{consumer_secret},
        token           => $self->{access_token},
        token_secret    => $self->{access_token_secret},
    );

    my %req_params;
    if ( $opt{method} eq 'POST' ) {
        $url = $req->normalized_request_url;
        $req_params{body} = $req->to_post_body;
        $req_params{headers} =
          { 'Content-Type' => 'application/x-www-form-urlencoded' };
    }
    else {
        $url = $req->to_url;
    }

    AnyEvent::HTTP::http_request $opt{method} => $url,
      %req_params, sub {
        my ( $body, $hdr ) = @_;

        if ( $hdr->{Status} =~ /^2/ ) {
            local $@;
            my $json = eval { JSON::decode_json($body) };
            $cb->( $hdr, $json, $@ ? "parse error: $@" : $hdr->{Reason} );
        }
        else {
            $cb->( $hdr, undef, $hdr->{Reason} );
        }
      };

    return $self;
}

=encoding utf8

=head1 NAME

AnyEvent::Yammer -

=head1 SYNOPSIS

  use AnyEvent::Yammer;

=head1 DESCRIPTION

AnyEvent::Yammer is

=head1 AUTHOR

 E<lt>E<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
