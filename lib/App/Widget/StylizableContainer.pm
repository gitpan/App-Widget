
######################################################################
## $Id: StylizableContainer.pm 3367 2004-09-02 21:05:00Z spadkins $
######################################################################

package App::Widget::StylizableContainer;
$VERSION = do { my @r=(q$Revision: 3367 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::StylizableContainer - An HTML element which can use the standard set of style elements

=head1 SYNOPSIS

   use App::Widget::StylizableContainer;

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

1;

