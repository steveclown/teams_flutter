<?php
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $employee_id = $_POST['employee_id'];
    $employee_attendance_date = $_POST['employee_attendance_date'];

    $cek = "SELECT COUNT(employee_attendance_id) from hro_employee_attendance WHERE employee_id='$employee_id' AND employee_attendance_date='$employee_attendance_date'";

    $result = mysqli_fetch_assoc(mysqli_query($con, $cek));

    if (isset($result)) {
        $response[] = $result;
        $response['value'] = 1;
        $response['message'] = 'Data Ada';
        echo json_encode($response);
    } else {
        $response['value'] = 0;
        $response['message'] = "Data Kosong";
        echo json_encode($response);
    }
}
