
######################################################################
## $Id: TabbedView.pm,v 1.5 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::TabbedView;
$VERSION = do { my @r=(q$Revision: 1.5 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget::HierView;
@ISA = ( "App::Widget::HierView" );

use strict;

=head1 NAME

App::Widget::TabbedView - A screen selector widget

=head1 SYNOPSIS

   use App::Widget::TabbedView;

   $name = "get_data";
   $w = App::Widget::TabbedView->new($name);
   print $w->html();

=cut

=head1 DESCRIPTION

This class implements a screen selector view such as is used in
M$ Outlook.

=cut

######################################################################
# INITIALIZATION
######################################################################

sub _init {
    my $self = shift;
    $self->SUPER::_init(@_);
    if (! $self->get("selected")) {
        $self->select_first();
    }
}

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my ($context, $name, $node, $html, $label, $icon);
    $context = $self->{context};
    $name    = $self->{name};
    $node    = $self->get("node");

    my ($bgcolor, $width, $fontface, $fontsize, $fontcolor, $fontbegin, $fontend);
    my ($html_url_dir, $xgif);

    $bgcolor   = $self->get("bgcolor",   "#888888");
    $width     = $self->get("width",     "100%");
    $fontface  = $self->get("fontface",  "verdana,geneva,arial,sans-serif");
    $fontsize  = $self->get("fontsize",  "-2");
    $fontcolor = $self->get("fontcolor", "#ffffff");

    #$fontbegin = "<font face=\"$fontface\" size=\"$fontsize\" color=\"$fontcolor\">";
    #$fontend   = "</font>";

    my ($nodebase, $nodeidx, $nodenumber, $nodelabel, $parentnodenumber, $nodelevel, $opennodenumber);
    my (@nodeidx, $selected_nodenumber, $w);

    $selected_nodenumber = $self->{selected};
    @nodeidx = split(/\./,$selected_nodenumber);

    $html_url_dir = $context->get_option("html_url_dir");
    $xgif = "$html_url_dir/images/Widget/dot_clear.gif";

    $html = '<table border="0" cellpadding="0" cellspacing="0" width="100%">' . "\n";

    $nodebase = "";
    for ($nodelevel = 0; $nodelevel <= $#nodeidx; $nodelevel++) {
        $html .= "  <tr><td rowspan=\"3\" width=\"1%\" height=\"19\" nowrap>";
        $nodeidx = 1;
        $nodenumber = "$nodebase$nodeidx"; # create its node number
        while (defined $node->{$nodenumber}) {

            $label = $node->{$nodenumber}{label};
            $label = $node->{$nodenumber}{value} if (!defined $label);
            $label = "" if (!defined $label);

            $w = $context->widget("$name.button$nodenumber",
                class => "App::Widget::ImageButton",
                image_script => "app-button",
                volatile     => 1,
                height       => "19",
                width        => "127",
                bevel        => "2",
                label        => $label,
                event_target => $name,
                event        => "open_exclusively",
                args         => $nodenumber,
                type         => "tab",
            );
            #$w->set("selected", $node->{$nodenumber}{open} ? 1 : 0);
            if ($node->{$nodenumber}{open}) {
                $w->set("selected", 1);
            }
            else {
                $w->set("selected", 0);
            }
            $html .= $w->html();
            $html .= "<!--\n    -->";

            $nodeidx++;
            $nodenumber = "$nodebase$nodeidx"; # create its node number
        }
        $nodebase .= "$nodeidx[$nodelevel].";
        $html .= "</td>\n";
        $html .= "    <td height=16 width=\"99%\"><img src=transp.gif height=16 width=1></td>\n";
        $html .= "    <td height=\"16\" width=\"99%\"></td>\n";
        $html .= "  </tr>\n";
        $html .= "  <tr>\n";
        $html .= "    <td height=\"1\" width=\"99%\" bgcolor=\"#000000\"><img src=\"$xgif\" height=\"1\" width=\"1\"></td>\n";
        $html .= "  </tr>\n";
        $html .= "  <tr>\n";
        $html .= "    <td height=\"2\" width=\"99%\" bgcolor=\"#ffffff\"><img src=\"$xgif\" height=\"2\" width=\"1\"></td>\n";
        $html .= "  </tr>\n";
    }

    $html .= "</table>\n";

    $html;
}

1;

