package Net::LDNS::Key;

use 5.008008;
use strict;
use warnings;

use Net::LDNS ':all';

our $VERSION = '0.02';

require XSLoader;
XSLoader::load('Net::LDNS', $VERSION);

sub new {
    my ($class, %args) = @_;

    my $key;

    if ($args{filename} or $args{file}) {
	my $status = &LDNS_STATUS_OK;
	my $line_nr = 0;
	my $file = $args{file};
	if ($args{filename}) {
	    unless (open FILE, $args{filename}) {
		$Net::LDNS::last_status = &LDNS_STATUS_FILE_ERR;
		return;
	    }
	    $file = \*FILE;
	}

	$key = _new_from_file($file, $line_nr, $status);
	if ($args{filename}) {
	    close $file;
	}

	$Net::LDNS::last_status = $status;
	$Net::LDNS::line_nr = $line_nr;
	if (!defined $key) {
	    return;
	}
    }
    else {
	$key = _new();
    }

    return $key;
}

sub set_pubkey_owner {
    my ($self, $owner) = @_;
    my $oldowner = $self->pubkey_owner;
    Net::LDNS::GC::disown($oldowner) if (defined $oldowner);
    $self->_set_pubkey_owner($owner);
    Net::LDNS::GC::own($owner, $self);
    return $owner;
}

sub pubkey_owner {
    my $self = shift;
    my $owner = _pubkey_owner($self);
    Net::LDNS::GC::own($owner, $self) if (defined $owner);
    return $owner;
}

sub DESTROY {
    Net::LDNS::GC::free($_[0]);
}

1;
=head1 NAME

Net::LDNS - Perl extension for the ldns library

=head1 SYNOPSIS

  use Net::LDNS ':all'

  key = new Net::LDNS::Key
  key = new Net::LDNS::Key(file => \*FILE)
  key = new Net::LDNS::Key(filename => 'keyfile')

  str = key->to_string
  key->print(\*OUTPUT)

  key->set_algorithm(alg)
  alg = key->algorithm
  key->set_flags(flags)
  flags = key->flags
  key->set_hmac_key(hmac)
  hmac = key->hmac_key
  key->set_hmac_size(size)
  size = key->hmac_size
  key->set_origttl(ttl)
  ttl = key->origttl
  key->set_inception(epoch)
  epoch = key->inception
  key->set_expiration(epoch)
  epoch = key->expiration
  key->set_pubkey_owner(rdata)
  rdata = key->pubkey_owner
  key->set_keytag(tag)
  tag = key->keytag
  key->set_use(bool)
  bool = key->use

  str = key->get_file_base_name

  rr = key->to_rr

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