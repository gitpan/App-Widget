
######################################################################
## $Id: HierSelector.pm 3550 2006-02-28 20:39:11Z spadkins $
######################################################################

package App::Widget::HierSelector;
$VERSION = do { my @r=(q$Revision: 3550 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::HierSelector - A generic hierarchical view

=head1 SYNOPSIS

   use App::Widget::HierSelector;

   $name = "tree";
   $w = App::Widget::HierSelector->new($name);
   print $w->html();

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################
# {node}{number}{type}       # whether open or closed
# {node}{number}{open}       # 1=open 0=closed
# {node}{number}{value}      #
# {node}{number}{label}      #
# {node}{number}{icon}       # icon to use (default, closed)
# {node}{number}{openicon}   # icon to use when open (optional)
# {node}{number}{hovericon}  # icon to use when cursor over icon

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class implements a generic hierarchical view such as is useful
for a TreeSelector, a Menu, a ToolbarSet, or an IconPaneSelector.
The main function of a HierSelector is to display a hierarchical set of
data and allow the user to generate events based on that view.

=cut

######################################################################
# INITIALIZATION
######################################################################

# uncomment this when I need to do more than just call SUPER::_init()
sub _init {
    my $self = shift;
    $self->SUPER::_init(@_);
}

######################################################################
# EVENTS
######################################################################

# Usage: $widget->handle_event($wname, $event, @args);
sub handle_event {
    my ($self, $wname, $event, @args) = @_;
    my ($node, $nodenumber, $x, $y);

    $node = $self->get("node");
    $self->set("node", $node);

    if ($event eq "open") {
        ($nodenumber, $x, $y) = @args;
        $node->{$nodenumber}{open} = 1;
    }
    elsif ($event eq "open_exclusively") {
        ($nodenumber, $x, $y) = @args;
        $self->open_exclusively($nodenumber);
    }
    elsif ($event eq "close") {
        ($nodenumber, $x, $y) = @args;
        $node->{$nodenumber}{open} = 0;
    }
    elsif ($event eq "select") {
        ($nodenumber, $x, $y) = @args;
        $self->set("selected", $nodenumber);  # save node number
        # intentionally bubble "select" event to the container
        if ($wname =~ /^(.*)-([^.]+)$/) {
            my $parent = $1;
            my $result = $self->{context}->widget($parent)->handle_event($wname, $event, @args);
            return $result;
        }
    }
    else {
        return $self->SUPER::handle_event($wname, $event, @args);
    }
    return 1;
}

sub select_first {
    my $self = shift;
    my $node = $self->get("node");
    
    my ($nodebase, $nodeidx, $nodenumber, $nodenumberfound, $nodelevel);
    my (@nextnodebase, @nextnodeidx, @nextnodelevel);

    @nextnodebase  = ("");   # the next nodenumber to check is "$nodebase$nodeidx" (nodenumber = "1" is first)
    @nextnodeidx   = (1);    # check nodenumber "1" next
    @nextnodelevel = (1);    # index into the resulting table that the folder icon will go

    $nodenumberfound = "";
    while ($#nextnodebase > -1) {
        $nodebase  = pop(@nextnodebase);   # get info about next node to check
        $nodeidx   = pop(@nextnodeidx);
        $nodelevel = pop(@nextnodelevel);
        $nodenumber = "$nodebase$nodeidx"; # create its node number

        if (defined $node->{$nodenumber}) {      # if the node exists...

            if ($nodelevel > 1) {                # we have found the first node below the uppermost level
                $nodenumberfound = $nodenumber;
                last;
            }

            push(@nextnodebase,    $nodebase);   #   let's search for the node's brother (same depth, next idx)
            push(@nextnodeidx,     $nodeidx+1);  #   (next idx)
            push(@nextnodelevel,   $nodelevel);  #   (same level)

            push(@nextnodebase,  "${nodenumber}."); #   let's search for the node's children (1 deeper, idx 1)
            push(@nextnodeidx,   1);                #   (idx is 1)
            push(@nextnodelevel, $nodelevel+1);     #   (1 deeper)
        }
    }
    if ($nodenumberfound) {
        $self->set("selected", $nodenumberfound);
        my $basenodenumber = $nodenumberfound;
        $basenodenumber =~ s/\..*//;
        $self->open_exclusively($basenodenumber);
    }
    else {
        $self->open_exclusively("1");
    }
}

sub select {
    my ($self, $nodeattrib, $value) = @_;
    my $node = $self->get("node");
    my $success = 0;
    foreach my $nodenumber (keys %$node) {
        if ($node->{$nodenumber}{$nodeattrib} eq $value) {
            $self->set("selected", $nodenumber);
            $success = 1;
            last;
        }
    }
    return($success);
}

sub open_selected_exclusively {
    my ($self) = @_;
    $self->open_exclusively($self->{selected});
}

# i.e. $self->open_exclusively("2.2");
# this should "open" 2 and close 1,3,4,5,...
# this should "open" 2.2 and close 2.1,2.3,2.4,...
# if "2.2.1" exists, it should set the first open to the "selected"
# else it should set itself "2.2" as the "selected"
sub open_exclusively {
    my ($self, $opennodenumber) = @_;
    my ($nodebase, $nodeidx, $nodenumber);
    my $node = $self->get("node");
    # set after get to ensure a deep data structure is stored in the session
    $self->set("node", $node);

    $nodebase = $opennodenumber;   # i.e. "2.2.3", "2.2" or "2"
    if ($nodebase =~ /(.*)\.[^\.]+$/) {  # all but the last number
        $nodebase = $1 . ".";      # i.e. "2.2.",  "2."
    }
    else {
        $nodebase = "";            # if top level, $nodebase is blank ""
    }
    $nodeidx = 1;

    while (1) {
        $nodenumber = "$nodebase$nodeidx";
        last if (!defined $node->{$nodenumber});
        $node->{$nodenumber}{open} = 0;  # close all others at this level
        $nodeidx++;
    }

    if (defined $node->{$opennodenumber}) {
        $node->{$opennodenumber}{open} = 1;  # open this one
    }

    # Hmmm. I don't think I should be selecting anything here... just opening/closing.
    if (!defined $node->{"$opennodenumber.1"}) {
        $self->set("selected", $opennodenumber);
    }
}

# i.e. $self->select_first_open_leaf("2.2");
# this should scan 2.2.1 through 2.2.n for the first open
# this should "open" 2.2 and close 2.1,2.3,2.4,...
# if "2.2.1" exists, it should set the first open to the "selected"
# else it should set itself "2.2" as the "selected"
sub select_first_open_leaf {
    my ($self, $selected_nodenumber) = @_;

    my $node = $self->{node};
    my $nodebase = $selected_nodenumber;
    my $nodeidx = 1;
    my ($nodenumber);
    my $found = 0;

    while (!$found) {
        $nodenumber = "$nodebase.$nodeidx";
        if (!defined $node->{$nodenumber}) {
            if ($nodeidx == 1) {  # there are no leaves. $nodebase must be a leaf.
                $self->set("selected", $nodebase);
                $found = 1;
            }
            else {  # no "open" leaves on this branch
                $node->{"$nodebase.1"}{open} = 1;
                $self->set("selected", "$nodebase.1");
                $found = 1;
            }
        }
        elsif ($node->{$nodenumber}{open}) {
            $nodebase = $nodenumber;
            $nodeidx  = 1;
        }
        else {
            $nodeidx++;
        }
    }
    #$self->{debug} .= "select_first_open_leaf($selected_nodenumber): [$nodenumber]<br>";
}

######################################################################
# METHODS
######################################################################

sub get_selected {
    my ($self, $nodeattrib) = @_;
    my ($node, $nodenumber);

    $nodenumber = $self->get("selected");
    return undef if (!defined $nodenumber);
    return $nodenumber if (!defined $nodeattrib);

    $node = $self->get("node");
    return $node->{$nodenumber}{$nodeattrib};
}

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my ($node, $html, $label);

    $node    = $self->get("node");

    my ($nodebase, $nodeidx, $nodenumber, $nodelevel);
    my (@nextnodebase, @nextnodeidx, @nextnodelevel);

    @nextnodebase  = ("");   # the next nodenumber to check is "$nodebase$nodeidx" (nodenumber = "1" is first)
    @nextnodeidx   = (1);    # check nodenumber "1" next
    @nextnodelevel = (1);    # index into the resulting table that the folder icon will go

    $html = "";
    while ($#nextnodebase > -1) {
        $nodebase  = pop(@nextnodebase);   # get info about next node to check
        $nodeidx   = pop(@nextnodeidx);
        $nodelevel = pop(@nextnodelevel);
        $nodenumber = "$nodebase$nodeidx"; # create its node number

        if (defined $node->{$nodenumber}) {      # if the node exists...
            $label = $node->{$nodenumber}{label};
            $label = $node->{$nodenumber}{value} if (!defined $label);
            $label = "" if (!defined $label);
            $html .= ("&nbsp;&nbsp;" x ($nodelevel-1)) if ($nodelevel > 1);
            $html .= $label;
            $html .= $node->{$nodenumber}{open} ? " (open)" : " (closed)";
            $html .= "<br>\n";

            push(@nextnodebase,    $nodebase);   #   let's search for the node's brother (same depth, next idx)
            push(@nextnodeidx,     $nodeidx+1);  #   (next idx)
            push(@nextnodelevel,   $nodelevel);  #   (same level)

            push(@nextnodebase,  "${nodenumber}."); #   let's search for the node's children (1 deeper, idx 1)
            push(@nextnodeidx,   1);                #   (idx is 1)
            push(@nextnodelevel, $nodelevel+1);     #   (1 deeper)
        }
    }

    $html;
}

1;

