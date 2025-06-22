open Eio
open Cmdliner
open Chat_app

let is_client =
  (* A CLI flag to run a client instance instead of server *)
  let info =
    Arg.info [ "c"; "client" ]
      ~doc:"Run a client instance (instead of the default i.e. server instance)"
  in
  Arg.value (Arg.flag info)

let port_num =
  (* Optional CLI argument specifying a different port *)
  let default = 8080 in
  let info =
    Arg.info [ "p"; "port" ]
      ~doc:"Optionally provide a different port no. (Default is 8080)"
  in
  Arg.value (Arg.opt Arg.int default info)

let username =
  (* Optional CLI argument specifying username to be used in the chat *)
  let default = Printf.sprintf "Anonymous#%d" @@ Random.int 1_000_000_000 in
  let info =
    Arg.info [ "u"; "username" ] ~doc:"Optionally provide your username"
  in
  Arg.value (Arg.opt Arg.string default info)

let ip_addr =
  (* Optional CLI argument specifying a different ip address*)
  let default = "127.0.0.1" in
  let info =
    Arg.info [ "ip-address" ]
      ~doc:
        "Optionally provide the ip-address of the host (Default is localhost \
         i.e. '127.0.0.1').\n\
         Note that this option is only for client instances"
  in
  Arg.value (Arg.opt Arg.string default info)

let run is_client ip_addr port username =
  (* main event loop *)
  Eio_main.run @@ fun env ->
  Switch.run @@ fun sw ->
  (* based on whether the client flag was passed run the server / client instance accordingly *)
  if is_client then Client.run ~env ip_addr port username
  else Server.run ~env ~sw port username

let () =
  let info = Cmd.info "One-on-one chat app" in
  Term.(const run $ is_client $ ip_addr $ port_num $ username)
  |> Cmd.v info |> Cmd.eval |> exit
