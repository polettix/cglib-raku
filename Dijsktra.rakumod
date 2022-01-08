#!/usr/bin/env raku
use v6;
use PriorityQueue;

class Dijkstra {
   has %!thread-to is built; # thread to a destination
   has $!start     is built;     # starting node
   has &!id-of     is built;     # turn a node into an identifier

   method new (:&distance!, :&successors!, :$start!, :@goals,
         :$more-goals is copy, :&id-of = -> $n { $n.Str }) {
      my %is-goal = @goals.map: { &id-of($_) => 1 };
      $more-goals //= (sub ($id) { %is-goal{$id}:delete; %is-goal.elems })
         if %is-goal.elems;
      my $id = &id-of($start);
      my $queue = PriorityQueue.new(
         before => sub ($a, $b) { $a<d> < $b<d> },
         id-of  => sub ($n) { $n<id> },
         items  => [{v => $start, id => $id, d => 0},],
      );
      my %thr-to = $id => {d => 0, p => Nil, pid => $id};
      while ! $queue.is-empty {
         my ($ug, $uid, $ud) = $queue.dequeue<v id d>;
         for &successors($ug) -> $vg {
            my ($vid, $alt) = &id-of($vg), $ud + &distance($ug, $vg);
            next if ($queue.contains-id($vid)
               ?? ($alt >= (%thr-to{$vid}<d> //= $alt + 1))
               !! (%thr-to{$vid}:exists));
            $queue.enqueue({v => $vg, id => $vid, d => $alt});
            %thr-to{$vid} = {d => $alt, p => $ug, pid => $uid};
         }
      }
      self.bless(thread-to => %thr-to, :&id-of, :$start);
   }

   method path-to ($v is copy) {
      my $vid = &!id-of($v);
      my $thr = %!thread-to{$vid} or return;
      my @retval;
      while defined $v {
         @retval.unshift: $v;
         ($v, $vid) = $thr<p pid>;
         $thr = %!thread-to{$vid};
      }
      return @retval;
   }
   method distance-to ($v) { (%!thread-to{&!id-of($v)} // {})<d> }
}

sub MAIN () {
   my %graph =
      Roma => { Milano => 5, Bologna => 2, Napoli => 1 },
      Milano => { Roma => 5, Bologna => 1 },
      Bologna => { Milano => 1, Roma => 2, Bari => 5 },
      Napoli => { Roma => 1, Bari => 5 },
      Bari => { Napoli => 5, Bologna => 5 }
      ;
   my $d = Dijkstra.new(
      distance => { %graph{$^a}{$^b} },
      successors => { %graph{$^a}.keys },
      start => 'Roma',
      goals => ['Milano'],
   );
   put "({$d.path-to('Milano').join(', ')}) total cost {$d.distance-to('Milano')}";
}
