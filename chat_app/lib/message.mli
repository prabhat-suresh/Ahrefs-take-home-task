type t =
  | Ack of int
  | Msg of { id : int; username : string; msg : string; time_sent : float }

val to_string : t -> string
val of_string : string -> t Ppx_deriving_yojson_runtime.error_or
