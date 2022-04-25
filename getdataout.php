<?php
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $result = array();
    $employee_id = $_POST['employee_id'];

    $queryResult = $con->query("SELECT m1.*
    FROM hro_employee_attendance m1
    LEFT JOIN hro_employee_attendance m2 ON (m1.employee_id = m2.employee_id AND m1.employee_attendance_id < m2.employee_attendance_id)
    WHERE m2.employee_attendance_id IS NULL AND m1.employee_id = '$employee_id'");

    while ($fetchData = $queryResult->fetch_assoc()) {
        $result[] = $fetchData;
    }

    echo json_encode($result);
}
