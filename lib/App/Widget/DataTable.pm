
######################################################################
## $Id: DataTable.pm,v 1.6 2004/09/02 21:05:00 spadkins Exp $
######################################################################

package App::Widget::DataTable;
$VERSION = do { my @r=(q$Revision: 1.6 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use strict;

=head1 NAME

App::Widget::DataTable - An HTML button

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
# {border}         = 0;
# {cellspacing}    = 2;
# {cellpadding}    = 0;
# {width}          = "";
# {bgcolor}        = "";
# {nowrap}         = "1";
# {fontFace}       = "verdana,geneva,arial,sans-serif";
# {fontSize}       = "-2";
# {fontColor}      = "";
# {headingBgcolor} = "#cccccc";
# {headingNowrap}  = 0;
# {columns}        = [ "Name", "Address", "City", "State", "Country", "Home Phone" ];
# {headings}       = [ "Name", "Address", "City", "State", "Country", "Home Phone" ];
# {data}           = [ [ "Smith, Harold", "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1810" ],
#                      [ "Smith, Mike",   "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1811" ],
#                      [ "Smith, Sarah",  "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1812" ],
#                      [ "Smith, Ken",    "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1813" ],
#                      [ "Smith, Mary",   "1215 Interloke Pass", "Jonesboro", "GA", "US", "770-603-1814" ], ];
# {startrow}       = 1
# {maxrows}        = 20
# {scrollable}     = 0;
# {sortable}       = 0;
# {filterable}     = 0;
# {editable}       = 0;

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class is a <input type=submit> HTML element.
In the advanced configurations, it is rendered as an image button.

=cut

######################################################################
# INITIALIZATION
######################################################################

# uncomment this when I need to do more than just call SUPER::_init()
sub _init {
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
    my ($self, $wname, $event, @args) = @_;
    my ($name, $context, $colnum, $x, $y, $startrow, $maxrows, $width, $direction);

    #$self->clear_messages();

    $name = $self->{name};
    $self->{context}->dbgprint("DataTable($name)->handle_event($wname,$event,@args)")
        if ($App::DEBUG && $self->{context}->dbg(1));

    if ($wname eq "$name.view") {
        $self->set("mode","view");
        $self->delete("editdata");
        return 1;
    }
    elsif ($wname eq "$name.edit") {
        $self->set("mode","edit");
        return 1;
    }
    elsif ($wname eq "$name.next") {
        $startrow = $self->get("startrow",1,1);
        $maxrows  = $self->get("maxrows",20,1);
        $startrow += $maxrows;
        $self->set("startrow",$startrow);
        return 1;
    }
    elsif ($wname eq "$name.prev") {
        $startrow = $self->get("startrow",1,1);
        $maxrows  = $self->get("maxrows",20,1);
        $startrow -= $maxrows;
        $startrow = 1 if ($startrow < 1);
        $self->set("startrow",$startrow);
        return 1;
    }
    elsif ($wname eq "$name.save") {
        $self->save();
        $self->delete("editdata");
        return 1;
    }
    elsif ($wname eq "$name.add") {
        $self->{context}->add_message("Add Rows: not yet implemented");
        return 1;
    }
    elsif ($wname eq "$name.delete") {
        $self->{context}->add_message("Delete Rows: not yet implemented");
        return 1;
    }
    elsif ($event eq "sort") {
        ($colnum, $direction) = @args;

        my ($columns, $directions, $ordercols, $column, $i);
        $columns    = $self->get_columns();
        $column     = $columns->[$colnum];

        $ordercols = $self->get("ordercols");
        if (defined $ordercols) {
            $directions = $self->get("directions");
            $directions = [] if (!defined $directions);
            for ($i = 0; $i <= $#$ordercols; $i++) {
                if ($ordercols->[$i] eq $column) {
                    splice(@$ordercols, $i, 1);     # delete the use of $column
                    splice(@$directions, $i, 1);    # delete the sort direction
                    last;
                }
            }
            unshift(@$ordercols, $column);      # put it at the beginning
            unshift(@$directions, $direction);
        }
        else {
            $ordercols = [ $column ];
            $directions = [ $direction ];
        }

        $self->set("ordercols",$ordercols);
        $self->set("directions",$directions);
        return 1;
    }
    elsif ($wname =~ /^$name.sort[0-9]*$/) {
        ($colnum, $x, $y) = @args;
        $context = $self->{context};
        $width = $context->widget($wname)->get("width");
        if ($x <= $width/2) {
            return $self->handle_event($wname, "sort", $colnum, "UP");
        }
        else {
            return $self->handle_event($wname, "sort", $colnum, "DOWN");
        }
    }
    else {
        return $self->SUPER::handle_event(@_);
    }
}

######################################################################
# METHODS
######################################################################

sub get_columns {
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
    $columns;
}

sub get_headings {
    my $self = shift;
    $self->{context}->dbgprint("DataTable->get_headings()")
        if ($App::DEBUG && $self->{context}->dbg(1));
    my ($table, $headings, $heading, $columns, $column, $lang);
    $table = $self->get("table");
    $columns = $self->get_columns();
    $headings = $self->get("headings");
    $lang = $self->{lang};
    if (!defined $headings) {
        $headings = [];
        my ($repname, $context, $rep, $columnlabels);
        $repname = $self->get("repository");
        $context  = $self->{context};
        $rep = $context->repository($repname);
        $columnlabels = $rep->get_column_labels($table);
        foreach $column (@$columns) {
            $heading = $columnlabels->{$column};
            $heading = $column if (!defined $heading);
            $heading = $self->translate($heading, $lang) if (defined $lang);
            push(@$headings, $heading);
            $self->{context}->dbgprint("DataTable->get_headings(): column=$column(",$#$columns,") heading=$heading(",$#$headings,")")
                if ($App::DEBUG >= 6 && $self->{context}->dbg(6));
        }
    }
    $self->{context}->dbgprint("DataTable->get_headings(): columns=[", join(",", @{$self->get("columns",[])}), "]")
        if ($App::DEBUG && $self->{context}->dbg(1));
    $headings;
}

sub get_data {
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
    return $data;
}

sub load {
    my $self = shift;
    $self->{context}->dbgprint("DataTable->load()")
        if ($App::DEBUG && $self->{context}->dbg(1));
    my ($context, $repname, $rep, $rows, $table, $columns, $sql, $error, $data);
    my ($params, $paramvalues, $param, $paramvalue, @paramvalues);
    my ($ordercols, $startrow, $maxrows, $endrow, $directions, $keycolidx);
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
        $paramvalues = $self->get("paramvalues",{});
        %paramvalues = %$paramvalues;
        $self->substitute(\%paramvalues);
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

        $ordercols   = $self->get("ordercols");
        $directions  = $self->get("directions");
        $startrow    = $self->get("startrow", 1, 1);
        $maxrows     = $self->get("maxrows", 20, 1);
        $endrow      = ($maxrows != 0) ? ($startrow + $maxrows - 1) : 0;

        if ($App::DEBUG && $self->{context}->dbg(1)) {
            $self->{context}->dbgprint("DataTable->load(): get_rows($table,c=$columns,p=$params,pv=$paramvalues,oc=$ordercols,$startrow,$endrow,$directions);");
            $self->{context}->dbgprint("DataTable->load(): columns=[", join(",", @$columns), "]") if (ref($columns) eq "ARRAY");
            $self->{context}->dbgprint("DataTable->load(): params=[", join(",", @$params), "]") if (ref($params) eq "ARRAY");
            $self->{context}->dbgprint("DataTable->load(): paramvalues=[", join(",", %$paramvalues), "]") if (ref($paramvalues) eq "HASH");
            $self->{context}->dbgprint("DataTable->load(): ordercols=[", join(",", @$ordercols), "]") if (ref($ordercols) eq "ARRAY");
            $self->{context}->dbgprint("DataTable->load(): directions=[", join(",", @$directions), "]") if (ref($directions) eq "ARRAY");
        }

        #$rows  = $rep->select_rows($table, $columns, $params, \%paramvalues, $ordercols, $startrow, $endrow, $directions);
        #$rows  = $rep->select_rows($table, $columns, undef, \%paramvalues, $ordercols, $startrow, $endrow, $directions);
        $rows  = $rep->get_rows($table, \%paramvalues, $columns,
            {ordercols => $ordercols, startrow => $startrow, endrow => $endrow, directions => $directions});
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
}

sub save {
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
            $rep->set_values($table, $key, \@columns, \@values);
        }
    }
    $rep->commit();
}

sub substitute {
    my ($self, $text, $values) = @_;
    $self->{context}->dbgprint("DataTable->substitute()")
        if ($App::DEBUG && $self->{context}->dbg());
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
        return($newhash); # short-circuit this whole process
    }

    while ( $text =~ /\[([^\[\]]+)\]/ ) {
        $phrase = $1;
        while ( $phrase =~ /\{([^\{\}]+)\}/ ) {
            $var = $1;
            if (defined $values->{$var}) {
                $value = $values->{$var};
                $phrase =~ s/\{$var\}/$value/g;
            }
            else {
                if ($var =~ /^(.+)\.([^.]+)$/) {
                    $value = $context->wget($1, $2);
                    if (defined $value) {
                        $phrase =~ s/\{$var\}/$value/g;
                    }
                    else {
                        $phrase = "";
                    }
                }
                else {
                    $phrase = "";
                }
            }
        }
        if ($phrase eq "") {
            $text =~ s/\[[^\[\]]+\]\n?//;  # zap it including (optional) ending newline
        }
        else {
            $text =~ s/\[[^\[\]]+\]/$phrase/;
        }
    }
    while ( $text =~ /\{([^\{\}]+)\}/ ) {  # vars of the form {var}
        $var = $1;
        if (defined $values->{$var}) {
            $value = $values->{$var};
            $text =~ s/\{$var\}/$value/g;
        }
        else {
            $value = "";
            if ($var =~ /^(.+)\.([^.]+)$/) {
                $value = $context->wget($1, $2);
            }
        }
        $value = "" if (!defined $value);
        $text =~ s/\{$var\}/$value/g;
    }
    $text;
}

