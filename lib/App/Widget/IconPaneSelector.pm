
######################################################################
## $Id: IconPaneSelector.pm 3465 2005-08-09 19:26:19Z spadkins $
######################################################################

package App::Widget::IconPaneSelector;
$VERSION = do { my @r=(q$Revision: 3465 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget::HierSelector;
@ISA = ( "App::Widget::HierSelector" );

use strict;

=head1 NAME

App::Widget::IconPaneSelector - A screen selector widget

=head1 SYNOPSIS

   use App::Widget::IconPaneSelector;

   $name = "get_data";
   $w = App::Widget::IconPaneSelector->new($name);
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
    $context      = $self->{context};
    $name    = $self->{name};
    $node    = $self->get("node");

    my ($bgcolor, $fontface, $fontsize, $fontcolor, $fontbegin, $fontend);

    $bgcolor   = $self->get("bgcolor",   "#888888");
    $fontface  = $self->get("fontface",  "verdana,geneva,arial,sans-serif");
    $fontsize  = $self->get("fontsize",  "-2");
    $fontcolor = $self->get("fontcolor", "#ffffff");

    $fontbegin = "<font face=\"$fontface\" size=\"$fontsize\" color=\"$fontcolor\">";
    $fontend   = "</font>";

    my ($nodebase, $nodeidx, $nodenumber, $nodelabel, $parentnodenumber, $nodelevel, $opennodenumber);
    my (@nextnodebase, @nextnodeidx, @nextnodelevel);

    @nextnodebase  = ("");   # the next nodenumber to check is "$nodebase$nodeidx" (nodenumber = "1" is first)
    @nextnodeidx   = (1);    # check nodenumber "1" next
    @nextnodelevel = (1);    # index into the resulting table that the folder icon will go

    $html = <<EOF;
<table border="0" cellpadding="0" cellspacing="0" height="100%" width="1%">
  <tr>
    <td bgcolor="$bgcolor" align="center" valign="top">$fontbegin
EOF

    $opennodenumber = 9999;

    while ($#nextnodebase > -1) {
        $nodebase  = pop(@nextnodebase);   # get info about next node to check
        $nodeidx   = pop(@nextnodeidx);
        $nodelevel = pop(@nextnodelevel);
        $nodenumber = "$nodebase$nodeidx"; # create its node number

        if (defined $node->{$nodenumber}) {      # if the node exists...

            if ($nodelevel == 1) {
                
                $opennodenumber = $nodenumber if ($node->{$nodenumber}{open});
                if ($nodenumber == $opennodenumber+1) {
                    $html .= <<EOF;
    <p>&nbsp;$fontend</td>
  </tr>
  <tr>
    <td bgcolor="$bgcolor" align="center" valign="bottom">$fontbegin
EOF
                }

                $label = $node->{$nodenumber}{label};
                $label = $node->{$nodenumber}{value} if (!defined $label);
                $label = "" if (!defined $label);
                $html .= $context->widget("$name-button$nodenumber",
                    class => "App::Widget::ImageButton",
                    image_script => "app-button",
                    volatile     => 1,
                    height       => "19",
                    width        => "98",
                    bevel        => "2",
                    label        => $label,
                    event_target => $name,
                    event        => "open_exclusively",
                    args         => $nodenumber,
                )->html();
                $html .= "<br>\n";

            }
            else {

                $icon = $node->{$nodenumber}{icon};
                if (!defined $icon) {
                    $parentnodenumber = $nodenumber;
                    $parentnodenumber =~ s/\.[^.]+$//;
                    $icon = $node->{$parentnodenumber}{icon};
                }
                $icon = "notes.gif" if (!defined $icon);

                $label = $node->{$nodenumber}{label};
                $label = $node->{$nodenumber}{value} if (!defined $label);
                $label = "" if (!defined $label);
                $nodelabel = $nodenumber;
                $nodelabel =~ s/\./_/g;

                $html .= "<p>";
                $html .= $context->widget("$name-button$nodelabel",
                    class        => "App::Widget::ImageButton",
                    image        => "images/IconPaneSelector/$icon",
                    height       => "36",
                    width        => "36",
                    label        => $label,
                    event        => "select",
                    event_target => $name,
                    args         => $nodenumber,
                )->html();
                $html .= "<br>$label\n";
            }

            push(@nextnodebase,    $nodebase);   #   let's search for the node's brother (same depth, next idx)
            push(@nextnodeidx,     $nodeidx+1);  #   (next idx)
            push(@nextnodelevel,   $nodelevel);  #   (same level)

            if ($node->{$nodenumber}{open} || $nodelevel > 1) {
                push(@nextnodebase,  "${nodenumber}."); #   let's search for the node's children (1 deeper, idx 1)
                push(@nextnodeidx,   1);                #   (idx is 1)
                push(@nextnodelevel, $nodelevel+1);     #   (1 deeper)
            }
        }
    }

    $html .= <<EOF;
    $fontend</td>
  </tr>
</table>
EOF

    $html;
}

1;

