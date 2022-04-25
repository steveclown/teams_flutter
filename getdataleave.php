<?php
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $result = array();
    $employee_id = $_POST['employee_id'];

    $queryResult = $con->query("SELECT *
    FROM hro_employee_leave 
    WHERE employee_id='$employee_id' and data_state=0 ORDER BY employee_leave_id DESC");

    while ($fetchData = $queryResult->fetch_assoc()) {
        $result[] = $fetchData;
    }

    echo json_encode($result);
}
