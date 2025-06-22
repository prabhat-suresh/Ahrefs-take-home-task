open Eio

val run :
  env:
    < clock : [> float Time.clock_ty ] Resource.t
    ; net : [> [> `Generic ] Net.ty ] Resource.t
    ; stdin : [> Flow.source_ty ] Resource.t
    ; .. > ->
  sw:Switch.t ->
  int ->
  string ->
  'a
