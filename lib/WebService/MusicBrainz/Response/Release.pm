package WebService::MusicBrainz::Response::Release;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.01';

=head1 NAME

WebService::MusicBrainz::Response::Release

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

__PACKAGE__->mk_accessors(qw/id type title text_rep_language text_rep_script asin artist release_event_list disc_list puid_list track_list relation_list extension/);

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
