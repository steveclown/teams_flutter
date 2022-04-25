<?php
require "connect.php";
if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();


    $image = $_FILES['image']['name']; //[variable][prperty]
    $image_name = substr($image, 0, 18);
    $region_id = $_POST['region_id'];
    $branch_id = $_POST['branch_id'];
    $division_id = $_POST['division_id'];
    $department_id = $_POST['department_id'];
    $section_id = $_POST['section_id'];
    $unit_id = $_POST['unit_id'];
    $location_id = $_POST['location_id'];
    $shift_id = $_POST['shift_id'];
    $employee_shift_id = $_POST['employee_shift_id'];
    $employee_id = $_POST['employee_id'];
    $employee_rfid_code = $_POST['employee_rfid_code'];
    $periode = $_POST['periode'];
    $days = $_POST['days'];
    $employee_attendance_in_status = $_POST['employee_attendance_in_status'];
    $employee_attendance_out_status = $_POST['employee_attendance_out_status'];
    $employee_attendance_date = $_POST['employee_attendance_date'];
    $employee_attendance_log_date = $_POST['employee_attendance_log_date'];
    $employee_attendance_log_in_date = $_POST['employee_attendance_log_in_date'];
    $employee_attendance_log_out_date = $_POST['employee_attendance_log_out_date'];
    $machine_ip_address = $_POST['machine_ip_address'];
    $employee_attendance_location_in = $_POST['employee_attendance_location_in'];
    $employee_attendance_location_out = $_POST['employee_attendance_location_out'];
    $employee_attendance_location_address = $_POST['employee_attendance_location_address'];

    $imagePath = 'assets/images/attendance/' . $image_name . '.jpg';
    $tmp_name = $_FILES['image']['tmp_name'];

    move_uploaded_file($tmp_name, $imagePath);

    $insert = "INSERT INTO hro_employee_attendance (region_id,
    branch_id, 
    division_id, 
    department_id, 
    section_id,
    unit_id, 
    location_id,
    shift_id, 
    employee_shift_id, 
    employee_id,
    employee_rfid_code,
    employee_attendance_in_status, 
    employee_attendance_out_status, 
    employee_attendance_date, 
    employee_attendance_log_date, 
    employee_attendance_log_in_date, 
    employee_attendance_log_out_date, 
    machine_ip_address, 
    employee_attendance_location_in, 
    employee_attendance_location_out,
    employee_attendance_location_address,
    employee_attendance_images)
    VALUES (
    '$region_id',
    '$branch_id', 
    '$division_id', 
    '$department_id', 
    '$section_id', 
    '$unit_id', 
    '$location_id', 
    '$shift_id', 
    '$employee_shift_id', 
    '$employee_id',
    '$employee_rfid_code',
    '$employee_attendance_in_status', 
    '$employee_attendance_out_status', 
    '$employee_attendance_date', 
    '$employee_attendance_log_date', 
    '$employee_attendance_log_in_date', 
    '$employee_attendance_log_out_date', 
    '$machine_ip_address',
    '$employee_attendance_location_in',
    '$employee_attendance_location_out',
    '$employee_attendance_location_address',
    '$image_name.jpg')";

    $updatescheduleitem = "UPDATE schedule_employee_schedule_item
    SET employee_schedule_item_status = '1', employee_schedule_item_log_in_date = '$employee_attendance_log_in_date', employee_schedule_item_log_status = '1' 
    WHERE employee_id='$employee_id' and employee_schedule_item_date = '$employee_attendance_date'";

    mysqli_query($con, $updatescheduleitem);

    $updatescheduleshift = "UPDATE schedule_employee_schedule_shift
    SET employee_schedule_shift_status = '1'
    WHERE employee_id='$employee_id' and employee_schedule_shift_date = '$employee_attendance_date'";

    mysqli_query($con, $updatescheduleshift);

    $ceklog = "SELECT *
    FROM hro_employee_attendance_log
    WHERE hro_employee_attendance_log.employee_id = '$employee_id' AND 
    hro_employee_attendance_log.employee_attendance_log_period = '$periode'";

    $resultceklog = mysqli_num_rows(mysqli_query($con, $ceklog));

    if ($resultceklog > 0) {
        $updatelog = "UPDATE hro_employee_attendance_log
        SET day_$days = '1'
        WHERE employee_id='$employee_id' and employee_attendance_log_period = '$periode'";

        mysqli_query($con, $updatelog);

        if (mysqli_query($con, $insert)) {
            $decode['message'] = "Berhasil didaftarkan";
            echo json_encode($decode);
        } else {
            $decode['message'] = "gagal didaftarkan";
            echo json_encode($decode);
        }
    } else {
        $insertlog = "INSERT INTO hro_employee_attendance_log (region_id,
        branch_id, 
        division_id, 
        department_id, 
        section_id,
        unit_id, 
        location_id,
        shift_id, 
        employee_shift_id, 
        employee_id,
        employee_rfid_code,
        employee_attendance_log_period,
        day_$days)
        VALUES (
        '$region_id',
        '$branch_id', 
        '$division_id', 
        '$department_id', 
        '$section_id', 
        '$unit_id', 
        '$location_id', 
        '$shift_id', 
        '$employee_shift_id', 
        '$employee_id',
        '$employee_rfid_code',
        '$periode',
        '1')";

        mysqli_query($con, $insertlog);

        if (mysqli_query($con, $insert)) {
            $decode['message'] = "Berhasil didaftarkan";
            echo json_encode($decode);
        } else {
            $decode['message'] = "gagal didaftarkan";
            echo json_encode($decode);
        }
    }
}
