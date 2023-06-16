#!/usr/bin/perl

use strict;
use warnings;

my ($help_screen);

$help_screen = << 'Endofblock';

This program generates a password using xkcd's algorithm (concatenating
several random dictionary words). This gives passwords that are strong and
easy to remember.

NOTE - This uses rand(), which is not cryptographically strong.

Usage:  gen-password  <options>

Options:
--help               Prints this screen.
--dictionary=(file)  Specifies dictionary; default is "/usr/share/dict/words".
--numwords=N         Specifies number of words; default is 4.
--debug-dict         Prints dictionary debugging information.

Endofblock



#
# Functions


# No arguments.
# Returns a pointer to a configuration hash.

sub ParseArgs
{
  my ($config_p);
  my ($aidx, $thisarg);

  $config_p =
  { 'want_help' => 0, 'had_problem' => 0,
    'numwords' => 4, 'want_dict_debug' => 0 };

  if (-e '/usr/share/dict/words')
  { $$config_p{'dictionary'} = '/usr/share/dict/words'; }
  elsif (-e '/etc/dictionaries-common/words')
  { $$config_p{'dictionary'} = '/etc/dictionaries-common/words'; }


  for ($aidx = 0; defined ($thisarg = $ARGV[$aidx]); $aidx++)
  {
    if ( ($thisarg eq '--help') || ($thisarg eq '-?') )
    { $$config_p{'want_help'} = 1; }
    elsif ($thisarg =~ m/^--dictionary=(.*)$/)
    { $$config_p{'dictionary'} = $1; }
    elsif ($thisarg =~ m/^--numwords=(\d+)$/)
    { $$config_p{'numwords'} = $1; }
    elsif ($thisarg eq '--debug-dict')
    { $$config_p{'want_dict_debug'} = 1; }
    else
    {
      print
        "###  Unrecognized option \"$thisarg\". Use \"--help\" for help.\n";
      $$config_p{'had_problem'} = 1;
    }
  }

  if ($$config_p{'numwords'} < 1)
  { $$config_p{'numwords'} = 1; }

  return $config_p;
}



# Arg 0 is the filename to read from.
# Returns a pointer to a list of dictionary words, filtered to remove
# various unwanted entries. Returns undef on error.

sub ReadDictionary
{
  my ($dict_p, $fname);
  my (@rawlist, @cookedlist, $thisword);
  my ($skipcount);

  $fname = $_[0];
  $dict_p = undef;

  if (!open(INFILE, "<$fname"))
  { print "###  Couldn't read from \"$fname\"!\n"; }
  else
  {
    @rawlist = <INFILE>;
    close(INFILE);

    @cookedlist = [];
    $skipcount = 0;
    foreach $thisword (@rawlist)
    {
      chomp($thisword);

      # Get rid of apostrophes, suffixes, etc; there are a lot of these.
      # Also words starting with capitals, short words, etc.
      if ( (length($thisword) >= 5) && (length($thisword) <= 7)
        && (!($thisword =~ m/[^a-z]/)) && (!($thisword =~ m/s$/))
        && (!($thisword =~ m/ed$/)) && (!($thisword =~ m/ing$/))
        && (!($thisword =~ m/ly$/)) && (!($thisword =~ m/er$/)) )
      { push @cookedlist, $thisword; }
      else
      { $skipcount++; }
    }

    if (scalar(@cookedlist) < 1000)
    {
      print "###  Didn't find enough words in \"$fname\"!\n";
      PrintDictionaryStats(\@cookedlist);
      print "Filtered $skipcount words.\n";
    }
    else
    {
      $dict_p = [];
      @$dict_p = @cookedlist;
    }
  }

  return $dict_p;
}



# Arg 0 points to a list of words.
# No return value.

sub PrintDictionaryStats
{
  my ($dict_p);

  $dict_p = $_[0];

  print "Dictionary contains " . scalar(@$dict_p) . " words.\n";
}



# Arg 0 points to a list of words.
# Arg 1 is the number of words to concatenate.
# Returns a concatenated word string.

sub GenPassword
{
  my ($result, $dict_p, $wordcount);
  my ($dictcount, $widx, $didx);

  $dict_p = $_[0];
  $wordcount = $_[1];
  $result = '';

  $dictcount = scalar(@$dict_p);

  for ($widx = 0; $widx < $wordcount; $widx++)
  {
    $didx = int(rand($dictcount));
    $result = $result . ucfirst($$dict_p[$didx]);
  }

  return $result;
}



#
# Main Program


my ($config_p, $dictlist_p);

$config_p = ParseArgs();

if ($$config_p{'want_help'})
{ print $help_screen; }
elsif (!($$config_p{'had_problem'}))
{
  $dictlist_p = ReadDictionary($$config_p{'dictionary'});
  if (defined $dictlist_p)
  {
    if ($$config_p{'want_dict_debug'})
    { PrintDictionaryStats($dictlist_p); }
    else
    {
      print GenPassword($dictlist_p, $$config_p{'numwords'}) . "\n";
    }
  }
}


#
# This is the end of the file.
