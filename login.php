<?php

require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $username = $_POST['username'];
    $password = md5($_POST['password']);

    $cek = "SELECT system_user.region_id, system_user.branch_id, system_user.location_id, system_user.division_id, system_user.department_id, 
    system_user.section_id, system_user.unit_id, system_user.employee_id, system_user.username, system_user.password, system_user.avatar, system_user.payroll_employee_level, core_department.department_code, 
    schedule_employee_schedule_item.shift_id, hro_employee_data.employee_shift_id, hro_employee_data.employee_rfid_code
    FROM system_user
    INNER JOIN core_department ON system_user.department_id=core_department.department_id
    INNER JOIN hro_employee_data ON system_user.employee_id=hro_employee_data.employee_id
    INNER JOIN schedule_employee_schedule_item ON system_user.employee_id=schedule_employee_schedule_item.employee_id
    WHERE system_user.username='$username' and system_user.password='$password' GROUP BY employee_id";

    $result = mysqli_fetch_array(mysqli_query($con, $cek));

    if (isset($result)) {
        $response['value'] = 1;
        $response['region_id'] = $result['region_id'];
        $response['branch_id'] = $result['branch_id'];
        $response['location_id'] = $result['location_id'];
        $response['division_id'] = $result['division_id'];
        $response['department_id'] = $result['department_id'];
        $response['section_id'] = $result['section_id'];
        $response['unit_id'] = $result['unit_id'];
        $response['employee_id'] = $result['employee_id'];
        $response['shift_id'] = $result['shift_id'];
        $response['employee_shift_id'] = $result['employee_shift_id'];
        $response['username'] = $result['username'];
        $response['avatar'] = $result['avatar'];
        $response['payroll_employee_level'] = $result['payroll_employee_level'];
        $response['department_code'] = $result['department_code'];
        $response['employee_rfid_code'] = $result['employee_rfid_code'];
        $response['message'] = 'Login Berhasil';
        echo json_encode($response);
    } else {
        $response['value'] = 0;
        $response['message'] = "login gagal";
        echo json_encode($response);
    }
}
