<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { echo json_encode(['success'=>false,'error'=>'Method not allowed']); exit; }

$input = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? '';
$deviceId = $input['device_id'] ?? '';
$dataFile = __DIR__ . '/devices.json';

switch ($action) {
    case 'activate':
        if (empty($deviceId)) { echo json_encode(['success'=>false,'error'=>'device_id مطلوب']); exit; }
        $devices = file_exists($dataFile) ? (json_decode(file_get_contents($dataFile), true) ?? []) : [];
        if (isset($devices[$deviceId])) {
            echo json_encode(['success'=>true,'message'=>'مفعل مسبقًا','expiry'=>$devices[$deviceId]['expiry']]);
        } else {
            $expiry = date('Y/m/d', strtotime('+365 days'));
            $devices[$deviceId] = ['activated_at'=>date('Y-m-d H:i:s'),'expiry'=>$expiry,'device_name'=>$input['device_name']??'unknown'];
            file_put_contents($dataFile, json_encode($devices, JSON_PRETTY_PRINT));
            echo json_encode(['success'=>true,'message'=>'تم التفعيل بنجاح','expiry'=>$expiry]);
        }
        break;
    case 'check':
        if (empty($deviceId)) { echo json_encode(['valid'=>false,'error'=>'device_id مطلوب']); exit; }
        $devices = file_exists($dataFile) ? (json_decode(file_get_contents($dataFile), true) ?? []) : [];
        echo json_encode(['valid'=>isset($devices[$deviceId]),'expiry'=>$devices[$deviceId]['expiry']??'']);
        break;
    default:
        echo json_encode(['success'=>false,'error'=>'action غير معروف']);
}
