package Plagger::Plugin::Filter::TrimLink;
use strict;
use utf8;
use base qw( Plagger::Plugin );

sub register {
    my($self, $context) = @_;

    $context->register_hook(
        $self,
        'update.entry.fixup' => \&fixup,
    );
}

sub fixup {
    my($self, $context, $args) = @_;

    $args->{entry}{link} =~ s/(^[\n\t ]+|[\n\t ]+$)//gs;
}

1;
