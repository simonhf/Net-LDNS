package Net::LDNS::DNSSecRRSets;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.02';

require XSLoader;
XSLoader::load('Net::LDNS', $VERSION);

# Note: Since this class does not have a constructor, we can let its child
# objects be owned by the parent. This reduces the recursion depth on
# DESTROY.

sub rrs {
    my $self = shift;
    my $rrs = _rrs($self);
    Net::LDNS::GC::own($rrs, Net::LDNS::GC::owner($self)) if (defined $rrs);
    return $rrs;
}

sub signatures {
    my $self = shift;
    my $sigs = _signatures($self);
    Net::LDNS::GC::own($sigs, Net::LDNS::GC::owner($self)) if (defined $sigs);
    return $sigs;
}

sub next {
    my $self = shift;
    my $rrsets = _next($self);
    Net::LDNS::GC::own($rrsets, Net::LDNS::GC::owner($self)) if (defined $rrsets);
    return $rrsets;
}

sub set_type {
    my ($self, $type) = @_;
    my $s = _set_type($self, $type);
    $Net::LDNS::last_status = $s;
    return $s;
}

sub add_rr {
    my ($self, $rr) = @_;

    my $s = _add_rr($self, my $copy = $rr->clone);
    $Net::LDNS::last_status = $s;
    Net::LDNS::GC::own($copy, $self);
    return $s;
}

sub DESTROY {
    Net::LDNS::GC::free($_[0]);
}

1;
=head1 NAME

Net::LDNS - Perl extension for the ldns library

=head1 SYNOPSIS

  use Net::LDNS ':all'

  rrs = rrsets->rrs
  rrs = rrsets->signatures
  rrsets2 = rrsets->next
  rrsets->add_rr(rr)
  bool = rrsets->contains_type(rr_type)
  rr_type = rrsets->type
  rrsets->set_type(rr_type)

=head1 SEE ALSO

http://www.nlnetlabs.nl/projects/ldns

=head1 AUTHOR

Erik Pihl Ostlyngen, E<lt>erik.ostlyngen@uninett.noE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Erik Pihl Ostlyngen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
