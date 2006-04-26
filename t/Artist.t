# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 10;
BEGIN { use_ok('WebService::MusicBrainz::Artist') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# TEST SEARCH API

my $ws = WebService::MusicBrainz::Artist->new();
ok( $ws, 'create WebService::MusicBrainz::Artist object' );

my $search_mbid = $ws->search({ MBID => 'd15721d8-56b4-453d-b506-fc915b14cba2' });
ok( $search_mbid, 'get MBID search response object' );

my $search_name = $ws->search({ NAME => 'throwing muses' });
ok( $search_name, 'get NAME search response object' );

my $search_name_limit = $ws->search({ NAME => 'james', LIMIT => 5 });
ok( $search_name_limit, 'get NAME, LIMIT search response object' );

my $search_inc_aliases = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases' });
ok( $search_inc_aliases, 'get INC aliases search response object' );

my $search_inc_artist_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'artist-rels' });
ok( $search_inc_artist_rels, 'get INC artist_rels search response object' );

my $search_inc_release_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });
ok( $search_inc_release_rels, 'get INC release_rels search response object' );

my $search_inc_track_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });
ok( $search_inc_track_rels, 'get INC track_rels search response object' );

my $search_inc_url_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'url-rels' });
ok( $search_inc_url_rels, 'get INC url_rels search response object' );

# TEST RESPONSE OBJECT API 
