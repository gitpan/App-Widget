
#############################################################################
## $Id: TemplateToolkit.pm,v 1.1 2003/03/22 04:04:37 spadkins Exp $
#############################################################################

package App::TemplateEngine::TemplateToolkit;

use App;
use App::TemplateEngine;
@ISA = ( "App::TemplateEngine" );

use strict;

=head1 NAME

App::TemplateEngine::TemplateToolkit - Interface for rendering HTML templates using the Template Toolkit

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

This implementation does the rendering using the Template Toolkit.

=cut

#############################################################################
# CLASS
#############################################################################

=head1 Class: App::TemplateEngine

 * Throws: App::Exception::TemplateEngine
 * Since:  0.01

A TemplateEngine Service is a means by which a template (such as an
HTML template) may be rendered (with variables interpolated).

This implementation does the rendering using the Template Toolkit.

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
    my ($self, $template) = @_;

    my ($template_text, $values, $text);
    $template_text = $self->read_template($template);
    $values = $self->prepare_values();
    $text = $self->substitute($template_text, $values);
    $text;
}

#############################################################################
# PROTECTED METHODS
#############################################################################

=head1 Protected Methods:

=cut

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
    my ($self) = @_;

    my ($session, %values);
    $session = $self->{context}->session();

    # OK. I'm breaking some of the encapsulation.
    # They say Perl is post-modern. ;-)

    if (defined $session->{cache}{Widget}{session} &&
        ref($session->{cache}{Widget}{session}) eq "HASH") {
        %values = %{$session->{cache}{Widget}{session}}; # make a copy
    }
    if (defined $session->{cache}{Widget} && ref($session->{cache}{Widget}) eq "HASH") {
        $values{WIDGET} = $session->{cache}{Widget};  # add ref to higher level
    }
    if (defined $session->{cache} && ref($session->{cache}) eq "HASH") {
        $values{SESSION} = $session->{cache};         # add ref to higher level
    }
    $values{CTX} = $self->{context};

    return(\%values);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <stephen.adkins@officevision.com>
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

L<C<App::Context>|App::Context>,
L<C<App::Service>|App::Service>

=cut

1;

