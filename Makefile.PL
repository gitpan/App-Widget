
######################################################################
## File: $Id: Makefile.PL,v 1.4 2004/09/02 21:05:00 spadkins Exp $
######################################################################

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

# * The files in "sbin" are used during installation but are not
# installed themselves.  Executables that are also to be installed
# should be in "bin".
# * I borrowed the technique for putting the correct interpreter line
# at the top of scripts from the libwww-perl distribution.

my @programs = (
    "cgi-bin/app-button",
);

%opts = (
    'NAME'        => 'App-Widget',
    'DISTNAME'    => 'App-Widget',
    'VERSION'     => '0.90',
    'EXE_FILES'   => [ @programs ],
    'PREREQ_PM'   => { # I haven't yet determined what the minimum versions should be
                       #'Aspect'                   => 0,  # used for debugging
                       #'Class::MethodMaker'       => 0,  # [prereq for Aspect] auto-generate methods
                       'Compress::Zlib'           => 0,  # for compressed serialization and browser responses
                       'Data::Dumper'             => 0,  # used for debugging
                       'Date::Parse'              => 0,  # date support
                       'Date::Format'             => 0,  # date support
                       #'Error'                    => 0,  # allows try/catch syntax for exceptions (deprecated)
                       'Exception::Class'         => 0,  # allows exception hierarchies
                       'Class::Data::Inheritable' => 0,  # [prereq for Exception::Class]
                       'Devel::StackTrace'        => 0,  # [prereq for Exception::Class]
                       #'Fatal'                    => 0,  # causes perl functions to throw exceptions
                       #'Hook::LexWrap'            => 0,  # [prereq for Aspect] support PRE/POST processing for subs
                       'MIME::Base64'             => "2.1", # used for turning binary (serialized?) data into text (Sessions)
                       'Storable'                 => 0,  # used for serialization everywhere
                     },
    'clean'       => { FILES => '$(EXE_FILES)' },
    'dist'        => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
                      'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
);

######################################################################
# MAKE THE MAKEFILE
######################################################################

WriteMakefile(%opts);

sub MY::postamble {
    return <<EOF;

install ::
	@\$(MOD_INSTALL) blib/script "\$(PREFIX)/cgi-bin/App"
	@\$(MOD_INSTALL) htdocs  "\$(PREFIX)/htdocs/App"

EOF
}
