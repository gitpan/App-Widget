
######################################################################
## $Id: RepositoryEditor.pm 3464 2005-08-09 19:25:46Z spadkins $
######################################################################
## x TODO: add "summary" feature
## x TODO: add cross-tabulation
## x TODO: add editing capability
## x TODO (edit): pass sort information into the edit rows screen
## x TODO (edit): check for formulas and primary key to determine read-only (Rep::DB.pm)
## o TODO (edit): don't allow editing for read-only fields
## o TODO (edit): only allow editable fields to be selected
## o TODO (edit): for selected rows screen, show all fields, allow editing on selected fields
## o TODO (edit): when no rows selected, use the selection criteria to get the new rows
## o TODO (export): allow exporting of data
## o TODO (import): allow importing of data
## o TODO (import): allow export/import of data
## o TODO (edit): include some column for modifying the size, maxlength of edit field
## o TODO (edit): include some column for validation rules
## o TODO (edit): include some column for drop-down selections
## o TODO: add report-saving feature
## x TODO: transform into a standard HTML::Widget::Base constructor interface
## o TODO: get context logic out of this class
## o TODO: can't edit "summary" data (what should I do when they try?)
## o TODO: add show/hide detail of report criteria screen
## x TODO: if sort column is chosen which is not in the list of selected columns
##   we add it to the list and use its alias
## x TODO: add primary key to the group-by clause whenever non-summary group-by is required
##   (or editing is required)
## x TODO: autogenerate missing aliases (i.e. col001) for use in group by, order by
## x TODO: only display the columns in the selected columns list (more will be returned)
## x TODO: add default {summary} formula as count(distinct COL) (for non-numbers)
## x TODO: add default {summary} formula as sum(COL)            (for numbers)

