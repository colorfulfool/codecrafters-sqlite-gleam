import argv
import file_streams/read_stream
import gleam/int.{to_string}
import gleam/io

pub fn main() {
  case argv.load().arguments {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(rs) = read_stream.open(database_file_path)
      let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 16)
      let assert Ok(page_size) = read_stream.read_int16_be(rs)

      let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 85)
      let assert Ok(page_cells) = read_stream.read_int16_be(rs)

      io.print("database page size: ")
      io.println(page_size |> to_string)

      io.print("number of tables: ")
      io.println(page_cells |> to_string)
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
