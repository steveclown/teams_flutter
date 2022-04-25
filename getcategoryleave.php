<?php
require "connect.php";

$person = $con->query("SELECT * from core_annual_leave");
$list = array();

while ($rowdata = $person->fetch_assoc()) {
    $list[] = $rowdata;
}

echo json_encode($list);
