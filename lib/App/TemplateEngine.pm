
#############################################################################
## $Id: TemplateEngine.pm 3462 2005-08-09 19:19:21Z spadkins $
#############################################################################

package App::TemplateEngine;

use App;
use App::Service;
@ISA = ( "App::Service" );

use strict;

=head1 NAME

App::TemplateEngine - Interface for rendering HTML templates

=head1 SYNOPSIS

    use App;

    $context = App->context();
    $template_engine = $context->service("TemplateEngine");  # or ...
    $template_engine = $context->template_engine();

    $template = "index.html";
    $text = $template_engine->render($template);

=head1 DESCRIPTION

A TemplateEngine Service is a means by which a template (such as an
HTML template) may be rendered (with variables interpolated).

=cut

#############################################################################
# CLASS GROUP
#############################################################################

=head1 Class Group: TemplateEngine

The following classes might be a part of the TemplateEngine Class Group.

=over

=item * Class: App::TemplateEngine

=item * Class: App::TemplateEngine::TemplateToolkit

=item * Class: App::TemplateEngine::Embperl

=item * Class: App::TemplateEngine::Mason

=item * Class: App::TemplateEngine::AxKit

=item * Class: App::TemplateEngine::ASP

=item * Class: App::TemplateEngine::CGIFastTemplate

=item * Class: App::TemplateEngine::TextTemplate

=item * Class: App::TemplateEngine::HTMLTemplate

=back

=cut

#############################################################################
# CLASS
#############################################################################

=head1 Class: App::TemplateEngine

A TemplateEngine Service is a means by which a template (such as an
HTML template) may be rendered (with variables interpolated).

 * Throws: App::Exception::TemplateEngine
 * Since:  0.01

=head2 Class Design

...

=cut

#############################################################################
# CONSTRUCTOR METHODS
#############################################################################

=head1 Constructor Methods:

=cut

#############################################################################
# new()
#############################################################################

=head2 new()

The constructor is inherited from
L<C<App::Service>|App::Service/"new()">.

=cut

#############################################################################
# PUBLIC METHODS
#############################################################################

=head1 Public Methods:

=cut

#############################################################################
# render()
#############################################################################

=head2 render()

    * Signature: $text = $template_engine->render($template);
    * Param:     $template          string
    * Return:    $text              text
    * Throws:    App::Exception::TemplateEngine
    * Since:     0.01

    Sample Usage:

    $text = $template_engine->render($template);

=cut

sub render {
    &App::sub_entry if ($App::trace);
    my ($self, $template) = @_;

    my ($template_text, $values, $text);
    $template_text = $self->read_template($template);
    $values = $self->prepare_values();
    $text = $self->substitute($template_text, $values);
    &App::sub_exit($text) if ($App::trace);
    $text;
}

#############################################################################
# PROTECTED METHODS
#############################################################################

=head1 Protected Methods:

=cut

#############################################################################
# Method: service_type()
#############################################################################

=head2 service_type()

Returns 'TemplateEngine';

    * Signature: $service_type = App::TemplateEngine->service_type();
    * Param:     void
    * Return:    $service_type  string
    * Since:     0.01

    $service_type = $template_engine->service_type();

=cut

sub service_type () { 'TemplateEngine'; }

#############################################################################
# read_template()
#############################################################################

=head2 read_template()

    * Signature: $template_text = $template_engine->read_template($template);
    * Param:     $template          string
    * Return:    $template_text     text
    * Throws:    App::Exception::TemplateEngine
    * Since:     0.01

    Sample Usage:

    $template_text = $template_engine->read_template($template);

=cut

sub read_template {
    &App::sub_entry if ($App::trace);
    my ($self, $template) = @_;

    my ($template_dir, $template_text);
    local(*App::FILE);
    $template_dir = $self->{template_dir};
    $template_dir = $self->{context}->get_option("template_dir") if (!$template_dir);
    $template_dir = "templates" if (!$template_dir);

    if (open(App::FILE,"< $template_dir/$template")) {
        $template_text = join("",<App::FILE>);
        close(App::FILE);
    }
    else {
        # maybe we should throw an exception here
        $template_text = "Template [$template_dir/$template] not found.";
    }

    &App::sub_exit($template_text) if ($App::trace);
    return($template_text);
}

#############################################################################
# prepare_values()
#############################################################################

=head2 prepare_values()

    * Signature: $values = $template_engine->prepare_values();
    * Param:     void
    * Return:    $values            {}
    * Throws:    App::Exception::TemplateEngine
    * Since:     0.01

    Sample Usage:

    $values = $template_engine->prepare_values();

=cut

sub prepare_values {
    &App::sub_entry if ($App::trace);
    my ($self) = @_;

    #my ($session, %values);
    #$session = $self->{context}->session();

    #if (defined $session->{cache}{SessionObject}{session} &&
    #    ref($session->{cache}{SessionObject}{session}) eq "HASH") {
    #    %values = %{$session->{cache}{SessionObject}{session}}; # make a copy
    #}
    #if (defined $session->{cache}{SessionObject} && ref($session->{cache}{SessionObject}) eq "HASH") {
    #    $values{SESSIONOBJECT} = $session->{cache}{SessionObject};  # add ref to higher level
    #}
    #if (defined $session->{cache} && ref($session->{cache}) eq "HASH") {
    #    $values{SESSION} = $session->{cache};         # add ref to higher level
    #}

    my $values = $self->{context}->options();

    &App::sub_exit($values) if ($App::trace);
    return($values);
}

#############################################################################
# substitute()
#############################################################################

=head2 substitute()

    * Signature: $text = $template_engine->substitute($template_text, $values);
    * Param:     $template_text     string
    * Param:     $values            {}
    * Return:    $text              text
    * Throws:    App::Exception::TemplateEngine
    * Since:     0.01

    Sample Usage:

    $text = $template_engine->substitute($template_text, $values);

=cut

sub substitute {
    &App::sub_entry if ($App::trace);
    my ($self, $template_text, $values) = @_;

    my ($phrase, $var, $value, $context, $expand);
    $context = $self->{context};
    $values = {} if (! defined $values);

    while ( $template_text =~ /\[%(\+?)([^%]+)%\]/ ) {  # vars of the form [%var%] or [%+var%]
        $expand = $1;
        $var    = $2;
        if ($expand) {
            eval {
                $value = $context->widget($var)->html();
            };
            $value = "[$var: $@]" if ($@);
        }
        elsif (defined $values->{$var}) {
            $value = $values->{$var};
        }
        else {
            $value = $context->so_get($var);
            $value = $values->{$var} if (!defined $value);
            $value = "" if (!defined $value);
        }
        $template_text =~ s/\[%\+$var%\]/$value/g;
    }

    while ( $template_text =~ /\{(\+?)([a-zA-Z][a-zA-Z0-9_.-]*)\}/ ) {  # vars of the form {var} or {+var}
        $expand = $1;
        $var    = $2;
        if ($expand) {
            eval {
                $value = $context->widget($var)->html();
            };
            $value = "[$var: $@]" if ($@);
        }
        elsif (defined $values->{$var}) {
            $value = $values->{$var};
        }
        else {
            $value = $context->so_get($var);
            $value = $values->{$var} if (!defined $value);
            $value = "" if (!defined $value);
        }
        $template_text =~ s/\{$var\}/$value/g;
    }

    &App::sub_exit($template_text) if ($App::trace);
    $template_text;
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <stephen.adkins@officevision.com>
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

L<C<App::Context>|App::Context>,
L<C<App::Service>|App::Service>

=cut

1;

