
######################################################################
## $Id: Button.pm 3668 2006-03-11 20:51:13Z spadkins $
######################################################################

package App::Widget::Button;
$VERSION = (q$Revision: 3668 $ =~ /(\d[\d\.]*)/)[0];  # VERSION numbers generated by svn

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::Button - An HTML button

=head1 SYNOPSIS

   use App::Widget::Button;

   $name = "get_data";
   $w = App::Widget::Button->new($name);
   print $w->html();

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is a <input type=submit> HTML element.
In the advanced configurations, it is rendered as an image button.

=cut

######################################################################
# INITIALIZATION
######################################################################

# uncomment this when I need to do more than just call SUPER::_init()
#sub _init {
#   my $self = shift;
#   $self->SUPER::_init(@_);
#}

######################################################################
# EVENTS
######################################################################

# Usage: $widget->handle_event($event, @args);
#sub handle_event {
#    my $self = shift;
#
#    if ($_[0] eq "click") {
#        $self->click(@_);
#        return 1;
#    }
#    else {
#        return $self->SUPER::handle_event(@_);
#    }
#}

#sub click {
#    my $self = shift;
#}

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my $name = $self->{name};
    my $label = $self->html_escape($self->{label});
    my $html_attribs = $self->html_attribs();
    return "<input type=\"submit\" name=\"app.event.${name}.click\" value=\"$label\"$html_attribs/>";
}

1;

