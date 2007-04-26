package WebService::MusicBrainz::Response;

use strict;
use XML::Twig;

our $VERSION = '0.08';

=head1 NAME

WebService::MusicBrainz::Response

=head1 SYNOPSIS

=head1 DESCRIPTION

This module will hide the details of the XML web service response and provide an API to query the XML data which has been returned.  This module is responsible for parsing the XML web service response and instantiating objects to provide access to the details of the response.

=head1 METHODS

=head2 new()

This method is the constructor and it will call for  initialization.

=cut

sub new {
   my $class = shift;
   my %params = @_;
   my $self = {};

   bless $self, $class;

   $self->{_xml} = $params{XML} || die "XML parameter required";

   $self->_get_twig();

   $self->_init();

   return $self;
}

sub _get_twig {
   my $self = shift;

   my $xTwig = XML::Twig->new();

   $xTwig->safe_parse($self->{_xml}) or die "Failure to parse XML";

   my $xRoot = $xTwig->root();

   $self->{_xmltwig} = $xRoot;

   return;
}

=head2 as_xml()

This method returns the raw XML from the MusicBrainz web service response.

=cut

sub as_xml {
   my $self = shift;

   return $self->{_xml};
}

sub _init {
   my $self = shift;

   my $xRoot = $self->{_xmltwig} || return;

   require WebService::MusicBrainz::Response::Metadata;

   my $metadata = WebService::MusicBrainz::Response::Metadata->new();

   $metadata->generator( $xRoot->att('generator') ) if $xRoot->att('generator');
   $metadata->created( $xRoot->att('created') ) if $xRoot->att('created');
   $metadata->score( $xRoot->att('ext:score') ) if $xRoot->att('ext:score');
   $metadata->artist( _create_artist( $xRoot->first_child('artist') ) ) if $xRoot->first_child('artist');
   $metadata->artist_list( _create_artist_list( $xRoot->first_child('artist-list') ) ) if $xRoot->first_child('artist-list');
   $metadata->release( _create_release( $xRoot->first_child('release') ) ) if $xRoot->first_child('release');
   $metadata->release_list( _create_release_list( $xRoot->first_child('release-list') ) )
         if $xRoot->first_child('release-list');
   $metadata->track( _create_track( $xRoot->first_child('track') ) ) if $xRoot->first_child('track');
   $metadata->track_list( _create_track_list( $xRoot->first_child('track-list') ) ) if $xRoot->first_child('track-list');

   $self->{_metadata_cache} = $metadata;
}

=head2 generator()

This method will return an optional value of the generator.

=cut

sub generator {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->generator();
}

=head2 created()

This method will return an optional value of the created date.

=cut

sub created {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->created();
}

=head2 score()

This method will return an optional value of the relevance score.

=cut

sub score {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->score();
}

=head2 metadata()

This method will return an Response::Metadata object.

=cut

sub metadata {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata;
}

=head2 artist()

This method will return an Response::Artist object.

=cut

sub artist {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist = $metadata->artist_list() ? shift @{ $metadata->artist_list()->artists() } : $metadata->artist();

   return $artist;
}

=head2 release()

This method will return an Reponse::Release object;.

=cut

sub release {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release = $metadata->release_list() ? shift @{ $metadata->release_list()->releases() } : $metadata->release();

   return $release;
}

=head2 track()

This method will return an Response::Track object.

=cut

sub track {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $track = $metadata->track_list() ? shift @{ $metadata->track_list()->tracks() } : $metadata->track();

   return $metadata->track();
}

=head2 artist_list()

This method will return a reference to the Response::ArtistList object in a scalar context.  If in a array context, an array of Response::Artist objects will be returned.

=cut

sub artist_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist_list = $metadata->artist_list();

   return wantarray ? @{ $artist_list->artists() } : $artist_list;
}

=head2 release_list()

This method will return a reference to the Response::ReleaseList object in a scalar context.  If in a array context, an array of Response::Release objects will be returned.

