import subprocess, sys
sdkmanager = r"C:\Users\fuziya.candas\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"
p = subprocess.Popen([sdkmanager, "--licenses"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.PIPE)
for line in iter(p.stdout.readline, b''):
    if b'Accept?' in line or b'y/N' in line:
        p.stdin.write(b'y\n')
        p.stdin.flush()
    sys.stdout.write(line.decode('utf-8', errors='replace'))
p.stdin.close()
p.wait()
