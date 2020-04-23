# JavaScript-Refactoring tool for Client Insourcing(JS-RCI)
Our approach is enabled by Client Insourcing, a novel automatic refactoring that creates a semantically equivalent centralized version of a distributed application. This centralized version is then inspected, modified, and redistributed to meet new requirements of web applications.

## How does JS-RCI work?
To examine HTTP traffic, JS-RCI automatically instruments remote functionalities executed at a Web server. It uses dynamic analysis (by means of a contraints solver) to identify the relevant remotely executed code. It enables idempotent execution in the presence of stateful server, with changes at both the JavaScript and relational database levels. In the end, JS-RCI automatically generates a semantically equivalent centralized variant of the original full-stack JavaScript application. This resulting centralized app can then be refactored and analyzed by applying all the numerous techniques deveveloped for centralized applications.


## Installing
```bash
npm install
```
Installing [z3py](https://github.com/Z3Prover/z3) for python
```bash
pip2.7 install z3-solver
```

## Running a demo
1. Running a node.js server with instrumenting code(based on [jalangi2](https://github.com/Samsung/jalangi2) and [z3py](https://github.com/Z3Prover/z3))
```bash
SERVER=subject_apps/ionic2-realty-rest/server.js npm run instrumenting
```
2. Replaying HTTP traffics(```bin/goreplay```is for MacOS. Download another binary if it is neccessary  https://github.com/buger/goreplay/releases)
```bash
sudo ./bin/goreplay --input-file records/record_example1_0.gor --output-http="http://127.0.0.1:5000"
```
- JS-RCI replicates and fuzzes the original traffic ```http GET /properties/1 HTTP/1.1``` to identify the marshalling points, restore the initial state, and perform the Client Insourcing refactoring:
  - 1) Capture the server's initial state (performed by default)
  - 2) Fuzz HTTP traffic: ```http GET /properties/90001 HTTP/1.1```
  - 3) Restore the server's initial state: ```http GET /properties/JSRCIRestore HTTP/1.1```
  - 4) Perform Client Insourcing ```GET /properties/JSRCIInsourcing HTTP/1.1```
- After replaying the HTTP traffic, JS-RCI automatcally generates and executes a contraints solving script [results/example1/result_datalog.py](results/example1/result_datalog.py) for executing the ```Marshal```, ```unMarshal```, and ```ExecutedStmts``` rules. Finally, JS-RCI generates a semantically equivalent centralized variant (in multiple JavaScript files), automatically extracted from the server.

- You can skip steps 1 and 2 by running only the contraint solving python script.
```bash
python2.7 results/result_datalog.py
```

