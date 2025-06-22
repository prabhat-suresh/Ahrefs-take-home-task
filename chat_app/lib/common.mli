open Eio

val send_msg : [> Eio__Flow.sink_ty ] Resource.t -> Message.t -> unit

val start_chat :
  env:
    < clock : [> float Time.clock_ty ] Resource.t
    ; stdin : [> Flow.source_ty ] Resource.t
    ; .. > ->
  [> `Flow | `R | `W ] Resource.t ->
  string ->
  unit
