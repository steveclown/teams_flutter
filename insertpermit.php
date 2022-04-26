<?php
require "connect.php";
if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();


    $image = $_FILES['image']['name']; //[variable][prperty]
    $image_name = substr($image, 0, 18);
    $image_exstension = pathinfo($image, PATHINFO_EXTENSION);
    $employee_id = $_POST['employee_id'];
    $permit_id = $_POST['permit_id'];
    $employee_attendance_data_id = $_POST['employee_attendance_data_id'];
    $employee_permit_date = $_POST['employee_permit_date'];
    $employee_permit_start_date = $_POST['employee_permit_start_date'];
    $employee_permit_end_date = $_POST['employee_permit_end_date'];
    $employee_permit_description = $_POST['employee_permit_description'];
    $employee_permit_duration = $_POST['employee_permit_duration'];
    $employee_permit_whole_days = $_POST['employee_permit_whole_days'];
    $permit_type = $_POST['permit_type'];
    $deduction_type = $_POST['deduction_type'];
    $employee_attendance_date_status = $_POST['employee_attendance_date_status'];

    $imagePath = 'assets/images/permit/' . $image_name . '.' . $image_exstension;
    $tmp_name = $_FILES['image']['tmp_name'];

    move_uploaded_file($tmp_name, $imagePath);

    $insert = "INSERT INTO hro_employee_permit (employee_id, permit_id, employee_attendance_data_id, employee_permit_date, employee_permit_start_date, employee_permit_end_date, employee_permit_description, employee_permit_duration, employee_permit_whole_days, permit_type, deduction_type, employee_attendance_date_status, employee_permit_image)
    VALUES(
        '$employee_id', '$permit_id', '$employee_attendance_data_id', '$employee_permit_date', '$employee_permit_start_date', '$employee_permit_end_date', '$employee_permit_description', '$employee_permit_duration', '$employee_permit_whole_days', '$permit_type', '$deduction_type', '$employee_attendance_date_status', '$image_name.$image_exstension');";

    $updatescheduleitem = "UPDATE schedule_employee_schedule_item
    SET employee_schedule_item_status = '3'
    WHERE employee_id='$employee_id' and employee_schedule_item_date BETWEEN '$employee_permit_start_date' AND '$employee_permit_end_date'";

    mysqli_query($con, $updatescheduleitem);


    $updatescheduleshift = "UPDATE schedule_employee_schedule_shift
    SET employee_schedule_shift_status = '3'
    WHERE employee_id='$employee_id' and employee_schedule_shift_date BETWEEN '$employee_permit_start_date' AND '$employee_permit_end_date'";

    mysqli_query($con, $updatescheduleshift);

    if (mysqli_query($con, $insert)) {
        $response['values'] = 1;
        $response['message'] = "Berhasil didaftarkan";
        echo json_encode($response);
    } else {
        $response['values'] = 0;
        $response['message'] = "Gagal didaftarkan";
        echo json_encode($response);
    }
}
