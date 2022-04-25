<?php
require "connect.php";
if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();


    $image = $_FILES['image']['name']; //[variable][prperty]
    $image_name = substr($image, 0, 18);
    $image_exstension = pathinfo($image, PATHINFO_EXTENSION);

    $employee_id = $_POST['employee_id'];
    $username = $_POST['username'];
    $password = md5($_POST['password']);

    $imagePath = 'assets/images/profile/' . $image_name . '.' . $image_exstension;
    $tmp_name = $_FILES['image']['tmp_name'];

    move_uploaded_file($tmp_name, $imagePath);

    $update = "UPDATE system_user
    SET username = '$username', password = '$password', avatar = '$image_name.$image_exstension'
    WHERE employee_id='$employee_id'";


    if (mysqli_query($con, $update)) {
        $response['values'] = 1;
        $response['message'] = "Edit Profile Berhasil";
        echo json_encode($response);
    } else {
        $response['values'] = 0;
        $response['message'] = "Edit Profile Gagal";
        echo json_encode($response);
    }
}
