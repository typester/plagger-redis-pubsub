package Plagger::Plugin::Subscription::Redis;
use strict;
use base qw( Plagger::Plugin );

use Encode;
use Plagger::Tag;

use Redis;
use JSON;
use Try::Tiny;

sub register {
    my($self, $context) = @_;

    $context->register_hook(
        $self,
        'subscription.load' => $self->can('load'),
    );
}

sub load {
    my($self, $context) = @_;

    my $key = $self->conf->{key} || 'subs';

    my $host = $self->conf->{host} || '127.0.0.1';
    my $port = $self->conf->{port} || 6379;

    my $redis = Redis->new(server => "${host}:${port}");

    my ($data, $err);
    try {
        $data = $redis->get($key);
    } catch {
        $err = $_;
    };

    if ($data) {
        my $subs = decode_json $data;

        for my $list (values %$subs) {
            for my $u (@$list) {
                my $feed = Plagger::Feed->new;
                $feed->url($u);
                $context->subscription->add($feed);
            }
        }
    }
    else {
        $context->error("cannot fetch subs: " . ($err || 'no data'));
    }
}

1;
