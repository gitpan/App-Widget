
######################################################################
## $Id: TextField.pm 3668 2006-03-11 20:51:13Z spadkins $
######################################################################

package App::Widget::TextField;
$VERSION = (q$Revision: 3668 $ =~ /(\d[\d\.]*)/)[0];  # VERSION numbers generated by svn

use App;
use App::Widget::Stylizable;
@ISA = ( "App::Widget::Stylizable" );

use strict;

=head1 NAME

App::Widget::TextField - An HTML text field

=head1 SYNOPSIS

   $name = "first_name";
   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);
   # OR ...
   $w = $context->widget($name,
      class => "App::Widget::TextField",
      size  => 8,                 # from HTML spec
      maxlength => 18,            # from HTML spec
      tabindex => 1,              # from HTML spec
      style => "mystyle",         # from HTML to support CSS
      color => "#6666CC",         # from CSS spec
      font_size => "10px",        # from CSS spec
      border_style => "solid",    # from CSS spec
      border_width => "1px",      # from CSS spec
      border_color => "#6666CC",  # from CSS spec
      padding => "2px",           # from CSS spec
      background_color => "#ccffcc",           # from CSS spec
      font_family => "Verdana, Geneva, Arial", # from CSS spec
      override => 1,              # increase precedence of following options to "override" from "default"
      #validate => "date",         # not impl. yet ("date", "time", "datetime", "enum", "number", "integer", ":regexp")
      #autocomplete => \@previous_choices,  # not impl. yet
   );

   # internal way
   use App::Widget::TextField;
   $w = App::Widget::TextField->new($name);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is a <input type=text> HTML element.

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

sub unstyled_html {
    my $self = shift;
    my ($name, $value, $html_value, $html, $var, $size, $maxlength, $tabindex);
    $name = $self->{name};
    $value = $self->fget_value();
    $html_value = $self->html_escape($value);
    $size = $self->get("size");
    $maxlength = $self->get("maxlength");
    $tabindex = $self->get("tabindex");
    $html = "<input type=\"text\" name=\"${name}\" value=\"$html_value\"";
    $html .= " size=\"$size\"" if ($size);
    $html .= " maxlength=\"$maxlength\"" if ($maxlength);
    $html .= " tabindex=\"$tabindex\"" if ($tabindex);
    $html .= "/>";
    $html;
}

1;

