use Test::More tests => 7;

use FindBin qw/$Bin/;

use Net::LDNS ':all';

BEGIN { use_ok('Net::LDNS') };

# Create a new dnssec zone
my $z = new Net::LDNS::DNSSecZone;
isa_ok($z, 'Net::LDNS::DNSSecZone', 'Create an empty zone');

# Read a zone from file and create a dnssec zone from it
my $z2 = new Net::LDNS::Zone(
    filename => "$Bin/testdata/myzone.org");

$z->create_from_zone($z2);

my $rrset = $z->find_rrset(
    new Net::LDNS::RData(LDNS_RDF_TYPE_DNAME, 'ns1.myzone.org.'), 
        LDNS_RR_TYPE_A);

is($rrset->rrs->rr->type, LDNS_RR_TYPE_A, 'Found an A record');
is($rrset->rrs->rr->dname, 'ns1.myzone.org.', 'Dname is ns1.myzone.org.');

is($z->add_empty_nonterminals, LDNS_STATUS_OK, 'Add empty non-terminals');

my $klist = new Net::LDNS::KeyList;
$klist->push(new Net::LDNS::Key(filename => "$Bin/testdata/key.private"));
$klist->key(0)->set_pubkey_owner(
    new Net::LDNS::RData(LDNS_RDF_TYPE_DNAME, 'myzone.org'));

is($z->sign($klist, LDNS_SIGNATURE_REMOVE_ADD_NEW, 0), LDNS_STATUS_OK, 'Sign');
is($z->sign_nsec3($klist, LDNS_SIGNATURE_REMOVE_ADD_NEW, 1, 0, 10, 'ABBA', 0),
   LDNS_STATUS_OK, 'Sign nsec3');
