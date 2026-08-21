///|
/// Binary Serializer / Deserializer for encrypted data objects
pub struct BinaryBuffer {
  bytes : Array[Byte]
}

///|
/// Create new empty BinaryBuffer
pub fn BinaryBuffer::new() -> BinaryBuffer {
  { bytes: [] }
}

///|
/// Write 32-bit int to buffer
pub fn BinaryBuffer::write_int(self : BinaryBuffer, val : Int) -> Unit {
  let b = @crypto.uint32_to_be_bytes(val.reinterpret_as_uint())
  for i in 0..<4 {
    self.bytes.push(b[i])
  }
}

///|
/// Write byte sequence with length prefix
pub fn BinaryBuffer::write_bytes(self : BinaryBuffer, data : Bytes) -> Unit {
  self.write_int(data.length())
  for i in 0..<data.length() {
    self.bytes.push(data[i])
  }
}

///|
/// Write string with length prefix
pub fn BinaryBuffer::write_string(self : BinaryBuffer, s : String) -> Unit {
  let b = @crypto.string_to_bytes(s)
  self.write_bytes(b)
}

///|
/// Convert buffer to Bytes
pub fn BinaryBuffer::to_bytes(self : BinaryBuffer) -> Bytes {
  let len = self.bytes.length()
  let out : FixedArray[Byte] = FixedArray::make(len, b'\x00')
  for i in 0..<len {
    out[i] = self.bytes[i]
  }
  Bytes::from_array(out)
}
