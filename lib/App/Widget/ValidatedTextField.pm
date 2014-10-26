
######################################################################
## $Id: ValidatedTextField.pm,v 1.3 2003/05/19 17:41:18 spadkins Exp $
######################################################################

package App::Widget::ValidatedTextField;
$VERSION = do { my @r=(q$Revision: 1.3 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget::TextField;
@ISA = ( "App::Widget::TextField" );

use strict;

=head1 NAME

App::Widget::ValidatedTextField - An HTML text field

=head1 SYNOPSIS

   $name = "first_name";
   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);
   # OR ...
   $w = $context->widget($name,
      class => "App::Widget::ValidatedTextField",
      size  => 8,                 # from HTML spec
      maxlength => 18,            # from HTML spec
      tabindex => 1,              # from HTML spec
      style => "mystyle",         # from HTML to support CSS
      color => "#6666CC",         # from CSS spec
      fontSize => "10px",        # from CSS spec
      borderStyle => "solid",    # from CSS spec
      borderWidth => "1px",      # from CSS spec
      borderColor => "#6666CC",  # from CSS spec
      padding => "2px",           # from CSS spec
      backgroundColor => "#ccffcc",           # from CSS spec
      fontFamily => "Verdana, Geneva, Arial", # from CSS spec
      override => 1,              # increase precedence of following options to "override" from "default"
      validate => "date",         # not impl. yet ("date", "time", "datetime", "enum", "number", "integer", ":regexp")
      #autocomplete => \@previous_choices,  # not impl. yet
   );

   # internal way
   use App::Widget::ValidatedTextField;
   $w = App::Widget::ValidatedTextField->new($name);

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
# METHODS
######################################################################

sub set_value {
    my ($self, $value) = @_;
    my ($validate);
    $validate = $self->get("validate");
    $value = $self->format($validate,$value) if ($validate);
    $self->{context}->wset_value($self->{name}, $value);
}

sub get_value {
    my ($self) = @_;

    my ($validate, $value, $newvalue);
    $validate = $self->get("validate");

    $value = $self->{context}->wget($self->{name}, "");
    $value = "" if (!defined $value);
    if ($validate) {
        $newvalue = $self->format($validate,$value);
        if ($newvalue ne $value) {
            $self->{context}->wset_value($self->{name}, $value);
            $value = $newvalue;
        }
    }
    return $value;
}

# OBSOLETE: use set_value(), get_value()
#sub value {
#    my ($self, $value) = @_;
#
#    my ($validate, $newvalue);
#    $validate = $self->get("validate");
#
#    if (defined $value) {
#        $value = $self->format($validate,$value) if ($validate);
#        $self->{context}->wset_value($self->{name}, $value);
#    }
#    else {
#        $value = $self->{context}->wget($self->{name}, "");
#        if ($validate) {
#            $newvalue = $self->format($validate,$value);
#            if (!defined $value || $newvalue ne $value) {
#                $self->{context}->wset_value($self->{name}, $value);
#                $value = $newvalue;
#            }
#        }
#        return $value;
#    }
#}

sub format {
    my ($self, $validate, $text) = @_;
    if ($validate eq "date") {
        return $self->format_date($text);
    }
    #elsif ($validate eq "datetime") {
    #    return $self->format_datetime($text);
    #}
    #elsif ($validate eq "time") {
    #    return $self->format_time($text);
    #}
    elsif ($validate eq "ssn") {
        return $self->format_ssn($text);
    }
    elsif ($validate eq "mixedcase") {
        return $self->format_mixedcase($text);
    }
    elsif ($validate eq "zip") {
        return $self->format_zip($text);
    }
    elsif ($validate eq "phone") {
        return $self->format_phone($text);
    }
    elsif ($validate eq "integer") {
        return $self->format_integer($text);
    }
    elsif ($validate eq "float") {
        return $self->format_float($text);
    }

    return $text;
}

sub format_date {
    my ($self, $datetext) = @_;
    return "" if (!$datetext);
    return $datetext if ($datetext =~ /^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$/);    # correct format: 1999-12-31

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

sub format_phone {
    my ($self, $phonetext) = @_;
    return "" if (!$phonetext);
    return $phonetext if ($phonetext =~ /^[0-9]{3}-[0-9]{3}-[0-9]{4}$/);  # correct format: 213-394-8654
    my ($phone, $ext);
    $phone = $phonetext;
    $phone =~ s/^ +//;         # delete leading spaces
    $phone =~ s/ +$//;         # delete trailing spaces
    $phone =~ s![- \(\)/]!!g;  # delete common telephone number delimiters
    if ($phone =~ /^1?([0-9]{3})([0-9]{3})([0-9]{4})$/) {   # i.e. 1-800-732-4556, 770/933-0551, 404 4322664
        $phone = "$1-$2-$3";
    }
    elsif ($phone =~ /^1?([0-9]{3})([0-9]{3})([0-9]{4})([^0-9].*)/) {   # i.e. 404-432-2664 x352
        $phone = "$1-$2-$3";
        $ext = $4;
        $ext =~ s/^ +//;         # delete leading spaces
        $ext =~ s/ +$//;         # delete trailing spaces
        $phone .= " $ext";  # put the extension back on with a space
    }
    elsif ($phone =~ /^([0-9]{3})([0-9]{4})$/) {   # i.e. 933-0551, 4322664
        $phone = "$1-$2";
    }
    elsif ($phone =~ /^([0-9]{3})([0-9]{4})([^0-9].*)/) {   # i.e. 432-2664 x352
        $phone = "$1-$2";
        $ext = $3;
        $ext =~ s/^ +//;         # delete leading spaces
        $ext =~ s/ +$//;         # delete trailing spaces
        $phone .= " $ext";  # put the extension back on with a space
    }
    else {
        $phone = $phonetext;   # I can't reformat it. I'll return it as it came to me.
    }
    $phone;
}

sub format_zip {
    my ($self, $ziptext) = @_;
    return "" if (!$ziptext);
    return $ziptext if ($ziptext =~ /^[0-9]{5}$/);  # correct format: 213-394-8654
    my $zip = $ziptext;
    $zip =~ s/[- ]//g;      # delete spaces and dashes
    if ($zip =~ /^([0-9]{5})([0-9]{4})?$/) {
        $zip = $1;
        $zip .= "-$2" if ($2 ne "");
    }
    else {
        $zip = $ziptext;   # I can't reformat it. I'll return it as it came to me.
    }
    $zip;
}

sub format_mixedcase {
    my ($self, $text) = @_;
    return "" if (!defined $text);
    my $ftext = $text;
    if ($ftext =~ /[a-z]/ && $ftext !~ /[A-Z]/) {      # all lower-case
        $ftext =~ s/([a-zA-Z])([a-zA-Z]*)/uc($1).lc($2)/ge;
    }
    elsif ($ftext !~ /[a-z]/ && $ftext =~ /[A-Z]/ && length($ftext) > 2) {   # ALL UPPER-CASE
        $ftext =~ s/([a-zA-Z])([a-zA-Z]*)/uc($1).lc($2)/ge;
    }
    else {
        $ftext = $text;   # I can't reformat it. I'll return it as it came to me.
    }
    $ftext;
}

sub format_ssn {
    my ($self, $ssntext) = @_;
    my $ssn = $ssntext;
    $ssn =~ s/[- ]//g;      # delete spaces and dashes
    if ($ssn =~ /^([0-9][0-9][0-9])([0-9][0-9])([0-9][0-9][0-9][0-9])$/) {
        $ssn = "$1-$2-$3";
    }
    else {
        $ssn = $ssntext;   # I can't reformat it. I'll return it as it came to me.
    }
    $ssn;
}

sub format_integer {
    my ($self, $inttext) = @_;
    my $int = $inttext;
    $int =~ s/[, ]//g;      # delete spaces and commas
    $int =~ s/^[\+\$]+//;   # delete leading "+" or "$"
    if ($int =~ /^(-?[0-9]+)/) {
        $int = $1;
    }
    else {
        $int = 0;   # I can't find any integer in it. I will return "0".
    }
    $int;
}

sub format_float {
    my ($self, $floattext) = @_;
    my $float = $floattext;
    $float =~ s/[, ]//g;      # delete spaces and commas
    $float =~ s/^[\+\$]+//;   # delete leading "+" or "$"
    if ($float =~ /^(-?[0-9]+\.[0-9]+)/) {
        $float = $1;
    }
    elsif ($float =~ /^(-?[0-9]+)/) {
        $float = $1;
    }
    else {
        $float = 0;   # I can't find any float in it. I will return "0".
    }
    $float;
}

1;

