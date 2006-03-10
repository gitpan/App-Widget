
######################################################################
## $Id: DateField.pm 3491 2005-10-20 20:30:25Z spadkins $
######################################################################

package App::Widget::DateField;
$VERSION = do { my @r=(q$Revision: 3491 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget::TextField;
@ISA = ( "App::Widget::TextField" );

use strict;

=head1 NAME

App::Widget::DateField - An HTML text field

=head1 SYNOPSIS

   $name = "first_name";
   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);
   # OR ...
   $w = $context->widget($name,
      class => "App::Widget::DateField",
      size  => 8,                 # from HTML spec
      maxlength => 18,            # from HTML spec
      style => "mystyle",         # from HTML to support CSS
      color => "#6666CC",         # from CSS spec
      font_size => "10px",        # from CSS spec
      border_style => "solid",    # from CSS spec
      border_width => "1px",      # from CSS spec
      border_color => "#6666CC",  # from CSS spec
      padding => "2px",           # from CSS spec
      background_color => "#ccffcc",           # from CSS spec
      font_family => "Verdana, Geneva, Arial", # from CSS spec
      override => 1,              # increase precedence of following options to "override" from "default"
      #validate => "date",         # not impl. yet ("date", "time", "datetime", "enum", "number", "integer", ":regexp")
      #autocomplete => \@previous_choices,  # not impl. yet
   );

   # internal way
   use App::Widget::DateField;
   $w = App::Widget::DateField->new($name);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is a <input type=text> HTML element.

=cut

######################################################################
# INITIALIZATION
######################################################################

# no special initialization

######################################################################
# EVENTS
######################################################################

# no events

######################################################################
# METHODS
######################################################################

sub value {
    my ($self, $value) = @_;
    if (defined $value) {
        if ($value !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
            $value = $self->format_date($value);
        }
        $self->{context}->wvalue($self->{name}, $value);
    }
    else {
        $value = $self->{context}->wvalue($self->{name});
        if ($value ne "" && $value !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
            $value = $self->format_date($value);
            $self->{context}->wvalue($self->{name}, $value);
        }
        return $value;
    }
}

sub get_value {
    my ($self, $default, $setdefault) = @_;
    $self->{context}->wget($self->{name}, "", $default, $setdefault);
}

sub fget_value {
    my ($self, $format) = @_;
    $format = $self->get("format") if (!defined $format);
    if (! defined $format) {
        return $self->{context}->wget($self->{name}, "", "");
    }
    else {
        my ($value, $type);
        $type = $self->get("validate");
        $value = $self->{context}->wget($self->{name}, "", "");
        if ($type) {
            $value = App::Widget->format($value, $type, $format);
        }
        return $value;
    }
}

sub get_values {
    my ($self, $default, $setdefault) = @_;
    my $values = $self->{context}->wget($self->{name}, "", $default, $setdefault);
    return (ref($values) eq "ARRAY") ? @$values : ($values);
}

sub format_date {
    my ($self, $datetext) = @_;
    my ($monthtext, $mon, $day, $year, %mon, $date);
    if ($datetext =~ /\b([a-zA-Z]+)[- ]+([0-9]{1,2})[- ,]+([0-9]{2,4})\b/) {  # i.e. December 31, 1999, 9-march-01
        $monthtext = $1;
        $day = $2;
        $year = $3;
    }
    elsif ($datetext =~ /\b([0-9]{1,2})[- ]+([a-zA-Z]+)[- ]+([0-9]{2,4})\b/) {  # i.e. 31-Dec-1999, 9 march 01
        $day = $1;
        $monthtext = $2;
        $year = $3;
    }
    elsif ($datetext =~ /\b([0-9]{4})([0-9]{2})([0-9]{2})\b/) {     # i.e. 19991231, 20010309
        $year = $1;
        $mon = $2;
        $day = $3;
    }
    elsif ($datetext =~ m!\b([0-9]{4})[- /]+([0-9]{1,2})[- /]+([0-9]{1,2})\b!) { # i.e. 1999-12-31, 2001/3/09
        $year = $1;
        $mon = $2;
        $day = $3;
    }
    elsif ($datetext =~ m!\b([0-9]{1,2})[- /]+([0-9]{1,2})[- /]+([0-9]{2,4})\b!) {  # i.e. 12/31/1999, 3-9-01
        $mon = $1;
        $day = $2;
        $year = $3;
    }
    else {
        return("");
    }
    if ($monthtext) {
        if    ($monthtext =~ /^jan/i) { $mon =  1; }
        elsif ($monthtext =~ /^feb/i) { $mon =  2; }
        elsif ($monthtext =~ /^mar/i) { $mon =  3; }
        elsif ($monthtext =~ /^apr/i) { $mon =  4; }
        elsif ($monthtext =~ /^may/i) { $mon =  5; }
        elsif ($monthtext =~ /^jun/i) { $mon =  6; }
        elsif ($monthtext =~ /^jul/i) { $mon =  7; }
        elsif ($monthtext =~ /^aug/i) { $mon =  8; }
        elsif ($monthtext =~ /^sep/i) { $mon =  9; }
        elsif ($monthtext =~ /^oct/i) { $mon = 10; }
        elsif ($monthtext =~ /^nov/i) { $mon = 11; }
        elsif ($monthtext =~ /^dec/i) { $mon = 12; }
        else                          { return("");  }
    }
    if ($year < 0) { return(""); }
    elsif ($year < 50) { $year += 2000; }
    elsif ($year < 100) { $year += 1900; }
    elsif ($year < 1000) { return(""); }
    return("") if ($mon > 12);
    return("") if ($day > 31);
    sprintf("%04d-%02d-%02d",$year,$mon,$day);
}

1;

