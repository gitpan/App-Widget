
######################################################################
## $Id: Label.pm,v 1.1 2002/10/12 03:13:08 spadkins Exp $
######################################################################

package App::Widget::Label;
$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::Label - A simple label

=head1 SYNOPSIS

   $name = "label";

   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::Label;
   $w = App::Widget::Label->new($name);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class implements a simple label.

=cut

######################################################################
# INITIALIZATION
######################################################################

# no special initialization

######################################################################
# EVENTS
######################################################################

# no events

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my $html = $self->label();
    $html;
}

1;

