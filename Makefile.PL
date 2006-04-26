use 5.008004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'WebService::MusicBrainz',
    VERSION_FROM      => 'lib/WebService/MusicBrainz/Query.pm', # finds $VERSION
    PREREQ_PM         => { XML::Twig => 3,
                           LWP::UserAgent => 2,
			   Class::Accessor => 0,
			 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WebService/MusicBrainz/Query.pm', # retrieve abstract from module
       AUTHOR         => 'Bob Faist <bob.faist@gmail.com>') : ()),
);
