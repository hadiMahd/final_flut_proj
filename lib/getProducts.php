<?php
header('Content-Type: application/json');

// CORS (Important! Use .htaccess if possible, see below)
header('Access-Control-Allow-Origin: *'); // Allow from any origin (DEV ONLY! In production, use a specific origin)
header('Access-Control-Allow-Methods: GET, POST, OPTIONS'); // Allow these methods
header('Access-Control-Allow-Headers: Content-Type'); // Allow this header

$server = 'localhost';
$user = 'root';
$pass = '';
$db = 'flut_proj';

$conn = mysqli_connect($server, $user, $pass, $db);

if (!$conn) {
    // Handle connection error properly
    http_response_code(500); // Internal Server Error
    echo json_encode(['error' => 'Database connection failed: ' . mysqli_connect_error()]);
    exit; // Stop execution
}

$sql = "SELECT * FROM products";
$result = mysqli_query($conn, $sql);

if (!$result) {
    // Handle query error
    http_response_code(500);
    echo json_encode(['error' => 'Query failed: ' . mysqli_error($conn)]);
    mysqli_close($conn);
    exit;
}

$data = array(); // Initialize the array to avoid warnings if no data is found
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

mysqli_close($conn); // Close the connection

echo json_encode($data);

?>