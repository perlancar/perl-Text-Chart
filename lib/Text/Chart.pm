package Text::Chart;

# DATE
# VERSION

use 5.010001;
use strict;
use utf8;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(gen_text_chart);

our %SPEC;

our @CHART_TYPES = (
    #'bar',
    #'column',
    'sparkline',
    #line
    #pie
    #area (see Google Charts API)
    #tree map (see Google Charts API)
);

my @sparkline_chars = split //, '▁▂▃▄▅▆▇█';

$SPEC{gen_text_chart} = {
    v => 1.1,
    summary => "Generate text-based chart",
    args => {
        data => {
            summary => '(Table) data to chart',
            schema => ['any*', of => [
                ['array*' => of => 'num*'],
                ['array*' => of => 'array*'],
                ['array*' => of => 'hash*'],
            ]],
            req => 1,
            pos => 1,
            description => <<'_',

Either in the form of array of numbers, example:

    [1366,1248,319,252]

or an array of arrays (there must be at least one number columns), example:

    [["China",1366],["India",1248],["United Status",319], ["Indonesia",252]]

or an array of hashes (there must be at least one key which consistently contain
numbers), example:

    [{country=>"China"        , population=>1366},
     {country=>"India"        , population=>1248},
     {country=>"United Status", population=> 319},
     {country=>"Indonesia"    , population=> 252}]

All data needs to be in table form (where there are notions of rows and
columns/fields). Array data is assumed to be a single-column table with the
column named `data`. Array of arrays will have columns named `column0`,
`column1` and so on. Array of hashes will have columns named according to the
hash keys.

_
        },
        spec => {
            summary => 'Table specification, according to TableDef',
            schema => 'hash*', # XXX TableDef
        },
        type => {
            summary => 'Chart type',
            schema => ['str*', in => \@CHART_TYPES],
            req => 1,
        },
        label_column => {
            summary => 'Which column contains data labels',
            schema => 'str*',
            description => <<'_',

If not specified, the first non-numeric column will be selected.

_
        },
        data_column => {
            summary => 'Which column(s) contain data to plot',
            description => <<'_',

Multiple data columns are supported.

_
            schema => ['any*' => of => [
                'str*',
                ['array*' => of => 'str*'],
            ]],
        },
        # XXX show_data_label
        # XXX show_data_value
        # XXX data_formats
        # XXX show_x_axis
        # XXX show_y_axis
        # XXX canvas_height
        # XXX canvas_width
        # XXX data_scale
        # XXX log_scale
    },
};
sub gen_text_chart {
    require TableData::Object;

    my %args = @_;

    # XXX schema
    $args{data} or return [400, "Please specify 'data'"];
    my $tbl = TableData::Object->new($args{data}, $args{spec});

    my @data_cols;
    {
        my $dc = $args{data_column};
        if (defined $dc) {
            @data_cols = ref($dc) eq 'ARRAY' ? @$dc : ($dc);
        } else {
            # find first numeric column
        }
    }
}

1;
# ABSTRACT: Generate text-based chart

=head1 SYNOPSIS

 use Text::Chart qw(gen_text_chart);

B<Bar chart:>

 my $res = gen_text_chart(
     data => [1, 5, 3, 9, 2],
     type => 'bar',
 );

will produce this:

 *
 *****
 ***
 *********
 **

B<Adding data labels and showing data values:>

 my $res = gen_text_chart(
     data => [["Andi",1], ["Budi",5], ["Cinta",3], ["Dewi",9], ["Edi",2]],
     type => 'bar',
     show_data_label => 1,
     show_data_value => 1,
 );

Result:

 Andi |*         (1)
 Budi |*****     (5)
 Cinta|***       (3)
 Dewi |********* (9)
 Edi  |**        (2)

C<Column chart:>

 my $res = gen_text_chart(
     data => [["Andi",1], ["Budi",5], ["Cinta",3], ["Dewi",9], ["Edi",2]],
     type => 'column',
     show_data_label => 1,
 );

Result:

                     *
                     *
                     *
                     *
        *            *
        *            *
  *     *      *     *
  *     *      *     *     *
  *     *      *     *     *
 Andi  Budi  Cinta  Dewi  Edi

C<Sparkline chart:>

 my $res = gen_text_chart(
     data => [["Andi",1], ["Budi",5], ["Cinta",3], ["Dewi",9], ["Edi",2]],
     type => 'column',
     show_data_label => 1,
 );

 my $res = gen_text_chart(
     data => [1.5, 0.5, 3.5, 2.5, 5.5, 4.5, 7.5, 6.5],
     type => 'sparkline',
 );

Result:

 XXX

C<Plotting multiple data columns:>

 XXX


=head1 DESCRIPTION

B<EARLY RELEASE, SOME FEATURES NOT YET IMPLEMENTED.> Currently only sparkline
chart is implemented. Showing data labels and data values are not yet
implemented.

This module lets you generate text-based charts.


=head1 TODO

=over

=item * More chart types

=item * Colors

=item * Resampling

Reduce data points, for example I have 1000 numbers that I want to display in a
80-column chart or sparkline.

=item * Formatting of data (or label)

Using L<Data::Unixish> (like in L<Text::ANSITable>), and specifiable from an
environment variable.

=item * Option to switch column/row (like in Excel)?

Probably not. I prefer that the data is adjusted instead.

=back


=head1 SEE ALSO

L<Text::Graph>, a mature CPAN module for doing text-based graphs. Before writing
Text::Chart I used this module for a while, but ran into the problem of weird
generated graphs. In addition, I don't like the way Text::Graph draws things,
e.g. a data value of 1 is drawn as zero-width bar, or the label separator C<:>
is always drawn. So I decided to write an alternative charting module instead.
Compared to Text::Graph, here are the things I want to add or do differently as
well: functional (non-OO) interface, colors, Unicode, resampling, more chart
types like sparkline, animation and some interactivity (perhaps).

=cut
