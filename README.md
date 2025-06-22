# Ahrefs-take-home-task
[Instructions for the task](/instructions.md)

### Demo
[View the demo](./Ahrefs_take_home_task_demo.mkv)


## Build and Run the project
To build the project you should have Opam and Dune setup on your system. Visit [OCaml's website](https://ocaml.org/install#linux_mac_bsd) for instructions.

**Install dependencies:**
```bash
opam install eio eio_main cmdliner yojson ppx_deriving ppx_deriving_yojson
```

Clone and cd into the chat_app directory. Then run

```bash
dune build --release
```

Run the executable and get info regarding arguments:
```bash
./_build/default/bin/main.exe --help
```


### Running the executable without building
You can find the executable for Linux(x86-64) in the release section. Download and execute it after giving it permissions.

Run a server instance:
```bash
./_build/default/bin/main.exe --username=Alice 
```

Run a client instance connecting to a server on localhost:
```bash
./_build/default/bin/main.exe --client --username=Bob 
```

### Project details
The project uses:
- [Eio](https://github.com/ocaml-multicore/eio) for concurrency and network IO
- [Cmdliner](https://erratique.ch/software/cmdliner) for building an extensible CLI with proper info and help
- [Yojson](https://github.com/ocaml-community/yojson) and [ppx_deriving_yojson](https://github.com/ocaml-ppx/ppx_deriving_yojson) for serialization and deserialization in json format
