<?php
require "connect.php";

$result = array();

$queryResult = $con->query("SELECT *
    FROM preference_company");

while ($fetchData = $queryResult->fetch_assoc()) {
    $result[] = $fetchData;
}

echo json_encode($result);
