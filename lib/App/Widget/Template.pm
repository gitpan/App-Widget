
######################################################################
## $Id: Template.pm,v 1.2 2002/10/25 19:50:19 spadkins Exp $
######################################################################

package App::Widget::Template;
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::Template - An HTML widget built from a template, rendered by a TemplateEngine

=head1 SYNOPSIS

   use App::Widget::Template;

=cut

#############################################################################
# ATTRIBUTES
#############################################################################

=head1 Attributes

  templateEngine  - The name of the TemplateEngine service that will do the
                    rendering. If not given, the name "default" will be used.
  templateName    - The name of the template that should be rendered.
                    If not given, the widget name is changed to a template
                    name by changing dots (".") to slashes ("/") and
                    appending ".html".

=cut

#############################################################################
# PUBLIC METHODS
#############################################################################

=head1 Public Methods

=cut

#############################################################################
# html()
#############################################################################

=head2 html()

    * Signature: $html = $w->html();
    * Param:  void
    * Return: $html        text
    * Throws: App::Blue::Exception
    * Since:  0.01

    Sample Usage: 

    print $w->html();

The html() method returns the HTML output of the Template as rendered through
its TemplateEngine.

Note: By using the App::Widget::Template, the developer or
deployer is guaranteeing that the output of the template will be valid HTML.
If this is not the case, perhaps the App::Widget::Template is the
correct widget class to use instead.

=cut

sub html {
    my $self = shift;

    my ($name);
    my ($html, $template_name, $template_engine);

    $self->{context}->dbgprint("App::Widget::Template(",
            $self->{name}, ")->html()")
        if ($App::DEBUG && $self->{context}->dbg(1));

    $name = $self->{name};
    $template_name = $self->{templateName};
    if (!$template_name) {
        $template_name = $name;
        $template_name =~ s/\./\//g;
        $template_name .= ".html";
    }

    $template_engine = $self->{context}->template_engine($self->{templateEngine});
    $html = $template_engine->render($template_name);

    return $html;
}

1;

