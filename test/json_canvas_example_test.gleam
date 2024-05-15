import gleam/dynamic as dyn
import gleam/json
import gleeunit
import gleeunit/should

import json_canvas_example/canvas.{Canvas, decode_canvas}

pub fn main() {
  gleeunit.main()
}

pub fn canvas_missing_fields_test() {
  "{}"
  |> json.decode(decode_canvas)
  |> should.equal(
    Error(
      json.UnexpectedFormat([
        dyn.DecodeError("field", "nothing", ["nodes"]),
        dyn.DecodeError("field", "nothing", ["edges"]),
      ]),
    ),
  )
}

pub fn canvas_test() {
  "{ \"nodes\": [], \"edges\": [] }"
  |> json.decode(decode_canvas)
  |> should.equal(Ok(Canvas(nodes: [], edges: [])))
}

pub fn canvas_invalid_node_test() {
  "{
    \"nodes\": [
      {
        \"id\": \"264a4af1cbdf8391\"
      }
    ],
    \"edges\": []
  }"
  |> json.decode(decode_canvas)
  |> should.equal(
    Error(
      json.UnexpectedFormat([
        dyn.DecodeError("field", "nothing", ["nodes", "*", "type"]),
        dyn.DecodeError("field", "nothing", ["nodes", "*", "x"]),
        dyn.DecodeError("field", "nothing", ["nodes", "*", "y"]),
        dyn.DecodeError("field", "nothing", ["nodes", "*", "width"]),
        dyn.DecodeError("field", "nothing", ["nodes", "*", "height"]),
      ]),
    ),
  )
}

pub fn canvas_invalid_node_type_test() {
  "{
    \"nodes\": [
      {
        \"id\": \"264a4af1cbdf8391\",
        \"type\": \"foo\",
        \"x\": -125,
        \"y\": -30,
        \"width\": 185,
        \"height\": 60
      }
    ],
    \"edges\": []
  }"
  |> json.decode(decode_canvas)
  |> should.equal(
    Error(
      json.UnexpectedFormat([
        dyn.DecodeError("text, file, link or group", "foo", [
          "nodes", "*", "type",
        ]),
      ]),
    ),
  )
}
