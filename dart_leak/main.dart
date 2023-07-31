import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

typedef my_c_func = ffi.Void Function();
typedef MyCFunc = void Function();

void createLeak1() {
  // #1. Leak directly from Dart
  "some string".toNativeUtf8();
}

void createLeak2() {
  // #2. Leak from C

  String libPath = "mylib.so";
  final ffi.DynamicLibrary _library = ffi.DynamicLibrary.open(libPath);
  final myCFuncAddress =
      _library.lookup<ffi.NativeFunction<my_c_func>>('createCLeak');

  final MyCFunc func = myCFuncAddress.asFunction();
  func();
}

void createLeaks() {
  createLeak1();
  createLeak2();
}

void main(List<String> args) {
  createLeaks();

  /// Ending with an exception is required otherwise it appears that the AOT
  /// gets unmapped before LSAN can print the results.
  throw Null;
}
