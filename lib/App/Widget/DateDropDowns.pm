
######################################################################
## $Id: DateDropDowns.pm 3464 2005-08-09 19:25:46Z spadkins $
######################################################################

package App::Widget::DateDropDowns;
$VERSION = do { my @r=(q$Revision: 3464 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget::StylizableContainer;
@ISA = ( "App::Widget::StylizableContainer" );

use strict;

=head1 NAME

App::Widget::DateDropDowns - A three-dropdown widget for a date

=head1 SYNOPSIS


=cut

######################################################################
# CONSTANTS
######################################################################

my @dayvalues = (
    "01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
    "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
    "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
    "31",
);

my @monthvalues = (
    "01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
    "11", "12",
);

my %monthlabels = (
    "01" => "Jan", "02" => "Feb", "03" => "Mar",
    "04" => "Apr", "05" => "May", "06" => "Jun",
    "07" => "Jul", "08" => "Aug", "09" => "Sep",
    "10" => "Oct", "11" => "Nov", "12" => "Dec",
);

my %monthnumbers = (
    "Jan" => "01", "Feb" => "02", "Mar" => "03",
    "Apr" => "04", "May" => "05", "Jun" => "06",
    "Jul" => "07", "Aug" => "08", "Sep" => "09",
    "Oct" => "10", "Nov" => "11", "Dec" => "12",
);

my @days = ( "00", "31", "28", "31", "30", "31", "30", "31", "31", "30", "31", "30", "31" );

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is three dropdowns for a date widget.

=cut

######################################################################
# CONSTRUCTOR
######################################################################

sub _init {
    my $self = shift;
    $self->SUPER::_init(@_);
    my $name = $self->{name};
    my $context = $self->{context};

    # NOTE: container is inferred by the naming convention
    #       otherwise, I should include "container => $name," line
    $context->widget("${name}-day",  # note: container is inferred
        class => "App::Widget::Select",
        values => \@dayvalues,
    );

    $context->widget("${name}-month",
        class => "App::Widget::Select",
        values => \@monthvalues,
        labels => \%monthlabels,
    );

    my ($begin_year, $end_year);
    $begin_year = $self->{begin_year} || 1980;
    $end_year   = $self->{end_year}   || 2010;
    $context->widget("${name}-year",
        class => "App::Widget::Select",
        values => [ $begin_year .. $end_year ],
    );
}

######################################################################
# EVENTS
######################################################################

# Usage: $widget->handle_event($name, $event, @args);
sub handle_event {
    my ($self, $name, $event, @args) = @_;

    if ($event eq "split_date") {
        $self->split_date(@_);
        return 1;
    }
    elsif ($event eq "join_date") {
        $self->join_date(@_);
        return 1;
    }
    elsif ($event eq "change") {   # i.e. onChange
        $self->change(@_);
        return 1;
    }
    else {
        return $self->SUPER::handle_event(@_);
    }
}

# NOTE: internal format of dates is YYYY-MM-DD
#       display is three drop-downs: DD Mon YYYY
sub split_date {
    my $self = shift;
    my ($date, $day, $month, $year);
    $date  = $self->get_value();
    return if (!$date);
    if ($date =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})$/) {
        $year  = $1;
        $month = $2;
        $day   = $3;
        $self->set("year", $year);
        $self->set("month", $month);
        $self->set("day", $day);
    }
}

sub get_value {
    my $self = shift;
    my ($date, $day, $month, $year);
    $date  = $self->SUPER::get_value();
    return ($date) if (!$date);
    return ($date) if ($date =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/);
    if ($date =~ /([0-9]{4}-[0-9]{2}-[0-9]{2})/) {
        $date = $1;
    }
    elsif ($date =~ /([0-9]{4})([0-9]{2})([0-9]{2})/) {
        $date = "$1-$2-$3";
    }
    elsif ($date =~ /([0-9]{2})-(...)-([0-9]{4})/) {
        $date = "$3-$monthnumbers{$2}-$1";
    }
    $self->set_value($date);
    return ($date);
}

sub join_date {
    my $self = shift;
    my ($date, $day, $month, $year);
    $year  = $self->get("year");
    $month = $self->get("month");
    $day   = $self->get("day");

    if ($day le $days[$month]) {
        # success. day is valid. do nothing.
    }
    elsif ($month eq "02") {
        my $isleap = ( (($year % 4) == 0) && ( (($year % 100) != 0) || (($year % 400) == 0) ) );
        $day = $isleap ? "29" : "28";
        $self->set("day",$day);
    }
    else {
        $day = $days[$month];
        $self->set("day",$day);
    }

    $date  = "${year}-${month}-$day";
    $self->set_value($date);
}

sub change {
    my $self = shift;
    $self->join_date();
}

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my ($context, $name);

    $context = $self->{context};
    $name = $self->{name};

    $self->split_date();

    return 
        $context->widget("${name}-day")->html() .
        $context->widget("${name}-month")->html() .
        $context->widget("${name}-year")->html() .
        $self->callback_event_tag("change");
}

1;

