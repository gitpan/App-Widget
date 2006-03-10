
######################################################################
## $Id: Widget.pm 3551 2006-02-28 22:02:31Z spadkins $
######################################################################

package App::Widget;
$VERSION = do { my @r=(q$Revision: 3551 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::SessionObject;
@ISA = ( "App::SessionObject" );

use strict;

=head1 NAME

App::Widget - a family of web user interface widgets (works with App::Context), enabling development of UI's and UI components as compound, nested sets of other UI components

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
#        if ($name =~ /^(.+)-[a-zA-Z][a-zA-Z0-9_]*$/) {
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

    if (defined $self->{content}) {
        my $content = $self->{content};
        $self->{content} = "";
        &App::sub_exit($content) if ($App::trace);
        return($content);
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
    my $options = $context->{options};
    my $response = $context->response();
    my $context_head = $options->{"app.html.head"} || "";
    my $context_body = "";
    if ($response->{include}{css_list}) {
        my $items = $response->{include}{css_list};
        foreach my $item (@$items) {
            if ($item =~ /^</) {
                $context_head .= $item;
            }
            else {
                $context_head .= "<link href=\"$item\" type=\"text/css\" rel=\"stylesheet\"></script>\n";
            }
        }
    }
    if ($response->{include}{javascript}) {
        my $items = $response->{include}{javascript_list};
        foreach my $item (@$items) {
            if ($item =~ /^</) {
                $context_head .= $item;
            }
            else {
                $context_head .= "<script src=\"$item\" type=\"text/javascript\" language=\"JavaScript\"></script>\n";
            }
        }
    }

    #$context_head = $self->{context}->head_html();
    #$context_body = $self->{context}->body_html(\%main::conf);

    my $session_html = $context->session()->html();
    my $event_placeholder = '<input type="hidden" id="app-event-aux" name="app.event" value="">';

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
$event_placeholder
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
# set_alternative_content()
#############################################################################

=head2 set_alternative_content()

    * Signature: $service->set_alternative_content($content, $extension);
    * Param:     $content        string
    * Param:     $extension      string
    * Return:    void
    * Throws:    App::Exception
    * Since:     0.01

    Sample Usage:

    $service->set_alternative_content("red,green,blue\n1,2,3\n", "csv");

=cut

sub set_alternative_content {
    &App::sub_entry if ($App::trace);
    my ($self, $content, $extension) = @_;
    $self->{content}   = $content;
    $self->{extension} = $extension;
    &App::sub_exit() if ($App::trace);
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

my %content_type = (
    html => "text/html",
    txt  => "text/plain",
    pdf  => "application/pdf\nContent-disposition: attachment; filename=\"data.pdf\"",
    xls  => "application/vnd.ms-excel\nContent-disposition: attachment; filename=\"data.xls\"",
    xml  => "application/xml",
    csv  => "application/octet-stream\nContent-disposition: attachment; filename=\"data.csv\"",
    bin  => "application/octet-stream\nContent-disposition: attachment; filename=\"data.bin\"",
);

sub content_type {
    &App::sub_entry if ($App::trace);
    my ($self) = @_;
    my $extension = $self->{extension} || "html";
    delete $self->{extension} if (!defined $self->{content});
    my $content_type = $content_type{$extension};
    if (!$content_type) {
        $content_type = $content_type{bin};
    }
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
    &App::sub_entry if ($App::trace);
    my ($self, $text) = @_;
    if (!defined $text) {
        $text = "";
    }
    elsif ($text) {
        $text =~ s{&}{&amp;}gso;
        $text =~ s{<}{&lt;}gso;
        $text =~ s{>}{&gt;}gso;
        $text =~ s{\"}{&quot;}gso;
    }
    &App::sub_exit($text) if ($App::trace);
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

