# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 42;
BEGIN { use_ok('WebService::MusicBrainz::Release') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# TEST SEARCH API

my $ws = WebService::MusicBrainz::Release->new();
ok( $ws );

my $search_title = $ws->search({ TITLE => 'Highway to Hell' });
ok( $search_title );

my $title_release_list = $search_title->release_list();
ok( $title_release_list );

my $title_releases = $title_release_list->releases();
ok( $title_releases );

my $title_first_release = shift @$title_releases;
ok( $title_first_release );

ok( $title_first_release->title() eq 'Highway to Hell' );
ok( $title_first_release->text_rep_language() eq 'ENG' );

my $title_first_release_event_list = $title_first_release->release_event_list();
ok( $title_first_release_event_list );

my $title_first_release_disc_list = $title_first_release->disc_list();
ok( $title_first_release_disc_list );
ok( $title_first_release_disc_list->count() eq '8');

my $title_first_release_track_list = $title_first_release->track_list();
ok( $title_first_release_track_list );
ok( $title_first_release_track_list->count() eq '10' );

my $search_discid = $ws->search({ DISCID => 'XgrrQ8Npf9Uz_trPIFMrSz6Mk6Q-' });
ok( $search_discid );

my $search_discid_release = $search_discid->release();
ok( $search_discid_release );

ok( $search_discid_release->title() eq "Heartbreaker" );
ok( $search_discid_release->score() eq "100" );

my $search_discid_release_event_list = $search_discid_release->release_event_list();
ok( scalar( @{ $search_discid_release_event_list->events() } ) > 1 );

ok( $search_discid_release->disc_list()->count() eq "2" );
ok( $search_discid_release->track_list()->count() eq "15" );

my $search_artist = $ws->search({ ARTIST => 'sleater kinney' });
ok( $search_artist );

my $search_artist_release = $search_artist->release();

ok( $search_artist_release->id() eq "3ba90142-0a08-4100-aff6-e2ac5c645fdf" );
ok( $search_artist_release->type() eq "Album Official" );
ok( $search_artist_release->score() =~ m/\d+/ );

my $search_artist_id = $ws->search({ ARTISTID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab' });
ok( $search_artist_id );

my $search_artist_id_releases = $search_artist_id->release_list()->releases();
ok( $search_artist_id_releases );

foreach my $_release ( @$search_artist_id_releases ) {
    if ( $_release->id() eq "fed37cfc-2a6d-4569-9ac0-501a7c7598eb" ) {
        ok($_release->title() eq "Master of Puppets" );
	ok($_release->asin() eq "B000025ZVE" );

	my $artist = $_release->artist();

	ok($artist->name() eq "Metallica");
	last;
    }
}

my $search_releasetypes = $ws->search({ RELEASETYPES => 'Official', MBID => 'a89e1d92-5381-4dab-ba51-733137d0e431' });
ok( $search_releasetypes );

my $search_releasetypes_release = $search_releasetypes->release();
ok( $search_releasetypes_release );

ok( $search_releasetypes_release->type() eq "Album Official" );
ok( $search_releasetypes_release->title() eq "Kill \'em All" );

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