package App::Widget::RepositoryEditor;
$VERSION = do { my @r=(q$Revision: 3464 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Widget;
@ISA = ( "App::Widget" );

use App::Repository;

use strict;

=head1 NAME

App::Widget::RepositoryEditor - A widget allowing the user to browse and edit a repository

=head1 SYNOPSIS

   $name = "repedit";

   # official way
   use App;
   $context = App->context();
   $w = $context->widget($name);

   # internal way
   use App::Widget::RepositoryEditor;
   $w = App::Widget::RepositoryEditor->new($name);

=cut

######################################################################
# CONSTANTS
######################################################################

######################################################################
# ATTRIBUTES
######################################################################

# INPUTS FROM THE ENVIRONMENT

=head1 DESCRIPTION

This class implements a widget.

=cut

######################################################################
# INITIALIZATION
######################################################################

sub _init {
    my $self = shift;
    $self->SUPER::_init(@_);

    my ($context, $name, $rep, $repname, $table, $table_names);

    $context = $self->{context};
    $name    = $self->{name};
    $repname = $self->get("repository");
    $rep     = $context->repository($repname);

    $table = $self->get("table");
    if (! $table) {
        $table_names = $rep->get_table_names();
        $table = $table_names->[0];
        $self->set("table",$table);
    }
    $self->{columns} = [] if (!defined $self->{columns});

    $context->widget("${name}_datatable",
        class => "App::Widget::DataTable",
        scrollable  => 1,
        sortable    => 1,
        filterable  => 1,
        repository  => $repname,
    );
}

######################################################################
# EVENTS
######################################################################

# Usage: $widget->handle_event($wname, $event, @args);
sub handle_event {
    my ($self, $wname, $event, @args) = @_;
    my ($name, $table);

    $name = $self->{name};
    $self->{context}->dbgprint("RepositoryEditor($name)->handle_event($wname,$event,@args)")
        if ($App::DEBUG && $self->{context}->dbg(1));

    if ($wname eq "$name-open_button") {
    }
    elsif ($wname eq "$name-save_button") {
    }
    elsif ($wname eq "$name-delete_button") {
    }
    elsif ($wname eq "$name-saveas_button") {
    }
    elsif ($wname eq "$name-view_button") {
        $self->set_mode("view", 0);
    }
    elsif ($wname eq "$name-edit_button") {
        $self->set_mode("edit", 1);
    }
    elsif ($wname eq "$name-select_button") {
        $table = $self->get("new_table");
        $self->set("table", $table);
        $self->set("columns",     []);
        $self->set("ordercols",   []);
        $self->set("directions",  []);
        $self->set("param",[]);
        $self->set("param_min",[]);
        $self->set("param_max",[]);
        $self->set("param_contains",[]);
    }
    else {
        return $self->SUPER::handle_event($wname, $event, @args);
    }

    return 1;
}

sub set_mode {
    my ($self, $mode, $editable) = @_;

    my ($context, $name, $w);

    $self->set("mode", $mode);
    $context = $self->{context};
    $name = $self->{name};
    $w = $context->widget("${name}_datatable");
    $w->set("table",       $self->get("table"));
    $w->set("columns",     $self->get("columns"));
    $w->set("ordercols",   $self->get("ordercols"));
    $w->set("directions",  $self->get("directions"));
    $w->set("paramvalues", $self->get("paramvalues"));
    $w->set("maxrows",     $self->get("maxrows"));
    $w->set("editable",    $editable);

    my ($i, @params, %paramvalues, $param, $params, $param_min, $param_max, $param_contains);
    $params         = $self->get("param");
    $param_min      = $self->get("param_min",[]);
    $param_max      = $self->get("param_max",[]);
    $param_contains = $self->get("param_contains",[]);
    $paramvalues{"_conjunction"} = $self->get("conjunction");
 
    if ($params && ref($params) eq "ARRAY") {
        for ($i = 0; $i <= $#$params; $i++) {
            $param = $params->[$i];
            next if (!defined $param || $param eq "");
            if (defined $param_min->[$i] && $param_min->[$i] ne "") {
                push(@params, "${param}.ge");
                $paramvalues{"${param}.ge"} = $param_min->[$i];
            }
            if (defined $param_max->[$i] && $param_max->[$i] ne "") {
                push(@params, "${param}.le");
                $paramvalues{"${param}.le"} = $param_max->[$i];
            }
            if (defined $param_contains->[$i] && $param_contains->[$i] ne "") {
                push(@params, "${param}.contains");
                $paramvalues{"${param}.contains"} = $param_contains->[$i];
            }
        }
    }

    $w->set("params",      \@params);
    $w->set("paramvalues", \%paramvalues);

    if ($App::DEBUG && $self->{context}->dbg(2)) {
        my ($ref);
        $ref = $self->get("columns");
        $self->{context}->dbgprint("RepositoryEditor->set_mode(): columns=[", join(",", @$ref), "]") if ($ref);
        $ref = $self->get("ordercols");
        $self->{context}->dbgprint("RepositoryEditor->set_mode(): ordercols=[", join(",", @$ref), "]") if ($ref);
        $ref = $self->get("directions");
        $self->{context}->dbgprint("RepositoryEditor->set_mode(): directions=[", join(",", @$ref), "]") if ($ref);
        $ref = $params;
        $self->{context}->dbgprint("RepositoryEditor->set_mode(): params=[", join(",", @$ref), "]") if ($ref);
        $ref = $param_contains;
        $self->{context}->dbgprint("RepositoryEditor->set_mode(): param_contains=[", join(",", @$ref), "]") if ($ref);
        $self->{context}->dbgprint("RepositoryEditor->set_mode(): params=[", join(",", @params), "]");
        $self->{context}->dbgprint("RepositoryEditor->set_mode(): paramvalues=[", join(",", %paramvalues), "]");
    }
}

######################################################################
# OUTPUT METHODS
######################################################################

sub html {
    my $self = shift;
    my ($context, $name, $mode);

    $context = $self->{context};
    $name    = $self->{name};
    $mode    = $self->get("mode","");

    if ($mode eq "edit" || $mode eq "view") {
        return $context->widget("${name}_datatable")->html();
    }
    else {
        return $self->mk_criteria_html();
    }
}

sub mk_criteria_html {
    my $self = shift;

    my ($name, $context, $repname, $rep, $table, $table_names, $table_label_hashref, $table_label);

    $context = $self->{context};
    $name    = $self->{name};
    $repname = $self->{repository};
    $rep     = $context->repository($repname);
    $self->{rep} = $rep;
    $rep = $self->{rep};

    $table_names = $rep->get_table_names();
    $table_label_hashref = $rep->get_table_labels();
    $table = $self->get("table");
    $table_label = $table_label_hashref->{$table};
    $table_label = $table if (!$table_label);

    $self->set("saveas_view","");
    $self->set("new_table",$table);

    my ($html);
    my ($view, $saveas_view, $new_table, $maxrows);
    my ($open_button, $save_button, $delete_button, $saveas_button);
    my ($view_button, $edit_button, $select_button);
    my ($columns, $params);

    $view          = $context->widget("$name-view",
                         class => "App::Widget::TextField",
                         size => 20,
                         maxwidth => 99,
                     )->html();

    $saveas_view   = $context->widget("$name-saveas_view",
                         class => "App::Widget::TextField",
                         size => 20,
                         maxwidth => 99,
                     )->html();

    $new_table     = $context->widget("$name-new_table",
                         class => "App::Widget::Select",
                         values => $table_names,
                         labels => $table_label_hashref,
                     )->html();

    $self->set_default("maxrows",25);

    $maxrows       = $context->widget("$name-maxrows",
                         class => "App::Widget::TextField",
                         size => 4,
                         maxlength => 99,
                     )->html();

    $open_button   = $context->widget("$name-open_button",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         label => "Open",
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();

    $save_button   = $context->widget("$name-save_button",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         label => "Save",
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();

    $delete_button = $context->widget("$name-delete_button",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         label => "Delete",
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();

    $saveas_button = $context->widget("$name-saveas_button",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         label => "Save As",
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();

    $view_button   = $context->widget("$name-view_button",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         label => "View",
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();

    $edit_button   = $context->widget("$name-edit_button",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         label => 'Edit',
                         height => 17,
                         width => 50,
                         bevel => 2,
                     )->html();

    $select_button = $context->widget("$name-select_button",
                         class => "App::Widget::ImageButton",
                         image_script => 'app-button',
                         label => "Select Table",
                         height => 17,
                         width => 100,
                         bevel => 2,
                     )->html();

    $columns       = $self->column_selection_html();
    $params        = $self->param_selection_html();

    my ($fontbegin, $fontend);
    $fontbegin = "<font face=\"verdana,geneva,arial,sans-serif\" size=-1>";
    $fontend = "</font>";

    $html = <<EOF;
<table border=0 cellspacing=0 cellpadding=3 width=100%>
<tr>
  <td nowrap width="2%">${fontbegin}Select View: ${fontend}</td>
  <td nowrap>${fontbegin}$view $open_button $save_button $delete_button
    : $saveas_button $saveas_view
  ${fontend}</td>
</tr>
<tr>
  <td nowrap width="2%">${fontbegin}Select Table: ${fontend}</td>
  <td nowrap>${fontbegin}$new_table $select_button${fontend}</td>
</tr>
<tr>
  <td colspan=2><hr size=1></td>
</tr>
<tr>
  <td nowrap width="2%">${fontbegin}Table:${fontend}</td>
  <td nowrap>${fontbegin}<b>$table_label</b>${fontend}</td>
</tr>
<tr>
  <td nowrap width="2%">${fontbegin}Query: ${fontend}</td>
  <td nowrap>${fontbegin}$view_button $edit_button Max Rows: $maxrows${fontend}</td>
</tr>
<tr>
  <td nowrap valign="top" width="2%">${fontbegin}Columns: ${fontend}</td>
  <td nowrap valign="top">${fontbegin}$columns${fontend}</td>
</tr>
<tr>
  <td nowrap valign="top" width="2%">${fontbegin}Criteria: ${fontend}</td>
  <td nowrap valign="top">${fontbegin}$params${fontend}</td>
</tr>
</table>
EOF

    $html;
}

sub column_selection_html {
    my $self = shift;

    my ($context, $name, $repname, $rep, $table);
    $context = $self->{context};
    $name    = $self->{name};
    $repname = $self->get("repository");
    $rep     = $context->repository($repname);
    $table   = $self->get("table");
    return     "ERROR: No table specified" if (!$table);

    my ($columns, $column_labels, $column_menu, $column_menu_html);
    $columns       = $rep->get_column_names($table);
    $column_labels = $rep->get_column_labels($table);
    $column_menu = $context->widget("$name-columns",
        override => 1,
        class => "App::Widget::Select",
        values => $columns,
        labels => $column_labels,
        size => 8,
        multiple => 1,
    );
    $column_menu_html = $column_menu->html();

    my (@order_menu, @dir_menu, @summ_checkbox, @xtab_checkbox, $i);

    for ($i = 0; $i < 5; $i++) {

        $order_menu[$i]    = $context->widget("$name\{ordercols\}[$i]",
                                 class => "App::Widget::Select",
                                 values => $columns,
                                 labels => $column_labels,
                                 size => 1,
                                 nullable => 1,
                             )->html();

        $dir_menu[$i]      = $context->widget("$name\{directions\}[$i]",
                                 class => "App::Widget::Select",
                                 values => [ '', 'asc', 'desc', ],
                                 labels => { '' => '', 'asc' => 'Up', 'desc' => 'Down', },
                             )->html();

        $summ_checkbox[$i] = $context->widget("$name\{summarize\}[$i]",
                                 class => "App::Widget::Checkbox",
                             )->html();

        $xtab_checkbox[$i] = $context->widget("$name\{crosstabulate}[$i]",
                                 class => "App::Widget::Checkbox",
                             )->html();
    }

    my ($fontbegin, $fontend);
    $fontbegin = "<font face=\"verdana,geneva,arial,sans-serif\" size=-1>";
    $fontend = "</font>";

    my $html = <<EOF;
<table border=0 cellspacing=0 cellpadding=3>
<tr>
  <td valign=top width=2%>$column_menu_html</td>
  <td valign=top nowrap>
    <table border=0 cellpadding=0 cellspacing=1>
      <tr>
        <td>${fontbegin}Sort Order:${fontend}</td>
        <!-- <td align=center>${fontbegin}&nbsp;Summarize&nbsp;${fontend}</td> -->
        <!-- <td align=center nowrap>${fontbegin}&nbsp;Cross-tabulate&nbsp;${fontend}</td> -->
      </tr>
      <tr>
        <td nowrap>$order_menu[0] $dir_menu[0]</td>
        <!-- <td align=center>$summ_checkbox[0]</td> -->
        <!-- <td align=center>$xtab_checkbox[0]</td> -->
      </tr>
      <tr>
        <td nowrap>$order_menu[1] $dir_menu[1]</td>
        <!-- <td align=center>$summ_checkbox[1]</td> -->
        <!-- <td align=center>$xtab_checkbox[1]</td> -->
      </tr>
      <tr>
        <td nowrap>$order_menu[2] $dir_menu[2]</td>
        <!-- <td align=center>$summ_checkbox[2]</td> -->
        <!-- <td align=center>$xtab_checkbox[2]</td> -->
      </tr>
      <tr>
        <td nowrap>$order_menu[3] $dir_menu[3]</td>
        <!-- <td align=center>$summ_checkbox[3]</td> -->
        <!-- <td align=center>$xtab_checkbox[3]</td> -->
      </tr>
      <tr>
        <td nowrap>$order_menu[4] $dir_menu[4]</td>
        <!-- <td align=center>$summ_checkbox[4]</td> -->
        <!-- <td align=center>$xtab_checkbox[4]</td> -->
      </tr>
    </table>
  </td>
</tr>
</table>
EOF
    $html;
}

sub param_selection_html {
    my $self = shift;

    my ($context, $name, $repname, $rep, $table);
    $context = $self->{context};
    $name    = $self->{name};
    $repname = $self->get("repository");
    $rep     = $context->repository($repname);
    $table   = $self->get("table");
    return     "ERROR: No table specified" if (!$table);

    my ($columns, $column_labels);
    $columns       = $rep->get_column_names($table);
    $column_labels = $rep->get_column_labels($table);

    my ($conjunction_menu);
    my (@conjunction, %conjunction);
    @conjunction = ("AND", "OR", "NOT_AND", "NOT_OR");
    %conjunction = (
        "AND"     => "All of the following conditions",
        "OR"      => "Any of the following conditions",
        "NOT_AND" => "Not all of the following conditions",
        "NOT_OR"  => "Not any of the following conditions",
    );

    $conjunction_menu = $context->widget("$name-conjunction",
        class => "App::Widget::Select",
        values => \@conjunction,
        labels => \%conjunction,
    )->html();

    my (@param_menu, @param_min, @param_max, @param_contains, $i);

    for ($i = 0; $i < 5; $i++) {

        $param_menu[$i]    = $context->widget("$name\{param}[$i]",
                                 class => "App::Widget::Select",
                                 values => $columns,
                                 labels => $column_labels,
                                 nullable => 1,
                             )->html();

        $param_min[$i]     = $context->widget("$name\{param_min}[$i]",
                                 class => "App::Widget::TextField",
                                 size => 8,
                                 maxlength => 99,
                             )->html();

        $param_max[$i]     = $context->widget("$name\{param_max}[$i]",
                                 class => "App::Widget::TextField",
                                 size => 8,
                                 maxlength => 99,
                             )->html();

        $param_contains[$i]= $context->widget("$name\{param_contains}[$i]",
                                 class => "App::Widget::TextField",
                                 size => 8,
                                 maxlength => 99,
                             )->html();
    }

    my ($fontbegin, $fontend);
    $fontbegin = "<font face=\"verdana,geneva,arial,sans-serif\" size=-1>";
    $fontend = "</font>";

    my $html = <<EOF;
<table border=0 cellspacing=0 cellpadding=3>
  <tr>
    <td valign="top" nowrap>${fontbegin}
      $conjunction_menu<br>
      $param_menu[0] Min: $param_min[0] Max: $param_max[0] Contains: $param_contains[0]<br>
      $param_menu[1] Min: $param_min[1] Max: $param_max[1] Contains: $param_contains[1]<br>
      $param_menu[2] Min: $param_min[2] Max: $param_max[2] Contains: $param_contains[2]<br>
      $param_menu[3] Min: $param_min[3] Max: $param_max[3] Contains: $param_contains[3]<br>
      $param_menu[4] Min: $param_min[4] Max: $param_max[4] Contains: $param_contains[4]${fontend}</td>
  </tr>
</table>
EOF

    $html;
}

1;

