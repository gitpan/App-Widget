
######################################################################
## $Id: Select.pm,v 1.2 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::Select;
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget::Stylizable;
@ISA = ( "App::Widget::Stylizable" );

use strict;

=head1 NAME

App::Widget::Select - Generic HTML element can be anything with proper configuration

=head1 SYNOPSIS

   use App::Widget::Select;

   $name = "gobutton";
   $config = { };
   $state = CGI->new({});
   $w = App::Widget::Select->new($config,$state,"gobutton", $config, $state);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is a <select> HTML element.

=cut

######################################################################
# CONSTRUCTOR
######################################################################

# uncomment this when I need to do more than just call SUPER::_init()
#sub _init {
#   my $self = shift;
#   $self->SUPER::_init(@_);
#}

######################################################################
# METHODS
######################################################################

######################################################################
# OUTPUT METHODS
######################################################################

sub unstyled_html {
    my $self = shift;
    my ($context, $name, @currvalues, $values, @values, $labels);
    my ($tagname, $nullable, $size, $multiple, $tabindex);

    $context       = $self->{context};
    $name     = $self->{name};

    $nullable = $self->get("nullable");
    $size     = $self->get("size");
    $multiple = $self->get("multiple");
    $tabindex = $self->get("tabindex");

    ($values, $labels) = $self->values_labels();

    if ($nullable) {
        $values = [ "", @$values ];
    }

    $size     = (defined $size && $size ne "") ? " size='$size'" : "";
    $tabindex = (defined $tabindex && $tabindex ne "") ? " tabindex='$tabindex'" : "";
    $multiple = $multiple ? " multiple" : "";
    $tagname  = $multiple ? "$name\[]" : $name;

    my ($value, $v, %value_exists, $value_exists, @html);
    @currvalues = $self->get_values();
    foreach $value (@currvalues) {
        if (defined $value) {
            $value_exists{$value} = 1;
            $value_exists = 1;
        }
    }
    for ($v = 0; $v <= $#$values; $v++) {
        $value = $values->[$v];
        push(@html,"  <option value='$value'" .
            #(($value_exists{$value} || ($v == 0 && !$value_exists)) ? " selected>" : ">") .
            ($value_exists{$value} ? " selected>" : ">") .
            ((defined $labels->{$value}) ? $labels->{$value} : $value) .
            "</option>\n");
    }

    return "<select name='$tagname'${size}${multiple}${tabindex}>\n" . join("",@html) . "</select>";
}

1;
