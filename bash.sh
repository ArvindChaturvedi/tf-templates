uptime_secs=$(cut -d. -f1 /proc/uptime)
awk -v now=$(date +%s) -v uptime="$uptime_secs" '
{
  if (match($0, /^\[\s*([0-9]+\.[0-9]+)\]/, m)) {
    boot_time = now - uptime
    timestamp = strftime("%Y-%m-%d %H:%M:%S", boot_time + m[1])
    sub(/\[\s*[0-9]+\.[0-9]+\]/, "[" timestamp "]")
  }
  print
}
' /var/log/dmesg.old
