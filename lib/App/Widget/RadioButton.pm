
######################################################################
## $Id: RadioButton.pm,v 1.1 2002/10/12 03:13:08 spadkins Exp $
######################################################################

package App::Widget::RadioButton;
$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::RadioButton - A widget

=head1 SYNOPSIS

   $name = "widget01";

   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::RadioButton;
   $w = App::Widget::RadioButton->new($name);

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
    my ($name, $widget_value, $radiobutton_value, $html);
    $name = $self->{name};
    $widget_value = $self->get_value();
    $radiobutton_value = $self->{value};

    # HTML checkboxes are funny.
    # They don't submit anything unless checked.
    # So we have to send a hidden variable to unset them.
    # Then they are reset if they are still really checked.
    # This relies on the behavior that browsers will post values
    # in the order in which they occurred in the HTML.
    # (This is not specified explicitly in standards docs but
    # universally implemented. If anyone knows differently, please
    # let me know.)

    if ($widget_value eq $radiobutton_value) {
        $html = "<input type=\"radio\" name=\"$name\" value=\"$radiobutton_value\" checked />";
    }
    else {
        $html = "<input type=\"radio\" name=\"$name\" value=\"$radiobutton_value\" />";
    }
    $html;
}

1;

