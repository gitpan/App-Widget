
######################################################################
## $Id: DualListSelect.pm,v 1.5 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::DualListSelect;
$VERSION = do { my @r=(q$Revision: 1.5 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App::Widget::StylizableContainer;
@ISA = ( "App::Widget::StylizableContainer" );

use strict;

=head1 NAME

App::Widget::DualListSelect - An ordered multi-select widget made up of two HTML <select> tags and four buttons

=head1 SYNOPSIS

   use App::Widget::DualListSelect;

   ...

=cut

my $NONE = "[-None-]";

sub _init {
    my $self = shift;
    my $name = $self->{name};
    my $context = $self->{context};

    my $size     = $self->{size} || 5;
    my $tabindex = $self->{tabindex};
    my @select_attribs = ("multiple", 1, "size", $size);
    push(@select_attribs, "tabindex", $tabindex) if (defined $tabindex);

    my ($values, $labels) = $self->values_labels();

    $context->widget("${name}.unselected",
        class => "App::Widget::Select",
        labels => $labels,
        @select_attribs,
        lightweight => 1,
    );

    $context->widget("${name}.selected",
        class => "App::Widget::Select",
        labels => $labels,
        @select_attribs,
        lightweight => 1,
    );

    if ($self->{noimagebuttons}) {
        $context->widget("${name}.select_button",
            class => "App::Widget::Button",
            label       => " >> ",
            event       => "select",
            event_target => $name,
            lightweight => 1,
        );

        $context->widget("${name}.unselect_button",
            class => "App::Widget::Button",
            label       => " << ",
            event       => "unselect",
            event_target => $name,
            lightweight => 1,
        );

        $context->widget("${name}.up_button",
            class => "App::Widget::Button",
            label       => " Up ",
            event       => "move_up",
            event_target => $name,
            lightweight => 1,
        );

        $context->widget("${name}.dn_button",
            class => "App::Widget::Button",
            label       => " Dn ",
            event       => "move_down",
            event_target => $name,
            lightweight => 1,
        );
    }
    else {
        $context->widget("${name}.select_button",
            class => "App::Widget::ImageButton",
            image       => "images/DualListSelect/rtarrow.gif",
            height      => "19",
            width       => "19",
            label       => "Select",
            event       => "select",
            event_target => $name,
            lightweight => 1,
        );
    
        $context->widget("${name}.unselect_button",
            class => "App::Widget::ImageButton",
            image       => "images/DualListSelect/lfarrow.gif",
            height      => "19",
            width       => "19",
            label       => "Unselect",
            event       => "unselect",
            event_target => $name,
            lightweight => 1,
        );
    
        $context->widget("${name}.up_button",
            class => "App::Widget::ImageButton",
            image       => "images/DualListSelect/uparrow.gif",
            height      => "19",
            width       => "19",
            label       => "Up",
            event       => "move_up",
            event_target => $name,
            lightweight => 1,
        );
    
        $context->widget("${name}.dn_button",
            class => "App::Widget::ImageButton",
            image       => "images/DualListSelect/dnarrow.gif",
            height      => "19",
            width       => "19",
            label       => "Down",
            event       => "move_down",
            event_target => $name,
            lightweight => 1,
        );
    }
    my @curr_values = $self->get_values();
    $self->SUPER::_init(@_);
}

######################################################################
# EVENTS
######################################################################

# Usage: $widget->handle_event($event, @args);
sub handle_event {
    my ($self, $wname, $event, @args) = @_;

    my $name = $self->{name};
    my $context = $self->{context};

    my $success = 0;
    if ($event eq "select") {
        $success = $self->select();
    }
    elsif ($event eq "unselect") {
        $success = $self->unselect();
    }
    elsif ($event eq "move_up") {
        $success = $self->move_up();
    }
    elsif ($event eq "move_down") {
        $success = $self->move_down();
    }
    else {
        $success = $self->SUPER::handle_event($wname, $event, @args);
    }
    return($success);
}

######################################################################
# METHODS
######################################################################

sub select {
    my ($self) = @_;
    my $unselected = $self->{unselected};
    my @values = $self->get_values();
    if ($unselected) {
        if ($#values > -1) {
            push(@values, @$unselected);
        }
        else {
            @values = @$unselected;
        }
    }
    $self->set_value(\@values);
    return 1;
}

sub unselect {
    my ($self) = @_;
    my $selected = $self->{selected};
    my @values = $self->get_values();
    my (%unselected, @newvalues);
    foreach my $value (@$selected) {
        $unselected{$value} = 1;
    }
    foreach my $value (@values) {
        if (!$unselected{$value}) {
            push(@newvalues, $value);
        }
    }
    $self->set_value(\@newvalues);
    return 1;
}

sub move_up {
    my ($self) = @_;
    my $selected = $self->{selected};
    my @values = $self->get_values();
    my (%moved, @newvalues, $value);
    foreach $value (@$selected) {
        $moved{$value} = 1;
    }
    for (my $i = 0; $i < $#values; $i++) {
        if ($moved{$values[$i+1]} && !$moved{$values[$i]}) {
            $value = $values[$i+1];
            $values[$i+1] = $values[$i];
            $values[$i] = $value;
        }
    }
    $self->set_value(\@values);
    return 1;
}

sub move_down {
    my ($self) = @_;
    my $selected = $self->{selected};
    my @values = $self->get_values();
    my (%moved, @newvalues, $value);
    foreach $value (@$selected) {
        $moved{$value} = 1;
    }
    for (my $i = $#values; $i > 0; $i--) {
        if ($moved{$values[$i-1]} && !$moved{$values[$i]}) {
            $value = $values[$i-1];
            $values[$i-1] = $values[$i];
            $values[$i] = $value;
        }
    }
    $self->set_value(\@values);
    return 1;
}

######################################################################
# OUTPUT METHODS
######################################################################

sub _set_child_widget_values {
    my ($self, $values) = @_;

    my $name = $self->{name};
    my $context = $self->{context};
    my $domain = $self->{domain};
    my $allvalues = $context->value_domain($domain)->values();

    my @selected_list = $self->get_values();
    my @unselected_list = ();
    my ($value, %value_exists, $value_exists);

    foreach $value (@selected_list) {
        if (defined $value) {
            $value_exists{$value} = 1;
            $value_exists = 1;
        }
    }

    for (my $v = 0; $v <= $#$allvalues; $v++) {
        $value = $allvalues->[$v];
        if (!$value_exists{$value}) {
            push(@unselected_list, $value);
        }
    }

    push(@selected_list, $NONE) if ($#selected_list == -1);
    push(@unselected_list, $NONE) if ($#unselected_list == -1);

    $context->widget("$name.selected")->{values}   = \@selected_list;
    $context->widget("$name.unselected")->{values} = \@unselected_list;
    $context->so_delete($name, "selected");
    $context->so_delete($name, "unselected");
}

sub html {
    my $self = shift;

    my $context  = $self->{context};
    my $name     = $self->{name};

    $self->_set_child_widget_values();

    my $unselected_list = $context->widget("${name}.unselected")->html();
    my $selected_list   = $context->widget("${name}.selected")->html();
    my $select_button   = $context->widget("${name}.select_button")->html();
    my $unselect_button = $context->widget("${name}.unselect_button")->html();
    my $up_button       = $context->widget("${name}.up_button")->html();
    my $dn_button       = $context->widget("${name}.dn_button")->html();

    my $var_hidden = "";
    # my $var_hidden = $self->callback_event_tag("restore");

    my $html = <<EOF;
<table border=0 cellspacing=3>
<tr>
   <td align=center valign=middle rowspan=2>$unselected_list</td>
   <td align=center valign=bottom>$select_button</td>
   <td align=center valign=middle rowspan=2>$selected_list</td>
   <td align=center valign=bottom>$up_button</td>
</tr>
<tr>
   <td align=center valign=top>$unselect_button</td>
   <td align=center valign=top>$dn_button</td>
</tr>
<tr>
   <td align=center valign=top>Not Selected</td>
   <td align=center valign=top>&nbsp;</td>
   <td align=center valign=top>Selected</td>
</tr>
</table>
$var_hidden
EOF

    $html;
}

1;
