<?php
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $employee_id = $_POST['employee_id'];

    $cek = "SELECT *
    FROM hro_employee_leave 
    WHERE employee_id='$employee_id' and data_state=0
    ORDER BY employee_leave_id DESC limit 1";

    $result = mysqli_fetch_array(mysqli_query($con, $cek));

    if (isset($result)) {
        $response[] = $result;
        echo json_encode($response);
    } else {
        echo json_encode($response);
    }
}
