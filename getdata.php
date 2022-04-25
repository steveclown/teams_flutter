<?php
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $result = array();
    $employee_id = $_POST['employee_id'];

    $queryResult = $con->query("SELECT *
    FROM hro_employee_attendance 
    WHERE employee_id='$employee_id'
    GROUP BY employee_attendance_date 
    ORDER BY employee_attendance_date DESC");

    while ($fetchData = $queryResult->fetch_assoc()) {
        $result[] = $fetchData;
    }

    echo json_encode($result);
}
