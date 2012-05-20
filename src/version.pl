#!/usr/local/bin/perl -w

# version[.pl] - Interpreter for the Version Programming Language
# Chris Pressey, Cat's Eye Technologies
# http://catseye.tc/projects/version/
# $Id: version.pl 525 2010-04-29 16:08:22Z cpressey $

# Copyright (c)2001-2010 Cat's Eye Technologies.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#   Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# 
#   Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# 
#   Neither the name of Cat's Eye Technologies nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE. 

### BEGIN version[.pl] ###

# usage: [perl] version[.pl] version-source-filename

### INITIALIZATION ###

# Open and read source file.

$|=1;
die "Usage: $0 version-source-filename\n" if not $ARGV[0];
if (open(FILE, $ARGV[0]))
{
  @program = <FILE>;
} else
{
  die "Can't open file '$ARGV[0]' for reading";
}
close FILE;

# Set initial values of variables.

$ip = 0;                          # instruction pointer
$ig = "";                         # ignore-space
$last_var = "DUANE";              # last variable assigned to
$ignord = 0;                      # number of lines ignored

### MAIN LOOP ###

while(1)
{
  $d = $program[$ip];             # fetch line from program
  if ($d =~ /^(.*?)\:(.*)$/)      # if it's an instruction
  {
    $lab = $1;
    $ins = $2;
    if ($lab !~ /$ig/)            # and it's not being ignored
    {
      execute($ins);              # do it
      $ignord = 0;
    } else
    {
      $ignord++;
    }
  } else
  {
    $ignord++;
  }
  exit(0) if $ignord > $#program; # halt if all lines are ignored
  $ip++;                          # otherwise, keep going and
  $ip = 0 if $ip > $#program;     # wrap around when necessary
}

### SUBROUTINES ###

# execute($string) - Execute a line of source code.

sub execute
{
  my $ins = shift;
  if ($ins =~ /^\s*(.*?)\s*\=\s*(.*)\s*$/)
  {
    $lv = uc $1;
    $rv = $2;
    $v = calculate($rv);
    if ($lv eq 'OUTPUT')
    {
      print $v;
    }
    elsif ($lv eq 'IGNORE')
    {
      $ig = convert_regexp($v);
    }
    elsif ($lv eq 'CAT')
    {
      $var{$last_var} .= $v;
    }
    elsif ($lv eq 'PUT')
    {
      $var{$last_var . $v} = $var{$last_var};
    }
    elsif ($lv eq 'GET')
    {
      $var{$last_var} = $var{$last_var . $v};
    }
    else
    {
      $var{$lv} = $v;
      $last_var = $lv;
    }
  } else
  {
    die "Badly formed instruction '$ins'";
  }
}

# calculate($string) - Determine the value of an expression.

sub calculate
{
  my $expr = shift;
  if ($expr =~ /^\s*\"(.*?)\"\s*$/)
  {
    return $1;                    # it's a literal string
  } elsif ($expr =~ /^\s*(.*?)\s+(.*)\s*$/)
  {
    my $func = uc $1;             # it's a function
    my $rv = $2;
    my $v = calculate($rv);       # recurse; get rest of line first
    
    if ($func eq 'PRED')          # apply appropriate transform
    {
      $v = 0+$v-1;
      return("$v");
    }
    elsif ($func eq 'SUCC')
    {
      $v = 0+$v+1;
      return("$v");
    }
    elsif ($func eq 'CHOP')
    {
      chop $v;
      return("$v");
    }
    elsif ($func eq 'POP')
    {
      $v =~ s/^.//s;
      return("$v");
    }
    elsif ($func eq 'LEN')
    {
      $v = length($v);
      return("$v");
    }
    else
    {
      die "Unknown function $func";
    }
  } else                          # it's an identifier
  {
    if (uc($expr) eq 'INPUT')     # check if it's a special identifier
    {
      my $r = <STDIN>;
      if (not defined $r)
      {
        $var{'EOF'} = 'TRUE';
        $r = "";
      }
      return $r;
    }
    elsif (uc($expr) eq 'IGNORE')
    {
      return $ig;
    }
    elsif (uc($expr) eq 'EOL')
    {
      return "\n";
    }
    else                          # not so special, just a variable
    {
      $var{$expr} = '' if not defined $var{$expr};
      return $var{$expr};
    }
  }
}

# convert_regexp($string) - Turn a Version irregular expression into
#                           a Perl regular expression

sub convert_regexp
{
  my $reg = shift;
  $reg = quotemeta($reg);         # make sure any perlisms are caught
  $reg =~ s/\\\?/\./g;            # ?'s become .'s
  $reg =~ s/\\\*/\.\*\?/g;        # *'s become .*?'s
  $reg =~ s/\\\|/\|/g;            # |'s stay as |'s
  return '^(' . $reg . ')$';      # grouped, with bos and eos symbols
}

### END of version[.pl] ###
