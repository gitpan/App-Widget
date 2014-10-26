
######################################################################
## $Id: TreeSelector.pm 3465 2005-08-09 19:26:19Z spadkins $
######################################################################

package App::Widget::TreeSelector;
$VERSION = do { my @r=(q$Revision: 3465 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget::HierSelector;
@ISA = ( "App::Widget::HierSelector" );

use strict;

=head1 NAME

App::Widget::TreeSelector - An HTML tree view

=head1 SYNOPSIS

   use App::Widget::TreeSelector;

   $name = "get_data";
   $w = App::Widget::TreeSelector->new($name);
   print $w->html();

=cut

=head1 DESCRIPTION

This class implements a graphical tree view such as is used in
Windows Explorer.

=cut

######################################################################
# INITIALIZATION
######################################################################

# uncomment this when I need to do more than just call SUPER::_init()
#sub _init {
#   my $self = shift;
#   $self->SUPER::_init(@_);
#}

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my ($context, $name, $node);
    $context      = $self->{context};
    $name    = $self->{name};
    $node    = $self->get("node");

    my ($nodebase, $nodeidx, $nodenumber, $nodelevel, $maxnodelevel);
    my (@nextnodebase, @nextnodeidx, @nextnodelevel, @shownnodenumber, @shownnodelevel);

    @nextnodebase  = ("");   # the next nodenumber to check is "$nodebase$nodeidx" (nodenumber = "1" is first)
    @nextnodeidx   = (1);    # check nodenumber "1" next
    @nextnodelevel = (1);    # index into the resulting table that the folder icon will go
    @shownnodenumber = ();   # list of the nodenumbers which are to be shown
    @shownnodelevel  = ();   # the levels at which those shown nodes exist
    $maxnodelevel    = 0;

    while ($#nextnodebase > -1) {
        $nodebase  = pop(@nextnodebase);   # get info about next node to check
        $nodeidx   = pop(@nextnodeidx);
        $nodelevel = pop(@nextnodelevel);
        $nodenumber = "$nodebase$nodeidx"; # create its node number

        if (defined $node->{$nodenumber}) {      # if the node exists...
            push(@shownnodenumber, $nodenumber); #   take note that it exists so that we can display it
            push(@shownnodelevel,  $nodelevel);  #   take note of its depth (so we display it properly)
            push(@nextnodebase,    $nodebase);   #   let's search for the node's brother (same depth, next idx)
            push(@nextnodeidx,     $nodeidx+1);  #   (next idx)
            push(@nextnodelevel,   $nodelevel);  #   (same level)
            $maxnodelevel = $nodelevel+1 if ($nodelevel+1 > $maxnodelevel);  # maxnodelevel will be # cols in table

            if ($node->{$nodenumber}{open}) {           # if the node is open...
                push(@nextnodebase,  "${nodenumber}."); #   let's search for the node's children (1 deeper, idx 1)
                push(@nextnodeidx,   1);                #   (idx is 1)
                push(@nextnodelevel, $nodelevel+1);     #   (1 deeper)
            }
        }
    }

    my ($row, $col, $row2, @colislink);
    my ($html_url_dir, $imgstart, $imgend, $imgbuttonstart, $imgbuttonend);
    my ($html, $label, $colspan, $isparent, $open);

    for ($row = $#shownnodenumber; $row >= 0; $row--) {
        $nodenumber = $shownnodenumber[$row];
        $nodelevel  = $shownnodelevel[$row];
        $col = $nodelevel - 1;
        for ($row2 = $row-1; $row2 >= 0; $row2--) {
            $colislink[$row2][$col] = 1;
            last if ($shownnodelevel[$row2] == $nodelevel - 1);
        }
    }

    $html_url_dir   = $self->{context}->get_option("html_url_dir");
    $imgstart       = "<img src=\"$html_url_dir/images/TreeSelector/";
    $imgend         = "\" width=\"19\" height=\"16\" border=\"0\"/>";
    $imgbuttonstart = "<input type=\"image\" src=$html_url_dir/images/TreeSelector/";
    $imgbuttonend   = " width=\"19\" height=\"16\" border=\"0\"/>";

    $html = "";
    $html .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";

    for ($row = 0; $row <= $#shownnodenumber; $row++) {
        $nodenumber = $shownnodenumber[$row];
        $nodelevel  = $shownnodelevel[$row];
        $html      .= "  <tr>\n";
        for ($col = 0; $col <= $maxnodelevel+1; $col++) {
            if ($col < $nodelevel-1) {
                if ($colislink[$row][$col]) {
                    $html .= "    <td>${imgstart}vbar.gif${imgend}</td>\n";
                }
                else {
                    $html .= "    <td></td>\n";
                }
            }
            elsif ($col == $nodelevel-1) {
                $isparent = (defined $node->{"$nodenumber.1"});
                $open = $node->{$nodenumber}{open};
                if ($isparent) {
                    if ($open) {
                        $html .= "    <td>${imgbuttonstart}minus.gif name=\"app.event.$name.close($nodenumber)\" ${imgbuttonend}</td>\n";
                    }
                    else {
                        $html .= "    <td>${imgbuttonstart}plus.gif name=\"app.event.$name.open($nodenumber)\" ${imgbuttonend}</td>\n";
                    }
                }
                else {
                    if ($colislink[$row][$col]) {
                        $html .= "    <td>${imgstart}tee.gif${imgend}</td>\n";
                    }
                    else {
                        $html .= "    <td>${imgstart}ell.gif${imgend}</td>\n";
                    }
                }
            }
            elsif ($col == $nodelevel) {
                if ($node->{$nodenumber}{open}) {
                    $html .= "    <td>${imgbuttonstart}ofolder.gif name=\"app.event.$name.select($nodenumber)\" ${imgbuttonend}</td>\n";
                }
                else {
                    $html .= "    <td>${imgbuttonstart}cfolder.gif name=\"app.event.$name.select($nodenumber)\" ${imgbuttonend}</td>\n";
                }
            }
            else {
                $colspan = $maxnodelevel - $nodelevel;
                $label = $node->{$nodenumber}{label};
                $label = $node->{$nodenumber}{value} if (!defined $label);
                $label = "" if (!defined $label);
                $html .= "    <td nowrap colspan=\"$colspan\"><font face=\"verdana,geneva,arial,sans-serif\" size=\"-2\">$label</font></td>\n";
                last;
            }
        }
        $html .= "  </tr>\n";
    }

    $html .= "</table>\n";
    $html;
}

1;

