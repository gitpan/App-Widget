
######################################################################
## $Id: TabbedSelector.pm 3558 2006-03-01 03:35:40Z spadkins $
######################################################################

package App::Widget::TabbedSelector;
$VERSION = do { my @r=(q$Revision: 3558 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget::HierSelector;
@ISA = ( "App::Widget::HierSelector" );

use strict;

=head1 NAME

App::Widget::TabbedSelector - A screen selector widget

=head1 SYNOPSIS

   use App::Widget::TabbedSelector;

   $name = "get_data";
   $w = App::Widget::TabbedSelector->new($name);
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
    if (! $self->{selected}) {
        $self->select_first();
    }
}

sub select {
    my ($self, $nodeattrib, $value) = @_;
    my $success = $self->SUPER::select($nodeattrib, $value);
    $self->open_selected_exclusively();
    return($success);
}

sub open_exclusively {
    my ($self, $opennodenumber) = @_;
    #$self->{debug} .= "open_exclusively($opennodenumber)<br>";
    $self->SUPER::open_exclusively($opennodenumber);
    $self->select_first_open_leaf($opennodenumber);
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

    $bgcolor   = $self->{bgcolor}   || "#cccccc";
    $width     = $self->{width}     || "100%";
    $fontface  = $self->{fontface}  || "verdana,geneva,arial,sans-serif";
    $fontsize  = $self->{fontsize}  || "-2";
    $fontcolor = $self->{fontcolor} || "#ffffff";

    $bgcolor = " bgcolor=\"$bgcolor\"";

    #$fontbegin = "<font face=\"$fontface\" size=\"$fontsize\" color=\"$fontcolor\">";
    #$fontend   = "</font>";

    my ($nodebase, $nodeidx, $nodenumber, $nodelabel, $parentnodenumber, $nodelevel, $opennodenumber);
    my (@nodeidx, $selected_nodenumber, $w);

    $selected_nodenumber = $self->{selected};
    @nodeidx = split(/\./,$selected_nodenumber);

    $html_url_dir = $context->get_option("html_url_dir");
    $xgif = "$html_url_dir/images/Widget/dot_clear.gif";

    $html = $self->{debug} || "";

    $nodelevel = 0;
    $nodebase = "";
    if (defined $node->{1} && !defined $node->{2}) {
        $nodelevel = 1;
        $nodebase = "1.";
    }
    for (; $nodelevel <= $#nodeidx; $nodelevel++) {
        $html .= '<table border="0" cellpadding="0" cellspacing="0" width="100%">' . "\n";
        $html .= "  <tr><td rowspan=\"3\" width=\"1%\" height=\"19\" nowrap>";

        $nodeidx = 1;
        $nodenumber = "$nodebase$nodeidx"; # create its node number
        while (defined $node->{$nodenumber}) {

            $label = $node->{$nodenumber}{label};
            $label = $node->{$nodenumber}{value} if (!defined $label);
            $label = "" if (!defined $label);

            $w = $context->widget("$name-button$nodenumber",
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
        $html .= "    <td height=16 width=\"99%\"$bgcolor><img src=transp.gif height=16 width=1></td>\n";
        $html .= "    <td height=\"16\" width=\"99%\"></td>\n";
        $html .= "  </tr>\n";
        $html .= "  <tr>\n";
        $html .= "    <td height=\"1\" width=\"99%\" bgcolor=\"#000000\"><img src=\"$xgif\" height=\"1\" width=\"1\"></td>\n";
        $html .= "  </tr>\n";
        $html .= "  <tr>\n";
        $html .= "    <td height=\"2\" width=\"99%\" bgcolor=\"#ffffff\"><img src=\"$xgif\" height=\"2\" width=\"1\"></td>\n";
        $html .= "  </tr>\n";
        $html .= "</table>\n";
    }

    $html;
}

1;
