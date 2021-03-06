BEGIN {
  if ( $ENV{NO_NETWORK_TESTING} ) {
    print '1..0 # SKIP Network connections required for this test';
    exit;
  }
}

use strict;
use Test::More;

use WebService::MusicBrainz;

sub exit_if_mb_busy {
   my $res = shift;
   if(exists $res->{error} && $res->{error} =~ m/^The MusicBrainz web server is currently busy/) {
      done_testing();
      exit(0);
   }
}

my $ws = WebService::MusicBrainz->new();
ok($ws);

# JSON TESTS
my $s1_res = $ws->search(area => { mbid => '044208de-d843-4523-bd49-0957044e05ae' });
exit_if_mb_busy($s1_res);
ok($s1_res->{type} eq 'City');
ok($s1_res->{name} eq 'Nashville');
ok($s1_res->{'sort-name'} eq 'Nashville');
sleep(1);

my $s2_res = $ws->search(area => { area => 'cincinnati' });
exit_if_mb_busy($s2_res);
ok($s2_res->{count} == 2);
ok($s2_res->{areas}->[0]->{type} eq 'City');
ok($s2_res->{areas}->[1]->{type} eq 'City');
sleep(1);

my $s3_res = $ws->search(area => { iso => 'US-OH' });
exit_if_mb_busy($s3_res);
ok($s3_res->{count} == 1);
ok($s3_res->{areas}->[0]->{name} eq 'Ohio');
sleep(1);

eval { my $s4_res = $ws->search(area => { something => '99999' }) };
if($@) { ok($@) }  # catch error
sleep(1);

my $s5_res = $ws->search(area => { iso => 'US-CA', fmt => 'xml' });
exit_if_mb_busy($s5_res);
ok($s5_res->find('name')->first->text eq 'California');
ok($s5_res->at('area')->attr('ext:score') == 100);
sleep(1);

done_testing();
