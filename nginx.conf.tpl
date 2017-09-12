worker_processes auto;

events {
    worker_connections  1024;
}

{{ $bind := $.Env.SERVICE_BIND }}
{{ $port := $.Env.SERVICE_PORT }}
{{ $hosts := split $.Env.SERVICES_HOSTS "," }}

# Load balance UDP-based DNS traffic across two servers
stream {
    upstream udp_{{$port}} {
      {{ range $host := $hosts }} 
       server {{ $host }}:{{ $port }};
      {{ end }}
    }

    server {
        listen {{$bind}} udp;
        proxy_pass udp_{{$port}};
        proxy_timeout 1s;
        proxy_responses 1;
        error_log dns.log;
    }
}
