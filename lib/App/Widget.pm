
######################################################################
## $Id: Widget.pm,v 1.6 2005/01/07 13:52:17 spadkins Exp $
######################################################################

package App::Widget;
$VERSION = do { my @r=(q$Revision: 1.6 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::SessionObject;
@ISA = ( "App::SessionObject" );

use strict;

=head1 NAME

App::Widget - An abstract base class for all Widget::* classes

=head1 SYNOPSIS

   use App::Widget;

=cut

#############################################################################
# PUBLIC METHODS
#############################################################################

=head1 Public Methods:

=cut

#############################################################################
# Method: handle_event()
#############################################################################

=head2 handle_event()

    * Signature: $handled = $self->handle_event($widget_name, $event, @args);
    * Param:     widget_name   string
    * Param:     event         string
    * Param:     @args         ARRAY
    * Return:    $handled      boolean
    * Throws:    App::Exception
    * Since:     0.01

    $handled = $widget->handle_event($widget_name, $event, @args);

=cut

#sub handle_event {
#    &App::sub_entry if ($App::trace);
#    my ($self, $wname, $event, @args) = @_;
#
#    my $handled = 0;
#
#    if ($event eq "noop") {   # handle all known events
#        $handled = 1;
#    }
#    else {
#        my $name = $self->{name};
#        my $container = "default";
#        if ($name =~ /^(.+)\.[a-zA-Z][a-zA-Z0-9_]*$/) {
#            $container = $1;
#        }
#        my $context = $self->{context};
#        if ($container eq "default") {
#print "Widget($name).handle_event($wname, $event, @args)\n";
#            if (!defined $self->{messages}) {
#                $self->{messages}  = "Event not handled: {$wname}.$event(@args)";
#            }
#            else {
#                $self->{messages} .= "\nEvent not handled: {$wname}.$event(@args)";
#            }
#print "Widget($name).handle_event($wname, $event, @args)\n";
#print "Widget($name).handle_event() self=[$self] messages=[$self->{messages}]\n";
#            $handled = 1;
#        }
#        else {
#            my $w = $context->session_object($container);
#            $handled = $w->handle_event($wname, $event, @args);  # bubble the event to container session_object
#        }
#    }
#
#    &App::sub_exit($handled) if ($App::trace);
#    return($handled);
#}

#############################################################################
# Method: content()
#############################################################################

=head2 content()

    * Signature: $content = $self->content();
    * Param:     void
    * Return:    $content   any
    * Throws:    App::Exception
    * Since:     0.01

    $content = $so->content();
    if (ref($content)) {
        App::Reference->print($content);
        print "\n";
    }
    else {
        print $content, "\n";
    }

=cut

sub content {
    &App::sub_entry if ($App::trace);
    my $self = shift;

    my ($html);
    eval {
        $html = $self->html();
    };
    if ($@) {
        my ($name, $msg);
        if (ref($@) eq "") {  # i.e. a string thrown with "die"
            $msg = $@;
        }
        elsif ($@->isa("App::Exception")) {
            $msg = $@->error . "\n" . $@->trace->as_string . "\n";
        }
        else {
            $@->rethrow();
        }
        $msg =~ s{&}{&amp;}gso;
        $msg =~ s{<}{&lt;}gso;
        $msg =~ s{>}{&gt;}gso;
        $msg =~ s{\"}{&quot;}gso;
        $msg =~ s{\n}{<br>\n}gso;
        $name = $self->{name};
        $html = <<EOF;
<table border="1" cellspacing="0">
<tr><td bgcolor="#aaaaaa">
<b>Widget Display Error: $name</b><br>
</td></tr>
<tr><td bgcolor="#ffaaaa">
<font size="-1" face="sans-serif">
$msg
</font>
</td></tr>
</table>
EOF
    }

    my ($title, $bodyoptions, $w, $var, $value);

    $title = "Widget";
    $bodyoptions = "";
    if (ref($self)) {
        $title = $self->get("title");
        $title = $self->get("name") if (!$title);
        foreach $var ('bgcolor', 'text', 'link', 'vlink', 'alink',
                      'leftmargin', 'topmargin', 'rightmargin', 'bottommargin') {
            $value = $self->get($var);
            if (defined $value && $value ne "") {
                $bodyoptions .= " $var=\"$value\"";
            }
            elsif ($var eq "bgcolor") {
                $bodyoptions .= " $var=\"#ffffff\"";
            }
        }
    }

    my $context = $self->{context};
    my $response = $context->response();
    my $context_head = "";
    my $context_body = "";
    if ($response->{include}{javascript}) {
        my $javascript = $response->{include}{javascript};
        foreach my $url (keys %$javascript) {
            $context_head .= "<script src=\"$url\"></script>\n";
        }
    }

    #$context_head = $self->{context}->head_html();
    #$context_body = $self->{context}->body_html(\%main::conf);

    my $session_html = $context->session()->html();

    my $messages = $context->get_messages() || "";
    if ($messages) {
        $messages =~ s{&}{&amp;}gso;
        $messages =~ s{<}{&lt;}gso;
        $messages =~ s{>}{&gt;}gso;
        $messages =~ s{\"}{&quot;}gso;
        $messages =~ s{\n}{<br>\n}gso;
        $messages = <<EOF;
<table width="100%">
  <tr>
    <td bgcolor="#ffaaaa">
$messages
    </td>
  </tr>
</table>
EOF
        delete $self->{messages};
    }

    my $content = <<EOF;
<html>
<head>
<title>${title}</title>
$context_head</head>
<body${bodyoptions}>
$messages<form method="POST">
$session_html
$context_body
$html
</form>
</body>
</html>
EOF

    &App::sub_exit($content) if ($App::trace);
    return $content;
}

#############################################################################
# content_type()
#############################################################################

=head2 content_type()

    * Signature: $content_type = $service->content_type();
    * Param:     void
    * Return:    $content_type   string
    * Throws:    App::Exception
    * Since:     0.01

    Sample Usage:

    $content_type = $service->content_type();

=cut

sub content_type {
    &App::sub_entry if ($App::trace);
    my $content_type = 'text/html';
    &App::sub_exit($content_type) if ($App::trace);
    return($content_type);
}

#############################################################################
# PROTECTED METHODS
#############################################################################

=head1 Protected Methods:

=cut

#############################################################################
# user_event_name()
#############################################################################

=head2 user_event_name()

    * Signature: $text = $widget->user_event_name($event,@args);
    * Param:     void
    * Return:    $text              text
    * Throws:    App::Exception::Widget
    * Since:     0.01

    Sample Usage:

    $name = $self->user_event_name("open","folder","1.1");
    $html .= "<input type='submit' name='$name' value='Push Me'>\n";

=cut

# Creates a name suitable for use in <input type=submit> and
# <input type=image> tags that will cause an event to be
# handled when the form is posted back to the web server.
# i.e.

sub user_event_name {
    &App::sub_entry if ($App::trace);
    my ($self, $event, @args) = @_;
    my ($name, $args);
    $name = $self->{name};
    $args = "";
    $args = "(" . join(",",@args) . ")" if ($#args > -1);
    my $result = "app.event.{${name}}.${event}${args}";
    &App::sub_exit($result) if ($App::trace);
    return($result);
}

#############################################################################
# callback_event_tag()
#############################################################################

=head2 callback_event_tag()

    * Signature: $text = $widget->callback_event_tag($event,@args);
    * Param:     void
    * Return:    $text              text
    * Throws:    App::Exception::Widget
    * Since:     0.01

    Sample Usage:

    $html .= $self->callback_event_tag("open","folder","1.1");

=cut

# Creates an <input type=hidden> tag that will cause an event to be
# automatically handled when the form is posted back to the web server.

sub callback_event_tag {
    &App::sub_entry if ($App::trace);
    my ($self, $event, @args) = @_;
    my ($name, $args);
    $name = $self->{name};
    $args = "";
    $args = "(" . join(",",@args) . ")" if ($#args > -1);
    my $result = "<input type=hidden name='app.event' value='${name}.${event}${args}'/>";
    &App::sub_exit($result) if ($App::trace);
    return($result);
}

# unescape URL-encoded data
sub url_unescape {
   my $self = shift;
   my($todecode) = @_;
   $todecode =~ tr/+/ /;       # pluses become spaces
   $todecode =~ s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
   return $todecode;
}

# URL-encode data
sub url_escape {
   my $self = shift;
   my ($toencode,$charset) = @_;
   if ($charset) {
      $toencode=~s/($charset)/uc sprintf("%%%02x",ord($1))/eg;
   }
   else {
      $toencode=~s/([^a-zA-Z0-9_\-. ])/uc sprintf("%%%02x",ord($1))/eg;
      $toencode =~ tr/ /+/;       # spaces become pluses
   }
   return $toencode;
}

# HTML-escape data
sub html_escape {
   my ($self, $text) = @_;
   return "" if (!defined $text || $text eq "");
   $text =~ s{&}{&amp;}gso;
   $text =~ s{<}{&lt;}gso;
   $text =~ s{>}{&gt;}gso;
   $text =~ s{\"}{&quot;}gso;
   return $text;
}

sub html_attribs {
   my ($self) = @_;
   my $html_attribs = "";
   if ($self->{attrib}) {
      my $attrib_value = $self->{attrib};
      foreach my $attrib (keys %$attrib_value) {
         $html_attribs .= " $attrib=\"$attrib_value->{$attrib}\"";
      }
   }
   return($html_attribs);
}

sub html {
   my ($self) = @_;
   return $self->html_escape($self->{name});
}

# get the URL of the host
sub host_url {
   my ($url, $protocol, $server, $port, $port_str);

   $protocol = "http";                            # assume it's vanilla HTTP
   $protocol = "https" if (defined $ENV{HTTPS});  # this is how Apache does it

   $server = $ENV{SERVER_NAME};
   $server = "localhost" if (!$server);

   $port = $ENV{SERVER_PORT};
   $port = "80" if (!$port);

   $port_str = "";
   if ($protocol eq "http") {
      $port_str = ($port == 80) ? "" : ":$port";
   }
   elsif ($protocol eq "https") {
      $port_str = ($port == 443) ? "" : ":$port";
   }

   $url = "${protocol}://${server}${port_str}";
   $url;
}

1;

