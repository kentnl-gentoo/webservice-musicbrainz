# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 36;
BEGIN { use_ok('WebService::MusicBrainz::Artist') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $ws = WebService::MusicBrainz::Artist->new();
ok( $ws, 'create WebService::MusicBrainz::Artist object' );

####  TEST ARTIST MBID SEARCH ###############################

my $search_mbid = $ws->search({ MBID => 'd15721d8-56b4-453d-b506-fc915b14cba2' });
ok( $search_mbid, 'get MBID search response object' );

my $artist_mbid = $search_mbid->artist();
ok( $artist_mbid, 'got artist response object' );

ok( $artist_mbid->type() eq "Group", 'check artist type' );
ok( $artist_mbid->name() eq "The Black Keys", 'check artist name');
ok( $artist_mbid->sort_name() eq "Black Keys, The", 'check artist sort name' );

####  TEST ARTIST MBID SEARCH ###############################

####  TEST ARTIST NAME SEARCH ###############################

my $search_name = $ws->search({ NAME => 'throwing muses' });
ok( $search_name, 'get NAME search response object' );

my $artist_name = $search_name->artist();
ok( $artist_name, 'get artist response object' );

ok( $artist_name->name() eq "Throwing Muses", 'check artist name' );
ok( $artist_name->sort_name() eq "Throwing Muses", 'check artist sort name' );
ok( $artist_name->life_span_begin() eq "1983", 'check artist life span begin' );
ok( $artist_name->life_span_end() eq "2003", 'check artist life span end' );

####  TEST ARTIST NAME SEARCH ###############################

####  TEST ARTIST NAME LIMIT SEARCH ###############################

my $limit = 5;

my $search_name_limit = $ws->search({ NAME => 'james', LIMIT => $limit });
ok( $search_name_limit, 'get NAME, LIMIT search response object' );

my $artist_name_limit = $search_name_limit->artist_list();

ok( $artist_name_limit, 'get artist list response object' );
ok( scalar(@{ $artist_name_limit }) == $limit, 'check size of artist list matches limit' );

####  TEST ARTIST NAME LIMIT SEARCH ###############################

####  TEST ARTIST MBID ALIASES SEARCH ###############################

my $search_inc_aliases = $ws->search({ MBID => '070d193a-845c-479f-980e-bef15710653e', INC => 'aliases' });
ok( $search_inc_aliases, 'get INC aliases search response object' );

my $artist_inc_aliases = $search_inc_aliases->artist();
ok( $artist_inc_aliases, 'get artist response object' );

ok( $artist_inc_aliases->name() eq "Prince", 'check artist name' );

my $artist_alias_list = $artist_inc_aliases->alias_list();
ok( $artist_alias_list, 'get artist alias list' );

ok( scalar(@{ $artist_alias_list }) > 3, 'check size of artist alias list' );

####  TEST ARTIST MBID ALIASES SEARCH ###############################

####  TEST ARTIST MBID ARTIST RELATIONS SEARCH ###############################

my $search_inc_artist_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'artist-rels' });
ok( $search_inc_artist_rels, 'get INC artist_rels search response object' );

my $artist_inc_artist_rels = $search_inc_artist_rels->artist();
ok( $artist_inc_artist_rels, 'get artist reponse object' );

ok( $artist_inc_artist_rels->name() eq "Metallica", 'check artist name' );
ok( $artist_inc_artist_rels->sort_name() eq "Metallica", 'check artist sort name' );
ok( $artist_inc_artist_rels->life_span_begin() eq "1981", 'check artist life span begin' );

my $artist_inc_relation_list = $artist_inc_artist_rels->relation_list();
ok( $artist_inc_relation_list, 'get artist relation list' );

foreach my $relation (@{ $artist_inc_relation_list }) {
    my $artist = $relation->artist();

    if($artist->name() eq "Jason Newsted") {
	 ok( $relation->begin() eq "1986", 'check artist begin relation' );
	 ok( $relation->end() eq "2001", 'check artist end relation' );
         ok( $artist->sort_name() eq "Newsted, Jason", 'check artist sort name' );
	 last;
    }
}

####  TEST ARTIST MBID ARTIST RELATIONS SEARCH ###############################

####  TEST ARTIST MBID RELEASE RELATIONS SEARCH ###############################

my $search_inc_release_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });
ok( $search_inc_release_rels, 'get INC release_rels search response object' );

my $artist_inc_release_rels = $search_inc_release_rels->artist();
ok( $artist_inc_release_rels, 'get artist response object' );

my $artist_inc_release_relation_list = $artist_inc_release_rels->relation_list();
ok( $artist_inc_release_relation_list, 'get artist relation list' );

ok( scalar(@{ $artist_inc_release_relation_list }) > 3, 'check size of artist relation list' );

####  TEST ARTIST MBID RELEASE RELATIONS SEARCH ###############################

my $search_inc_track_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });
ok( $search_inc_track_rels, 'get INC track_rels search response object' );

my $search_inc_url_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'url-rels' });
ok( $search_inc_url_rels, 'get INC url_rels search response object' );
