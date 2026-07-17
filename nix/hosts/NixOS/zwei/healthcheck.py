import http.server, json, urllib.request, sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.error import HTTPError

SERVICES = [
    ("audiobookshelf", "http://zwei.fglab/audiobookshelf", "https://audiobookshelf.mediacentrehub.com"),
    ("jellyfin",       "http://zwei.fglab/jellyfin",       None),
    ("immich",         "http://immich.zwei.fglab",         "https://immich.mediacentrehub.com"),
    ("kavita",         "http://zwei.fglab:8082",         "https://kavita.mediacentrehub.com"),
    ("grafana",        "http://zwei.fglab/grafana",        None),
    ("pocket-id",      "http://zwei.fglab:1411",           "https://id.mediacentrehub.com"),
    ("sonarr",         "http://zwei.fglab/sonarr",         None),
    ("radarr",         "http://zwei.fglab/radarr",         None),
    ("lidarr",         "http://zwei.fglab/lidarr",         None),
    ("readarr",        "http://zwei.fglab/readarr",        None),
    ("prowlarr",       "http://zwei.fglab/prowlarr",       None),
    ("plex",           "http://zwei.fglab/plex",           "https://mediacentrehub.com:15860"),
    ("transmission",   "http://zwei.fglab/transmission",   None),
]

def check(url, timeout=3):
    if url is None:
        return None
    try:
        urllib.request.urlopen(url, timeout=timeout)
        return True
    except HTTPError as e:
        return e.code < 500
    except Exception:
        return False

def check_service(lan_url, wan_url):
    lan = check(lan_url)
    wan = check(wan_url) if wan_url else None
    return lan, wan

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/x-ndjson")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()

        with ThreadPoolExecutor(max_workers=8) as ex:
            futs = {ex.submit(check_service, lan, wan): name for name, lan, wan in SERVICES}
            for fut in as_completed(futs):
                name = futs[fut]
                lan, wan = fut.result()
                o = {"name": name, "lan": lan}
                if wan is not None:
                    o["wan"] = wan
                self.wfile.write((json.dumps(o) + "\n").encode())
                self.wfile.flush()
    def log_message(self, *a): pass

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8083
    http.server.HTTPServer(("127.0.0.1", port), Handler).serve_forever()
