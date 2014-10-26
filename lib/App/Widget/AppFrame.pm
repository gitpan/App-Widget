
######################################################################
## $Id: AppFrame.pm,v 1.6 2005/08/09 19:25:46 spadkins Exp $
######################################################################

package App::Widget::AppFrame;
$VERSION = do { my @r=(q$Revision: 1.6 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::AppFrame - An application frame.

=head1 SYNOPSIS

   $name = "office";

   # official way
   use Widget;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::AppFrame;
   $w = App::Widget::AppFrame->new($name);

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

    if ($wname eq "$name-selector" && $event eq "select") {
        $selector_widget = $context->widget("$name-selector");
        $screen_wname    = $selector_widget->get_selected("wname");
        $screen_widget   = $context->widget($screen_wname);
        $screen_settings = $selector_widget->get_selected("set");

        if ($screen_settings) {
            foreach (keys %$screen_settings) {
                $screen_widget->set($_, $screen_settings->{$_});
            }
        }
        else {
            $screen_msg = $selector_widget->get_selected("send");
            if ($screen_msg && ref($screen_msg) eq "ARRAY" && $#$screen_msg >= 1) {
                my ($target_widget, $target_wname, $method, @args);
                ($target_wname, $method, @args) = @$screen_msg;
                $target_widget = $context->widget($target_wname);
                $target_widget->$method(@args);
            }
        }

        #my $frame = $selector_widget->get_selected("frame");
        #if (defined $frame) {
        #    my ($key);
        #    foreach $key (keys %$frame) {
        #        $self->set($key,$frame->{$key});
        #    }
        #}

        #my $target = $selector_widget->get_selected("target");
        #if ($target) {
        #    $main::target = $target;
        #}

        #$self->{noframe} = $selector_widget->get_selected("noframe");

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

    my ($menu, $toolbar, $screentitle, $screentoolbar);
    my ($selector_widget, $selector);
    my ($screen_wname, $screen, $screen_widget, $screen_bgcolor);
    my ($screentitle_widget, $screentitle_bgcolor, $screentitle_value);

    if (1) {     # view as table

        $menu            = $context->widget("$name-menu",
                               class => "App::Widget::Menu",
                           )->html();

        $toolbar         = $context->widget("$name-toolbar",
                               class => "App::Widget::Toolbar",
                           )->html();

        $screentoolbar   = $context->widget("$name-screentoolbar",
                               class => "App::Widget::Toolbar",
                           )->html();

        $selector_widget = $context->widget("$name-selector",
                               class => "App::Widget::IconPaneSelector",
                           );

        $selector        = $selector_widget->html();
        $screen_wname    = $selector_widget->get_selected("wname");

        if ($screen_wname) {
            $screen_widget     = $context->widget($screen_wname);
            $screentitle_value = $selector_widget->get_selected("value");
            $screentitle_value = $screen_widget->label() if (!$screentitle_value);
            if ($screen_widget->can("html")) {
                $screen        = $screen_widget->html();
            }
            else {
                $screen        = "[$screen_wname: not yet defined]";
            }
            $screen_bgcolor    = $screen_widget->get("bgcolor");
            $screen_bgcolor    = "#ffffff" if (!defined $screen_bgcolor);
        }
        else {
            $screentitle_value = "&nbsp;";
            $screen            = "&nbsp;";
            $screen_bgcolor    = "#cccccc";
        }

        #if ($self->{noframe}) {
        #    return $screen;    # no need to generate a frame
        #}

        #$screentitle_widget = $context->widget("$name-screentitle",
        #    -label     => $screentitle_value,
        #    -bgcolor   => "#888888",
        #);
        #$screentitle_bgcolor = $screentitle_widget->get("bgcolor");
        #$screentitle = $screentitle_widget->html();

        $screentitle_bgcolor = "#888888";
        $screentitle = "<font face=verdana,geneva,arial,sans-serif size=+1 color=#ffffff>$screentitle_value</font>";

#  <tr>
#    <td colspan="2" valign="top" height="1%">
#      $menu
#    </td>
#  </tr>
#  <tr>
#    <td colspan="2" valign="top" height="1%">
#      $toolbar
#    </td>
#  </tr>
#  <tr>
#    <td valign="top" height="1%">
#      $screentoolbar
#    </td>
#  </tr>

        my ($messages, $messagebox);
        $messages = $context->get_messages();
        $messages =~ s/\n/<br>\n/g;
        $messagebox = "";
        if (defined $messages && $messages ne "") {
            my ($elem_begin, $elem_end, $font_face, $font_size, $font_color);
            $font_face  = $self->{font_face} || "verdana,geneva,arial,sans-serif";
            $font_size  = $self->{font_size} || "+1";
            $font_color = $self->{font_color};
            $elem_begin = "";
            $elem_end = "";
            if ($font_face || $font_size || $font_color) {
                $elem_begin = "<font";
                $elem_begin .= " face=\"$font_face\""   if ($font_face);
                $elem_begin .= " size=\"" . ($font_size+1) . "\""   if ($font_size);
                $elem_begin .= " color=\"$font_color\"" if ($font_color);
                $elem_begin .= ">";
                $elem_end = "</font>";
            }

            $messagebox = <<EOF;
<table width=100% border=0 cellspacing=0 cellpadding=4>
  <TR>
    <TD>
      <table width=100% border=0 cellspacing=0 cellpadding=4>
        <TR>
          <TD class=body_sub1 valign=top align=left bgcolor=#ffaaaa>$elem_begin<B>Messages</B>$elem_end</TD>
        </TR>
        <TR>
          <TD valign=top align=left class=body_sub2>
            $elem_begin$messages$elem_end
          </TD>
        </TR>
        <TR>
          <TD valign=top align=left height=4></TD>
        </TR>
      </table>
    </td>
  </tr>
</table>
EOF
        }

#        $html = <<EOF;
#<table width="100%" height="100%" border="2" cellspacing="2" cellpadding="0">
#  <tr>
#    <td rowspan="2" valign="top" bgcolor="$screentitle_bgcolor" width="1%" height="100%">
#      $selector
#    </td>
#    <td valign="top" bgcolor="$screentitle_bgcolor" height="1%" class="short">
#      $screentitle
#    </td>
#  </tr>
#  <tr>
#    <td valign="top" bgcolor="$screen_bgcolor" height="99%" class="tall">
#      $messagebox$screen
#    </td>
#  </tr>
#</table>
#EOF

        $html = <<EOF;
<table width="100%" height="100%" border="2" cellspacing="2" cellpadding="0">
  <tr>
    <td rowspan="2" valign="top" bgcolor="$screentitle_bgcolor" width="1%">
      $selector
    </td>
    <td valign="top" bgcolor="$screentitle_bgcolor" height="1%">
      $screentitle
    </td>
  </tr>
  <tr>
    <td valign="top" bgcolor="$screen_bgcolor" height="99%">
      $messagebox$screen
    </td>
  </tr>
</table>
EOF
    }
    $html;
}


1;

