
######################################################################
## $Id: DataTable.pm 3492 2005-10-20 20:32:11Z spadkins $
######################################################################

package App::Widget::DataTable;
$VERSION = do { my @r=(q$Revision: 3492 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::DataTable - An HTML table which serves as a repository table viewer/editor

=head1 SYNOPSIS

   use App::Widget::DataTable;

   $name = "get_data";
   $w = App::Widget::DataTable->new($name);
   print $w->html();

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################
# {border}            = 0;
# {cellspacing}       = 2;
# {cellpadding}       = 0;
# {width}             = "";
# {bgcolor}           = "";
# {nowrap}            = "1";
# {font_face}         = "verdana,geneva,arial,sans-serif";
# {font_size}         = "-2";
# {font_color}        = "";
# {heading_bgcolor}   = "#cccccc";
# {heading_nowrap}    = 0;
# {heading_align}     = 0;
# {heading_valign}    = 0;
# {column_selectable} = 1;
# {row_selectable}    = 0;
# {row_single_selectable} = 0;
# {columns}           = [ "Name", "Address", "City", "State", "Country", "Home Phone" ];
# {headings}          = [ "Name", "Address", "City", "State", "Country", "Home Phone" ];
# {data}              = [ [ "Smith, Harold", "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1810" ],
#                         [ "Smith, Mike",   "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1811" ],
#                         [ "Smith, Sarah",  "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1812" ],
#                         [ "Smith, Ken",    "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1813" ],
#                         [ "Smith, Mary",   "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1814" ], ];
# {startrow}          = 1
# {maxrows}           = 20
# {scrollable}        = 0;
# {sortable}          = 0;
# {filterable}        = 0;
# {editable}          = 0;

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is a <input type=submit> HTML element.
In the advanced configurations, it is rendered as an image button.

=cut

######################################################################
# INITIALIZATION
######################################################################

sub _init {
    &App::sub_entry if ($App::trace);
    my $self = shift;
    $self->SUPER::_init(@_);
    $self->{table} = $self->{name} if (!$self->{table});

    $self->{context}->dbgprint("DataTable->init()")
        if ($App::DEBUG && $self->{context}->dbg(1));
}

######################################################################
# EVENTS
######################################################################

# Usage: $widget->handle_event($event, @args);
sub handle_event {
    &App::sub_entry if ($App::trace);
    my ($self, $wname, $event, @args) = @_;
    my ($name, $context, $colnum, $x, $y, $startrow, $maxrows, $width, $direction);

    #$self->clear_messages();

    $name = $self->{name};
    $self->{context}->dbgprint("DataTable($name)->handle_event($wname,$event,@args)")
        if ($App::DEBUG && $self->{context}->dbg(1));

    my $handled = 0;
    if ($wname eq "$name-view") {
        $self->set("mode","view");
        $self->delete("editdata");
        $handled = 1;
    }
    elsif ($wname eq "$name-edit") {
        $self->set("mode","edit");
        $handled = 1;
    }
    elsif ($wname eq "$name-next") {
        $startrow = $self->get("startrow",1,1);
        $maxrows  = $self->get("maxrows",20,1);
        $startrow += $maxrows;
        $self->set("startrow",$startrow);
        $handled = 1;
    }
    elsif ($wname eq "$name-prev") {
        $startrow = $self->get("startrow",1,1);
        $maxrows  = $self->get("maxrows",20,1);
        $startrow -= $maxrows;
        $startrow = 1 if ($startrow < 1);
        $self->set("startrow",$startrow);
        $handled = 1;
    }
    elsif ($wname eq "$name-save") {
        $self->save();
        $self->delete("editdata");
        $handled = 1;
    }
    elsif ($wname eq "$name-add") {
        $self->{context}->add_message("Add Rows: not yet implemented");
        $handled = 1;
    }
    elsif ($wname eq "$name-delete") {
        $self->{context}->add_message("Delete Rows: not yet implemented");
        $handled = 1;
    }
    elsif ($event eq "sort") {
        ($colnum, $direction) = @args;

        my ($columns, $directions, $order_by, $column, $i);
        $columns    = $self->get_columns();
        $column     = $columns->[$colnum];

        $order_by = $self->get("order_by") || $self->get("ordercols");   # ordercols is deprecated in favor of order_by
        if (defined $order_by) {
            $directions = $self->get("directions");
            $directions = [] if (!defined $directions);
            for ($i = 0; $i <= $#$order_by; $i++) {
                if ($order_by->[$i] eq $column) {
                    splice(@$order_by, $i, 1);     # delete the use of $column
                    splice(@$directions, $i, 1);    # delete the sort direction
                    last;
                }
            }
            unshift(@$order_by, $column);      # put it at the beginning
            unshift(@$directions, $direction);
        }
        else {
            $order_by = [ $column ];
            $directions = [ $direction ];
        }

        $self->set("order_by",$order_by);
        $self->set("directions",$directions);
        $handled = 1;
    }
    elsif ($wname =~ /-sort[0-9]*$/) {
        ($colnum, $x, $y) = @args;
        $context = $self->{context};
        $width = $context->widget($wname)->get("width");
        if ($x <= $width/2) {
            $handled = $self->handle_event($wname, "sort", $colnum, "UP");
        }
        else {
            $handled = $self->handle_event($wname, "sort", $colnum, "DOWN");
        }
    }
    else {
        $handled = $self->SUPER::handle_event(@_);
    }
    &App::sub_exit($handled) if ($App::trace);
    return($handled);
}

######################################################################
# METHODS
######################################################################

sub get_columns {
    &App::sub_entry if ($App::trace);
    my $self = shift;
    my ($columns);
    $columns = $self->{columns};
    if (defined $columns && ref($columns) eq "") {
        $columns = [ $columns ];
        $self->set("columns", $columns);
    }
    if (!defined $columns) {
        my ($repository, $rep, $table);
        $repository = $self->{repository};
        $table      = $self->{table};
        $rep        = $self->{context}->repository($repository);
        if ($rep && $table) {
            $columns = $rep->get_column_names($table);
        }
    }
    $columns = [] if (!defined $columns || ref($columns) eq "");
    &App::sub_exit($columns) if ($App::trace);
    $columns;
}

sub get_headings {
    &App::sub_entry if ($App::trace);
    my $self = shift;
    $self->{context}->dbgprint("DataTable->get_headings()")
        if ($App::DEBUG && $self->{context}->dbg(1));
    my ($table, $headings, $heading, $columns, $column, $lang);
    $table = $self->get("table");
    $columns = $self->get_columns();
    $headings = $self->get("headings");
    $lang = $self->{lang};
    my $column_attribs = $self->{column} || {};
    if (!defined $headings) {
        $headings = [];
        my ($repname, $context, $rep, $columnlabels);
        $repname = $self->get("repository");
        $context  = $self->{context};
        $rep = $context->repository($repname);
        $columnlabels = $rep->get_column_labels($table);
        foreach $column (@$columns) {
            $heading = $column_attribs->{$column}{label} || $columnlabels->{$column} || $column;
            $heading = $self->translate($heading, $lang) if (defined $lang);
            push(@$headings, $heading);
            $self->{context}->dbgprint("DataTable->get_headings(): column=$column(",$#$columns,") heading=$heading(",$#$headings,")")
                if ($App::DEBUG >= 6 && $self->{context}->dbg(6));
        }
    }
    $self->{context}->dbgprint("DataTable->get_headings(): columns=[", join(",", @{$self->get("columns",[])}), "]")
        if ($App::DEBUG && $self->{context}->dbg(1));
    &App::sub_exit($headings) if ($App::trace);
    $headings;
}

sub get_data {
    &App::sub_entry if ($App::trace);
    my $self = shift;
    $self->{context}->dbgprint("DataTable->get_data()")
        if ($App::DEBUG && $self->{context}->dbg(1));
    my ($data);
    $data = $self->{data};
    $data = $self->get("data") if (! defined $data);
    if (!defined $data) {
        $self->load();
        $data = $self->{data};
    }
    &App::sub_exit($data) if ($App::trace);
    return $data;
}

sub load {
    &App::sub_entry if ($App::trace);
    my $self = shift;
    $self->{context}->dbgprint("DataTable->load()")
        if ($App::DEBUG && $self->{context}->dbg(1));
    my ($context, $repname, $rep, $rows, $table, $columns, $sql, $error, $data);
    my ($params, $paramvalues, $param, $paramvalue, @paramvalues);
    my ($startrow, $maxrows, $endrow, $keycolidx);
    my (%paramvalues, $filter, $column);

    $repname = $self->get("repository");
    $context = $self->{context};
    $rep = $context->repository($repname);
    return if (! defined $rep);

    $sql = $self->get("sql");
    $data = $self->get("data");

    if ($sql) {
        $paramvalues = $self->substitute($self->get("paramvalues"));
        $sql         = $self->substitute($sql, $paramvalues);
        $startrow    = $self->get("startrow", 1, 1);
        $maxrows     = $self->get("maxrows", 20, 1);
        $endrow      = ($maxrows != 0) ? ($startrow + $maxrows - 1) : 0;
        $rows        = [ $rep->exec_select($sql, $startrow, $endrow) ];
        $error       = $rep->error();
        if ($#$rows == -1 && $error) {
            $context->add_message("SQL error: $error<br>$sql");
        }
    }
    elsif ($data) {
        $rows = $data;
    }
    else {
        $table = $self->get("table");
    
        $columns = $self->get_columns();
        if (! defined $columns || $#$columns == -1) {
            $columns = $rep->get_column_names($table);
            if (!defined $columns || $#$columns == -1) {
                $context->add_message("No columns specified");
                return;
            }
        }
        else {
            $columns = [ @$columns ];
        }

        $params      = $self->get("params");
        $paramvalues = $self->substitute($self->get("paramvalues",{}));
        %paramvalues = %$paramvalues;
        $filter      = $self->get("filter",{});
        foreach $column (%$filter) {
            $param = $column;
            $paramvalue = $filter->{$column};
            if (defined $paramvalue && $paramvalue ne "") {
                if ($param =~ /\./) {
                    if (!defined $paramvalues{$param} && defined $params) {
                        push(@$params,$param);
                    }
                    $paramvalues{$param} = $paramvalue;
                }
                elsif ($paramvalue =~ /^ *[=~!<>\/]/) {
                    @paramvalues = split(/ *([=~!<>\/]+) */,$paramvalue);
                    my ($i, $op);
                    for ($i = 1; $i < $#paramvalues; $i += 2) {
                        $op = "";
                        if    ($paramvalues[$i] eq "=")  { $op = "eq"; }
                        elsif ($paramvalues[$i] eq "==") { $op = "eq"; }
                        elsif ($paramvalues[$i] eq "!=") { $op = "ne"; }
                        elsif ($paramvalues[$i] eq "<>") { $op = "ne"; }
                        elsif ($paramvalues[$i] eq "<")  { $op = "lt"; }
                        elsif ($paramvalues[$i] eq "<=") { $op = "le"; }
                        elsif ($paramvalues[$i] eq ">")  { $op = "gt"; }
                        elsif ($paramvalues[$i] eq ">=") { $op = "ge"; }
                        elsif ($paramvalues[$i] eq "~")  { $op = "contains"; }
                        elsif ($paramvalues[$i] eq "~=") { $op = "contains"; }
                        elsif ($paramvalues[$i] eq "=~") { $op = "contains"; }
                        elsif ($paramvalues[$i] eq "/")  { $op = "matches"; }

                        $paramvalue = $paramvalues[$i+1];
       
                        if ($op) {
                            $param = "$column.$op";
                            if (!defined $paramvalues{$param}) {
                                push(@$params,$param) if (defined $params);
                                $paramvalues{$param} = $paramvalue;
                            }
                        }
                    }
                }
                elsif ($paramvalue =~ /,/) {
                    $param = "$column.in";
                    if (!defined $paramvalues{$param}) {
                        push(@$params,$param) if (defined $params);
                        $paramvalues{$param} = $paramvalue;
                    }
                }
                else {
                    $param = "$column.contains";
                    if (!defined $paramvalues{$param} && defined $params) {
                        push(@$params,$param);
                    }
                    $paramvalues{$param} = $paramvalue;
                }
            }
        }

        my $order_by   = $self->get("order_by") || $self->get("ordercols");   # ordercols is deprecated in favor of order_by
        my $group_by   = $self->get("group_by");
        my $directions = $self->get("directions");
        $startrow      = $self->get("startrow", 1, 1);
        $maxrows       = $self->get("maxrows", 20, 1);
        $endrow        = ($maxrows != 0) ? ($startrow + $maxrows - 1) : 0;

        if ($App::DEBUG && $self->{context}->dbg(1)) {
            $self->{context}->dbgprint("DataTable->load(): get_rows($table,c=$columns,p=$params,pv=$paramvalues,oc=$order_by,$startrow,$endrow,$directions);");
            $self->{context}->dbgprint("DataTable->load(): columns=[", join(",", @$columns), "]") if (ref($columns) eq "ARRAY");
            $self->{context}->dbgprint("DataTable->load(): params=[", join(",", @$params), "]") if (ref($params) eq "ARRAY");
            $self->{context}->dbgprint("DataTable->load(): paramvalues=[", join(",", %$paramvalues), "]") if (ref($paramvalues) eq "HASH");
            $self->{context}->dbgprint("DataTable->load(): order_by=[", join(",", @$order_by), "]") if (ref($order_by) eq "ARRAY");
            $self->{context}->dbgprint("DataTable->load(): directions=[", join(",", @$directions), "]") if (ref($directions) eq "ARRAY");
        }

        #$rows  = $rep->select_rows($table, $columns, $params, \%paramvalues, $order_by, $startrow, $endrow, $directions);
        #$rows  = $rep->select_rows($table, $columns, undef, \%paramvalues, $order_by, $startrow, $endrow, $directions);
        $rows  = $rep->get_rows($table, \%paramvalues, $columns,
            {order_by => $order_by, startrow => $startrow, endrow => $endrow, directions => $directions, group_by => $group_by});
        $error = $rep->error();
        if ($#$rows == -1 && $error) {
            $sql = $rep->{sql};
            $context->add_message("SQL error: $error<br>$sql");
        }
    }

    my ($keys, $row);
 
    $self->{data} = $rows;

    $keycolidx = $self->get("keycolidx");
    if (defined $keycolidx && ref($keycolidx) eq "ARRAY") {
        $keys = [];
        foreach $row (@$rows) {
            push(@$keys, [ @{$row}[@$keycolidx] ]);
        }
        $self->set("keys", $keys);
    }
    &App::sub_exit() if ($App::trace);
}

sub save {
    &App::sub_entry if ($App::trace);
    my $self = shift;
    my ($repname, $context, $rep, $table);
    my ($editdata, $key, $column, @columns, @values);

    $repname = $self->get("repository");
    $context = $self->{context};
    $rep = $context->repository($repname);
    if (! $rep) {
        $context->add_message("No repository specified");
        return;
    }

    $table = $self->get("table");
    if (! $table) {
        $context->add_message("No table specified");
        return;
    }

    $editdata = $self->get("editdata");
    if ($editdata) {
        foreach $key (keys %$editdata) {
            @columns = ();
            @values = ();
            foreach $column (keys %{$editdata->{$key}}) {
                push(@columns, $column);
                push(@values, $editdata->{$key}{$column});
            }
            $rep->set($table, $key, \@columns, \@values);
        }
    }
    $rep->commit();
    &App::sub_exit() if ($App::trace);
}

sub substitute {
    &App::sub_entry if ($App::trace);
    my ($self, $text, $values) = @_;
    my ($phrase, $var, $value, $context);
    $context = $self->{context};
    $values = {} if (! defined $values);

    if (ref($text) eq "HASH") {
        my ($hash, $newhash);
        $hash = $text;    # oops, not text, but a hash of text values
        $newhash = {};    # prepare a new hash for the substituted values
        foreach $var (keys %$hash) {
            $newhash->{$var} = $self->substitute($hash->{$var}, $values);
        }
        &App::sub_exit($newhash) if ($App::trace);
        return($newhash); # short-circuit this whole process
    }

    while ( $text =~ /^\[([^\[\]]+)\]$/ ) {
        $phrase = $1;
        while ( $phrase =~ /\{([^\{\}]+)\}/ ) {
            $var = $1;
            if (defined $values->{$var}) {
                $value = $values->{$var};
                $value = join(",", @$value) if (ref($value) eq "ARRAY");
                $phrase =~ s/\{$var\}/$value/g;
            }
            else {
                $value = $context->so_get($var);
                $value = join(",", @$value) if (ref($value) eq "ARRAY");
                if (defined $value) {
                    $phrase =~ s/\{$var\}/$value/g;
                }
                else {
                    $phrase = "";
                }
            }
        }
        if ($phrase eq "") {
            $text =~ s/^\[[^\[\]]+\]\n?$//;  # zap it including (optional) ending newline
        }
        else {
            $text =~ s/^\[[^\[\]]+\]$/$phrase/;
        }
    }
    while ( $text =~ /\{([^\{\}]+)\}/ ) {  # vars of the form {var}
        $var = $1;
        if (defined $values->{$var}) {
            $value = $values->{$var};
            $value = join(",", @$value) if (ref($value) eq "ARRAY");
            $text =~ s/\{$var\}/$value/g;
        }
        else {
            $value = $context->so_get($var);
            $value = join(",", @$value) if (ref($value) eq "ARRAY");
        }
        $value = "" if (!defined $value);
        $text =~ s/\{$var\}/$value/g;
    }
    &App::sub_exit($text) if ($App::trace);
    $text;
}

######################################################################
# OUTPUT METHODS
######################################################################

sub table_html {
    &App::Widget::DataTable::html(@_);
}

sub html {
    &App::sub_entry if ($App::trace);
    my $self = shift;
    $self->{context}->dbgprint("DataTable->html()")
        if ($App::DEBUG && $self->{context}->dbg(1));

    my ($context, $name, $data);
    $context   = $self->{context};
    $name = $self->{name};

    my ($key, $column);

    my ($numcols, $table, $title);
    my ($width, $border, $cellspacing, $cellpadding);
    my ($bgcolor, $align, $valign, $nowrap);
    my ($font_face, $font_size, $font_color);
    my ($heading_bgcolor, $heading_align, $heading_valign, $heading_nowrap);
    my ($columns, $headings, $scrollable, $sortable, $filterable, $editable);
    my ($startrow, $numrow, $numbered);
    my ($keys, $mode, $sql);
    my ($column_selectable, $row_selectable, $row_single_selectable, $elem_selected, $single_row_select);
    my (@edit_style, @column_length);
    my ($rowactions, $rowactiondefs, $rowaction, $rowactiondef);
    my (@select_actions, @single_select_actions, @row_actions);

    $table             = $self->get("table");
    return "No table defined." if (!$table);
    $columns           = $self->get_columns();
    return "No columns defined for table [$table]. (maybe it doesn't exist)" if (!$columns || $#$columns == -1);
    $headings          = $self->get_headings();
    $data              = $self->get_data();
    $startrow          = $self->get("startrow",         1);
    $title             = $self->get("title");
    $width             = $self->get("width");
    $bgcolor           = $self->get("bgcolor");
    $font_color        = $self->get("font_color");
    $border            = $self->get("border",           0);
    $cellspacing       = $self->get("cellspacing",      2);
    $cellpadding       = $self->get("cellpadding",      2);
    $align             = $self->get("align",            "");
    $valign            = $self->get("valign",           "top");
    $nowrap            = $self->get("nowrap",           1);
    $font_face         = $self->get("font_face",         "verdana,geneva,arial,sans-serif");
    $font_size         = $self->get("font_size",         -2);
    $heading_bgcolor   = $self->get("heading_bgcolor",   "#cccccc");
    $heading_align     = $self->get("heading_align",     $align);
    $heading_valign    = $self->get("heading_valign",    "bottom");
    $heading_nowrap    = $self->get("heading_nowrap",    $nowrap);
    $mode              = $self->get("mode",             "view");
    $scrollable        = $self->get("scrollable",       0);
    $sortable          = $self->get("sortable",         0);
    $filterable        = $self->get("filterable",       0);
    $editable          = $self->get("editable",         0);
    $numbered          = $self->get("numbered",         1);
    $column_selectable = $self->get("column_selectable", 1);
    $row_selectable    = $self->get("row_selectable",    (($mode eq "edit") ? 1 : 0));
    $row_single_selectable = $self->get("row_single_selectable", 0);
    $keys              = $self->get("keys");
    $sql               = $self->get("sql");
    $rowactions        = $self->get("rowactions");
    $rowactiondefs     = $self->get("rowaction");

    my $repname = $self->get("repository");
    my $rep = $context->repository($repname);
    my $table_def = $rep->{table}{$table};
    my $table_column_defs = $table_def->{column};
    my $view_column_defs = $self->{column} || {};

    if (! $self->{keycolidx}) {
        $rowactions     = undef;
        $row_selectable = 0;        # can't select row(s) if no primary key
        $row_single_selectable = 0;  # can't select row    if no primary key
    }
    elsif ($rowactions && $rowactiondefs) {
        foreach $rowaction (@$rowactions) {
            if ($rowactiondefs->{$rowaction}{select} eq "single") {
                push(@single_select_actions, $rowaction);
                $row_single_selectable = 1;
            }
            elsif ($rowactiondefs->{$rowaction}{select} eq "multi") {
                push(@select_actions, $rowaction);
                $row_selectable = 1;
            }
            else {
                push(@row_actions, $rowaction);
            }
        }
    }

    # only needed for subtotals
    #my ($subtotal, $subtotal_keys, $order_by);
    #$subtotal_keys = $self->get("subtotal_keys");
    #$subtotal = (defined $subtotal_keys && ref($subtotal_keys) eq "ARRAY" && $#$subtotal_keys > -1);
    #if ($subtotal) {
    #    $order_by = $self->get("order_by") || $self->get("ordercols");   # ordercols is deprecated in favor of order_by
    #}

    my ($html, $row, $col, $elem);
    my ($td_row_attrib, $td_col_attrib, $elem_begin, $elem_end, $table_begin);

    $table_begin = "<table";
    $table_begin .= " width=\"$width\"" if (defined $width && $width ne "");
    $table_begin .= " border=\"$border\"" if (defined $border && $border ne "");
    $table_begin .= " cellspacing=\"$cellspacing\"" if (defined $cellspacing && $cellspacing ne "");
    $table_begin .= " cellpadding=\"$cellpadding\"" if (defined $cellpadding && $cellpadding ne "");
    $table_begin .= ">\n";

    $html = "<!--  -->";
    if (defined $title) {
        $title = $context->substitute($title);
        $html .= $title;
    }

    $numcols = $self->{numcols} || $#$headings + 1;

    if ($scrollable || $sortable || $filterable || $mode eq "edit") {

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

        if ($scrollable) {
            $html .= "<table border=\"0\" cellspacing=\"0\" cellpadding=\"5\"><tr><td>\n";
            $html .= "<table border=\"0\" cellspacing=\"0\" cellpadding=\"3\"><tr><td valign=\"middle\" nowrap>&nbsp;\n";
            $html .= $context->widget("$name-view",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => 'View',
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();
            $html .= " ";
            if ($editable) {
                $html .= $context->widget("$name-edit",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => 'Edit',
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();
                $html .= " ";
            }
            $html .= "    &nbsp;</td><td nowrap";
            $html .= " bgcolor=\"$heading_bgcolor\"" if ($heading_bgcolor);
            $html .= ">$elem_begin&nbsp;\n";
            $html .= $context->widget("$name-prev",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => '<< Prev',
                         height => 17,
                         width => 70,
                         bevel => 2,
                     )->html();
            $html .= "\n Start Row:";
            $html .= $context->widget("$name-startrow",
                         class => "App::Widget::TextField",
                         size => 4,
                         maxlength => 12,
                     )->html();
            $html .= " Num Rows:";
            $html .= $context->widget("$name-maxrows",
                         class => "App::Widget::TextField",
                         size => 4,
                         maxlength => 12,
                     )->html();
            $html .= "\n";
            $html .= $context->widget("$name-next",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => 'Next >>',
                         height => 17,
                         width => 70,
                         bevel => 2,
                     )->html();
            $html .= "&nbsp;$elem_end</td></tr></table>\n";
            $html .= "</td></tr></table>\n";
        }
    
        if ($mode eq "edit") {
            $html .= "<table border=\"0\" cellspacing=\"0\" cellpadding=\"3\"><tr>\n";
            $html .= "<td>\n";
            $html .= $context->widget("$name-save",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => 'Save',
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();
            $html .= "</td>\n";
            $html .= "<td>\n";
            $html .= $context->widget("$name.add",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => 'Add Rows',
                         height => 17,
                         width => 85,
                         bevel => 2,
                     )->html();
            $html .= "</td>\n";
            $html .= "<td>\n";
            $html .= $context->widget("$name-delete",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => 'Delete Rows',
                         height => 17,
                         width => 85,
                         bevel => 2,
                     )->html();
            $html .= "</td>\n";
            #$html .= "<td>\n";
            #$html .= $context->widget("$name-confirm",
            #             class => "App::Widget::RadioButtonSet",
            #             #volatile => 1,
            #             values => [ "no_confirm", "confirm", "auto_confirm" ],
            #             labels => {
            #                 "no_confirm" => "Changes Not Confirmed",
            #                 "confirm" => "Confirm Changes",
            #                 "auto_confirm" => "Auto-Confirm",
            #             },
            #         )->html();
            #$html .= "</td>\n";
            $html .= "</tr></table>\n";
        }
    
        $html .= $table_begin;
        if (!$sql) {
            if ($sortable) {
                $html .= "<tr>\n";
                $html .= "  <td>&nbsp;</td>\n" if ($numbered);
                $html .= "  <td>&nbsp;</td>\n" if ($row_selectable);
                $html .= "  <td>&nbsp;</td>\n" if ($row_single_selectable);
                $html .= "  <td>&nbsp;</td>\n" if ($#row_actions > -1);

                for ($col = 0; $col < $numcols; $col++) {
                    $elem = $context->widget("$name-sort$col",
                                class => "App::Widget::ImageButton",
                                image_script => 'app-button',
                                #volatile => 1,
                                label => 'Up|Dn',
                                height => 17,
                                width => 50,
                                bevel => 2,
                                args => $col,
                            )->html();
                    $html .= "  <td>$elem</td>\n";
                }
                $html .= "</tr>\n";
            }
            if ($filterable) {
                my ($w);
                $html .= "<tr>\n";
                $html .= "  <td>&nbsp;</td>\n" if ($numbered);
                $html .= "  <td>&nbsp;</td>\n" if ($row_selectable);
                $html .= "  <td>&nbsp;</td>\n" if ($row_single_selectable);
                $html .= "  <td>&nbsp;</td>\n" if ($#row_actions > -1);
                for ($col = 0; $col < $numcols; $col++) {
                    $column = $columns->[$col];
                    #$elem = $context->widget("$name\{filter}{$column}",
                    #            class => "App::Widget::TextField",
                    #            size => 5,
                    #            maxwidth => 99,
                    #        )->html();
                    $w = $context->widget("$name\{filter}{$column}",
                                class => "App::Widget::TextField",
                                size => 5,
                                maxwidth => 99,
                         );
                    $elem = $w->html();
                    $html .= "  <td>$elem_begin$elem$elem_end</td>\n";
                }
                $html .= "</tr>\n";
            }
        }
        if ($mode eq "edit" && $column_selectable) {
            $html .= "<tr>\n";
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($numbered);
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($row_selectable);
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($row_single_selectable);
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($#row_actions > -1);
            for ($col = 0; $col < $numcols; $col++) {
                $column = $columns->[$col];
                $elem = $context->widget("$name\{column_selected}{$column}",
                            class => "App::Widget::Checkbox",
                        )->html();
                $html .= "  <td bgcolor=\"#ffaaaa\" valign=\"bottom\" align=\"center\">$elem</td>\n";
            }
            $html .= "</tr>\n";
        }
    }
    else {
        $html .= $table_begin;
    }

    $elem_begin = "";
    $elem_end = "";
    if ($font_face || $font_size || $font_color) {
        $elem_begin = "<font";
        $elem_begin .= " face=\"$font_face\""   if ($font_face);
        $elem_begin .= " size=\"$font_size\""   if ($font_size);
        $elem_begin .= " color=\"$font_color\"" if ($font_color);
        $elem_begin .= ">";
        $elem_end = "</font>";
    }

    $td_row_attrib = "";
    $td_row_attrib .= " bgcolor=\"$heading_bgcolor\"" if ($heading_bgcolor);
    $td_row_attrib .= " align=\"$heading_align\""     if ($heading_align);
    $td_row_attrib .= " valign=\"$heading_valign\""   if ($heading_valign);
    $td_row_attrib .= " nowrap" if ($heading_nowrap);

    $html .= "<tr>\n";
    $html .= "  <td bgcolor=\"$heading_bgcolor\">&nbsp;</td>\n" if ($numbered);

    if ($row_selectable) {
        if ($#select_actions > -1) {
            my (%args);
            $html .= "  <td bgcolor=\"$heading_bgcolor\" valign=\"bottom\">";
            foreach $rowaction (@select_actions) {
                %args = (
                    override => 1,
                    class => "App::Widget::ImageButton",
                    image_script => 'app-button',
                    volatile => 1,
                    height => 17,
                    width => 50,
                    bevel => 2,
                );
                $rowactiondef = $rowactiondefs->{$rowaction};
                if ($rowactiondef) {
                    foreach (keys %$rowactiondef) {
                        $args{$_} = $rowactiondef->{$_};
                    }
                }
                $html .= $context->widget("$name-${rowaction}", %args, 
                             args => "{${name}" . "{row_selected}}"
                         )->html();
                $html .= "<br>\n" if ($rowaction ne $select_actions[$#select_actions]);
            }
            $html .= "</td>\n";
        }
        else {
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n";
        }
    }

    if ($row_single_selectable) {
        if ($#single_select_actions > -1) {
            my (%args);
            $html .= "  <td bgcolor=\"$heading_bgcolor\" valign=\"bottom\">";
            foreach $rowaction (@single_select_actions) {
                %args = (
                    override => 1,
                    class => "App::Widget::ImageButton",
                    image_script => 'app-button',
                    volatile => 1,
                    height => 17,
                    width => 50,
                    bevel => 2,
                );
                $rowactiondef = $rowactiondefs->{$rowaction};
                if ($rowactiondef) {
                    foreach (keys %$rowactiondef) {
                        $args{$_} = $rowactiondef->{$_};
                    }
                }
                $html .= $context->widget("$name-${rowaction}", %args, 
                             args => "{${name}" . "{row_single_selected}}"
                         )->html();
                $html .= "<br>\n" if ($rowaction ne $single_select_actions[$#select_actions]);
            }
            $html .= "</td>\n";
        }
        else {
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n";
        }
    }

    $html .= "  <td bgcolor=\"$heading_bgcolor\">&nbsp;</td>\n" if ($#row_actions > -1);
    for ($col = 0; $col < $numcols; $col++) {
        $td_col_attrib = "";
        $elem = $headings->[$col];
        $elem = "&nbsp;" if (!defined $elem || $elem eq "");
        $html .= "  <td$td_row_attrib$td_col_attrib>$elem_begin$elem$elem_end</td>\n";
    }
    $html .= "</tr>\n";

    $td_row_attrib = "";
    $td_row_attrib .= " bgcolor=\"$bgcolor\"" if ($bgcolor);
    #$td_row_attrib .= " align=\"$align\"" if ($align);
    $td_row_attrib .= " valign=\"$valign\"" if ($valign);
    $td_row_attrib .= " nowrap" if ($nowrap);

    # since we are editing, we need to prepare these two arrays...
    @edit_style = ();
    @column_length = ();

    if ($mode eq "edit") {

        # prepare the style attribute arrays
        push(@edit_style, "font_family", $font_face)  if ($font_face);
        push(@edit_style, "color",      $font_color) if ($font_color);

        # This seems to cause <input> elements to take on the font size
        # currently active for text that surrounds them
        # i.e. <font size="-2"><input type="text" style="font-size: 100%;"></font>
        push(@edit_style, "font_size",   "100%")     if ($font_size);

        # border_style",
        # border_width",
        # border_color",
        # padding",
        # background_color",

        # any columns we are editing, we need to compute max width (size) for textfield
        for ($col = 0; $col < $numcols; $col++) {
            $column_length[$col] = 5;  # minimum length
            $column = "";
            if (defined $columns && defined $columns->[$col]) {
                $column = $columns->[$col];
            }
    
            if (($column ne "" && $self->{column_selected}{$column}) ||
                ($self->{row_selected} && %{$self->{row_selected}})) {
                for ($row = 0; $row <= $#$data; $row++) {
                    $elem = $data->[$row][$col];
                    if (defined $elem && length($elem) > $column_length[$col]) {
                        $column_length[$col] = length($elem);
                    }
                }
            }
        }
    }

    my ($format, $scale_factor);
    for ($row = 0; $row <= $#$data; $row++) {
        $numrow = $startrow + $row;

        $html .= "<tr>\n";

        $key = "";
        if (defined $keys && defined $keys->[$row]) {
            $key = join(",", @{$keys->[$row]});   # need to HTML-escape these!
        }

        $html .= "  <td bgcolor=\"$heading_bgcolor\" align=\"right\">$elem_begin$numrow$elem_end</td>\n" if ($numbered);

        if ($row_selectable) {
            $html .= "  <td bgcolor=\"#ffaaaa\" valign=\"middle\" align=\"center\">\n";
            $html .= $context->widget("$name\{row_selected}{$key}",
                         class => "App::Widget::Checkbox",
                     )->html();
            $html .= "  </td>\n";
        }

        if ($row_single_selectable) {
            $html .= "  <td bgcolor=\"#ffaaaa\" valign=\"middle\" align=\"center\">\n";
            $html .= $context->widget("$name\{row_single_selected}",
                         class => "App::Widget::RadioButton",
                         override => 1,
                         value => $key,
                     )->html();
            $html .= "  </td>\n";
        }

        if ($#row_actions > -1) {
            my (%args);
            $html .= "  <td bgcolor=\"$heading_bgcolor\">";
            foreach $rowaction (@row_actions) {
                %args = (
                    override => 1,
                    class => "App::Widget::ImageButton",
                    image_script => 'app-button',
                    volatile => 1,
                    height => 17,
                    width => 50,
                    bevel => 2,
                );
                $rowactiondef = $rowactiondefs->{$rowaction};
                if ($rowactiondef) {
                    foreach (keys %$rowactiondef) {
                        $args{$_} = $rowactiondef->{$_};
                    }
                }
                $html .= $context->widget("$name.${rowaction}", %args, args => $key)->html();
            }
            $html .= "</td>\n";
        }

        for ($col = 0; $col < $numcols; $col++) {
            $elem = $data->[$row][$col];

            $column = "";
            $format = "";
            $scale_factor = "";
            $align = "";
            if (defined $columns && defined $columns->[$col]) {
                $column = $columns->[$col];
                $format       = $view_column_defs->{$column}{format}       || $table_column_defs->{$column}{format};
                $scale_factor = $view_column_defs->{$column}{scale_factor} || $table_column_defs->{$column}{scale_factor};
                $align        = $view_column_defs->{$column}{align}        || $table_column_defs->{$column}{align};
            }

            $elem_selected = 0;
            if ($mode eq "edit") {
                if (($self->{column_selected}{$column} && $self->{row_selected}{$key}) ||
                    ($self->{column_selected}{$column} && (!defined $self->{row_selected} || !%{$self->{row_selected}})) ||
                    ((!defined $self->{column_selected} || !%{$self->{column_selected}})  && $self->{row_selected}{$key})) {
                    $elem_selected = 1;
                }
            }

            if ($elem_selected) {
                if (!defined $elem || $elem eq "") {
                    $elem = "";
                    $td_col_attrib = " align=\"left\"";
                }
                else {
                    $elem = $elem * $scale_factor if ($scale_factor);
                    if ($align) {
                        $td_col_attrib = " align=\"$align\"";
                    }
                    elsif ($elem =~ /^[-0-9.,%]+$/) {
                        $td_col_attrib = " align=\"right\"";
                    }
                    else {
                        $td_col_attrib = " align=\"left\"";
                    }
                    $elem = sprintf($format, $elem) if ($format);
                }
                if (! defined $self->{editdata}{$key}{$column}) {
                    $self->{editdata}{$key}{$column} = $elem
                }
                $html .= "  <td $td_row_attrib$td_col_attrib>${elem_begin}";
                $html .= $context->widget("$name\{editdata}{$key}{$column}",
                             class => "App::Widget::TextField",
                             size => $column_length[$col]+2,   # add 2 just to give some visual space
                             maxlength => 99,
                             background_color => "#ffaaaa",
                             border_style => "solid",
                             border_width => "1px",
                             padding => 0,
                             @edit_style,
                         )->html();
                $html .= "$elem_end</td>\n";
            }
            else {
                $elem = $self->html_escape($elem);
                if (!defined $elem || $elem eq "") {
                    $elem = "&nbsp;";
                }
                else {
                    $elem = $elem * $scale_factor if ($scale_factor);
                    $elem = sprintf($format, $elem) if ($format);
                    if ($align) {
                        $td_col_attrib = " align=\"$align\"";
                    }
                    elsif ($elem =~ /^[-0-9.,%]+$/) {
                        $td_col_attrib = " align=\"right\"";
                    }
                    else {
                        $td_col_attrib = " align=\"left\"";
                    }
                }
                $html .= "  <td$td_row_attrib$td_col_attrib>$elem_begin$elem$elem_end</td>\n";
            }
        }
        $html .= "</tr>\n";
    }

    $html .= "</table>\n";
    if (1) {
        $html .= "<!-- SQL used in table query\n";
        $html .= $rep->{sql};
        $html .= "-->\n";
    }
    &App::sub_exit("<html ...>") if ($App::trace);
    $html;
}

1;

