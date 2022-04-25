<?php

require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $employee_id = $_POST['employee_id'];
    $username = $_POST['username'];
    $password = md5($_POST['password']);

    $del = "UPDATE system_user
    SET username = '$username', password = '$password'
    WHERE employee_id='$employee_id'";

    $result = mysqli_query($con, $del);

    if (isset($result)) {
        $response['valdel'] = 1;
        $response['message'] = 'Edit Profile Berhasil';
        echo json_encode($response);
    } else {
        $response['valdel'] = 0;
        $response['message'] = "Edit Profile Gagal";
        echo json_encode($response);
    }
}
