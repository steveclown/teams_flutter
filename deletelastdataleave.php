<?php

require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $employee_id = $_POST['employee_id'];
    $employee_leave_id = $_POST['employee_leave_id'];

    $del = "UPDATE hro_employee_leave
    SET data_state = 1
    WHERE employee_id='$employee_id' AND employee_leave_id='$employee_leave_id'";

    $result = mysqli_query($con, $del);

    if (isset($result)) {
        $response['valdel'] = 1;
        $response['message'] = 'Berhasil dihapus';
        echo json_encode($response);
    } else {
        $response['valdel'] = 0;
        $response['message'] = "Gagal dihapus";
        echo json_encode($response);
    }
}
