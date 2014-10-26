
######################################################################
## $Id: CheckboxGroup.pm 3224 2002-10-12 03:13:09Z spadkins $
######################################################################

package App::Widget::CheckboxGroup;
$VERSION = do { my @r=(q$Revision: 3224 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::CheckboxGroup - A widget

=head1 SYNOPSIS

   $name = "widget01";

   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::CheckboxGroup;
   $w = App::Widget::CheckboxGroup->new($name);

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
    my ($context, $name, @currvalues, $values, @values, $labels);
    my ($tagname, $nullable, $tabindex);

    $context  = $self->{context};
    $name     = $self->{name};

    $nullable = $self->get("nullable",1);
    $tabindex = $self->get("tabindex");

    ($values, $labels) = $self->values_labels();

    $tabindex = (defined $tabindex && $tabindex ne "") ? " tabindex='$tabindex'" : "";

    my ($value, $v, %value_exists, $value_exists, $html);
    @currvalues = $self->get_values();

    # HTML checkboxes are funny.
    # They don't submit anything unless checked.
    # So we have to send a hidden variable to unset them.
    # Then they are reset if they are still really checked.
    # This relies on the behavior that browsers will post values
    # in the order in which they occurred in the HTML.
    # (This is not specified explicitly in standards docs but
    # universally implemented. If anyone knows differently, please
    # let me know.)

    $html = "<input type=\"hidden\" name=\"$name\" value=\"{:delete:}\" />\n";

    foreach $value (@currvalues) {
        if (defined $value) {
            $value_exists{$value} = 1;
            $value_exists = 1;
        }
    }
    for ($v = 0; $v <= $#$values; $v++) {
        $value = $values->[$v];
        $html .= "<input type=\"checkbox\" name=\"$name\[]\" value=\"$value\"" .
            (($value_exists{$value} || ($v == 0 && !$value_exists && !$nullable)) ? " checked>" : ">") .
            ((defined $labels->{$value}) ? $labels->{$value} : $value) .
            "\n";
    }

    return $html;
}

1;

