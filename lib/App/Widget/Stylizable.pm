
######################################################################
## $Id: Stylizable.pm,v 1.3 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::Stylizable;
$VERSION = do { my @r=(q$Revision: 1.3 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::Stylizable - An HTML element which can use the standard set of style elements

=head1 SYNOPSIS

   use App::Widget::Stylizable;

=cut

######################################################################
# CONSTANTS
######################################################################

# These are the valid style sheet attributes
my @style_attrib = (
    "color",
    "font_size",
    "border_style",
    "border_width",
    "border_color",
    "padding",
    "background_color",
    "font_family",
);

my %style_attrib = (
    "color"            => "color",
    "font_size"        => "font-size",
    "border_style"     => "border-style",
    "border_width"     => "border-width",
    "border_color"     => "border-color",
    "padding"          => "padding",
    "background_color" => "background-color",
    "font_family"      => "font-family",
);

# TODO: consider getting list of ("lang") from parent
my @absorbable_attrib = (
    "lang",            # language (en, de, fr, en_us, en_ca, etc.)
    @style_attrib,
);

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is an HTML element which can take the STYLE attribute.

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

# NOTE: This is a *static* method.
#       It doesn't require an instance of the class to call it.
sub absorbable_attribs {
    \@absorbable_attrib;
}

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;

    my ($html);
    my ($var, $value, $stylevar, @style, $options, $class, $user_agent);

    $html    = $self->unstyled_html();
    return($html) if ($self->{nostyle});

    $user_agent = $self->{context}->user_agent();
    return($html) if (! $user_agent->supports("widget.Stylizable.style"));

    $class   = $self->get("style_class");
    $options = (defined $class && $class ne "") ? " class='$class'" : "";
    foreach $var (@style_attrib) {
        $value = $self->get($var);
        if (defined $value) {
            $stylevar = $style_attrib{$var};
            push(@style, "$stylevar:$value");
        }
    }
    if ($#style != -1) {
        $options .= " style='" . join("; ",@style) . "'";
    }
    $html =~ s!(/?>)!${options}$1! if ($options);
    $html;
}

1;

