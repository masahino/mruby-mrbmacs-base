use strict;
use warnings;

=head1 NAME

style-preview - POD documentation

=cut

my $scalar = "mrbmacs";
my @array = qw(Ruby Python Perl);
my %hash = (count => 17, enabled => 1);

sub greet {
  my ($name) = @_;
  return qq{hello $name\n};
}

for my $item (@array) {
  print greet($item) if $item =~ /P(?:yth|e)rl|Ruby/;
}

$scalar =~ s/mrb/mac/gi;
my $quoted = q{literal string};
my $words = qw(one two three);
my $command = qx{printf command};

my $document = <<"END_TEXT";
project=$scalar
count=$hash{count}
END_TEXT

format PREVIEW =
Name: @<<<<<<<<<<<<
$scalar
.

__DATA__
data section
