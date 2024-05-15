import gleam/dynamic.{type Dynamic} as dyn
import gleam/option.{type Option}
import gleam/result

import json_canvas_example/generic_node.{
  type Color, type NodeId, FileNodeType, GroupNodeType, LinkNodeType,
  TextNodeType, decode_node_attrs,
}

pub type FilePath {
  FilePath(String)
}

pub type SubPath {
  SubPath(String)
}

pub type Url {
  Url(String)
}

pub type GroupLabel {
  GroupLabel(String)
}

pub type GroupBackground {
  GroupBackground(String)
}

pub type GroupBackgroundStyle {
  Cover
  Ratio
  Repeat
}

fn decode_group_background_style(
  dyn: Dynamic,
) -> Result(GroupBackgroundStyle, List(dyn.DecodeError)) {
  use style <- result.try(dyn.string(dyn))
  case style {
    "cover" -> Ok(Cover)
    "ratio" -> Ok(Ratio)
    "repeat" -> Ok(Repeat)
    _ -> Error([dyn.DecodeError("cover, ratio or repeat", style, [])])
  }
}

pub type Node {
  TextNode(
    id: NodeId,
    x: Int,
    y: Int,
    width: Int,
    height: Int,
    color: Option(Color),
    text: String,
  )
  FileNode(
    id: NodeId,
    x: Int,
    y: Int,
    width: Int,
    height: Int,
    color: Option(Color),
    path: FilePath,
    subpath: Option(SubPath),
  )
  LinkNode(
    id: NodeId,
    x: Int,
    y: Int,
    width: Int,
    height: Int,
    color: Option(Color),
    url: Url,
  )
  GroupNode(
    id: NodeId,
    x: Int,
    y: Int,
    width: Int,
    height: Int,
    color: Option(Color),
    label: Option(GroupLabel),
    background: Option(GroupBackground),
    background_style: Option(GroupBackgroundStyle),
  )
}

pub fn decode_node(dyn: Dynamic) -> Result(Node, List(dyn.DecodeError)) {
  use attrs <- result.try(decode_node_attrs(dyn))

  case attrs.ty {
    TextNodeType -> {
      use text <- result.try(dyn.field("text", dyn.string)(dyn))
      Ok(TextNode(
        attrs.id,
        attrs.x,
        attrs.y,
        attrs.width,
        attrs.height,
        attrs.color,
        text,
      ))
    }
    FileNodeType -> {
      use #(path, subpath) <- result.try(
        dyn
        |> dyn.decode2(
          fn(path, subpath) { #(path, subpath) },
          dyn.field("path", dyn.string),
          dyn.optional_field("subpath", dyn.string),
        ),
      )
      Ok(FileNode(
        attrs.id,
        attrs.x,
        attrs.y,
        attrs.width,
        attrs.height,
        attrs.color,
        FilePath(path),
        option.map(over: subpath, with: SubPath),
      ))
    }
    LinkNodeType -> {
      use url <- result.try(dyn.field("url", dyn.string)(dyn))
      Ok(LinkNode(
        attrs.id,
        attrs.x,
        attrs.y,
        attrs.width,
        attrs.height,
        attrs.color,
        Url(url),
      ))
    }
    GroupNodeType -> {
      use #(label, background, background_style) <- result.try(
        dyn
        |> dyn.decode3(
          fn(label, background, background_style) {
            #(label, background, background_style)
          },
          dyn.optional_field("label", dyn.string),
          dyn.optional_field("background", dyn.string),
          dyn.optional_field("background_style", decode_group_background_style),
        ),
      )
      Ok(GroupNode(
        attrs.id,
        attrs.x,
        attrs.y,
        attrs.width,
        attrs.height,
        attrs.color,
        option.map(over: label, with: GroupLabel),
        option.map(over: background, with: GroupBackground),
        background_style,
      ))
    }
  }
}
