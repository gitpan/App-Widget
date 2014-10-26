
######################################################################
## $Id: Element.pm,v 1.2 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::Element;
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::Element - Generic HTML element can be anything with proper configuration

=head1 SYNOPSIS

   use App::Widget::Element;

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is a generic HTML element which can be made into any single
element by proper configuration.

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
# OUTPUT METHODS (standard to all true Widgets)
######################################################################
# must have: _type, config
# options: configkey
# options: name, _name
# options: _content
# options: _default, value

sub html {
    my $self = shift;
    my ($context, $tag, $name, $value, $html_value, $contents);

    $context = $self->{context};
    $name = $self->{name};

    $value = $self->get_value("");
    $html_value = $self->html_escape($value);

    $tag = $self->get("tag");
    $contents = $self->get("contents");

    if (!defined $tag || $tag eq "") {
        return $contents if (defined $contents);
        return "[$name widget tag not defined]. <input type=\"hidden\" name=\"$name\" value=\"$html_value\"/>";
    }

    my (@keys, $key, @html, $config);
    push(@html, $tag);
    push(@html, "name=\"$name\"") if ($name ne "");
    push(@html, "value=\"$html_value\"") if (defined $value);

    $config = $self->config();
    @keys = (keys %$config);
    foreach $key (@keys) {
        next if ($key eq "tag" || $key eq "name" || $key eq "default" || $key eq "contents" || $key =~ /^widget/);
        $value = $self->get($key);
        $html_value = $self->html_escape($value);
        push(@html, $key . "=\"$html_value\"") if (defined $value);
    }

    if (!defined $contents || $contents eq "") {
        return "<" . join(" ",@html) . "/>";
    }
    else {
        return "<" . join(" ",@html) . ">$contents</$tag>";
    }
}

1;

