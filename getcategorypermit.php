<?php
require "connect.php";

$person = $con->query("SELECT * from core_permit");
$listpermit = array();

while ($rowdata = $person->fetch_assoc()) {
    $listpermit[] = $rowdata;
}

echo json_encode($listpermit);
