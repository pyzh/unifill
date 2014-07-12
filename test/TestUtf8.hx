package test;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import unifill.Exception;
import unifill.Utf8;
using unifill.UtfTools;

class TestUtf8 extends haxe.unit.TestCase {

	public function test_fromString() {
		var u = Utf8.fromString("𩸽あëa");
		assertEquals("𩸽".code, u.codePointAt(0));
		assertEquals("あ".code, u.codePointAt(4));
		assertEquals("ë".code, u.codePointAt(7));
		assertEquals("a".code, u.codePointAt(9));
	}

	public function test_fromCodePoints() {
		var u = Utf8.fromCodePoints([
			"𩸽".code, "あ".code, "ë".code, "a".code]);
		assertEquals("𩸽".code, u.codePointAt(0));
		assertEquals("あ".code, u.codePointAt(4));
		assertEquals("ë".code, u.codePointAt(7));
		assertEquals("a".code, u.codePointAt(9));
	}

	public function test_toString() {
		var buf = new BytesBuffer();
		for (x in [0xf0, 0xa9, 0xb8, 0xbd, 0xe3, 0x81, 0x82, 0xc3, 0xab, 0x61]) {
			buf.addByte(x);
		}
		var u = Utf8.fromBytes(buf.getBytes());
		assertEquals("𩸽あëa", u.toString());
	}

	public function test_validate() {
		function a2b(a : Array<Int>) : Bytes {
			var buf = new BytesBuffer();
			for (x in a) {
				buf.addByte(x);
			}
			return buf.getBytes();
		}
		function isValid(s : Utf8) : Bool {
			try {
				s.validate();
			} catch (e : Exception) {
				return false;
			}
			return true;
		}
		var true_cases =
			[[0xf0, 0xa9, 0xb8, 0xbd, 0xe3, 0x81, 0x82, 0xc3, 0xab, 0x61],
			 [0xed, 0x9f, 0xbf],
			 [0xee, 0x80, 0x80],
			 [0xf4, 0x8f, 0xbf, 0xbf]];
		var false_cases =
			[[0xf0, 0xa9, 0xb8, 0xbd, 0xe3, 0x81, 0xc3, 0xab, 0x61],
			 [0xc0, 0xaf],
			 [0xed, 0xa0, 0x80],
			 [0xed, 0xbf, 0xbf],
			 [0xf4, 0x90, 0x80, 0x80]];
		for (c in true_cases) {
			var u = Utf8.fromBytes(a2b(c));
			assertTrue(isValid(u));
		}
		for (c in false_cases) {
			var u = Utf8.fromBytes(a2b(c));
			assertFalse(isValid(u));
		}
	}

	public function test_compare() {
		var s0 = Utf8.fromString("𩸽あëa");
		var s1 = Utf8.fromString("𩸽あëaa");
		var s2 = Utf8.fromString("𩸽あëb");
		var s3 = Utf8.fromString("𩸽");
		var s4 = Utf8.fromString("�");
		assertTrue(s0.compare(s0) == 0);
		assertTrue(s0.compare(s1) < 0);
		assertTrue(s1.compare(s0) > 0);
		assertTrue(s0.compare(s2) < 0);
		assertTrue(s2.compare(s0) > 0);
		assertTrue(s3.compare(s4) > 0);
	}

}
