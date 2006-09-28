package WebService::MusicBrainz::Response;

use strict;
use XML::Twig;

our $VERSION = '0.03';

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

=head2 _get_twig()

This method will create an XML::Twig object and parse the XML response which is then stored in the XML::Twig object.

=cut

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

=head2 _init()

This method will parse the XML response and act as a factory to generate the collection of WebService::MusicBrainz::Response::* objects that represent the XML data.

=cut

sub _init {
   my $self = shift;

   my $xRoot = $self->{_xmltwig} || return;

   require WebService::MusicBrainz::Response::Metadata;

   my $metadata = WebService::MusicBrainz::Response::Metadata->new();

   $metadata->generator( $xRoot->att('generator') ) if $xRoot->att('generator');
   $metadata->created( $xRoot->att('created') ) if $xRoot->att('created');

   my @artist_list;
   my @release_list;
   my @track_list;

   if($xRoot->first_child('artist')) {
      my $xArtist = $xRoot->first_child('artist');

      my $artist = _create_artist( $xArtist );

      push @artist_list, $artist;

   } elsif($xRoot->first_child('artist-list')) {
      foreach my $xArtist ($xRoot->get_xpath('artist-list/artist')) {
          my $artist = _create_artist( $xArtist );

          push @artist_list, $artist;
      }
   } elsif($xRoot->first_child('release')) {
      my $xRelease = $xRoot->first_child('release');

      my $release = _create_release( $xRelease );

      push @release_list, $release;

   } elsif($xRoot->first_child('release-list')) {
      foreach my $xRelease ($xRoot->get_xpath('release-list/release')) {
          my $release = _create_release( $xRelease );

          push @release_list, $release;
      }

   } elsif($xRoot->first_child('track')) {
      my $xTrack = $xRoot->first_child('track');

      my $track = _create_track( $xTrack );

      push @track_list, $track;

   } elsif($xRoot->first_child('track-list')) {
      foreach my $xTrack ($xRoot->get_xpath('track-list/track')) {
          my $track = _create_track( $xTrack );

          push @track_list, $track;
      }

   }
   
   $metadata->artist_list(\@artist_list);
   $metadata->track_list(\@track_list);
   $metadata->release_list(\@release_list);

   $self->{_metadata_cache} = $metadata;
}

=head2 artist()

This method will return the first artist object from the artist list.

=cut

sub artist {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist_list = $metadata->artist_list();

   return shift @{ $artist_list };
}

=head2 release()

This method will return the first release object from the release list.

=cut

sub release {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release_list = $metadata->release_list();

   return shift @{ $release_list };
}

=head2 track()

This method will return the first track object from the track list.

=cut

sub track {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $track_list = $metadata->track_list();

   return shift @{ $track_list };
}

=head2 artist_list()

This method will return the artist list.

=cut

sub artist_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist_list = $metadata->artist_list();

   return wantarray ? @$artist_list : $artist_list;
}

=head2 release_list()

This method will return the release list.

=cut

sub release_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release_list = $metadata->release_list();

   return wantarray ? @$release_list : $release_list;
}

=head2 track_list()

This method will return the track list.

=cut

sub track_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $track_list = $metadata->track_list();

   return wantarray ? @$track_list : $track_list;
}

=head2 _create_artist()

Helper function to create a WebService::MusicBrainz::Response::Artist object and to populate it with data.
Internal use only.

=cut

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

   if($xArtist->first_child('alias-list')) {
       my @alias_list;

       foreach my $xAlias ($xArtist->get_xpath('alias-list/alias')) {
           my $alias = _create_alias($xAlias);

	   push @alias_list, $alias;
       }

       $artist->alias_list( \@alias_list );
   }

   if($xArtist->first_child('relation-list')) {
       my @relation_list;

       foreach my $xRelation ($xArtist->get_xpath('relation-list/relation')) {
           my $relation = _create_relation($xRelation);

	   push @relation_list, $relation;
       }

       $artist->relation_list( \@relation_list );
   }

   if($xArtist->first_child('release-list')) {
       my @release_list;

       foreach my $xRelease ($xArtist->get_xpath('release-list/release')) {
           my $release = _create_release($xRelease);

	   push @release_list, $release;
       }

       $artist->release_list( \@release_list );
   }

   return $artist;
}

=head2 _create_release()

Helper function to create a WebService::MusicBrainz::Response::Release object and to populate it with data.
Internal use only.

=cut

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

   my $xArtist = $xRelease->first_child('artist');

   if(defined($xArtist)) {
       my $artist = _create_artist($xArtist);

       $release->artist($artist);
   }

   my @track_list;

   if ($xRelease->first_child('track-list')) {

      foreach my $xTrack ($xRelease->get_xpath('track-list/track')) {
          my $track = _create_track( $xTrack );
          push @track_list, $track;
      }
   }

   $release->track_list(\@track_list);

   return $release;
}

=head2 _create_track()

Helper function to create a WebService::MusicBrainz::Response::Track object and to populate it with data.
Internal use only.

=cut

sub _create_track {
   my $xTrack = shift;

   require WebService::MusicBrainz::Response::Track;

   my $track= WebService::MusicBrainz::Response::Track->new();

   $track->id( $xTrack->att('id') ) if $xTrack->att('id');
   $track->title( $xTrack->first_child('title')->text() ) if $xTrack->first_child('title');
   $track->duration( $xTrack->first_child('duration')->text() ) if $xTrack->first_child('duration');

   my $xArtist = $xTrack->first_child('artist');

   if(defined($xArtist)) {
       my $artist = _create_artist($xArtist);

       $track->artist($artist);
   }

   my @release_list;

   foreach my $xRelease ($xTrack->get_xpath('release-list/release')) {
       my $release = _create_release($xRelease);

       push @release_list, $release;
   }

   $track->release_list(\@release_list);

   return $track;
}

=head2 _create_alias()

Helper function to create a WebService::MusicBrainz::Response::Alias object and to populate it with data.
Internal use only.

=cut

sub _create_alias {
   my $xAlias = shift;

   require WebService::MusicBrainz::Response::Alias;

   my $alias = WebService::MusicBrainz::Response::Alias->new();

   $alias->type( $xAlias->att('type') ) if $xAlias->att('type');
   $alias->script( $xAlias->att('script') ) if $xAlias->att('script');
   $alias->text( $xAlias->text() ) if $xAlias->text();

   return $alias;
}

=head2 _create_relation()

Helper function to create a WebService::MusicBrainz::Response::Relation object and to populate it with data.
Internal use only.

=cut

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

   if($xRelation->first_child('artist')) {
       my $artist = _create_artist($xRelation->first_child('artist'));

       $relation->artist($artist);
   } elsif($xRelation->first_child('release')) {
       my $release = _create_release($xRelation->first_child('release'));

       $relation->release($release);
   } elsif($xRelation->first_child('track')) {
       my $track = _create_track($xRelation->first_child('track'));

       $relation->track($track);
   }

   return $relation;
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
