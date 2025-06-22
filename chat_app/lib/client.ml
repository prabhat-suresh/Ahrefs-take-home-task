open Eio

let run ~env ip_addr port username =
  traceln "Connecting to server at %s on port %d..." ip_addr port;
  try
    (* connect to server on given ip_addr and port and start a chat session *)
    Net.with_tcp_connect ~host:ip_addr ~service:(string_of_int port)
      (Stdenv.net env)
    @@ fun flow -> Common.start_chat ~env flow username
  with _ ->
    traceln
      "Failed to connect. Please check if you have given the right ip address \
       and port"
