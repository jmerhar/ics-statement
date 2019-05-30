# ICS Statement converter

Convert icscards.nl pdf statements to csv, to import them to Buxfer or other personal finance app.

Requires Ghostscript version 9.05 or later and Perl. You can install Ghostscript on a Mac with Homebrew:

```
brew install gs
```

## Usage

```
Usage: ics-pdf-to-csv.pl <input.pdf> [output.csv]
```

## Examples

```
ics-pdf-to-csv.pl Statement-12345678901-2019-05.pdf
ics-pdf-to-csv.pl Statement-12345678901-2019-05.pdf output.csv
```
