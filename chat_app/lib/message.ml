type t =
  (* message format *)
  | Ack of
      int (* Ack i is the acknowledgement in response to the message of id=i *)
  | Msg of { id : int; username : string; msg : string; time_sent : float }
    (* Here time_sent is a float representing no. of seconds since 1970 as returned by Unix.time *)
[@@deriving yojson]

(* json serialization and deserialization using yojson *)
let to_string msg = msg |> to_yojson |> Yojson.Safe.to_string
let of_string s = s |> Yojson.Safe.from_string |> of_yojson
