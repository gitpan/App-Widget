
######################################################################
## $Id: FileTreeSelector.pm,v 1.1 2005/08/09 19:26:19 spadkins Exp $
######################################################################

package App::Widget::FileTreeSelector;
$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget::TreeSelector;
@ISA = ( "App::Widget::TreeSelector" );

use strict;

=head1 NAME

App::Widget::FileTreeSelector - An HTML tree view

=head1 SYNOPSIS

   use App::Widget::FileTreeSelector;

   $name = "get_data";
   $w = App::Widget::FileTreeSelector->new($name);
   print $w->html();

=cut

=head1 DESCRIPTION

This class implements a graphical tree view such as is used in
Windows Explorer.

=cut

######################################################################
# INITIALIZATION
######################################################################

sub _init {
   my $self = shift;
   $self->set_default("curr_dir", "/");
   $self->{selected} = "1.1";
   $self->{node} = {
        1 =>       { open => 0, value => 'root',           },
        # 1.1 =>     { open => 1, value => 'Criteria',       },
        # 1.2 =>     { open => 0, value => 'Rate Comparison',},
        # 1.3 =>     { open => 0, value => 'Rate Detail',    },
        # 1.4 =>     { open => 0, value => 'Profiles',       },
        # 1.5 =>     { open => 0, value => 'Request Queue',  },
   };

   $self->SUPER::_init(@_);
}

1;

