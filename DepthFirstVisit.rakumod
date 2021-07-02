use v6;
sub depth-first-visit (
      :&discover-action,       # first time a node is found
      :action(:&visit-action), # when node is visited
      :&skip-action,           # node skipped due previous visit
      :&leave-action,          # node visiting ends
      :identifier(:&id) = -> $item {~$item},
      :&successors!,
      :@start!,
) {
   my %a; # adjacent nodes
   my @s = @start.map: { &discover-action($_, Nil) if &discover-action;
                         %a{&id($_)} = [&successors($_)]; [$_, Nil] };
   while @s {
      my ($v, $pred) = @s[*-1]; # "top" of the stack
      &visit-action($v, $pred) if &visit-action;
      my $vid = &id($v);
      if %a{$vid}.elems {
         my $w = %a{$vid}.shift;
         my $wid = &id($w);
         if (%a{$wid}:exists) {
            &skip-action($w, $v) if &skip-action;
         }
         else {
            &discover-action($w, $v) if &discover-action;
            %a{$wid} = [&successors($w)];
            @s.push: [$w, $v];
         }
      }
      else {
         &leave-action($v, $pred) if &leave-action;
         @s.pop;
      }
   }
   return %a.keys;
}

sub MAIN {
   my %graph =
      1 => (2, 3, 4),
      2 => (3),
      3 => (5, 6),
      4 => (1, 6),
      5 => (1, 2),
      6 => (3, 4),
   ;
   my &printable = -> $name {
      -> $v, $p is copy {
         $p //= '(*)';
         put "$name $v (from $p)";
      }
   };
   .put for depth-first-visit(
      successors => { %graph{$^node}.List },
      start      => [ 1 ],
      discover-action => &printable('found'),
      skip-action     => &printable('skip'),
      visit-action    => &printable('visit'),
      leave-action    => &printable('leave'),
   );
}
