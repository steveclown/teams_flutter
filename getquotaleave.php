<?php
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $employee_id = $_POST['employee_id'];
    $person = $con->query("SELECT * from hro_employee_leave_quota WHERE employee_id='$employee_id'");
    $list = array();

    while ($rowdata = $person->fetch_assoc()) {
        $list[] = $rowdata;
    }

    echo json_encode($list);
}
