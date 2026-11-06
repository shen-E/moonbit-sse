///|
/// Variable-Byte integer compression for encrypted posting lists
pub fn compress_vbyte(values : Array[Int32]) -> Bytes {
  let buf : Array[Byte] = []
  for i in 0..<values.length() {
    let mut v = values[i]
    while v >= 128 {
      buf.push(((v & 0x7F) | 0x80).to_byte())
      v = v >> 7
    }
    buf.push((v & 0x7F).to_byte())
  }

  let out : FixedArray[Byte] = FixedArray::make(buf.length(), b'\x00')
  for i in 0..<buf.length() {
    out[i] = buf[i]
  }
  Bytes::from_array(out)
}

///|
/// Variable-Byte integer decompression
pub fn decompress_vbyte(data : Bytes) -> Array[Int32] {
  let values : Array[Int32] = []
  let mut cur_val = 0
  let mut shift = 0

  for i in 0..<data.length() {
    let b = data[i].to_int()
    cur_val = cur_val | ((b & 0x7F) << shift)
    if (b & 0x80) == 0 {
      values.push(cur_val)
      cur_val = 0
      shift = 0
    } else {
      shift = shift + 7
    }
  }

  values
}

///|
/// Delta-encoding for sorted posting lists
pub fn delta_encode(sorted_ids : Array[Int32]) -> Array[Int32] {
  let deltas : Array[Int32] = []
  let mut prev = 0
  for i in 0..<sorted_ids.length() {
    let cur = sorted_ids[i]
    deltas.push(cur - prev)
    prev = cur
  }
  deltas
}

///|
/// Delta-decoding
pub fn delta_decode(deltas : Array[Int32]) -> Array[Int32] {
  let ids : Array[Int32] = []
  let mut accum = 0
  for i in 0..<deltas.length() {
    accum = accum + deltas[i]
    ids.push(accum)
  }
  ids
}
