# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 15;
BEGIN { use_ok('WebService::MusicBrainz::Release') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# TEST SEARCH API

my $ws = WebService::MusicBrainz::Release->new();
ok( $ws );

my $search_title = $ws->search({ TITLE => 'Highway to Hell' });
ok( $search_title );

# TODO:  Need to find a DISCID for testing
# my $search_discid = $ws->search({ DISCID => '' });
# ok( $search_discid );

my $search_artist = $ws->search({ ARTIST => 'sleater kinney' });
ok( $search_artist );

my $search_artist_id = $ws->search({ ARTISTID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab' });
ok( $search_artist_id );

my $search_releasetypes = $ws->search({ RELEASETYPES => 'Official', MBID => 'a89e1d92-5381-4dab-ba51-733137d0e431' });
ok( $search_releasetypes );

my $search_inc_artist = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist' });
ok( $search_inc_artist );

my $search_inc_counts = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'counts' });
ok( $search_inc_counts );

my $search_inc_release_events = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-events' });
ok( $search_inc_release_events );

my $search_inc_discs = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'discs' });
ok( $search_inc_discs );

my $search_inc_tracks = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'tracks' });
ok( $search_inc_tracks );

my $search_inc_artist_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist-rels' });
ok( $search_inc_artist_rels );

my $search_inc_release_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-rels' });
ok( $search_inc_release_rels );

my $search_inc_track_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'track-rels' });
ok( $search_inc_track_rels );

my $search_inc_url_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'url-rels' });
ok( $search_inc_url_rels );
