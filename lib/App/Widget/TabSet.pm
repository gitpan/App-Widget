
######################################################################
## $Id: TabSet.pm,v 1.3 2003/05/19 17:41:18 spadkins Exp $
######################################################################

package App::Widget::TabSet;
$VERSION = do { my @r=(q$Revision: 1.3 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::TabSet - An application frame.

=head1 SYNOPSIS

   $name = "office";

   # official way
   use Widget;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::TabSet;
   $w = App::Widget::TabSet->new($name);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class implements an application frame.
This includes a menu, an application toolbar, a screen selector, 
a screen title, a screen toolbar, and 
a screen frame.  The application is actually implemented by the set
of screens that the application frame is configured to allow navigation
to.

The application frame can implement itself in frames if it is
configured to do so.  Otherwise, it implements itself as a table.

=cut

######################################################################
# INITIALIZATION
######################################################################

# no special initialization

######################################################################
# EVENTS
######################################################################

sub handle_event {
    my ($self, $wname, $event, @args) = @_;
    my ($context, $name, $node);
    my ($selector_widget, $screen_wname, $screen_widget, $screen_settings);
    my ($screen_msg, $target);

    $name = $self->{name};
    $context   = $self->{context};

    if ($wname eq "$name.selector" && $event eq "select") {
        $selector_widget = $context->widget("$name.selector");
        $screen_wname    = $selector_widget->get_selected("wname");
        $screen_widget   = $context->widget($screen_wname);

        $screen_settings = $selector_widget->get_selected("set");
        $self->{context}->dbgprint("TabSet->handle_event($wname, $event, @args): $screen_settings [",
            join(",",%$screen_settings), "]")
            if ($App::DEBUG && $self->{context}->dbg(1));
        if ($screen_settings) {
            foreach (keys %$screen_settings) {
                $screen_widget->set($_, $screen_settings->{$_});
            }
            return 1;
        }

        $screen_msg = $selector_widget->get_selected("send");
        if ($screen_msg && ref($screen_msg) eq "ARRAY" && $#$screen_msg >= 1) {
            my ($target_widget, $target_wname, $method, @args);
            ($target_wname, $method, @args) = @$screen_msg;
            $target_widget = $context->widget($target_wname);
            $target_widget->$method(@args);
        }

        my $frame = $selector_widget->get_selected("frame");
        if (defined $frame) {
            my ($key);
            foreach $key (keys %$frame) {
                $self->set($key,$frame->{$key});
            }
        }

        my $target = $selector_widget->get_selected("target");
        if ($target) {
            $main::target = $target;
        }

        $self->{noframe} = $selector_widget->get_selected("noframe");

        return 1;
    }
    else {
        return $self->SUPER::handle_event($wname, $event, @args);
    }
}


######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my ($context, $name, $html);
    $name = $self->{name};
    $context = $self->{context};

    my ($selector_widget, $selector);
    my ($screen_wname, $screen, $screen_widget, $screen_bgcolor);

    if (1) {     # view as table

        $selector_widget = $context->widget("$name.selector",
                               class => "App::Widget::TabbedView",
                           );

        $selector        = $selector_widget->html();
        $screen_wname    = $selector_widget->get_selected("wname");

        if ($screen_wname) {
            $screen_widget     = $context->widget($screen_wname);
            $screen            = $screen_widget->html();
            $screen_bgcolor    = $screen_widget->get("bgcolor","#cccccc");
        }
        else {
            $screen            = "&nbsp;";
            $screen_bgcolor    = "#cccccc";
        }

        if ($self->{noframe}) {
            return $screen;    # no need to generate a frame
        }

        $html = <<EOF;
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top">
      $selector
    </td>
    <td valign="top" bgcolor="$screen_bgcolor">
      $screen
    </td>
  </tr>
</table>
EOF
    }
    $html;
}


1;
