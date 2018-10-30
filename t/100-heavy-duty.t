#! /usr/bin/env perl6
use v6.c;
use lib 'lib';
use Test;
use Test::Output;
use File::Directory::Tree;
use Pod::Cached;

if 't/tmp'.IO ~~ :d  {
    empty-directory 't/tmp';
}
else {
    mktree 't/tmp'
}
mktree 't/tmp/doc';

# set up pod files
constant DRY-RUN = 5;
constant HEAVY-RUN = 256;
constant TEST-FILE = 't/doctest/contexts.pod6';

my $text = TEST-FILE.IO.slurp;
my Pod::Cached $cache;
my ( $start1, $start2, $stop1, $stop2);

"t/tmp/doc/test-$_.pod6".IO.spurt($text) for ^DRY-RUN;
is +'t/tmp/doc'.IO.dir, DRY-RUN, 'files written';
$start1 = now;
lives-ok { $cache .= new(:path<t/tmp/ref>, :source<t/tmp/doc>); $cache.update-cache }, 'dry run lives';
$stop1 = now;
is +$cache.list-files( Pod::Cached::Updated ), DRY-RUN, DRY-RUN ~ ' files cached as updated (new/compiled)';

empty-directory 't/tmp';
mktree 't/tmp/doc';

diag 'Starting Heavy run';
"t/tmp/doc/test-$_.pod6".IO.spurt($text) for ^HEAVY-RUN;
is +'t/tmp/doc'.IO.dir, HEAVY-RUN, 'files written';
$start2 = now;
lives-ok { $cache .= new(:path<t/tmp/ref>, :source<t/tmp/doc>); $cache.update-cache }, 'Heavy run lives';
$stop2 = now;
is +$cache.list-files( Pod::Cached::Updated ), HEAVY-RUN, HEAVY-RUN ~ ' files cached as updated (new/compiled)';

diag "Dry run took " ~ DateTime.new($stop1 - $start1).hh-mm-ss ~ '. Heavy run took ' ~ DateTime.new($stop2-$start2).hh-mm-ss;
empty-directory 't/tmp';

done-testing;