=cut

sub release_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release_list = $metadata->release_list();

   return wantarray ? @{ $release_list->releases() } : $release_list;
}

=head2 track_list()

This method will return a reference to the Response::TrackList object in a scalar context.  If in a array context, an array of Response::Track objects will be returned.

=cut

sub track_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $track_list = $metadata->track_list();

   return wantarray ? @{ $track_list->tracks() } : $track_list;
}

sub _create_artist {
   my $xArtist = shift;

   require WebService::MusicBrainz::Response::Artist;

   my $artist = WebService::MusicBrainz::Response::Artist->new();

   $artist->id( $xArtist->att('id') ) if $xArtist->att('id');
   $artist->type( $xArtist->att('type') ) if $xArtist->att('type');
   $artist->name( $xArtist->first_child('name')->text() ) if $xArtist->first_child('name');
   $artist->sort_name( $xArtist->first_child('sort-name')->text() ) 
            if $xArtist->first_child('sort-name');
   $artist->disambiguation( $xArtist->first_child('disambiguation')->text() ) 
            if $xArtist->first_child('disambiguation');
   $artist->life_span_begin( $xArtist->first_child('life-span')->att('begin') ) 
            if $xArtist->first_child('life-span') && $xArtist->first_child('life-span')->att('begin');
   $artist->life_span_end( $xArtist->first_child('life-span')->att('end') ) 
            if $xArtist->first_child('life-span') && $xArtist->first_child('life-span')->att('end');
   $artist->score( $xArtist->att('ext:score') ) if $xArtist->att('ext:score');

   $artist->alias_list( _create_alias_list( $xArtist->first_child('alias-list') ) ) if $xArtist->first_child('alias-list');

   $artist->relation_list( _create_relation_list( $xArtist->first_child('relation-list') ) )
       if $xArtist->first_child('relation-list');

   $artist->release_list( _create_release_list( $xArtist->first_child('release-list') ) )
       if $xArtist->first_child('release-list');

   return $artist;
}

sub _create_artist_list {
   my $xArtistList = shift;

   require WebService::MusicBrainz::Response::ArtistList;

   my $artist_list = WebService::MusicBrainz::Response::ArtistList->new();

   my @artists;

   foreach my $xArtist ($xArtistList->get_xpath('artist')) {
       my $artist = _create_artist( $xArtist );

       push @artists, $artist;
   }

   $artist_list->artists( \@artists );

   return $artist_list;
}

sub _create_release {
   my $xRelease = shift;

   require WebService::MusicBrainz::Response::Release;

   my $release = WebService::MusicBrainz::Response::Release->new();

   $release->id( $xRelease->att('id') ) if $xRelease->att('id');
   $release->type( $xRelease->att('type') ) if $xRelease->att('type');
   $release->title( $xRelease->first_child('title')->text() ) if $xRelease->first_child('title');
   $release->text_rep_language( $xRelease->first_child('text-representation')->att('language') )
        if $xRelease->first_child('text-representation') && $xRelease->first_child('text-representation')->att('language');
   $release->text_rep_script( $xRelease->first_child('text-representation')->att('script') )
        if $xRelease->first_child('text-representation') && $xRelease->first_child('text-representation')->att('script');
   $release->asin( $xRelease->first_child('asin')->text() ) if $xRelease->first_child('asin');
   $release->score( $xRelease->att('ext:score') ) if $xRelease->att('ext:score');
   $release->artist( _create_artist( $xRelease->first_child('artist') ) ) if $xRelease->first_child('artist');
   $release->release_event_list( _create_release_event_list( $xRelease->first_child('release-event-list') ) )
        if $xRelease->first_child('release-event-list');
   $release->disc_list( _create_disc_list( $xRelease->first_child('disc-list') ) ) if $xRelease->first_child('disc-list');
   $release->puid_list( _create_puid_list( $xRelease->first_child('puid-list') ) ) if $xRelease->first_child('puid-list');
   $release->track_list( _create_track_list( $xRelease->first_child('track-list') ) ) if $xRelease->first_child('track-list');
   $release->relation_list( _create_relation_list( $xRelease->first_child('relation-list') ) )
        if $xRelease->first_child('relation-list');

   return $release;
}

