<?php
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $employee_id = $_POST['employee_id'];
    $employee_schedule_item_date = $_POST['schedule_item_date'];

    $cek = "SELECT * from schedule_employee_schedule_item WHERE employee_id='$employee_id' AND employee_schedule_item_date='$employee_schedule_item_date'";

    $result = mysqli_fetch_assoc(mysqli_query($con, $cek));

    if (isset($result)) {
        $response[] = $result;
        $response['value'] = 1;
        $response['message'] = 'Data MAX IN ATTENDANCE Ada';
        echo json_encode($response);
    } else {
        $response['value'] = 0;
        $response['message'] = "Data MAX IN ATTENDANCE Kosong";
        echo json_encode($response);
    }
}