######################################################################
# OUTPUT METHODS
######################################################################

sub table_html {
    &App::Widget::DataTable::html(@_);
}

sub html {
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
    my ($fontFace, $fontSize, $fontColor);
    my ($headingBgcolor, $headingAlign, $headingValign, $headingNowrap);
    my ($columns, $headings, $scrollable, $sortable, $filterable, $editable);
    my ($startrow, $numrow, $numbered);
    my ($keys, $mode, $sql);
    my ($columnSelectable, $rowSelectable, $rowSingleSelectable, $elemSelected, $single_row_select);
    my (@edit_style, @column_length);
    my ($rowactions, $rowactiondefs, $rowaction, $rowactiondef);
    my (@select_actions, @single_select_actions, @row_actions);

    $table            = $self->get("table");
    return "No table defined." if (!$table);
    $columns          = $self->get_columns();
    return "No columns defined for table [$table]. (maybe it doesn't exist)" if (!$columns || $#$columns == -1);
    $headings         = $self->get_headings();
    $data             = $self->get_data();
    $startrow         = $self->get("startrow",         1);
    $title            = $self->get("title");
    $width            = $self->get("width");
    $bgcolor          = $self->get("bgcolor");
    $fontColor        = $self->get("fontColor");
    $border           = $self->get("border",           0);
    $cellspacing      = $self->get("cellspacing",      2);
    $cellpadding      = $self->get("cellpadding",      2);
    $align            = $self->get("align",            "");
    $valign           = $self->get("valign",           "top");
    $nowrap           = $self->get("nowrap",           1);
    $fontFace         = $self->get("fontFace",         "verdana,geneva,arial,sans-serif");
    $fontSize         = $self->get("fontSize",         -2);
    $headingBgcolor   = $self->get("headingBgcolor",   "#cccccc");
    $headingAlign     = $self->get("headingAlign",     $align);
    $headingValign    = $self->get("headingValign",    "bottom");
    $headingNowrap    = $self->get("headingNowrap",    $nowrap);
    $mode             = $self->get("mode",             "view");
    $scrollable       = $self->get("scrollable",       0);
    $sortable         = $self->get("sortable",         0);
    $filterable       = $self->get("filterable",       0);
    $editable         = $self->get("editable",         0);
    $numbered         = $self->get("numbered",         1);
    $columnSelectable = $self->get("columnSelectable", 1);
    $rowSelectable    = $self->get("rowSelectable",    0);
    $rowSingleSelectable = $self->get("rowSingleSelectable", 0);
    $keys             = $self->get("keys");
    $sql              = $self->get("sql");
    $rowactions       = $self->get("rowactions");
    $rowactiondefs    = $self->get("rowaction");

    if (! $self->{keycolidx}) {
        $rowactions    = 0;
        $rowSelectable = 0;        # can't select row(s) if no primary key
        $rowSingleSelectable = 0;  # can't select row    if no primary key
    }
    elsif ($rowactions && $rowactiondefs) {
        foreach $rowaction (@$rowactions) {
            if ($rowactiondefs->{$rowaction}{select} eq "single") {
                push(@single_select_actions, $rowaction);
                $rowSingleSelectable = 1;
            }
            elsif ($rowactiondefs->{$rowaction}{select} eq "multi") {
                push(@select_actions, $rowaction);
                $rowSelectable = 1;
            }
            else {
                push(@row_actions, $rowaction);
            }
        }
    }

    # only needed for subtotals
    #my ($subtotal, $subtotalKeys, $ordercols);
    #$subtotalKeys = $self->get("subtotalKeys");
    #$subtotal = (defined $subtotalKeys && ref($subtotalKeys) eq "ARRAY" && $#$subtotalKeys > -1);
    #if ($subtotal) {
    #    $ordercols = $self->get("ordercols");
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
        if ($fontFace || $fontSize || $fontColor) {
            $elem_begin = "<font";
            $elem_begin .= " face=\"$fontFace\""   if ($fontFace);
            $elem_begin .= " size=\"" . ($fontSize+1) . "\""   if ($fontSize);
            $elem_begin .= " color=\"$fontColor\"" if ($fontColor);
            $elem_begin .= ">";
            $elem_end = "</font>";
        }

        if ($scrollable) {
            $html .= "<table border=\"0\" cellspacing=\"0\" cellpadding=\"5\"><tr><td>\n";
            $html .= "<table border=\"0\" cellspacing=\"0\" cellpadding=\"3\"><tr><td valign=\"middle\" nowrap>&nbsp;\n";
            $html .= $context->widget("$name.view",
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
                $html .= $context->widget("$name.edit",
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
            $html .= " bgcolor=\"$headingBgcolor\"" if ($headingBgcolor);
            $html .= ">$elem_begin&nbsp;\n";
            $html .= $context->widget("$name.prev",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         #volatile => 1,
                         label => '<< Prev',
                         height => 17,
                         width => 70,
                         bevel => 2,
                     )->html();
            $html .= "\n Start Row:";
            $html .= $context->widget("$name.startrow",
                         class => "App::Widget::TextField",
                         size => 4,
                         maxlength => 12,
                     )->html();
            $html .= " Num Rows:";
            $html .= $context->widget("$name.maxrows",
                         class => "App::Widget::TextField",
                         size => 4,
                         maxlength => 12,
                     )->html();
            $html .= "\n";
            $html .= $context->widget("$name.next",
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
            $html .= $context->widget("$name.save",
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
            $html .= $context->widget("$name.delete",
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
            #$html .= $context->widget("$name.confirm",
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
                $html .= "  <td>&nbsp;</td>\n" if ($rowSelectable);
                $html .= "  <td>&nbsp;</td>\n" if ($rowSingleSelectable);
                $html .= "  <td>&nbsp;</td>\n" if ($#row_actions > -1);

                for ($col = 0; $col < $numcols; $col++) {
                    $elem = $context->widget("$name.sort$col",
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
                $html .= "  <td>&nbsp;</td>\n" if ($rowSelectable);
                $html .= "  <td>&nbsp;</td>\n" if ($rowSingleSelectable);
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
        if ($mode eq "edit" && $columnSelectable) {
            $html .= "<tr>\n";
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($numbered);
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($rowSelectable);
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($rowSingleSelectable);
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n" if ($#row_actions > -1);
            for ($col = 0; $col < $numcols; $col++) {
                $column = $columns->[$col];
                $elem = $context->widget("$name\{columnSelected}{$column}",
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
    if ($fontFace || $fontSize || $fontColor) {
        $elem_begin = "<font";
        $elem_begin .= " face=\"$fontFace\""   if ($fontFace);
        $elem_begin .= " size=\"$fontSize\""   if ($fontSize);
        $elem_begin .= " color=\"$fontColor\"" if ($fontColor);
        $elem_begin .= ">";
        $elem_end = "</font>";
    }

    $td_row_attrib = "";
    $td_row_attrib .= " bgcolor=\"$headingBgcolor\"" if ($headingBgcolor);
    $td_row_attrib .= " align=\"$headingAlign\""     if ($headingAlign);
    $td_row_attrib .= " valign=\"$headingValign\""   if ($headingValign);
    $td_row_attrib .= " nowrap" if ($headingNowrap);

    $html .= "<tr>\n";
    $html .= "  <td bgcolor=\"$headingBgcolor\">&nbsp;</td>\n" if ($numbered);

    if ($rowSelectable) {
        if ($#select_actions > -1) {
            my (%args);
            $html .= "  <td bgcolor=\"$headingBgcolor\" valign=\"bottom\">";
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
                $html .= $context->widget("$name.${rowaction}", %args, 
                             args => "{${name}" . "{rowSelected}}"
                         )->html();
                $html .= "<br>\n" if ($rowaction ne $select_actions[$#select_actions]);
            }
            $html .= "</td>\n";
        }
        else {
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n";
        }
    }

    if ($rowSingleSelectable) {
        if ($#single_select_actions > -1) {
            my (%args);
            $html .= "  <td bgcolor=\"$headingBgcolor\" valign=\"bottom\">";
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
                $html .= $context->widget("$name.${rowaction}", %args, 
                             args => "{${name}" . "{rowSingleSelected}}"
                         )->html();
                $html .= "<br>\n" if ($rowaction ne $single_select_actions[$#select_actions]);
            }
            $html .= "</td>\n";
        }
        else {
            $html .= "  <td bgcolor=\"#ffaaaa\">&nbsp;</td>\n";
        }
    }

    $html .= "  <td bgcolor=\"$headingBgcolor\">&nbsp;</td>\n" if ($#row_actions > -1);
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
        push(@edit_style, "fontFamily", $fontFace)  if ($fontFace);
        push(@edit_style, "color",      $fontColor) if ($fontColor);

        # This seems to cause <input> elements to take on the font size
        # currently active for text that surrounds them
        # i.e. <font size="-2"><input type="text" style="font-size: 100%;"></font>
        push(@edit_style, "fontSize",   "100%")     if ($fontSize);

        # borderStyle",
        # borderWidth",
        # borderColor",
        # padding",
        # backgroundColor",

        # any columns we are editing, we need to compute max width (size) for textfield
        for ($col = 0; $col < $numcols; $col++) {
            $column_length[$col] = 5;  # minimum length
            $column = "";
            if (defined $columns && defined $columns->[$col]) {
                $column = $columns->[$col];
            }
    
            if (($column ne "" && $self->{columnSelected}{$column}) ||
                ($self->{rowSelected} && %{$self->{rowSelected}})) {
                for ($row = 0; $row <= $#$data; $row++) {
                    $elem = $data->[$row][$col];
                    if (defined $elem && length($elem) > $column_length[$col]) {
                        $column_length[$col] = length($elem);
                    }
                }
            }
        }
    }

    for ($row = 0; $row <= $#$data; $row++) {
        $numrow = $startrow + $row;

        $html .= "<tr>\n";

        $key = "";
        if (defined $keys && defined $keys->[$row]) {
            $key = join(",", @{$keys->[$row]});   # need to HTML-escape these!
        }

        $html .= "  <td bgcolor=\"$headingBgcolor\" align=\"right\">$elem_begin$numrow$elem_end</td>\n" if ($numbered);

        if ($rowSelectable) {
            $html .= "  <td bgcolor=\"#ffaaaa\" valign=\"middle\" align=\"center\">\n";
            $html .= $context->widget("$name\{rowSelected}{$key}",
                         class => "App::Widget::Checkbox",
                     )->html();
            $html .= "  </td>\n";
        }

        if ($rowSingleSelectable) {
            $html .= "  <td bgcolor=\"#ffaaaa\" valign=\"middle\" align=\"center\">\n";
            $html .= $context->widget("$name\{rowSingleSelected}",
                         class => "App::Widget::RadioButton",
                         override => 1,
                         value => $key,
                     )->html();
            $html .= "  </td>\n";
        }

        if ($#row_actions > -1) {
            my (%args);
            $html .= "  <td bgcolor=\"$headingBgcolor\">";
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
            $elemSelected = 0;
            if ($mode eq "edit") {
                if (defined $columns && defined $columns->[$col]) {
                    $column = $columns->[$col];
                }
                if (($self->{columnSelected}{$column} && $self->{rowSelected}{$key}) ||
                    ($self->{columnSelected}{$column} && (!defined $self->{rowSelected} || !%{$self->{rowSelected}})) ||
                    ((!defined $self->{columnSelected} || !%{$self->{columnSelected}})  && $self->{rowSelected}{$key})) {
                    $elemSelected = 1;
                }
            }

            if ($elemSelected) {
                if (!defined $elem || $elem eq "") {
                    $elem = "";
                    $td_col_attrib = " align=\"left\"";
                }
                elsif ($elem =~ /^[-0-9.%]+$/) {
                    $td_col_attrib = " align=\"right\"";
                }
                else {
                    $td_col_attrib = " align=\"left\"";
                }
                if (! defined $self->{editdata}{$key}{$column}) {
                    $self->{editdata}{$key}{$column} = $elem
                }
                $html .= "  <td $td_row_attrib$td_col_attrib>${elem_begin}";
                $html .= $context->widget("$name\{editdata}{$key}{$column}",
                             class => "App::Widget::TextField",
                             size => $column_length[$col]+2,   # add 2 just to give some visual space
                             maxlength => 99,
                             backgroundColor => "#ffaaaa",
                             borderStyle => "solid",
                             borderWidth => "1px",
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
                elsif ($elem =~ /^[-0-9.%]+$/) {
                    $td_col_attrib = " align=\"right\"";
                }
                else {
                    $td_col_attrib = " align=\"left\"";
                }
                $html .= "  <td$td_row_attrib$td_col_attrib>$elem_begin$elem$elem_end</td>\n";
            }
        }
        $html .= "</tr>\n";
    }

    $html .= "</table>\n";
    if (1) {
        my $repname = $self->get("repository");
        my $rep = $context->repository($repname);
        $html .= "<!-- SQL used in table query\n";
        $html .= $rep->{sql};
        $html .= "-->\n";
    }
    $html;
}

1;

