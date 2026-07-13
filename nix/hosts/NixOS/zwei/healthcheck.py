import http.server, json, urllib.request, sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.error import HTTPError

SERVICES = [
    ("audiobookshelf", "http://zwei.fglab/audiobookshelf", "https://audiobookshelf.mediacentrehub.com"),
    ("jellyfin",       "http://zwei.fglab/jellyfin",       None),
    ("immich",         "http://immich.zwei.fglab",         "https://immich.mediacentrehub.com"),
    ("kavita",         "http://zwei.fglab/kavita",         "https://kavita.mediacentrehub.com/api/opds"),
    ("grafana",        "http://zwei.fglab/grafana",        None),
    ("pocket-id",      "http://zwei.fglab:1411",           None),
    ("sonarr",         "http://zwei.fglab/sonarr",         None),
    ("radarr",         "http://zwei.fglab/radarr",         None),
    ("lidarr",         "http://zwei.fglab/lidarr",         None),
    ("readarr",        "http://zwei.fglab/readarr",        None),
    ("prowlarr",       "http://zwei.fglab/prowlarr",       None),
    ("plex",           "http://zwei.fglab/plex",           None),
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

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        results = {}
        with ThreadPoolExecutor(max_workers=8) as ex:
            futs = {}
            for name, lan, wan in SERVICES:
                futs[ex.submit(check, lan)] = (name, "lan")
                if wan:
                    futs[ex.submit(check, wan)] = (name, "wan")
            for fut in as_completed(futs):
                name, kind = futs[fut]
                results.setdefault(name, {})[kind] = fut.result()
        body = json.dumps({"services": results}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, *a): pass

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8083
    http.server.HTTPServer(("127.0.0.1", port), Handler).serve_forever()

