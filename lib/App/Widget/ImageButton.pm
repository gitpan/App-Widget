
######################################################################
## $Id: ImageButton.pm,v 1.5 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::ImageButton;
$VERSION = do { my @r=(q$Revision: 1.5 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::ImageButton - An HTML image button

=head1 SYNOPSIS

   use App::Widget::ImageButton;

   $name = "get_data";
   $w = App::Widget::ImageButton->new($name);
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
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my ($name);
    my ($url, $image, $image_script, $script_url_dir, $html_url_dir);
    my ($height, $width, $bevel, $event, $args, $tabindex, $bgcolor);
    my ($label, $url_label, $html_label, $event_target, $type, $selected);

    $name         = $self->{name};
    $label        = $self->label();
    $url_label    = $self->url_escape($label);
    $html_label   = $self->html_escape($label);
    $tabindex     = $self->get("tabindex");
    $tabindex     = ($tabindex) ? " tabindex=\"$tabindex\"" : "";
    $event_target = $self->get("event_target",$name);
    $event        = $self->get("event","click");
    $args         = $self->get("args");
    $args         = (defined $args && $args ne "") ? "($args)" : "";
    $type         = $self->{type};
    $type         = "button" if (!$type);
    $selected     = $self->{selected} ? "&selected=1" : "&selected=0";

    $image = $self->get("image");
    if ($image) {
        $height     = $self->get("height");
        $width      = $self->get("width");
        $height     = $height ? " height=\"$height\"" : "";
        $width      = $width ? " width=\"$width\"" : "";

        if ($image =~ /^\// || $image =~ /^https?:/i) {
            $url    = $image;
        }
        else {
            $html_url_dir = $self->{context}->get_option("html_url_dir");
            $url    = "$html_url_dir/$image";
        }

        return "<input type=\"image\" name=\"app.event.$event_target.$event$args\" src=\"$url\" border=\"0\"$height$width alt=\"$html_label\"$tabindex/>";
    }

    $image_script = $self->get("image_script","app-button");
    if ($image_script) {
        $height     = $self->get("height",17);
        $width      = $self->get("width",100);
        $bevel      = $self->get("bevel",2);

        if ($image_script =~ /^\// || $image_script =~ /^https?:/i) {
            $url    = $image_script;  # absolute URL
        }
        else {
            $script_url_dir = $self->{context}->get_option("script_url_dir");
            $url    = "$script_url_dir/$image_script";
        }
        $url .= "?mode=$type&width=$width&height=$height&bevel=$bevel&text=$url_label$selected";
        return "<input type=\"image\" name=\"app.event.$event_target.$event$args\" src=\"$url\" border=\"0\" height=\"$height\" width=\"$width\" alt=\"$html_label\"$tabindex/>";
    }

    return "<input type=\"submit\" name=\"app.event.$event_target.$event$args\" value=\"$html_label\"$tabindex/>";
}

1;

