<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? '';
$deviceId = $input['device_id'] ?? '';

$dataFile = __DIR__ . '/activated_devices.json';
$SECRET_KEY = 'mirror_scorpion_2026_secret';

switch ($action) {
    case 'activate':
        if (empty($deviceId)) {
            echo json_encode(['success' => false, 'error' => 'device_id مطلوب']);
            exit;
        }

        $devices = [];
        if (file_exists($dataFile)) {
            $devices = json_decode(file_get_contents($dataFile), true) ?? [];
        }

        if (isset($devices[$deviceId])) {
            echo json_encode([
                'success' => true,
                'message' => 'الجهاز مفعل مسبقًا',
                'expiry' => $devices[$deviceId]['expiry']
            ]);
            exit;
        }

        $expiry = date('Y/m/d', strtotime('+365 days'));
        $devices[$deviceId] = [
            'activated_at' => date('Y-m-d H:i:s'),
            'expiry' => $expiry,
            'device_name' => $input['device_name'] ?? 'unknown'
        ];

        file_put_contents($dataFile, json_encode($devices, JSON_PRETTY_PRINT));

        echo json_encode([
            'success' => true,
            'message' => 'تم تفعيل الجهاز بنجاح',
            'expiry' => $expiry
        ]);
        break;

    case 'check':
        if (empty($deviceId)) {
            echo json_encode(['valid' => false, 'error' => 'device_id مطلوب']);
            exit;
        }

        $devices = [];
        if (file_exists($dataFile)) {
            $devices = json_decode(file_get_contents($dataFile), true) ?? [];
        }

        if (isset($devices[$deviceId])) {
            echo json_encode([
                'valid' => true,
                'expiry' => $devices[$deviceId]['expiry']
            ]);
        } else {
            echo json_encode(['valid' => false]);
        }
        break;

    case 'list':
        if (($input['key'] ?? '') !== $SECRET_KEY) {
            echo json_encode(['error' => 'Unauthorized']);
            exit;
        }
        $devices = [];
        if (file_exists($dataFile)) {
            $devices = json_decode(file_get_contents($dataFile), true) ?? [];
        }
        echo json_encode(['devices' => $devices, 'count' => count($devices)]);
        break;

    default:
        echo json_encode(['success' => false, 'error' => 'action غير معروف']);
}
