<?php
require "connect.php";
if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $region_id = $_POST['region_id'];
    $branch_id = $_POST['branch_id'];
    $division_id = $_POST['division_id'];
    $department_id = $_POST['department_id'];
    $section_id = $_POST['section_id'];
    $location_id = $_POST['location_id'];
    $employee_id = $_POST['employee_id'];
    $annual_leave_id = $_POST['annual_leave_id'];
    $employee_leave_start_date = $_POST['employee_leave_start_date'];
    $employee_leave_due_date = $_POST['employee_leave_due_date'];
    $employee_leave_description = $_POST['employee_leave_description'];
    $periode = $_POST['periode'];
    $days = $_POST['days'];

    $insert = "INSERT INTO hro_employee_leave (region_id, branch_id, location_id, division_id, department_id, section_id, employee_id, annual_leave_id, employee_leave_start_date, employee_leave_due_date, employee_leave_description, created_id, created_on)
    VALUES('$region_id', '$branch_id', '$location_id', '$division_id', '$department_id', '$section_id', '$employee_id', '$annual_leave_id', '$employee_leave_start_date', '$employee_leave_due_date', '$employee_leave_description', '$employee_id', now());";

    $updatescheduleitem = "UPDATE schedule_employee_schedule_item
    SET employee_schedule_item_status = '4'
    WHERE employee_id='$employee_id' and employee_schedule_item_date BETWEEN '$employee_leave_start_date' AND '$employee_leave_due_date'";

    mysqli_query($con, $updatescheduleitem);

    $updatescheduleshift = "UPDATE schedule_employee_schedule_shift
    SET employee_schedule_shift_status = '4'
    WHERE employee_id='$employee_id' and employee_schedule_shift_date BETWEEN '$employee_leave_start_date' AND '$employee_leave_due_date'";

    mysqli_query($con, $updatescheduleshift);

    $updatelog = "UPDATE hro_employee_attendance_log
    SET day_$days = '4'
    WHERE employee_id='$employee_id' and employee_attendance_log_period = '$periode'";

    mysqli_query($con, $updatelog);

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
