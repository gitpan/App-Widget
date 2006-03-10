
######################################################################
## $Id: Select.pm 3494 2005-10-20 20:34:24Z spadkins $
######################################################################

package App::Widget::Select;
$VERSION = do { my @r=(q$Revision: 3494 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

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
sub _init {
    my $self = shift;
    my $context = $self->{context};
    my $name = $self->{name};
    my $value = $context->so_get($name);
    if ($value eq "EACH") {
        my ($values, $labels) = $self->values_labels();
        $value = join(",", @$values);
        $context->so_set($name, undef, $value);
    }
    $self->SUPER::_init(@_);
}

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

    my $html_attribs = $self->html_attribs();
    return "<select name='$tagname'${size}${multiple}${tabindex}$html_attribs>\n" . join("",@html) . "</select>";
}

1;

