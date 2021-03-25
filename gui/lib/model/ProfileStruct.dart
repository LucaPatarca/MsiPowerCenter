import 'dart:ffi';

import 'package:ffi/ffi.dart';

class ProfileStruct extends Struct {
  Pointer<Utf8> name;
  Pointer<Int8> cpuTemps;
  Pointer<Int8> gpuTemps;
  Pointer<Int8> cpuSpeeds;
  Pointer<Int8> gpuSpeeds;
  @Int32()
  int coolerBoostEnabled;
  @Int32()
  int cpuMaxFreq;
  @Int32()
  int cpuMinFreq;
  Pointer<Utf8> cpuGovernor;
  Pointer<Utf8> cpuEnergyPref;
  @Int32()
  int cpuMaxPerf;
  @Int32()
  int cpuMinPerf;
  @Int32()
  int cpuTurboEnabled;
}
