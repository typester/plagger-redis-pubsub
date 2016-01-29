package Plagger::Plugin::Notify::Redis;
use strict;
use utf8;
use base qw( Plagger::Plugin );

use Encode;
use JSON;
use Redis;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'publish.entry' => \&update,
        'plugin.init'   => \&initialize,
    );
}

sub initialize {
    my($self, $context, $args) = @_;

    my $host = $self->conf->{host} || '127.0.0.1';
    my $port = $self->conf->{port} || 6379;
    $self->conf->{topic} ||= 'entry.updated';

    $self->{redis} = Redis->new( server => "${host}:${port}" );
}

sub update {
    my($self, $context, $args) = @_;

    $context->log( info => encode_utf8("Notify @{[ $args->{entry}->title ]} to Redis"));

    my $data = encode_json({
        feed => $args->{feed}->url,
        title => $args->{entry}->title_text,
        link  => $args->{entry}->link,
    });

    $self->{redis}->publish( $self->conf->{topic}, $data );
}

1;