sub _create_track {
   my $xTrack = shift;

   require WebService::MusicBrainz::Response::Track;

   my $track= WebService::MusicBrainz::Response::Track->new();

   $track->id( $xTrack->att('id') ) if $xTrack->att('id');
   $track->title( $xTrack->first_child('title')->text() ) if $xTrack->first_child('title');
   $track->duration( $xTrack->first_child('duration')->text() ) if $xTrack->first_child('duration');
   $track->score( $xTrack->att('ext:score') ) if $xTrack->att('ext:score');
   $track->artist( _create_artist( $xTrack->first_child('artist') ) ) if $xTrack->first_child('artist');
   $track->release_list( _create_release_list( $xTrack->first_child('release-list') ) )
        if $xTrack->first_child('release-list');
   $track->puid_list( _create_puid_list( $xTrack->first_child('puid-list') ) ) if $xTrack->first_child('puid-list');
   $track->relation_list( _create_relation_list( $xTrack->first_child('relation-list') ) )
        if $xTrack->first_child('relation-list');

   return $track;
}

sub _create_track_list {
   my $xTrackList = shift;

   require WebService::MusicBrainz::Response::TrackList;

   my $track_list = WebService::MusicBrainz::Response::TrackList->new();

   $track_list->count( $xTrackList->att('count') ) if $xTrackList->att('count');

   my @tracks;

   foreach my $xTrack ($xTrackList->get_xpath('track')) {
       my $track = _create_track( $xTrack );
       push @tracks, $track;
   }

   $track_list->tracks( \@tracks );

   return $track_list;
}

sub _create_alias {
   my $xAlias = shift;

   require WebService::MusicBrainz::Response::Alias;

   my $alias = WebService::MusicBrainz::Response::Alias->new();

   $alias->type( $xAlias->att('type') ) if $xAlias->att('type');
   $alias->script( $xAlias->att('script') ) if $xAlias->att('script');
   $alias->text( $xAlias->text() ) if $xAlias->text();

   return $alias;
}

sub _create_alias_list {
   my $xAliasList = shift;

   require WebService::MusicBrainz::Response::AliasList;

   my $alias_list = WebService::MusicBrainz::Response::AliasList->new();

   $alias_list->count( $xAliasList->att('count') ) if $xAliasList->att('count');
   $alias_list->offset( $xAliasList->att('offset') ) if $xAliasList->att('offset');

   my @aliases;

   foreach my $xAlias ($xAliasList->get_xpath('alias')) {
       my $alias = _create_alias($xAlias);

       push @aliases, $alias if defined($alias);
   }

   $alias_list->aliases( \@aliases );

   return $alias_list;
}

sub _create_relation {
   my $xRelation = shift;

   require WebService::MusicBrainz::Response::Relation;

   my $relation = WebService::MusicBrainz::Response::Relation->new();

   $relation->type( $xRelation->att('type') ) if $xRelation->att('type');
   $relation->target( $xRelation->att('target') ) if $xRelation->att('target');
   $relation->direction( $xRelation->att('direction') ) if $xRelation->att('direction');
   $relation->attributes( $xRelation->att('attributes') ) if $xRelation->att('attributes');
   $relation->begin( $xRelation->att('begin') ) if $xRelation->att('begin');
   $relation->end( $xRelation->att('end') ) if $xRelation->att('end');
   $relation->score( $xRelation->att('ext:score') ) if $xRelation->att('ext:score');
   $relation->artist( _create_artist( $xRelation->first_child('artist') ) ) if $xRelation->first_child('artist');
   $relation->release( _create_release( $xRelation->first_child('release') ) ) if $xRelation->first_child('release');
   $relation->track( _create_track( $xRelation->first_child('track') ) ) if $xRelation->first_child('relation');

   return $relation;
}

