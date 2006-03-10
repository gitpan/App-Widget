
######################################################################
## $Id: NewWidget.pm 3224 2002-10-12 03:13:09Z spadkins $
######################################################################

package App::Widget::NewWidget;
$VERSION = do { my @r=(q$Revision: 3224 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::NewWidget - A widget

=head1 SYNOPSIS

   $name = "widget01";

   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::NewWidget;
   $w = App::Widget::NewWidget->new($name);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class implements a widget.

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
    $html = "new_widget ($name)";
    $html;
}

1;

