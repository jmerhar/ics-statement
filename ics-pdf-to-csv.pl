#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

my $gs_version = `gs --version`;
die "Ghostscript 9.05 or higher required" if $! > 0 || $gs_version < 9.05;

sub PRINT_DEBUG {
    my ($input) = @_;
    print Dumper($input) if $ENV{'ICS_DEBUG'};
}

sub replace {
    my ($from,$to,$string) = @_;
    $string =~ s/$from/$to/g;
    return $string;
}
sub esc_shell { replace("'", "\\'", @_) }
sub esc_csv   { replace('"', '\\"', @_) }

sub gs {
    my ($file) = @_;
    my $gs_command = sprintf "gs -sDEVICE=txtwrite -q -o - '%s'", esc_shell($file);
    PRINT_DEBUG $gs_command;
    return `$gs_command`;
}

sub csv_line { join ",", map { '"' . esc_csv(replace('\s+', ' ', $_)) . '"' } @_ }

my $pdf_file = $ARGV[0];
die "Usage: <input.pdf> [output.csv]" unless $pdf_file;
die "Input file not found: $pdf_file" unless -f $pdf_file;

my $csv_file = $ARGV[1];
if (!$csv_file) {
    $csv_file = $pdf_file;
    $csv_file =~ s/\.pdf$//i;
    $csv_file .= '.csv';
}

my $statement = gs($pdf_file);
die "Error running Ghostscript" if $! > 0;
PRINT_DEBUG $statement;

my $statement_begin = "Uw Card met als laatste vier cijfers";
my $statement_end   = "Uw betalingen aan";
my $regex = "^.*$statement_begin(.+?)$statement_end.*\$";
PRINT_DEBUG $regex;
$statement =~ s/$regex/$1/s;
PRINT_DEBUG $statement;

my @lines = split /\n/, $statement;
shift @lines; # remove last four CC digits
shift @lines; # remove name
pop @lines;   # remove empty line at the end

my @transactions = map { [ unpack 'x17A12A13A58A37A11A*' ] } @lines;
PRINT_DEBUG \@transactions;

my $csv_text = join "\n", map { csv_line(@$_) } @transactions;
PRINT_DEBUG $csv_text;

open(my $handle, ">", $csv_file);
print $handle $csv_text;

print "CSV written to: $csv_file\n";
