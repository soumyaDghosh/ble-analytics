import 'package:ble_mall/ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Eddystone-UID frame: [0x00 type, tx, namespace(10), instance(6)]
List<int> _frame(List<int> ns, List<int> instance, {int tx = 0xC5}) =>
    [0x00, tx, ...ns, ...instance];

const _ourNs = [0x42, 0x4c, 0x45, 0x4d, 0x41, 0x4c, 0x4c, 0x30, 0x30, 0x31]; // "BLEMALL001"

void main() {
  test('parses adv_id from our namespace', () {
    final sd = {
      Guid('FEAA'): _frame(_ourNs, [0x00, 0x00, 0x00, 0x00, 0x00, 0x02]),
    };
    expect(parseEddystone(sd), '000000000002');
  });

  test('ignores a foreign namespace', () {
    final other = List<int>.filled(10, 0xFF);
    final sd = {
      Guid('FEAA'): _frame(other, [0x00, 0x00, 0x00, 0x00, 0x00, 0x02]),
    };
    expect(parseEddystone(sd), isNull);
  });

  test('ignores non-Eddystone service data', () {
    expect(parseEddystone({Guid('180D'): [1, 2, 3]}), isNull);
  });
}
