#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json, os
from datetime import datetime, timedelta

DATA_FILE = os.path.join(os.path.dirname(__file__), "devices.json")
PORT = 8080

class Handler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin','*')
        self.send_header('Access-Control-Allow-Methods','POST,OPTIONS')
        self.send_header('Access-Control-Allow-Headers','Content-Type')
        self.end_headers()
    def do_POST(self):
        self.send_header('Access-Control-Allow-Origin','*')
        self.send_header('Content-Type','application/json')
        body = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        d = json.load(open(DATA_FILE)) if os.path.exists(DATA_FILE) else {}
        if body['action'] == 'activate':
            e = (datetime.now()+timedelta(days=365)).strftime('%Y/%m/%d')
            d[body['device_id']] = {'activated_at':datetime.now().strftime('%Y-%m-%d %H:%M:%S'),'expiry':e}
            json.dump(d, open(DATA_FILE,'w'), indent=2)
            self._respond(200,{'success':True,'message':'✅ تم التفعيل','expiry':e})
        elif body['action'] == 'check':
            self._respond(200,{'valid':body['device_id'] in d,'expiry':d.get(body['device_id'],{}).get('expiry','')})
        else:
            self._respond(400,{'error':'action غير معروف'})
    def _respond(self,s,d):
        self.send_response(s); self.end_headers(); self.wfile.write(json.dumps(d).encode())
    def log_message(self,f,*a): print(f"[{datetime.now().strftime('%H:%M:%S')}] {a[0]} {a[1]} {a[2]}")

HTTPServer(('0.0.0.0', PORT), Handler).serve_forever()
