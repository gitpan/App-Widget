
######################################################################
## $Id: Menu.pm,v 1.2 2005/08/09 19:25:46 spadkins Exp $
######################################################################

package App::Widget::Menu;
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::Menu - An application menu.

=head1 SYNOPSIS

   $name = "office-menu";

   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::Menu;
   $w = App::Widget::Menu->new($name);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class implements a toolbar full of pushbuttons.

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
    my ($name, $value, $html);
    $name = $self->{name};
    $value = $self->get_value("");
    $html = "<!-- menu ($name) -->";
    $html;
}

1;

