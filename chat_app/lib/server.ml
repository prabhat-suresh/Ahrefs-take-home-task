open Eio

let run ~env ~sw port username =
  let host_addr = `Tcp (Net.Ipaddr.V4.any, port) in
  (* `any` represents all the Internet addresses that the host machine possesses. *)
  let listening_socket =
    (* creates a listening socket to listen to all ip addresses available to host machine for incoming connection requests *)
    Net.listen ~reuse_addr:true ~backlog:max_int ~sw (Stdenv.net env) host_addr
  in
  traceln "Starting server on %a.   (Use Ctrl-C to shut down the server)"
    Eio.Net.Sockaddr.pp host_addr;
  traceln
    "--------------------------------------------------------------------------------------------------------------------+";
  Net.run_server
  (* creates a server that accepts connection requests sent to listening_socket, forks and creates a new socket to handle the new connection separately *)
    ~max_connections:1
      (* according to instructions a server must handle only 1 connection at a time *)
    ~on_error:(fun exc ->
      traceln "Server encountered an error: %s" @@ Printexc.to_string exc)
    listening_socket
  @@ fun flow addr ->
  (* connection handler for each new connection *)
  traceln
    "Accepted connection from %a. You can chat now:   (Use Ctrl-D (EOF) to \
     terminate chat session)"
    Eio.Net.Sockaddr.pp addr;
  traceln
    "--------------------------------------------------------------------------------------------------------------------+";
  Common.send_msg flow @@ Ack 0;
  (* a convention used to indicate to the client that the connection has been established *)
  Common.start_chat ~env flow username
