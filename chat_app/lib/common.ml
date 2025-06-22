open Eio

type session_terminator =
  (* an enum to distinguish who terminated the session *)
  | You
  | Other

let msg_sent_times_queue = Queue.create ()
(* a queue to maintain the msg dispatch times along with msg id. This is for calculating the round trip time for each message *)

let float_to_local_datetime f =
  (* converts time in float (as returned by Unix.time) to YYYY-MM-DD HH:MM:SS format *)
  let today = Unix.localtime f in
  Printf.sprintf "On %04d-%02d-%02d at %02d:%02d:%02d" (today.tm_year + 1900)
    (today.tm_mon + 1) today.tm_mday today.tm_hour today.tm_min today.tm_sec

let send_msg to_flow msg =
  (* buffered write a msg to the given flow *)
  Buf_write.with_flow to_flow @@ fun to_buf ->
  Buf_write.string to_buf @@ Message.to_string msg ^ "\n"

let send_chat_from_stdin ~env ~clock to_flow username () =
  let msg_id = ref 1 in
  (* a counter for sequential generation of msg id *)
  let stdin_buf = Buf_read.of_flow (Stdenv.stdin env) ~max_size:100 in
  (* stdin as an Eio Flow buffer *)
  try
    while true do
      (* infinite loop that reads messages from stdin, enqueues a corresponding dispatch entry to the queue and sends the msg across *)
      let msg = Buf_read.line stdin_buf in
      let time_sent = Time.now clock in
      Queue.add (!msg_id, time_sent) msg_sent_times_queue;
      send_msg to_flow @@ Msg { id = !msg_id; username; msg; time_sent };
      incr msg_id
    done
  with End_of_file -> You
(* indicates EOF due to user terminating session (Ctrl-C) or Ctrl-D for ending chat *)

let display_received_messages_and_acknowledge ~clock from_sender () =
  let inbox = Buf_read.of_flow from_sender ~max_size:1_000_000_000 in
  (* socket as a read buffer *)
  try
    while true do
      (* infinite loop that reads messages from buffer and prints to stdout; responds to messages with acknowledgement and displays round trip time after receiving acknowledgement for messages sent by referring to dispatch times in the queue *)
      let received_msg = Message.of_string @@ Buf_read.line inbox in
      match received_msg with
      | Ok (Msg { id; username; msg; time_sent }) ->
          traceln "%s sent msg no. %d: %s (%s)" username id msg
          @@ float_to_local_datetime time_sent;
          send_msg from_sender @@ Ack id
      | Ok (Ack 0) ->
          (* This is a convention used. The server sends this as soon as it handles the connection indicating successfully established connection to the client. 0 is used as all msg IDs start from 1 and hence Ack 0 will never be sent in response to a msg *)
          traceln
            "Server has accepted connection. You can chat now:   (Use Ctrl-D \
             (EOF) to terminate chat session)";
          traceln
            "--------------------------------------------------------------------------------------------------------------------+"
      | Ok (Ack id) -> (
          match Queue.take_opt msg_sent_times_queue with
          | Some (msg_id, time_sent) ->
              if msg_id = id then
                traceln
                  "msg no. %d sent by you: has been acknowledged by receiver \
                   (round trip time: %f ms)"
                  id
                  ((Time.now clock -. time_sent) *. 1000.0)
              else failwith "queue doesn't have the message with same id"
                (* As the whole chat protocol is linear there shouldn't be any other msg id in front of the queue *)
          | None ->
              failwith "Queue is empty"
              (* the queue shouldn't be empty on normal execution of the app as the dispatch time entry is always enqueued before sending the message *)
          )
      | Error s -> traceln "invalid message format. Failed to deserialize: %s" s
    done
  with End_of_file -> Other
(* indicates EOF due to the user at the other terminating session (Ctrl-C) or Ctrl-D for ending chat *)

let start_chat ~env flow username =
  let clock = Stdenv.clock env in
  Fiber.first
    (* runs both send_chat and display daemons as 2 fibers and returns as soon either is done (due to error/termination) *)
    (send_chat_from_stdin ~env ~clock flow username)
    (display_received_messages_and_acknowledge ~clock flow)
  |> function
  | You -> traceln "Chat session was terminated by you."
  | Other ->
      traceln "Chat session was terminated by the person on the other end."
