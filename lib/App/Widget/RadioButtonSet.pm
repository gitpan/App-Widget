
######################################################################
## $Id: RadioButtonSet.pm,v 1.2 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::RadioButtonSet;
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::RadioButtonSet - Set of HTML radio buttons

=head1 SYNOPSIS

   use App::Widget::RadioButtonSet;

   $name = "gobutton";
   $config = { };
   $state = CGI->new({});
   $w = App::Widget::RadioButtonSet->new($config,$state,"gobutton", $config, $state);

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

sub html {
    my $self = shift;
    my ($context, $name, $curr_value, $values, $labels);
    my ($nullable, $tabindex);
    my ($value, $v, @html, $label);

    $context  = $self->{context};
    $name     = $self->{name};

    $nullable = $self->get("nullable");
    $tabindex = $self->get("tabindex");

    ($values, $labels) = $self->values_labels();

    $tabindex = (defined $tabindex && $tabindex ne "") ? " tabindex=\"$tabindex\"" : "";

    @html = ();
    $curr_value = $self->get_value();
    for ($v = 0; $v <= $#$values; $v++) {
        $value = $values->[$v];
        $label = $self->html_escape($labels->{$value});
        push(@html,"  <input type=\"radio\" name=\"$name\" value=\"$value\"$tabindex" .
            (($value eq $curr_value) ? " checked />" : " />") .
            $label .
            "\n");
    }

    return join("",@html);
}

1;
