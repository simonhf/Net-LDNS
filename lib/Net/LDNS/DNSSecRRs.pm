package Net::LDNS::DNSSecRRs;

use 5.008008;
use strict;
use warnings;

use Net::LDNS;

our $VERSION = '0.02';

# Note: This class does not have a constructor. Thus, it can not be created
# as an individual object. The data structure of the node is owned 
# and freed by the owner of the parent rather than the parent node. This
# is to prevent deep recursion on DESTROY.

sub to_string {
    my $self = shift;
    my $ret = '';
    while ($self and $self->rr) {
	$ret .= $self->rr->to_string;
	$self = $self->next;
    }

    return $ret;
}

sub add_rr {
    my ($self, $rr) = @_;

    my $s = _add_rr($self, my $copy = $rr->clone);
    Net::LDNS::GC::own($self, $copy);
    $Net::LDNS::last_status = $s;
    return $s;
}

sub rr {
    my $self = shift;
    return Net::LDNS::GC::own($self->_rr, Net::LDNS::GC::owner($self));
}

sub next {
    my $self = shift;
    return Net::LDNS::GC::own($self->_next, Net::LDNS::GC::owner($self));
}

sub DESTROY {
    Net::LDNS::GC::free($_[0]);
}

1;
=head1 NAME

Net::LDNS - Perl extension for the ldns library

=head1 SYNOPSIS

  use Net::LDNS ':all'

  rrs->to_string
  rrs->add_rr(rr)
  rr = rrs->rr
  rrs2 = rrs->next

=head1 SEE ALSO

http://www.nlnetlabs.nl/projects/ldns

=head1 AUTHOR

Erik Pihl Ostlyngen, E<lt>erik.ostlyngen@uninett.noE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by UNINETT Norid AS

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
