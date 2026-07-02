#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
from datetime import datetime, timedelta

DATA_FILE = "activated_devices.json"
PORT = 8080

class ActivationHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Type', 'application/json')

        content_length = int(self.headers['Content-Length'])
        body = json.loads(self.rfile.read(content_length))

        action = body.get('action', '')
        device_id = body.get('device_id', '')

        devices = {}
        if os.path.exists(DATA_FILE):
            with open(DATA_FILE, 'r') as f:
                devices = json.load(f)

        if action == 'activate':
            if not device_id:
                self._respond(400, {'success': False, 'error': 'device_id مطلوب'})
                return

            if device_id in devices:
                self._respond(200, {
                    'success': True,
                    'message': 'مفعل مسبقًا',
                    'expiry': devices[device_id]['expiry']
                })
                return

            expiry = (datetime.now() + timedelta(days=365)).strftime('%Y/%m/%d')
            devices[device_id] = {
                'activated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'expiry': expiry,
                'device_name': body.get('device_name', 'unknown')
            }

            with open(DATA_FILE, 'w') as f:
                json.dump(devices, f, indent=2)

            self._respond(200, {
                'success': True,
                'message': '✅ تم التفعيل',
                'expiry': expiry
            })

        elif action == 'check':
            valid = device_id in devices
            self._respond(200, {
                'valid': valid,
                'expiry': devices[device_id]['expiry'] if valid else ''
              })

        elif action == 'list':
            self._respond(200, {
                'devices': devices,
                'count': len(devices)
            })

        else:
            self._respond(400, {'error': 'action غير معروف'})

    def _respond(self, status, data):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, format, *args):
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {args[0]} {args[1]} {args[2]}")

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', PORT), ActivationHandler)
    print(f"🚀 Server running on port {PORT}")
    server.serve_forever()
