
######################################################################
## $Id: HierView.pm,v 1.4 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::HierView;
$VERSION = do { my @r=(q$Revision: 1.4 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::HierView - A generic hierarchical view

=head1 SYNOPSIS

   use App::Widget::HierView;

   $name = "tree";
   $w = App::Widget::HierView->new($name);
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
for a TreeView, a Menu, a ToolbarSet, or a SelectorView.
The main function of a HierView is to display a hierarchical set of
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
        if ($wname =~ /^(.*)\.([^.]+)$/) {
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

sub open_exclusively {
    my ($self, $opennodenumber) = @_;
    my ($nodebase, $nodeidx, $nodenumber);
    my $node = $self->get("node");
    $self->set("node", $node);

    $nodebase = $opennodenumber;
    if ($nodebase =~ /(.*)\.[^\.]+$/) {
        $nodebase = $1 . ".";
    }
    else {
        $nodebase = "";
    }
    $nodeidx = 1;

    while (1) {
        $nodenumber = "$nodebase$nodeidx";
        last if (!defined $node->{$nodenumber});
        $node->{$nodenumber}{open} = 0;
        $nodeidx++;
    }

    if (defined $node->{$opennodenumber}) {
        $node->{$opennodenumber}{open} = 1;
    }

    if (!defined $node->{"$opennodenumber.1"}) {
        $self->set("selected", $opennodenumber);
    }
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

