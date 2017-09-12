worker_processes auto;

events {
    worker_connections  1024;
}

{{ $ports := split $.Env.SERVICES_LB "," }}
{{ $hosts := split $.Env.SERVICES_HOSTS "," }}

{{ range $port := $ports }}
# Load balance UDP-based DNS traffic across two servers
stream {
    upstream udp_{{$port}} {
      {{ range $host := $hosts }} 
       server {{ $host }}:{{ $port }};
      {{ end }}
    }

    server {
        listen {{$port}} udp;
        proxy_pass udp_{{$port}};
        proxy_timeout 1s;
        proxy_responses 1;
        error_log dns.log;
    }
}
{{ end }}
