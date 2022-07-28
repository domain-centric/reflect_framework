import 'dart:convert';
import 'dart:io';

main() async {
  await runInShell(
      'dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
}

runInShell(String executable, List<String> arguments,
    {String? workingDirectory,
    Map<String, String>? environment,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding}) async {
  var result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    environment: environment,
    stdoutEncoding: stdoutEncoding,
    stderrEncoding: stderrEncoding,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
