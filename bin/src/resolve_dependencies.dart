/*
 * MIT License
 *
 * Copyright (c) 2020 Alexei Sintotski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import 'dart:io';

import 'package:borg/src/configuration/configuration.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'utils/borg_exception.dart';
import 'utils/run_system_command.dart';

// ignore_for_file: avoid_print

void resolveDependencies({
  @required BorgConfiguration configuration,
  @required Directory location,
  String arguments = '',
}) {
  final command = configuration.flutterSdkPath.iif(
    some: (e) => '${path.joinAll([e, 'bin', 'flutter'])} packages get $arguments',
    none: () => '${_pub(configuration)} get $arguments',
  );

  final result = runSystemCommand(
    command: command,
    workingDirectory: location,
    environment: _pubEnvironment(configuration),
  );
  if (result.exitCode != 0) {
    stdout.write('\n');
    print(result.stdout);
    print(result.stderr);
  }
  if (result.exitCode != 0) {
    throw const BorgException('FAILURE: pub get failed');
  }
}

String _pub(BorgConfiguration config) => config.dartSdkPath.iif(
      some: (location) => path.joinAll([location, 'bin', 'pub']),
      none: () => 'pub',
    );

Map<String, String> _pubEnvironment(BorgConfiguration config) => config.flutterSdkPath.iif(
      some: (location) => {'FLUTTER_ROOT': location},
      none: () => {},
    );