sub _create_relation_list {
   my $xRelationList = shift;

   require WebService::MusicBrainz::Response::RelationList;

   my $relation_list = WebService::MusicBrainz::Response::RelationList->new();

   $relation_list->target_type( $xRelationList->att('target-type') ) if $xRelationList->att('target-type');
   $relation_list->count( $xRelationList->att('count') ) if $xRelationList->att('count');
   $relation_list->offset( $xRelationList->att('offset') ) if $xRelationList->att('offset');

   my @relations;

   foreach my $xRelation ($xRelationList->get_xpath('relation')) {
       my $relation = _create_relation($xRelation);

       push @relations, $relation if defined($relation);
   }

   $relation_list->relations( \@relations );

   return $relation_list;
}

sub _create_event {
   my $xEvent = shift;

   require WebService::MusicBrainz::Response::ReleaseEvent;

   my $event = WebService::MusicBrainz::Response::ReleaseEvent->new();

   $event->date( $xEvent->att('date') ) if $xEvent->att('date');
   $event->country( $xEvent->att('country') ) if $xEvent->att('country');

   return $event;
}

sub _create_release_event_list {
   my $xReleaseEventList = shift;

   require WebService::MusicBrainz::Response::ReleaseEventList;

   my $release_event_list = WebService::MusicBrainz::Response::ReleaseEventList->new();

   my @events;

   foreach my $xEvent ($xReleaseEventList->get_xpath('event')) {
       my $event = _create_event( $xEvent );
       push @events, $event;
   }

   $release_event_list->events( \@events );

   return $release_event_list;
}

sub _create_release_list {
   my $xReleaseList = shift;

   require WebService::MusicBrainz::Response::ReleaseList;

   my $release_list = WebService::MusicBrainz::Response::ReleaseList->new();

   $release_list->count( $xReleaseList->att('count') ) if $xReleaseList->att('count');
   $release_list->offset( $xReleaseList->att('offset') ) if $xReleaseList->att('offset');

   my @releases;

   foreach my $xRelease ($xReleaseList->get_xpath('release')) {
       my $release = _create_release($xRelease);

       push @releases, $release if defined($release);
   }

   $release_list->releases( \@releases );

   return $release_list;
}

sub _create_disc {
   my $xDisc = shift;

   require WebService::MusicBrainz::Response::Disc;

   my $disc = WebService::MusicBrainz::Response::Disc->new();

   $disc->id( $xDisc->att('id') ) if $xDisc->att('id');
   $disc->sectors( $xDisc->att('sectors') ) if $xDisc->att('sectors');

   return $disc;
}

sub _create_disc_list {
   my $xDiscList = shift;

   require WebService::MusicBrainz::Response::DiscList;

   my $disc_list = WebService::MusicBrainz::Response::DiscList->new();

   my @discs;

   $disc_list->count( $xDiscList->att('count') ) if $xDiscList->att('count');

   foreach my $xDisc ($xDiscList->get_xpath('disc')) {
      my $disc = _create_disc( $xDisc );
      push @discs, $disc;
   }

   $disc_list->discs( \@discs );

   return $disc_list;
}

sub _create_puid {
   my $xPuid = shift;

   require WebService::MusicBrainz::Response::Puid;

   my $puid = WebService::MusicBrainz::Response::Puid->new();

   $puid->id( $xPuid->att('id') ) if $xPuid->att('id');

   return $puid;
}

sub _create_puid_list {
   my $xPuidList = shift;

   require WebService::MusicBrainz::Response::PuidList;

   my $puid_list = WebService::MusicBrainz::Response::PuidList->new();

   my @puids;

   foreach my $xPuid ($xPuidList->get_xpath('puid')) {
       my $puid = _create_puid( $xPuid );
       push @puids, $puid;
   }

   $puid_list->puids( \@puids );

   return $puid_list;
}

=head1 AUTHOR

=over 4

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
