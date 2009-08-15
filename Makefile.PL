use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::Tunecore',
    AUTHOR              => q{Grant Grueninger <grantg@cpan.org>},
    VERSION_FROM        => 'lib/WWW/Tunecore.pm',
    ABSTRACT_FROM       => 'lib/WWW/Tunecore.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'WWW::Sitebase' => 0.09,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Tunecore-*' },
);
